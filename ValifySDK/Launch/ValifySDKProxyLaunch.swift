//
//  ValifySDKProxyLaunch.swift
//  ValifySDK
//
//  Created by Peter Samir on 04/09/2024.
//

import Foundation
import UIKit

/// used to launch the SDK
public class ValifySDKProxyLaunch {
    
    private let permissionManager: CameraPermissionManager

    public init() {
        self.permissionManager = CameraPermissionManager()
    }
    
    /// Check if the Camera Permission enable
    /// - Returns: CameraViewController if permission enabled
    public func launchSDK() -> UIViewController? {
        var vc: UIViewController?
        permissionManager.checkCameraPermissions { granted in
            if granted {
                let cameraHandler = CameraHandler()
                let cameraViewModel = CameraViewModel(cameraHandler: cameraHandler)
                let cameraViewController = CameraViewController(viewModel: cameraViewModel)
                vc = cameraViewController
            }
        }
        return vc
    }
}
