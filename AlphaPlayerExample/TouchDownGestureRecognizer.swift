//
//  TouchDownGestureRecognizer.swift
//  TestComposition
//
//  Created by Quentin Fasquel on 01/05/2019.
//  Copyright © 2019 Quentin Fasquel. All rights reserved.
//

import UIKit

class TouchDownGestureRecognizer: UIGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if state == .possible {
            state = .recognized
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .failed
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .failed
    }
    
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
//        state = .failed
//    }
}
