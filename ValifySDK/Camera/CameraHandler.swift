//
//  CameraHandler.swift
//  ValifySDK
//
//  Created by Peter Samir on 30/08/2024.
//

import AVFoundation
import UIKit
import MLKitFaceDetection
import MLKitVision

public class CameraHandler: NSObject {
    // MARK: - Properties
    private var captureSession: AVCaptureSession?
    private var photoOutput: AVCapturePhotoOutput?
    private var videoDataOutput: AVCaptureVideoDataOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var faceDetector: FaceDetector?
    private var isFaceDetected: Bool = false

    // Callbacks
    var onError: ((Error) -> Void)?
    var onFaceDetectionError: ((Error) -> Void)?
    var onPhotoCaptured: ((UIImage) -> Void)?

    // MARK: - Camera Setup
    func setupCamera() {
        checkCameraPermissions()
    }

    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureCameraSession()
        case .notDetermined:
            requestCameraAccess()
        case .denied, .restricted:
            onError?(CameraError.unauthorizedAccess)
        @unknown default:
            onError?(CameraError.cameraUnavailable)
        }
    }

    private func requestCameraAccess(){
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            if granted {
                self?.configureCameraSession()
            } else {
                self?.onError?(CameraError.unauthorizedAccess)
            }
        }
    }
    
    private func configureCameraSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {return }
            self.captureSession = AVCaptureSession()
            guard let captureSession = captureSession else { return }
            
            captureSession.beginConfiguration()
            setupFrontCamera(captureSession: captureSession)
            setupOutputPhoto(captureSession: captureSession)
            setupVideoOutput(captureSession: captureSession)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return }
                captureSession.commitConfiguration()
                captureSession.startRunning()
            }
        }
    }

    private func setupFrontCamera(captureSession: AVCaptureSession) {
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            onError?(CameraError.cameraUnavailable)
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: frontCamera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            } else {
                onError?(CameraError.cameraUnavailable)
            }
        } catch {
            onError?(error)
        }
    }

    private func setupOutputPhoto(captureSession: AVCaptureSession) {
        photoOutput = AVCapturePhotoOutput()
        guard let photoOutput = photoOutput else {
            onError?(CameraError.captureFailed)
            return
        }
        DispatchQueue.main.async {[weak self] in
            guard let self = self else {return }
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = .resizeAspectFill
        }
        
    }

    private func setupVideoOutput(captureSession: AVCaptureSession) {
        videoDataOutput = AVCaptureVideoDataOutput()
        guard let videoDataOutput = videoDataOutput else { return }

        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
        } else {
            onError?(CameraError.cameraUnavailable)
        }
    }

    func capturePhoto() {
        guard isFaceDetected else {
            onFaceDetectionError?(CameraError.NoFaceDetected)
            return
        }
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }

    func stopSession() {
        captureSession?.stopRunning()
    }

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

    func setupFaceDetection() {
        let options = FaceDetectorOptions()
        options.performanceMode = .fast
        options.landmarkMode = .all
        options.classificationMode = .none
        faceDetector = FaceDetector.faceDetector(options: options)
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraHandler: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let visionImage = VisionImage(buffer: sampleBuffer)
        visionImage.orientation = .right // Adjust based on your camera orientation

        faceDetector?.process(visionImage) { faces, error in
            if let error = error {
                print("Face detection error: \(error.localizedDescription)")
                self.isFaceDetected = false
                self.onFaceDetectionError?(error)
                return
            }

            guard let faces = faces, !faces.isEmpty else {
                print("No faces detected")
                self.isFaceDetected = false
                return
            }
            var allLandmarksVisible = false // Track if required landmarks are visible
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
                    break // Exit loop if one face has all required landmarks
                } else {
                    print("Required landmarks not fully detected.")
                }
            }
            // Update isFaceDetected status based on landmark visibility
            self.isFaceDetected = allLandmarksVisible
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraHandler: AVCapturePhotoCaptureDelegate {
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
