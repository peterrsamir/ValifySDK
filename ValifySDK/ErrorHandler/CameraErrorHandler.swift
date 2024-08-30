//
//  CameraErrorHandler.swift
//  ValifySDK
//
//  Created by Peter Samir on 30/08/2024.
//

import Foundation

enum CameraError: LocalizedError {
    case cameraUnavailable
    case captureFailed
    case unauthorizedAccess
    
    var errorDescription: String? {
        switch self {
        case .cameraUnavailable:
            return "The camera is unavailable. Please try again later."
        case .captureFailed:
            return "Failed to capture the photo. Please try again."
        case .unauthorizedAccess:
            return "Camera access is denied. Please enable access in settings."
        }
    }
}
