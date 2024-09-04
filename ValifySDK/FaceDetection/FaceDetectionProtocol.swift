//
//  FaceDetectionProtocol.swift
//  ValifySDK
//
//  Created by Peter Samir on 04/09/2024.
//

import AVFoundation

protocol FaceDetectionProtocol {
    func detectFaces(in sampleBuffer: CMSampleBuffer, completion: @escaping (Bool, Error?) -> Void)
}
