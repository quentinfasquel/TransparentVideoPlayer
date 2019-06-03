//
//  MultipleItemPlayerLooper.swift
//  AlphaPlayer
//
//  Created by Quentin Fasquel on 13/05/2019.
//  Copyright © 2019 Quentin Fasquel. All rights reserved.
//

import AVFoundation

public class MultipleItemPlayerLooper: NSObject, VideoPlaybackCompositionDelegate {

    private var currentPlayer: MultipleItemPlayer?
    private var currentItem: VideoPlaybackComposition?
    private var nextPlayer: MultipleItemPlayer?
    private var nextItem: VideoPlaybackComposition?

    public required init(player: MultipleItemPlayer) {
        super.init()
        
        currentPlayer = player
        currentItem = player.currentItem as? VideoPlaybackComposition
        currentItem?.playbackDelegate = self

        nextPlayer = type(of: player).init()
    }
    
    public func disableLooping() {
        //
    }
    
    // MARK: - Video Playback Composition Delegate

    internal func playbackWillEnd(_ composition: VideoPlaybackComposition) {
        if let newItem = composition.copy() as? AlphaPlayerItem {
            nextPlayer?.replaceCurrentItem(with: newItem)
            nextPlayer?.preload()
            nextItem = newItem
        }

        // Prepare for looping
        // nextItem set nextOutput
        // nextItem.preroll()
    }

    internal func playbackDidEnd(_ composition: VideoPlaybackComposition, hostTime: CMTime) {
        if let newItem = nextItem, let newPlayer = nextPlayer {
            currentItem?.playbackDelegate = nil
            currentItem?.cancelDisplayLink()
            currentItem = newItem

            newItem.playbackDelegate = self
            newItem.startDisplayLink()

//            let tti = (item.displayLink.timestamp + item.displayLink.targetTimestamp) * 0.5
//            let tt = CMTime(value: CMTimeValue(tti * 1000.0), timescale: 1000)
            newPlayer.syncPlay(atHostTime: hostTime)

            swap(&nextPlayer, &currentPlayer)
        }

    }
}
