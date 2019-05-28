//
//  AlphaPlayer.swift
//  TestComposition
//
//  Created by Quentin Fasquel on 29/04/2019.
//  Copyright © 2019 Quentin Fasquel. All rights reserved.
//

import AVFoundation

// TODO: Explore looping, chaining of items, etc.
///
public final class AlphaPlayer: MultipleItemPlayer, AlphaPlayerProtocol {
    
    public private(set) var currentComposition: AlphaPlayerItemComposition?

    public convenience init(composition: AlphaPlayerItemComposition) {
        self.init(playerItems: composition.playerItems)
        currentComposition = composition
        
//        composition.playbackDelegate = self
    }

    private var statusObserver: NSKeyValueObservation?
    private var otherStatusObservers: [NSKeyValueObservation]?
    
    internal func preload() {
        guard statusObserver == nil else {
            return
        }

        statusObserver = observe(\.aggregateStatus, changeHandler: { player, _ in
            print("status ready?", player.aggregateStatus)
            if player.aggregateStatus == .readyToPlay {
                player.preroll(atRate: 1) // this prerolls all
            }
        })
    }
    
    internal func syncPlay(atHostTime hostTime: CMTime) {
        let players: [AVPlayer] = [self] + otherPlayers
        players.forEach {
            $0.setRate(1.0, time: .invalid, atHostTime: hostTime)
        }
    }

}

extension AlphaPlayer: VideoPlaybackCompositionDelegate {
    internal func playbackWillEnd(_ composition: VideoPlaybackComposition) {
        print(#function)
        // Prepare for looping
        // nextItem set nextOutput
        // nextItem.preroll()
    }
    
    internal func playbackDidEnd(_ composition: VideoPlaybackComposition, hostTime: CMTime) {
        // Switch currentOutput & nextOutput, compositionCallback to nil
        print(#function)
        composition.seek(to: .zero) { (_) in
            self.play()
        }
    }
}
