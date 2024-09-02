//
//  SDKDelegate.swift
//  ValifySDK
//
//  Created by Peter Samir on 31/08/2024.
//

import UIKit

/// Any one will use the Framework should conform this protocol
public protocol SDKDelegate: AnyObject {
    /// you can here use the returned method in your view
    /// - Parameter imageView: the approved image
    func sdkDidFinish(with imageView: UIImageView)
}

func getSDKBundle() -> Bundle {
    let frameworkBundleID  = "com.valify.sdk";
    return Bundle(identifier: frameworkBundleID)!
}
