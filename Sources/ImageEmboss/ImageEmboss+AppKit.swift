import Foundation
import CoreImage
import Vision
import AppKit


#if os(macOS)
@available(macOS 14.0, visionOS 1.0, *)
public struct ImageEmboss {

    let req = VNGenerateForegroundInstanceMaskRequest()
    
    public init() {
    }
    
    public func ProcessImage(image: CGImage, combined: Bool) -> Result<[NSImage], Error> {
                
        let handler = VNImageRequestHandler(cgImage: image, options: [:])

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
    
    private func extractImages(handler: VNImageRequestHandler, results: VNInstanceMaskObservation) -> Result<[NSImage], Error>  {
        
        var images: [NSImage] = []
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
                
                let im_rsp = self.bufToImage(buf: buf)
                var im: NSImage
                
                switch im_rsp {
                case .failure(let error):
                    return .failure(error)
                case .success(let image):
                    im = image
                }
                
                images.append(im)
                
            } catch {
                return .failure(error)
            }
        }
        
        return .success(images)
    }
    
    private func extractImagesCombined(handler: VNImageRequestHandler, results: VNInstanceMaskObservation) -> Result<[NSImage], Error>  {
        
        var images: [NSImage] = []
        
            do {
                
                let buf = try results.generateMaskedImage(
                    ofInstances: results.allInstances,
                    from: handler,
                    croppedToInstancesExtent: true
                )
                       
                let im_rsp = self.bufToImage(buf: buf)
                var im: NSImage
                
                switch im_rsp {
                case .failure(let error):
                    return .failure(error)
                case .success(let image):
                    im = image
                }
                
                images.append(im)
                
            } catch {
                return .failure(error)
            }
        
        return .success(images)
    }
    
    // https://developer.apple.com/documentation/corevideo/cvpixelbuffer

    private func bufToImage(buf: CVPixelBuffer) -> Result<NSImage, Error> {
        
        let ciImage = CIImage(cvImageBuffer: buf)

        let width = CVPixelBufferGetWidth(buf)
        let height = CVPixelBufferGetHeight(buf)

        let context = CIContext(options: nil)
        
        guard let cgImage = context.createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: width, height: height)) else {
            return .failure(Errors.ciImage)
        }

        let nsImage = NSImage(cgImage: cgImage, size: CGSize(width: width, height: height))
        return .success(nsImage)
    }
}
#endif
