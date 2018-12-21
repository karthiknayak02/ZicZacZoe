//
//  EasyAI.swift
//  ARKitHorizontalPlaneDemo
//
//  Created by Karthik on 10/30/18.
//  Copyright © 2018 eye_Ohh_ess. All rights reserved.
//

import Foundation


class EasyAI {
    
    func getMove(availablePositions: [String]) -> String {
        let moveStr = availablePositions.randomElement()
        return moveStr!
    }
    
}
