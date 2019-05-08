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
public protocol MultiplePlayerItemVideoOutput: AbstractPlayerItemVideoOutput { // add Video
    associatedtype OutputId: RawRepresentable & Hashable

    var outputs: [OutputId: AVPlayerItemVideoOutput] { get }
}

public enum AlphaPlayerItemVideoOutputId: String {
    case rgb, alpha
}

///
/// An aggregate of an `rgb` and a `alpha` AVPlayerItemVideoOutputs
///
public class AlphaPlayerItemVideoOutput: NSObject, MultiplePlayerItemVideoOutput {

    public typealias OutputId = AlphaPlayerItemVideoOutputId
    public var outputs: [OutputId: AVPlayerItemVideoOutput] = [:]

    public var outputRGB: AVPlayerItemVideoOutput { return outputs[.rgb]! }
    public var outputAlpha: AVPlayerItemVideoOutput { return outputs[.alpha]! }

    // MARK: -
    
    private let queue: DispatchQueue = DispatchQueue(label: "blop") // item output pull delegate

    // state
    var rgbItemReady: Bool = false
    var alphaItemReady: Bool = false

    var onReadyToPlay: (() -> Void)?
    
    public override required init() {
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
        outputRGB.setDelegate(self, queue: queue)
        
        let outputAlpha = AVPlayerItemVideoOutput(pixelBufferAttributes: attributes)
        outputAlpha.setDelegate(self, queue: queue)

        outputs = [.rgb: outputRGB, .alpha: outputAlpha]
    }
    
    public func itemTime(forHostTime hostTimeInSeconds: CFTimeInterval) -> CMTime {
        return outputRGB.itemTime(forHostTime: hostTimeInSeconds)
    }

}

// MARK: - AVPlayerItemOutputPullDelegate
    
extension AlphaPlayerItemVideoOutput: AVPlayerItemOutputPullDelegate {
    
    public func outputMediaDataWillChange(_ sender: AVPlayerItemOutput) {
        switch sender {
        case outputRGB:
            rgbItemReady = true
        case outputAlpha:
            alphaItemReady = true
        default:
            return // unexpected
        }
        
        if rgbItemReady && alphaItemReady {
            onReadyToPlay?()
        }
    }
}
