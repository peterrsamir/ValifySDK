//
//  CameraHandler.swift
//  ValifySDK
//
//  Created by Peter Samir on 30/08/2024.
//

import AVFoundation
import UIKit

final class CameraHandler: NSObject {
    // MARK: - Properties
    private(set) var session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "cameraSessionQueue")
    private var photoOutput = AVCapturePhotoOutput()
    private var videoOutput = AVCaptureVideoDataOutput()
    private let faceDetectionHandler: FaceDetectionProtocol
    private(set) var isFaceDetected: Bool = false

    // Callbacks
    var onError: ((Error) -> Void)?
    var onFaceDetectionError: ((Error) -> Void)?
    var onPhotoCaptured: ((UIImage) -> Void)?

    // MARK: - Initialization
    init(faceDetectionHandler: FaceDetectionProtocol) {
        self.faceDetectionHandler = faceDetectionHandler
        super.init()
        configureSession()
    }
 
    // MARK: - Session Configuration
    private func configureSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            self.session.beginConfiguration()

            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
                self.onError?(CameraError.cameraUnavailable)
                return
            }
            // Add video input
            do {
                let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                if self.session.canAddInput(videoDeviceInput) {
                    self.session.addInput(videoDeviceInput)
                }
            } catch {
                self.onError?(CameraError.CouldnotAddInput)
                return
            }

            // Add photo output
            if self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)
                self.photoOutput.isHighResolutionCaptureEnabled = true
            } else {
                self.onError?(CameraError.CouldnotAddOutput)
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
        faceDetectionHandler.detectFaces(in: sampleBuffer) { [weak self] isDetected, error in
            if let error = error {
                self?.isFaceDetected = false
                self?.onFaceDetectionError?(error)
                return
            }
            self?.isFaceDetected = isDetected
        }
    }
}
