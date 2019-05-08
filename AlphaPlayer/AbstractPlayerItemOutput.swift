//
//  AbstractPlayerItemOutput.swift
//  AlphaPlayer
//
//  Created by Quentin Fasquel on 05/05/2019.
//  Copyright © 2019 Quentin Fasquel. All rights reserved.
//

import AVFoundation

public protocol AbstractPlayerItemOutput {

//    func itemTime(forHostTime hostTimeInSeconds: CFTimeInterval) -> CMTime

//    func itemTime(forMachAbsoluteTime machAbsoluteTime: Int64) -> CMTime
}

extension AbstractPlayerItemOutput {
//    func itemTime(forMachAbsoluteTime machAbsoluteTime: Int64) -> CMTime {
//        var timeInfo: mach_timebase_info_data_t!;
//        mach_timebase_info(&timeInfo);
//        let hostTime: CFTimeInterval = Double((machAbsoluteTime * Int64(timeInfo.numer)) / Int64(timeInfo.denom)) / 1.0e9;
//        return itemTime(forHostTime: hostTime)
//    }
}

public protocol AbstractPlayerItemVideoOutput: AbstractPlayerItemOutput {
    
//    func hasNewPixelBuffer(forItemTime itemTime: CMTime) -> Bool
    
//    func copyPixelBuffer(forItemTime itemTime: CMTime, itemTimeForDisplay outItemTimeForDisplay: UnsafeMutablePointer<CMTime>?) -> CVPixelBuffer?

    // MARK: Player Item Output Pull Delegate
    
//    var delegate: AVPlayerItemOutputPullDelegate? { get }

//    var delegateQueue: DispatchQueue? { get }

//    func setDelegate(_ delegate: AVPlayerItemOutputPullDelegate?, queue delegateQueue: DispatchQueue?)
}

