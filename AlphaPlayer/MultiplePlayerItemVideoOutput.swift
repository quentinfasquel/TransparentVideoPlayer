//
//  MultiplePlayerItemVideoOutput.swift
//  AlphaPlayer
//
//  Created by Quentin Fasquel on 08/05/2019.
//  Copyright © 2019 Quentin Fasquel. All rights reserved.
//

import AVFoundation

/// An aggregate of playerItem video outputs
public class MultiplePlayerItemVideoOutput: NSObject {

    public private(set) var outputs: [AVPlayerItemVideoOutput] = []
    internal private(set) var outputsById: [String: AVPlayerItemVideoOutput] = [:]

    /// item output pull delegate
    private let delegateQueue: DispatchQueue = DispatchQueue(label: "blop")
    
    public required override init() {
        super.init()
    }
    
    public func addOutput(id: String, _ output: AVPlayerItemVideoOutput) {
        output.setDelegate(self, queue: delegateQueue)
        outputs.append(output)
        outputsById[id] = output // weak?
    }

    public func itemTime(forHostTime hostTimeInSeconds: CFTimeInterval) -> CMTime {
        return outputs[0].itemTime(forHostTime: hostTimeInSeconds)
    }

    // func copyPixelBuffer(forItemTime: _, itemTimeForDisplay: _) -> CVPixelBuffer?
    public func copyFrames(forItemTime itemTime: CMTime) -> [CVFrame] {
        return outputs.map { output in
            var frame = CVFrame(itemTime: itemTime)
            if output.hasNewPixelBuffer(forItemTime: itemTime) {
                frame.pixelBuffer = output.copyPixelBuffer(forItemTime: itemTime, itemTimeForDisplay: &frame.presentationTime)
            }
            return frame
        }
    }
}

extension MultiplePlayerItemVideoOutput: AVPlayerItemOutputPullDelegate {

    public func outputMediaDataWillChange(_ sender: AVPlayerItemOutput) {
        // Does nothing by default
        print("data will change", sender)
    }
}
