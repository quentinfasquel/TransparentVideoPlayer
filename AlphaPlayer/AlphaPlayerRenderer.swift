//
//  AlphaPlayerRenderer.swift
//  AlphaPlayerExample
//
//  Created by Quentin Fasquel on 01/05/2019.
//  Copyright © 2019 Quentin Fasquel. All rights reserved.
//

import AVFoundation
import QuartzCore

/// This is the piece that holds a displayLink, common piece for AlphaQueuePlayer & AlphaPlayer
internal class AlphaPlayerRenderer {
    typealias CVFrame = (pixelBuffer: CVPixelBuffer?, presentationTime: CMTime)

    private var displayLink: CADisplayLink!
    private(set) var output: AlphaPlayerItemVideoOutputProtocol!
    
    internal init(player: AlphaPlayerProtocol, output videoOutput: AlphaPlayerItemVideoOutputProtocol) {
        guard let rgbItem = player.currentItem, let alphaItem = player.currentAlphaItem else {
            fatalError()
        }

        output = videoOutput
        setupItems(rgbItem, alphaItem)
        startDisplayLink()
    }

    internal func setupItems(_ rgbItem: AVPlayerItem, _ alphaItem: AVPlayerItem) {
        rgbItem.add(output.rgbOutput)
        alphaItem.add(output.alphaOutput)
    }
    
    internal func startDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkCallback))
        displayLink.add(to: .current, forMode: .default)
    }
    
    @objc
    private func displayLinkCallback(_ sender: CADisplayLink) {
        let hostTime = (sender.timestamp + sender.targetTimestamp) * 0.5
        //        let presentationTime = sender.targetTimestamp
        guard let itemTime = output?.rgbOutput.itemTime(forHostTime: hostTime) else {
            print("No item time")
            return
        }
        
        func fetchFrame(_ output: AVPlayerItemVideoOutput) -> CVFrame {
            var pixelBuffer: CVPixelBuffer?
            var presentationTime: CMTime = .invalid
            
            if output.hasNewPixelBuffer(forItemTime: itemTime) {
                pixelBuffer = output.copyPixelBuffer(forItemTime: itemTime, itemTimeForDisplay: &presentationTime)
            }
            
            return (pixelBuffer, presentationTime)
        }
        
        let rgbFrame = fetchFrame(output.rgbOutput)
        let alphaFrame = fetchFrame(output.alphaOutput)
        
        if let rgb = rgbFrame.pixelBuffer, let alpha = alphaFrame.pixelBuffer {
            output.render(rgb, alpha)
        } else {
//            if rgbFrame.pixelBuffer == nil && alphaFrame.pixelBuffer == nil {
//                print("No more frames")
//            }
//
//            if alphaFrame.pixelBuffer == nil {
//                print("Skipping frame no alpha")
//            }
        }
    }
}
