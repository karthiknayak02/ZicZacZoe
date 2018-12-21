//
//  cell.swift
//  ARKitHorizontalPlaneDemo
//
//  Created by Karthik on 10/28/18.
//  Copyright © 2018 eye_Ohh_ess. All rights reserved.
//

import Foundation
import UIKit
import ARKit

class Cell: SCNNode {
    
    enum cellState {
        case sphere
        case cross
        case empty
    }
    
    struct Index {
        var i, j, k: Int     // stores the location of the cell
    }
    
    var index = Index(i: -1, j: -1, k: -1)     // default value
    var indexStr = ""
    var state: cellState = cellState.empty // is reset for generator and solver
    
    // MARK: - Initialization
    override init() {
        super.init()
        
        // Set initial game board scale
//        simdScale = float3(GameBoard.minimumScale)

        guard let gameScene = SCNScene(named: "Assets.scnassets/game.scn") else { fatalError() }
        
        guard let node = gameScene.rootNode.childNode(withName: "Cell", recursively: true)
            else { fatalError() }
        
        self.rotation = node.rotation;
        self.transform = node.transform;
        self.boundingBox = node.boundingBox
        self.geometry = node.geometry
        self.geometry!.firstMaterial = node.geometry!.firstMaterial
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }
    
    func setData(i: Int, j: Int, k:Int, state: cellState) {
        // set cell index
        self.index.i = i
        self.index.j = j
        self.index.k = k
        self.indexStr = String(i) + String(j) + String(k)

        self.state = state          // set stare to empty, cross or sphere
    }
    
    func addMove(state: cellState) {
        var stateName: String!
        if (state == cellState.cross) {
            stateName = "cross"
        }
        else if (state == cellState.sphere){
            stateName = "sphere"
        }
        else { fatalError() }
        
        guard let gameScene = SCNScene(named: "Assets.scnassets/game.scn") else { fatalError() }
        guard let node = gameScene.rootNode.childNode(withName: "Cell", recursively: false)
            else { fatalError() }
        
        for childNode in node.childNodes {
            if (childNode.name == stateName) {
                addChildNode(childNode as SCNNode)
            }
        }
    }
    
    func removeXO() {
        // removes the 'X' or 'O' 3D object so it is a empty cell
        for childNode in childNodes {
            childNode.removeFromParentNode()
        }
    }
    
    func isSamePos(lastTappedIdx: Index) -> Bool {
        return self.index.i == lastTappedIdx.i && self.index.j == lastTappedIdx.j && self.index.k == lastTappedIdx.k
    }
}
