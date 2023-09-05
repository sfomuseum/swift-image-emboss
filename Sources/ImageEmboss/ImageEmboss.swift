import Foundation
import CoreImage
import Vision
import AppKit

public enum Errors: Error {
    case noResults
    case ciImage
}

@available(macOS 14.0, *)
public struct ImageEmboss {

    let req = VNGenerateForegroundInstanceMaskRequest()
    
    public init() {
    }
    
    public func ProcessImage(image: CGImage) -> Result<[NSImage], Error> {
                
        let handler = VNImageRequestHandler(cgImage: image, options: [:])

        do {
            try handler.perform([req])
        } catch {
            return .failure(error)
        }
        
        guard let results = req.results!.first else {
            return .failure(Errors.noResults)
        }
        
            // To do: generate an image for each instance in results
        
        // https://developer.apple.com/documentation/corevideo/cvpixelbuffer
        // https://developer.apple.com/documentation/corevideo/cvpixelbuffer
        
        var images: [NSImage] = []
        
            do {
                let buf = try results.generateMaskedImage(
                    ofInstances: results.allInstances,
                    from: handler,
                    croppedToInstancesExtent: true
                )
                                
                let ciImage = CIImage(cvImageBuffer: buf)

                let width = CVPixelBufferGetWidth(buf)
                let height = CVPixelBufferGetHeight(buf)

                let context = CIContext(options: nil)
                
                guard let cgImage = context.createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: width, height: height)) else {
                    throw(Errors.ciImage)
                }

                let nsImage = NSImage(cgImage: cgImage, size: CGSize(width: width, height: height))
                images.append(nsImage)
                
            } catch {
                return .failure(error)
            }
        
        
        return .success(images)
    }
}
