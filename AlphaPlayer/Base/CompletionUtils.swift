//
//  CompletionUtils.swift
//  AlphaPlayer
//
//  Created by Quentin Fasquel on 14/05/2019.
//  Copyright © 2019 Quentin Fasquel. All rights reserved.
//

import Foundation

typealias SuccessHandler = (Bool) -> Void

internal func merge(completionHandler: SuccessHandler?, count: Int) -> SuccessHandler? {
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
