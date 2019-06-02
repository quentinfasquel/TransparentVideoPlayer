//
//  AlphaPlayerView.swift
//  AlphaPlayer
//
//  Created by Quentin Fasquel on 29/04/2019.
//  Copyright © 2019 Quentin Fasquel. All rights reserved.
//

import AVFoundation
import MetalKit
import UIKit

protocol AlphaPlayerRendererView {
    func nextDrawable() -> CAMetalDrawable?
}

// TODO: Create AlphaPlayerLayer(player: AlphaPlayer) ?
// - pixelBufferAttributes should be able to change on the go
// - 

public class AlphaPlayerView: MTKView, AlphaPlayerRendererView {
    
    public private(set) weak var player: AlphaPlayerProtocol?

    private var playerDisplayOutput: AlphaPlayerDisplayOutput!
    private var playerRenderer: AlphaPlayerRendererProtocol!

    public override init(frame frameRect: CGRect, device: MTLDevice?) {
        // Create texture cache
        guard let device = device else { fatalError() }

        super.init(frame: frameRect, device: device)

        playerRenderer = AlphaPlayerRenderer(device: device)

        // Configure metal layer
        guard let metalLayer = layer as? CAMetalLayer else { fatalError() }

        metalLayer.framebufferOnly = false
        metalLayer.isOpaque = false
        metalLayer.pixelFormat = .bgra8Unorm
    }

    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var observer: NSKeyValueObservation!
    
    public func setPlayer(_ alphaPlayer: AlphaPlayerProtocol) {
        player = alphaPlayer
        playerDisplayOutput = AlphaPlayerDisplayOutput(player: alphaPlayer, renderer: playerRenderer, view: self)

        // On currentItem change, keep output
//        observer = (player as? AVPlayer)?.observe(\AVPlayer.currentItem, options: [.new], changeHandler: { [unowned self] player, _ in
//            print("currentItem change?")
//            if let alphaPlayerItem = player.currentItem as? AlphaPlayerItem {
//                alphaPlayerItem.add(self.rgbOutput)
//                alphaPlayerItem.alphaItem.add(self.alphaOutput)
//            }
//        })
    }
    
    // MARK: - AlphaPlayerRendererView

    public func nextDrawable() -> CAMetalDrawable? {
        return (layer as? CAMetalLayer)?.nextDrawable()
    }
}
