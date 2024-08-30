//
//  CameraHandler.swift
//  ValifySDK
//
//  Created by Peter Samir on 30/08/2024.
//

import AVFoundation
import UIKit

public class CameraHandler: NSObject {
    // MARK: - Properties
    private var captureSession: AVCaptureSession?
    private var photoOutput: AVCapturePhotoOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    // Callbacks
    var onError: ((Error) -> Void)?
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
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    self?.configureCameraSession()
                } else {
                    self?.onError?(CameraError.unauthorizedAccess)
                }
            }
        case .denied, .restricted:
            onError?(CameraError.unauthorizedAccess)
        @unknown default:
            onError?(CameraError.cameraUnavailable)
        }
    }

    private func configureCameraSession() {
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }

        captureSession.beginConfiguration()

        setupFrontCamera(captureSession: captureSession)
        setupOutputPhoto(captureSession: captureSession)

        captureSession.commitConfiguration()
        captureSession.startRunning()
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

        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }

        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = .resizeAspectFill
    }

    func capturePhoto() {
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

