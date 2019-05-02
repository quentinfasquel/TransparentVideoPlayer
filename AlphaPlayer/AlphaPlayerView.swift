//
//  AlphaPlayerView.swift
//  TestComposition
//
//  Created by Quentin Fasquel on 29/04/2019.
//  Copyright © 2019 Quentin Fasquel. All rights reserved.
//

import AVFoundation
import MetalKit
import UIKit

// TODO: Create AlphaPlayerLayer(player: AlphaPlayer) ?
// - pixelBufferAttributes should be able to change on the go
// - 

public class AlphaPlayerView: MTKView, AlphaPlayerItemVideoOutputProtocol {
    
    private let playerItemVideoOutput: AlphaPlayerItemVideoOutput
    private var playerRenderer: AlphaPlayerRenderer!

    public private(set) weak var player: AlphaPlayerProtocol?
    
    public override init(frame frameRect: CGRect, device: MTLDevice?) {
        // Create texture cache
        guard let device = device else {
            fatalError()
        }

        playerItemVideoOutput = AlphaPlayerItemVideoOutput(device: device)

        super.init(frame: frameRect, device: device)

        // Set transparent layer
        layer.isOpaque = false
    }

    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var observer: NSKeyValueObservation!
    
    public func setPlayer(_ alphaPlayer: AlphaPlayerProtocol) {
        player = alphaPlayer
        playerRenderer = AlphaPlayerRenderer(player: alphaPlayer, output: self)

        // On currentItem change, keep output
        observer = (player as? AVPlayer)?.observe(\AVPlayer.currentItem, options: [.new], changeHandler: { [unowned self] player, _ in
            if let alphaPlayerItem = player.currentItem as? AlphaPlayerItem {
                alphaPlayerItem.add(self.rgbOutput)
                alphaPlayerItem.alphaItem.add(self.alphaOutput)
            }
        })
    }
    
    // MARK: - AlphaPlayerItemVideoOutput

    public var rgbOutput: AVPlayerItemVideoOutput { return playerItemVideoOutput.rgbOutput }
    public var alphaOutput: AVPlayerItemVideoOutput { return playerItemVideoOutput.alphaOutput }
    
    public func render(_ rgbPixelBuffer: CVPixelBuffer, _ alphaPixelBuffer: CVPixelBuffer) -> MTLCommandBuffer? {
        guard let drawable = (layer as? CAMetalLayer)?.nextDrawable() else {
            return nil // Skip rendering
        }

        playerItemVideoOutput.currentTexture = drawable.texture
        let commandBuffer = playerItemVideoOutput.render(rgbPixelBuffer, alphaPixelBuffer)
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
        return commandBuffer
    }
}