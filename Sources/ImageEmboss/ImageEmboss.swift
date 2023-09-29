import Foundation
import CoreImage
import Vision

@available(macOS 14.0, iOS 17.0, tvOS 17.0, *)
public struct ImageEmboss {
    
    let req = VNGenerateForegroundInstanceMaskRequest()
    
    public init() {
    }
    
    public func ProcessImage(image: CIImage, combined: Bool) -> Result<[CIImage], Error> {
        
        let handler = VNImageRequestHandler(ciImage: image, options: [:])
        
        do {
            try handler.perform([req])
        } catch {
            return .failure(error)
        }
                
        guard let results = req.results!.first else {
            return .failure(Errors.noResults)
        }
        
        if combined {
            return self.extractImagesCombined(handler: handler, results: results)
        }
        
        return self.extractImages(handler: handler, results: results)
    }
    
    private func extractImages(handler: VNImageRequestHandler, results: VNInstanceMaskObservation) -> Result<[CIImage], Error>  {
        
        var images: [CIImage] = []
        var i = 1
        
        for _ in results.allInstances {
            
            defer {
                i += 1
            }
            
            do {
                
                let buf = try results.generateMaskedImage(
                    ofInstances: [i],
                    from: handler,
                    croppedToInstancesExtent: true
                )
                
                let im = CIImage(cvImageBuffer: buf)
                images.append(im)
                
            } catch {
                return .failure(error)
            }
        }
        
        return .success(images)
    }
    
    private func extractImagesCombined(handler: VNImageRequestHandler, results: VNInstanceMaskObservation) -> Result<[CIImage], Error>  {
        
        var images: [CIImage] = []
                
        do {
            
            let buf = try results.generateMaskedImage(
                ofInstances: results.allInstances,
                from: handler,
                croppedToInstancesExtent: true
            )
            
            let im = CIImage(cvImageBuffer: buf)
            images.append(im)
            
        } catch {
            return .failure(error)
        }
        
        return .success(images)
    }

}
