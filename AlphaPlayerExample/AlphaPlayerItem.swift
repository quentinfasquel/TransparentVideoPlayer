//
//  AlphaPlayerItem.swift
//  TestComposition
//
//  Created by Quentin Fasquel on 27/04/2019.
//  Copyright © 2019 Quentin Fasquel. All rights reserved.
//

import AVFoundation
import UIKit

enum AlphaPlayerItemError: Error {
    case incorrectFormat // RGB or Alpha isn't a supported video format
    case incorrectSize // RGB & Alpha aren't videos of the same `naturalSize`
    case incorrectDuration // RGB & Alpha aren't videos of the same `duration`
}

///
///
///
class AlphaPlayerItem: AVPlayerItem {
    
    ///
    public let alphaItem: AVPlayerItem

    private init(_ assetRGB: AVAsset, assetAlpha: AVAsset) {
        alphaItem = AVPlayerItem(asset: assetAlpha)
        super.init(asset: assetRGB, automaticallyLoadedAssetKeys: nil)
    }

    ///
    public required init(_ rgbURL: URL, _ alphaURL: URL) throws {
        let assetRGB = AVAsset(url: rgbURL)
        let assetAlpha = AVAsset(url: alphaURL)
        
        guard let trackRGB = assetRGB.tracks(withMediaType: .video).first else {
            throw AlphaPlayerItemError.incorrectFormat
        }

        guard let trackAlpha = assetRGB.tracks(withMediaType: .video).first else {
            throw AlphaPlayerItemError.incorrectFormat
        }

        guard trackRGB.naturalSize.equalTo(trackAlpha.naturalSize) else {
            throw AlphaPlayerItemError.incorrectSize
        }

        guard assetRGB.duration == assetAlpha.duration else {
            throw AlphaPlayerItemError.incorrectDuration
        }

        alphaItem = AVPlayerItem(asset: assetAlpha)

        super.init(asset: assetRGB, automaticallyLoadedAssetKeys: nil)
    }
    
    override func copy(with zone: NSZone? = nil) -> Any {
        return AlphaPlayerItem(asset, assetAlpha: alphaItem.asset)
    }

    /*
    override var error: Error? {
        return super.error ?? alphaItem.error
    }
    
    override func errorLog() -> AVPlayerItemErrorLog? {
        return super.errorLog() ?? alphaItem.errorLog()
    }
    
    override var status: AVPlayerItem.Status {
        let (rgbStatus, alphaStatus) = (super.status, alphaItem.status)
        switch (rgbStatus, alphaStatus) {
        case (.readyToPlay, .readyToPlay):
            return .readyToPlay
        case (.failed, _), (_, .failed):
            return .failed
        default:
            return .unknown
        }
    }
   */
    // TODO: override var tracks?
    
    // MARK: -
    
    override func seek(to date: Date, completionHandler: ((Bool) -> Void)? = nil) -> Bool {
        let singleCompletionHandler = mergeSuccess(completionHandler: completionHandler, count: 2)

        return super.seek(to: date, completionHandler: singleCompletionHandler)
            && alphaItem.seek(to: date, completionHandler: singleCompletionHandler)
    }

    override func seek(to time: CMTime, completionHandler: ((Bool) -> Void)? = nil) {
        let singleCompletionHandler = mergeSuccess(completionHandler: completionHandler, count: 2)
        super.seek(to: time, completionHandler: singleCompletionHandler)
        alphaItem.seek(to: time, completionHandler: singleCompletionHandler)
    }

    override func step(byCount stepCount: Int) {
        super.step(byCount: stepCount)
        alphaItem.step(byCount: stepCount)
    }
}

// MARK: -

typealias successCompletionHandler = (Bool) -> Void
fileprivate func mergeSuccess(completionHandler: successCompletionHandler?, count: Int) -> successCompletionHandler? {
    guard let finalCompletionHandler = completionHandler else {
        return nil
    }

    var completeCount: Int = 0
    var completeSuccess: Bool = false

    return { singleSuccess in
        completeSuccess = (completeCount == 0) ? singleSuccess : (completeSuccess && singleSuccess)
        completeCount += 1

        if completeCount == count - 1 {
            finalCompletionHandler(completeSuccess)
        }
    }
}

