//
//  AlphaPlayerItem.swift
//  AlphaPlayer
//
//  Created by Quentin Fasquel on 11/05/2019.
//  Copyright © 2019 Quentin Fasquel. All rights reserved.
//

import AVFoundation

public typealias AlphaPlayerItemError = AlphaPlayerItem.Error

public class AlphaPlayerItem: VideoPlaybackComposition {
    public enum Error: Swift.Error {
        case incorrectFormat // RGB or Alpha isn't a supported video format
        case incorrectSize // RGB & Alpha aren't videos of the same `naturalSize`
        case incorrectDuration // RGB & Alpha aren't videos of the same `duration`
    }

    internal required init(assets: [AVAsset], videoOutput: VideoPlaybackCompositionVideoOutput) {
        super.init(assets: assets, videoOutput: videoOutput)

        playerItems[0].add(videoOutput.outputs[0])
        playerItems[1].add(videoOutput.outputs[1])
    }
    
    public convenience init(_ rgbURL: URL, _ alphaURL: URL) throws {
        let assetRGB = AVAsset(url: rgbURL)
        let assetAlpha = AVAsset(url: alphaURL)
        let videoOutput = AlphaPlayerItemVideoOutput()

        try AlphaPlayerItem.validateAssets(assetRGB, assetAlpha)

        self.init(assets: [assetRGB, assetAlpha], videoOutput: videoOutput)
    }
    
    internal static func validateAssets(_ assets: AVAsset...) throws {
        let assetRGB = assets[0]
        let assetAlpha = assets[1]
        
        guard let trackRGB = assetRGB.tracks(withMediaType: .video).first else {
            throw Error.incorrectFormat
        }

        guard let trackAlpha = assetRGB.tracks(withMediaType: .video).first else {
            throw Error.incorrectFormat
        }

        guard trackRGB.naturalSize.equalTo(trackAlpha.naturalSize) else {
            throw Error.incorrectSize
        }

        guard assetRGB.duration == assetAlpha.duration else {
            throw Error.incorrectDuration
        }
    }
}
