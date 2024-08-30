//
//  Extension+UIImage.swift
//  Damoim
//
//  Created by 조규연 on 8/28/24.
//

import UIKit

extension UIImage {
    func resize(to targetSize: CGSize) -> UIImage? {
        let size = self.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Determine the scale factor that preserves aspect ratio
        let scaleFactor = min(widthRatio, heightRatio)

        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)

        // Create a bitmap graphics context
        UIGraphicsBeginImageContextWithOptions(scaledImageSize, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: scaledImageSize))

        // Get the resized image from the graphics context
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage
    }
    
    func circularImage() -> UIImage? {
        let minEdge = min(size.width, size.height)
        let squareSize = CGSize(width: minEdge, height: minEdge)
        
        let renderer = UIGraphicsImageRenderer(size: squareSize)
        let circularImage = renderer.image { context in
            let rect = CGRect(origin: .zero, size: squareSize)
            context.cgContext.addEllipse(in: rect)
            context.cgContext.clip()
            self.draw(in: rect)
        }
        
        return circularImage
    }
}
