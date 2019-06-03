//
//  VideoPlaybackComposition.swift
//  AlphaPlayer
//
//  Created by Quentin Fasquel on 08/05/2019.
//  Copyright © 2019 Quentin Fasquel. All rights reserved.
//

import AVFoundation

public protocol PlayerItemProtocol {
    func seek(to date: Date, completionHandler: ((Bool) -> Void)?) -> Bool
    func seek(to time: CMTime, completionHandler: ((Bool) -> Void)?)
    func step(byCount stepCount: Int)
}

internal protocol VideoPlaybackCompositionDisplayOutput: AnyObject {
    func playbackComposition(_ composition: VideoPlaybackComposition, pixelBuffers: [CVPixelBuffer])
}

internal protocol VideoPlaybackCompositionDelegate: AnyObject {
    func playbackWillEnd(_ composition: VideoPlaybackComposition)
    func playbackDidEnd(_ composition: VideoPlaybackComposition, hostTime: CMTime)
}

public class VideoPlaybackComposition: AVPlayerItem {

    internal let videoOutput: VideoPlaybackCompositionVideoOutput
    internal let otherPlayerItems: [AVPlayerItem]

    internal var displayLink: CADisplayLink!
    internal var displayOutputs: [VideoPlaybackCompositionDisplayOutput] = []

    internal weak var playbackDelegate: VideoPlaybackCompositionDelegate?

    /// All playerItems, including self
    internal lazy var playerItems: [AVPlayerItem] = { [unowned self] in
        return [self] + otherPlayerItems
    }()

    internal required init(assets: [AVAsset], videoOutput: VideoPlaybackCompositionVideoOutput) {
        var otherAssets = assets
        let asset = otherAssets.removeFirst()

        let assetKeys: [String] = [
            #keyPath(AVAsset.duration),
            #keyPath(AVAsset.isPlayable),
            #keyPath(AVAsset.tracks)]

        self.otherPlayerItems = otherAssets.map { AVPlayerItem(asset: $0, automaticallyLoadedAssetKeys: assetKeys) }
        self.videoOutput = videoOutput

        super.init(asset: asset, automaticallyLoadedAssetKeys: assetKeys)

        preparePlaybackTimes()
    }
    
    public override func copy(with zone: NSZone? = nil) -> Any {
        let assets = playerItems.map { $0.asset }
        
        let outputCopy = type(of: videoOutput).init()
        let copy = type(of: self).init(assets: assets, videoOutput: outputCopy)
        copy.displayOutputs = displayOutputs

        return copy
    }

    internal func validateAssets() throws {
        // TODO
    }
    
    // MARK: - Display Link
    
    private func makeDisplayLink() {
        #if os(iOS) || os(tvOS)
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkCallback))
        displayLink.isPaused = true

        if let fps = asset.tracks(withMediaType: .video).first?.nominalFrameRate {
            displayLink.preferredFramesPerSecond = Int(fps)
        }

        displayLink.add(to: .current, forMode: .default)
        #elseif os(macOS)
        // TODO
        #endif
    }
    
    internal func startDisplayLink() {
        if displayLink == nil {
            makeDisplayLink()
        }
        
        if displayLink.isPaused {
            displayLink.isPaused = false
        }
    }
    
    internal func cancelDisplayLink() {
        displayLink?.isPaused = true
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc
    private func displayLinkCallback(_ sender: CADisplayLink) {
        let hostTime = (sender.timestamp + sender.targetTimestamp) * 0.5

        // let presentationTime = sender.targetTimestamp
        let itemTime = videoOutput.itemTime(forHostTime: hostTime)
        let frames = videoOutput.copyFrames(forItemTime: itemTime)
        let pixelBuffers = frames.compactMap { $0.pixelBuffer }

        // If there aren't the same amount of pixelBuffers than frame,
        // 1 or more playerItem is not being played.
        if pixelBuffers.count == frames.count {
            displayOutputs.forEach {
                $0.playbackComposition(self, pixelBuffers: pixelBuffers)
            }
        }

        if !playbackEnding && itemTime > endingStartTime {
            playbackEnding = true
            playbackDelegate?.playbackWillEnd(self)
        } else if !playbackEnded && itemTime > finalFrameTime {
            playbackEnded = true
            let hostTimeCM = CMTime(value: Int64(hostTime * 1000.0), timescale: 1000)
            playbackDelegate?.playbackDidEnd(self, hostTime: hostTimeCM)
        }
    }
    
    internal func addDisplayOutput(_ displayOutput: AlphaPlayerDisplayOutput) {
//        assert(displayLink.isPaused)
        displayOutputs.append(displayOutput)
    }
    
    // MARK: - Looping

    private var endingStartTime: CMTime = .indefinite
    private var finalFrameTime: CMTime = .indefinite
    private var playbackEnding: Bool = false
    private var playbackEnded: Bool = false

    private func preparePlaybackTimes() {
        guard let videoTrack = self.asset.tracks(withMediaType: .video).first else {
            return
        }

        let endTime = videoTrack.timeRange.end
        let endingDuration = CMTime(seconds: 3.0, preferredTimescale: videoTrack.naturalTimeScale)

        endingStartTime = endTime - endingDuration
        finalFrameTime = endTime - videoTrack.minFrameDuration
    }
}


// MARK: -

extension VideoPlaybackComposition: PlayerItemProtocol {

    public override var error: Error? {
        return super.error ?? otherPlayerItems.first(where: { $0.error != nil })?.error
    }
    
    public override func errorLog() -> AVPlayerItemErrorLog? {
        return super.errorLog() ?? otherPlayerItems.first(where: { $0.errorLog() != nil })?.errorLog()
    }
    
    // MARK: -
   
    public override func seek(to date: Date, completionHandler: ((Bool) -> Void)?) -> Bool {
        let singleCompletionHandler = merge(completionHandler: completionHandler, count: otherPlayerItems.count)
        let initialSeek = super.seek(to: date, completionHandler: singleCompletionHandler)

        return otherPlayerItems.reduce(initialSeek, { previousResult, playerItem in
            let currentResult = playerItem.seek(to: date, completionHandler: singleCompletionHandler)
            return previousResult && currentResult
        })
    }

    public override func seek(to time: CMTime, completionHandler: ((Bool) -> Void)?) {
        let singleCompletionHandler = merge(completionHandler: completionHandler, count: otherPlayerItems.count)
        super.seek(to: time, completionHandler: singleCompletionHandler)
        otherPlayerItems.forEach { $0.seek(to: time, completionHandler: singleCompletionHandler) }
    }
    
    public override func step(byCount stepCount: Int) {
        super.step(byCount: stepCount)
        otherPlayerItems.forEach { $0.step(byCount: stepCount) }
    }
}

