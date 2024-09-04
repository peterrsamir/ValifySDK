//
//  ValifySDKProxyLaunch.swift
//  ValifySDK
//
//  Created by Peter Samir on 04/09/2024.
//

import Foundation
import UIKit

public enum FaceDetectionType {
case Vision
case MLKit
}
/// used to launch the SDK
public class ValifySDKProxyLaunch {
    
    private let permissionManager: CameraPermissionManager

    public init() {
        self.permissionManager = CameraPermissionManager()
    }
    
    /// Check if the Camera Permission enable
    /// - Returns: CameraViewController if permission enabled
    public func launchSDK(type: FaceDetectionType) -> UIViewController? {
        var vc: UIViewController?
        permissionManager.checkCameraPermissions { granted in
            if granted {
                var faceDetectionHandler: FaceDetectionProtocol
                switch type {
                case .Vision:
                    faceDetectionHandler = VisionFaceDetection()
                case .MLKit:
                    faceDetectionHandler = MLKitFaceDetection()
                }
                let cameraHandler = CameraHandler(faceDetectionHandler: faceDetectionHandler)
                let cameraViewModel = CameraViewModel(cameraHandler: cameraHandler)
                let cameraViewController = CameraViewController(viewModel: cameraViewModel)
                vc = cameraViewController
            }
        }
        return vc
    }
}
