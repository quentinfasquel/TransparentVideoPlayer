//
//  AlphaPlayerRenderer.swift
//  AlphaPlayerExample
//
//  Created by Quentin Fasquel on 01/05/2019.
//  Copyright © 2019 Quentin Fasquel. All rights reserved.
//

import AVFoundation
import QuartzCore

internal typealias CVFrame = (pixelBuffer: CVPixelBuffer?, presentationTime: CMTime)

/// This is the piece that holds a displayLink, common piece for AlphaQueuePlayer & AlphaPlayer
internal class AlphaPlayerDisplayOutput {

    private let output: AlphaPlayerItemVideoOutput
    private let renderer: AlphaPlayerRendererProtocol
    private let view: AlphaPlayerRendererView

    private var displayLink: CADisplayLink!

    internal init(renderer: AlphaPlayerRendererProtocol, view: AlphaPlayerRendererView) {
        self.output = AlphaPlayerItemVideoOutput()
        self.renderer = renderer
        self.view = view
        
        startDisplayLink()
    }
    
    internal convenience init(player: AlphaPlayerProtocol, renderer: AlphaPlayerRendererProtocol, view: AlphaPlayerRendererView) {
        guard let rgbItem = player.currentItem, let alphaItem = player.currentAlphaItem else {
            fatalError()
        }

        self.init(renderer: renderer, view: view)
        setupItems(rgbItem, alphaItem)
    }

    internal func setupItems(_ rgbItem: AVPlayerItem, _ alphaItem: AVPlayerItem) {
        rgbItem.add(output.outputRGB)
        alphaItem.add(output.outputAlpha)
    }
    
    // MARK: - Display Link
    
    private func makeDisplayLink() {
        #if os(iOS) || os(tvOS)
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkCallback))
        displayLink.isPaused = true
        displayLink.add(to: .current, forMode: .default)
        #elseif os(macOS)
        // TODO
        #endif
    }
    
    internal func startDisplayLink() {
        if displayLink == nil {
            makeDisplayLink()
        }
        
        if displayLink.isPaused {
            displayLink.isPaused = false
        }
    }
    
    internal func cancelDisplayLink() {
        displayLink?.isPaused = true
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc
    private func displayLinkCallback(_ sender: CADisplayLink) {
        func fetchFrame(_ output: AVPlayerItemVideoOutput, itemTime: CMTime) -> CVFrame {
            var pixelBuffer: CVPixelBuffer?
            var presentationTime: CMTime = .invalid

            if output.hasNewPixelBuffer(forItemTime: itemTime) {
                pixelBuffer = output.copyPixelBuffer(forItemTime: itemTime, itemTimeForDisplay: &presentationTime)
            }
            
            return (pixelBuffer, presentationTime)
        }

        let hostTime = (sender.timestamp + sender.targetTimestamp) * 0.5
//        let presentationTime = sender.targetTimestamp
        let itemTime = output.itemTime(forHostTime: hostTime)

        let rgbFrame = fetchFrame(output.outputRGB, itemTime: itemTime)
        let alphaFrame = fetchFrame(output.outputAlpha, itemTime: itemTime)

        if let rgb = rgbFrame.pixelBuffer, let alpha = alphaFrame.pixelBuffer {
            displayFrame(rgb, alpha)
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

    private func displayFrame(_ rgb: CVPixelBuffer, _ alpha: CVPixelBuffer) {
        guard let drawable = view.nextDrawable() else {
            print("skip drawable")
            return
        }

        renderer.currentTexture = drawable.texture
        let commandBuffer = renderer.render(rgb, alpha)
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
