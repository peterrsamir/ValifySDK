//
//  MLKitFaceDetection.swift
//  ValifySDK
//
//  Created by Peter Samir on 04/09/2024.
//

import MLKitVision
import MLKitFaceDetection

final class MLKitFaceDetection: FaceDetectionProtocol {
    private var faceDetector: FaceDetector
    
    init() {
        let options = FaceDetectorOptions()
        options.performanceMode = .accurate
        options.landmarkMode = .all
        options.classificationMode = .all
        
        faceDetector = FaceDetector.faceDetector(options: options)
    }
    
    func detectFaces(in sampleBuffer: CMSampleBuffer, completion: @escaping (Bool, Error?) -> Void) {
        guard CMSampleBufferGetImageBuffer(sampleBuffer) != nil else {
            completion(false, nil)
            return
        }
        
        let visionImage = VisionImage(buffer: sampleBuffer)
        visionImage.orientation = .right
        
        faceDetector.process(visionImage) { faces, error in
            if let error = error {
                completion(false, error)
                return
            }
            
            guard let faces = faces, !faces.isEmpty else {
                completion(false, nil)
                return
            }
            
            var allLandmarksVisible = false
            for face in faces {
                if face.landmark(ofType: .leftEye) != nil &&
                    face.landmark(ofType: .rightEye) != nil &&
                    face.landmark(ofType: .noseBase) != nil &&
                    face.landmark(ofType: .mouthLeft) != nil &&
                    face.landmark(ofType: .mouthBottom) != nil &&
                    face.landmark(ofType: .mouthRight) != nil {
                    allLandmarksVisible = true
                    break
                }
            }
            completion(allLandmarksVisible, nil)
        }
    }
}
