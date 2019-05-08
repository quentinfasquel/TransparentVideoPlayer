//
//  AlphaPlayerProtocol.swift
//  AlphaPlayerExample
//
//  Created by Quentin Fasquel on 01/05/2019.
//  Copyright © 2019 Quentin Fasquel. All rights reserved.
//

import AVFoundation

public protocol PlaybackControl {
    func play()
    func playImmediately(atRate rate: Float)
    func pause()
    func seek(to date: Date)
    func seek(to time: CMTime)
}

public protocol PlayerProtocol: AnyObject, PlaybackControl {
    var currentItem: AVPlayerItem? { get }
}

public protocol AlphaPlayerProtocol: AnyObject, PlaybackControl {
    var currentItem: AVPlayerItem? { get }
    var currentAlphaItem: AVPlayerItem? { get }
}

// MARK: -

extension AlphaPlayerProtocol {

    public var currentAlphaItem: AVPlayerItem? {
        return (currentItem as? AlphaPlayerItem)?.alphaItem
    }
}
