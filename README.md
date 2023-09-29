# swift-image-emboss

An opinionated Swift package for basic `VNGenerateForegroundInstanceMaskRequest` operations to extract subjects from an image.

## Documentation

Documentation is incomplete at this time.

## Example

```
var ciImage: CIImage

let em = ImageEmboss()
let rsp = em.ProcessImage(image: ciImage, combined: false)
```

## Requirements

This requires MacOS 14.0, iOS 17.0, tvOS 17.0 or higher.

## See also

* https://developer.apple.com/documentation/vision
* https://developer.apple.com/documentation/coreimage/ciimage
* https://github.com/sfomuseum/swift-image-emboss-cli