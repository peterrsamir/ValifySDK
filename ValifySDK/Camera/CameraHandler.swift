//
//  CameraHandler.swift
//  ValifySDK
//
//  Created by Peter Samir on 30/08/2024.
//

import AVFoundation
import MLKitVision
import MLKitFaceDetection

final class CameraHandler: NSObject {
    // MARK: - Properties
    private(set) var session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "cameraSessionQueue")
    private var photoOutput = AVCapturePhotoOutput()
    private var videoOutput = AVCaptureVideoDataOutput()
    private var faceDetector: FaceDetector!
    private(set) var isFaceDetected: Bool = false

    // Callbacks
    var onError: ((Error) -> Void)?
    var onFaceDetectionError: ((Error) -> Void)?
    var onPhotoCaptured: ((UIImage) -> Void)?

    // MARK: - Initialization
    override init() {
        super.init()
        configureSession()
        configureFaceDetection()
    }
 
    // MARK: - Session Configuration
    private func configureSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            self.session.beginConfiguration()

            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
                onError?(CameraError.cameraUnavailable)
                return
            }
            // Add video input
            do {
                let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                if self.session.canAddInput(videoDeviceInput) {
                    self.session.addInput(videoDeviceInput)
                }
            } catch {
                onError?(CameraError.CouldnotAddInput)
                return
            }

            // Add photo output
            if self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)
                self.photoOutput.isHighResolutionCaptureEnabled = true
            } else {
                onError?(CameraError.CouldnotAddOutput)
                return
            }

            // Add video data output for face detection
            self.videoOutput.setSampleBufferDelegate(self, queue: self.sessionQueue)
            if self.session.canAddOutput(self.videoOutput) {
                self.session.addOutput(self.videoOutput)
                self.videoOutput.alwaysDiscardsLateVideoFrames = true
            }

            self.session.commitConfiguration()
        }
    }

    // MARK: - Face Detection Configuration
    private func configureFaceDetection() {
        let options = FaceDetectorOptions()
        options.performanceMode = .accurate
        options.landmarkMode = .all
        options.classificationMode = .all

        faceDetector = FaceDetector.faceDetector(options: options)
    }

    // MARK: - Camera Controls
    public func startSession() {
        sessionQueue.async {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }

    public func stopSession() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }

    public func capturePhoto() {
        guard isFaceDetected else {
            onFaceDetectionError?(CameraError.NoFaceDetected)
            return
        }
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}


// MARK: - AVCapturePhotoCaptureDelegate
extension CameraHandler: AVCapturePhotoCaptureDelegate {
    
    /// Flips selected uiimage to make photo appears natural
    func fixImageOrientation(image: UIImage) -> UIImage {
            UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
            let context = UIGraphicsGetCurrentContext()
            context?.translateBy(x: image.size.width, y: 0)
            context?.scaleBy(x: -1.0, y: 1.0)
            image.draw(in: CGRect(origin: .zero, size: image.size))
            let flippedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return flippedImage ?? image
        }
    
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            onError?(error)
            return
        }
        guard let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) else {
            onError?(CameraError.captureFailed)
            return
        }
        let correctedImage = fixImageOrientation(image: image)
        onPhotoCaptured?(correctedImage)
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraHandler: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard CMSampleBufferGetImageBuffer(sampleBuffer) != nil else {
            return
        }

        let visionImage = VisionImage(buffer: sampleBuffer)
        visionImage.orientation = .right

        faceDetector.process(visionImage) {[weak self] faces, error in
            guard let self = self else {return}
            if let error = error {
                self.isFaceDetected = false
                self.onFaceDetectionError?(error)
                return
            }
            guard let faces = faces, !faces.isEmpty else {
                print("No faces detected")
                self.isFaceDetected = false
                return
            }
            // Face detected
            var allLandmarksVisible = false
            for face in faces {
                // Check if both eyes, the mouth, and the nose are detected
                if face.landmark(ofType: .leftEye) != nil &&
                    face.landmark(ofType: .rightEye) != nil &&
                    face.landmark(ofType: .noseBase) != nil &&
                    face.landmark(ofType: .mouthLeft) != nil &&
                    face.landmark(ofType: .mouthBottom) != nil &&
                    face.landmark(ofType: .mouthRight) != nil {
                    print("All required facial landmarks detected!")
                    allLandmarksVisible = true
                    break /// Exit loop if one face has all required landmarks
                } else {
                    onFaceDetectionError?(CameraError.NoFaceDetected)
                }
            }
            // Update isFaceDetected status based on landmark visibility
            self.isFaceDetected = allLandmarksVisible
        }
    }
}
