//
//  CameraPermissionManager.swift
//  ValifySDK
//
//  Created by Peter Samir on 04/09/2024.
//

import Foundation
import AVFoundation

final class CameraPermissionManager {
    
    func checkCameraPermissions(
        completion: @escaping (Bool) -> ()) {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .notDetermined:
                completion(requestCameraAccess())
                break
            case .authorized:
                completion(true)
            default:
                completion(requestCameraAccess())
            }
        }
    
    private func requestCameraAccess() -> Bool {
        var isGranted = false
        AVCaptureDevice.requestAccess(for: .video) { granted in
            isGranted = granted
        }
        return isGranted
    }
}
