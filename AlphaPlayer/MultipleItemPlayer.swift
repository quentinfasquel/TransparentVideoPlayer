//
//  MultipleItemPlayer.swift
//  AlphaPlayer
//
//  Created by Quentin Fasquel on 08/05/2019.
//  Copyright © 2019 Quentin Fasquel. All rights reserved.
//

import AVFoundation

/// An aggregate of players for given player items
public class MultipleItemPlayer: AVPlayer {
    internal var otherPlayers: [AVPlayer] = []
    
    internal override required init() {
        super.init()
    }

//    internal override required init(playerItem item: AVPlayerItem?) {
//        super.init(playerItem: item)
//    }

    private func makeOtherPlayersIfNeeded(for composition: VideoPlaybackComposition) {
        if otherPlayers.count != composition.otherPlayerItems.count {
            otherPlayers = composition.otherPlayerItems.map { AVPlayer(playerItem: $0) }
        }
        
        configurePlayers()
    }
    
    internal required init(playerItems: [AVPlayerItem]) {
        var otherPlayerItems = playerItems
        super.init(playerItem: otherPlayerItems.removeFirst())
        otherPlayers = otherPlayerItems.map { AVPlayer(playerItem: $0) }

        configurePlayers()
        observeStatus()
    }
    
    internal convenience init(playerItems: AVPlayerItem...) {
        self.init(playerItems: playerItems)
    }
    
    // MARK: - AVPlayer
    
    public override func pause() {
        super.pause()
        otherPlayers.forEach { $0.pause() }
    }
    
    public override func play() {
        super.play()
        otherPlayers.forEach { $0.play() }
        // TODO: Understand setRate / hostTime
    }
    
    public override func playImmediately(atRate rate: Float) {
        super.playImmediately(atRate: rate)
        otherPlayers.forEach { $0.playImmediately(atRate: rate) }
    }
    
    public override func preroll(atRate rate: Float, completionHandler: ((Bool) -> Void)? = nil) {
        let singleCompletionHandler = merge(completionHandler: completionHandler, count: otherPlayers.count + 1)
        super.preroll(atRate: rate, completionHandler: singleCompletionHandler)
        otherPlayers.forEach { $0.preroll(atRate: rate, completionHandler: singleCompletionHandler) }
    }
    
    public override func replaceCurrentItem(with item: AVPlayerItem?) {
        super.replaceCurrentItem(with: item)
        
        if let composition = item as? VideoPlaybackComposition {
            makeOtherPlayersIfNeeded(for: composition)

            otherPlayers.enumerated().forEach { index, player in
                player.replaceCurrentItem(with: composition.otherPlayerItems[index])
            }
        }
    }
    
    // MARK: - Status
    
    @objc internal dynamic var aggregateStatus: AVPlayer.Status = .unknown
    private var statusObservers: [NSKeyValueObservation]?
    
    private func configurePlayers() {
        let players: [AVPlayer] = [self] + otherPlayers
        
        
        let clock = CMClockGetHostTimeClock()
        
        players.forEach {
            $0.automaticallyWaitsToMinimizeStalling = false
            $0.masterClock = clock
        }
    }
    
    internal func observeStatus() {
        let players: [AVPlayer] = [self] + otherPlayers
        let numberOfPlayers: Int = players.count
        var completeCount: Int = 0

        let completion: (AVPlayer, NSKeyValueObservedChange<AVPlayer.Status>) -> Void = { [unowned self] player, _ in
            if player.status == .readyToPlay {
                completeCount += 1
            } else if player.status == .failed {
                self.aggregateStatus = .failed
            }

            if completeCount == numberOfPlayers, self.aggregateStatus != .failed {
                self.aggregateStatus = .readyToPlay
            }
        }

        statusObservers = players.map { $0.observe(\.status, changeHandler: completion) }
    }
        
    internal func restart() {
        
    }
}
