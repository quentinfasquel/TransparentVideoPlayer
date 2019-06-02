//
//  AlphaPlayerLooper.swift
//  AlphaPlayer
//
//  Created by Quentin Fasquel on 01/05/2019.
//  Copyright © 2019 Quentin Fasquel. All rights reserved.
//

import AVFoundation

class AlphaPlayerLooper: AVPlayerLooper {

    var alphaLooper: AVPlayerLooper!
    
//    override init(player: AVQueuePlayer, templateItem itemToLoop: AVPlayerItem, timeRange loopRange: CMTimeRange) {
//        super.init(player: player, templateItem: itemToLoop, timeRange: loopRange)
//    }

    required init(player: AlphaQueuePlayer, templateItem itemToLoop: AlphaPlayerItem) {
        let fullRange = CMTimeRange(start: .zero, duration: itemToLoop.duration)
        super.init(player: player, templateItem: itemToLoop, timeRange: fullRange)
        alphaLooper = AVPlayerLooper(player: player.alphaPlayer, templateItem: itemToLoop.alphaItem, timeRange: fullRange)
    }
}
