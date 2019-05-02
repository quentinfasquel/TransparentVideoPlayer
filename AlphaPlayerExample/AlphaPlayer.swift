//
//  AlphaPlayer.swift
//  TestComposition
//
//  Created by Quentin Fasquel on 29/04/2019.
//  Copyright © 2019 Quentin Fasquel. All rights reserved.
//

import AVFoundation

///
public class AlphaPlayer: AVPlayer, AlphaPlayerProtocol {

    ///
    private var playerItem: AlphaPlayerItem!
    
    ///
    var alphaPlayer: AVPlayer!

    public override init() {
        super.init()
    }

    // status ready -> if alphaPlayer status ready
    required init(alphaPlayerItem item: AlphaPlayerItem) {
        super.init(playerItem: item)
        playerItem = item
        alphaPlayer = AVPlayer(playerItem: item.alphaItem)
    }

    // MARK: - AVPlayer

    public override func pause() {
        super.pause()
        alphaPlayer.pause()
    }
    
    public override func play() {
        super.play()
        alphaPlayer.play()
    }

    public override func playImmediately(atRate rate: Float) {
        super.playImmediately(atRate: rate)
        alphaPlayer.playImmediately(atRate: rate)
    }
    
    public override func replaceCurrentItem(with item: AVPlayerItem?) {
        // TODO: Assert that item is AlphaPlayerItem?
        super.replaceCurrentItem(with: item)
    }
}
