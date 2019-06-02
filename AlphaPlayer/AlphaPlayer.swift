//
//  AlphaPlayer.swift
//  AlphaPlayer
//
//  Created by Quentin Fasquel on 29/04/2019.
//  Copyright © 2019 Quentin Fasquel. All rights reserved.
//

import AVFoundation

// TODO: Explore looping, chaining of items, etc.
///
public final class AlphaPlayer: MultipleItemPlayer, AlphaPlayerProtocol {

    public private(set) var currentComposition: VideoPlaybackComposition?

    public convenience init(composition: AlphaPlayerItemComposition) {
        self.init(playerItems: composition.playerItems)
        currentComposition = composition
        
        debugPrint(#function)
//        composition.playbackDelegate = self
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
