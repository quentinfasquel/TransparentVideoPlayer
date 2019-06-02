//
//  AlphaPlayerRenderer.swift
//  AlphaPlayerExample
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

//internal typealias CVFrame = (pixelBuffer: CVPixelBuffer?, presentationTime: CMTime)

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
//        currentItem = composition
        configureComposition(composition)
        
    }

    private func configureComposition(_ composition: VideoPlaybackComposition) {
        composition.addDisplayOutput(self)

        if composition.displayLink?.isPaused ?? true {
            composition.startDisplayLink()
        }
//        if composition.playbackDelegate == nil {
//            composition.playbackDelegate = self
//            composition.startDisplayLink()
//        }
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
    
//    private var currentPlayer: AlphaPlayer?
//    private var nextPlayer: AlphaPlayer?

    // a playback composition, will output to a view using a given renderer
//    private var currentItem: AlphaPlayerItemComposition?
//    private var nextItem: AlphaPlayerItemComposition?
//
//    private func swapPlayers() {
//        let tmpPlayer = currentPlayer
//        currentPlayer = nextPlayer
//        nextPlayer = tmpPlayer
//    }
}

// MARK: -

extension AlphaPlayerDisplayOutput: VideoPlaybackCompositionDisplayOutput {
    func playbackComposition(_ composition: VideoPlaybackComposition, pixelBuffers: [CVPixelBuffer]) {
        displayFrame(pixelBuffers[0], pixelBuffers[1])
    }
}

// MARK: -
/*
extension AlphaPlayerDisplayOutput: VideoPlaybackCompositionDelegate {
    internal func playbackWillEnd(_ composition: VideoPlaybackComposition) {
//        print(#function)
        
        if let newItem = composition.copy() as? AlphaPlayerItemComposition {
            nextPlayer?.replaceCurrentItem(with: newItem)
            nextPlayer?.preload()
            newItem.startDisplayLink()
            nextItem = newItem
        }

        // Prepare for looping
        // nextItem set nextOutput
        // nextItem.preroll()
    }
    
    internal func playbackDidEnd(_ composition: VideoPlaybackComposition, hostTime: CMTime) {
        // Switch currentOutput & nextOutput, compositionCallback to nil
//        print(#function)

        if let newItem = nextItem, let player = nextPlayer {
            currentItem?.cancelDisplayLink()
            configureComposition(newItem)
            currentItem = newItem
            
//            let tti = (item.displayLink.timestamp + item.displayLink.targetTimestamp) * 0.5
//            let tt = CMTime(value: CMTimeValue(tti * 1000.0), timescale: 1000)
            player.syncPlay(atHostTime: hostTime)
            
            swapPlayers()
        }

    }
}*/
