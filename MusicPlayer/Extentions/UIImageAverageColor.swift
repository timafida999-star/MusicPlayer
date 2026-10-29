import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

extension UIImage {
    var averageColor: UIColor? {
        guard let input = CIImage(image: self) else { return nil }

        let filter = CIFilter.areaAverage()
        filter.inputImage = input
        filter.extent = input.extent

        guard let output = filter.outputImage else { return nil }

        var pixel = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: NSNull()])
        context.render(
            output,
            toBitmap: &pixel,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: nil
        )

        return UIColor(
            red: CGFloat(pixel[0]) / 255,
            green: CGFloat(pixel[1]) / 255,
            blue: CGFloat(pixel[2]) / 255,
            alpha: 1
        )
    }
}

extension UIColor {
    func darkened(maxBrightness: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        guard getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else {
            return self
        }

        return UIColor(
            hue: hue,
            saturation: min(saturation * 1.15, 1),
            brightness: min(brightness, maxBrightness),
            alpha: alpha
        )
    }
}
