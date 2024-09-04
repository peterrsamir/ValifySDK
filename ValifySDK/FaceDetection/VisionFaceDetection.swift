//
//  VisionFaceDetection.swift
//  ValifySDK
//
//  Created by Peter Samir on 04/09/2024.
//

import Vision
import AVFoundation

final class VisionFaceDetection: FaceDetectionProtocol {
    
    // Method to detect faces using Vision
    func detectFaces(in sampleBuffer: CMSampleBuffer, completion: @escaping (Bool, Error?) -> Void) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            completion(false, nil)
            return
        }

        let request = VNDetectFaceRectanglesRequest { [weak self] request, error in
            if let error = error {
                completion(false, error)
                return
            }
            
            guard let observations = request.results as? [VNFaceObservation], !observations.isEmpty else {
                completion(false, nil)
                return
            }
            
            // Check if the entire face is visible
            let faceRect = observations.first!.boundingBox
            if self?.isFullFaceVisible(faceRect) == true {
                completion(true, nil)
            } else {
                completion(false, nil)
            }
        }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:])
        do {
            try handler.perform([request])
        } catch {
            completion(false, error)
        }
    }
    
    // Method to check if the full face is visible in the frame
    private func isFullFaceVisible(_ faceRect: CGRect) -> Bool {
        // Ensure the face rectangle covers a significant portion of the screen and is not too close to the edges
        return faceRect.minX > 0.1 && faceRect.maxX < 0.9 && faceRect.minY > 0.1 && faceRect.maxY < 0.9
    }
}
