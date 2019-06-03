//
//  AlphaPlayerRenderer.swift
//  AlphaPlayer
//
//  Created by Quentin Fasquel on 01/05/2019.
//  Copyright © 2019 Quentin Fasquel. All rights reserved.
//

import AVFoundation
import QuartzCore

public struct CVFrame {
    let itemTime: CMTime
    var pixelBuffer: CVPixelBuffer?
    var presentationTime: CMTime = .invalid

    init(itemTime: CMTime) {
        self.itemTime = itemTime
    }
}

/// This is the piece that holds a displayLink, common piece for AlphaQueuePlayer & AlphaPlayer
internal class AlphaPlayerDisplayOutput {

    private let renderer: AlphaPlayerRendererProtocol
    private let view: AlphaPlayerRendererView

    internal var currentPlayer: AlphaPlayer?
    
    internal required init(renderer: AlphaPlayerRendererProtocol, view: AlphaPlayerRendererView) {
        self.renderer = renderer
        self.view = view
    }

    internal convenience init(player: AlphaPlayerProtocol, renderer: AlphaPlayerRendererProtocol, view: AlphaPlayerRendererView) {
        guard let composition = player.currentComposition else {
            fatalError()
        }

        self.init(renderer: renderer, view: view)

        currentPlayer = player as? AlphaPlayer

        configureComposition(composition)
    }

    private func configureComposition(_ composition: VideoPlaybackComposition) {
        composition.addDisplayOutput(self)

        if composition.displayLink?.isPaused ?? true {
            composition.startDisplayLink()
        }
    }

    private func displayFrame(_ rgb: CVPixelBuffer, _ alpha: CVPixelBuffer) {
        guard let drawable = view.nextDrawable() else {
            return // Skip frame
        }

        renderer.currentTexture = drawable.texture
        let commandBuffer = renderer.render(rgb, alpha)
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}

// MARK: - Video Playback Composition Display Output

extension AlphaPlayerDisplayOutput: VideoPlaybackCompositionDisplayOutput {
    func playbackComposition(_ composition: VideoPlaybackComposition, pixelBuffers: [CVPixelBuffer]) {
        displayFrame(pixelBuffers[0], pixelBuffers[1])
    }
}
