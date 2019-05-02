//
//  AlphaQueuePlayer.swift
//  TestComposition
//
//  Created by Quentin Fasquel on 01/05/2019.
//  Copyright © 2019 Quentin Fasquel. All rights reserved.
//

import AVFoundation

class AlphaQueuePlayer: AVQueuePlayer, AlphaPlayerProtocol {

    var alphaPlayer: AVQueuePlayer!

    override init() {
        super.init()
    }
    
    required init(alphaPlayerItem item: AlphaPlayerItem?) {
        super.init(playerItem: item)
        alphaPlayer = AVQueuePlayer(playerItem: item?.alphaItem)
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
    
    // MARK: - Queue Player
    
    override func advanceToNextItem() {
        super.advanceToNextItem()
        #if DEBUG
        print(#function, self)
        #endif
    }
    
    override func insert(_ item: AVPlayerItem, after afterItem: AVPlayerItem?) {
        super.insert(item, after: afterItem)
        #if DEBUG
        print(#function, self)
        #endif

        let afterAlphaItem = (afterItem as? AlphaPlayerItem)?.alphaItem
        guard let alphaItem = (item as? AlphaPlayerItem)?.alphaItem else {
            print("Lost alpha item")
            return
        }

        alphaPlayer.insert(alphaItem, after: afterAlphaItem)
    }
    
    override func canInsert(_ item: AVPlayerItem, after afterItem: AVPlayerItem?) -> Bool {
        #if DEBUG
        print(#function, self)
        #endif
        return super.canInsert(item, after: afterItem) //&& alphaPlayer.canInsert(<#T##item: AVPlayerItem##AVPlayerItem#>, after: <#T##AVPlayerItem?#>)
    }

    override func cancelPendingPrerolls() {
        super.cancelPendingPrerolls()
        alphaPlayer.cancelPendingPrerolls()

        #if DEBUG
        print(#function, self)
        #endif
    }

    override func remove(_ item: AVPlayerItem) {
        super.remove(item)
        
        if let alphaItem = (item as? AlphaPlayerItem)?.alphaItem {
            alphaPlayer.remove(alphaItem)
        }

        #if DEBUG
        print(#function, self)
        #endif
    }
    
    override func removeAllItems() {
        super.removeAllItems()
        alphaPlayer.removeAllItems()

        #if DEBUG
        print(#function, self)
        #endif
    }
}
