//
//  AlphaPlayer.swift
//  AlphaPlayer
//
//  Created by Quentin Fasquel on 29/04/2019.
//  Copyright © 2019 Quentin Fasquel. All rights reserved.
//

import AVFoundation

///
public final class AlphaPlayer: MultipleItemPlayer, AlphaPlayerProtocol {

    public private(set) var currentComposition: VideoPlaybackComposition?

    public convenience init(composition: AlphaPlayerItem) {
        self.init(playerItems: composition.playerItems)
        currentComposition = composition
    }
}
