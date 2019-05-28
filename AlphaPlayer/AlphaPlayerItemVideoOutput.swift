//
//  AlphaPlayerItemVideoOutput.swift
//  TestComposition
//
//  Created by Quentin Fasquel on 29/04/2019.
//  Copyright © 2019 Quentin Fasquel. All rights reserved.
//

import AVFoundation
import Metal
import QuartzCore.CAMetalLayer
import UIKit

///
/// An aggregate of an `rgb` and a `alpha` AVPlayerItemVideoOutputs
///
public class AlphaPlayerItemVideoOutput: MultiplePlayerItemVideoOutput {

    internal enum OutputName: String {
        case rgb, alpha
    }

    private func output(named outputName: OutputName) -> AVPlayerItemVideoOutput {
        return outputsById[outputName.rawValue]!
    }

    internal var outputRGB: AVPlayerItemVideoOutput { return output(named: .rgb) }
    internal var outputAlpha: AVPlayerItemVideoOutput { return output(named: .alpha) }

//    var onReadyToPlay: (() -> Void)?
    
    public required init() {
        super.init()

        setupOutputs()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupOutputs() {
        // TODO: Allow reading with a different pixelFormatType?
        let attributes: [String: Any] = [
//            String(kCVPixelBufferPixelFormatTypeKey): kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
            String(kCVPixelBufferPixelFormatTypeKey): kCVPixelFormatType_32BGRA
        ]

        let outputRGB = AVPlayerItemVideoOutput(pixelBufferAttributes: attributes)
        addOutput(id: OutputName.rgb.rawValue, outputRGB)
        
        let outputAlpha = AVPlayerItemVideoOutput(pixelBufferAttributes: attributes)
        addOutput(id: OutputName.alpha.rawValue, outputAlpha)
    }
    
//    public func itemTime(forHostTime hostTimeInSeconds: CFTimeInterval) -> CMTime {
//        return outputRGB.itemTime(forHostTime: hostTimeInSeconds)
//    }
}
