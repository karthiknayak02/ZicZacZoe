//
//  Cube.swift
//  ARKitHorizontalPlaneDemo
//
//  Created by Karthik on 10/28/18.
//  Copyright © 2018 eye_Ohh_ess. All rights reserved.
//

import Foundation
import UIKit
import ARKit


class Cube {
    
    var sceneView: ARSCNView!
    var previewBox: SCNNode!
    var previewStarted: Bool = false
    var lastPreviewCell: Cell = Cell()
    var original: Cell!
    var cube = [[[Cell]]]()
    let N = 4   // size
    
    init(sceneView: ARSCNView) {
        self.sceneView = sceneView
        loadCubeData()
    }
    
    func loadCubeData() {
        guard let boxScene = SCNScene(named: "Assets.scnassets/game.scn") else { fatalError() }
        guard let boxNode = boxScene.rootNode.childNode(withName: "preview", recursively: false)
            else { fatalError() }
        self.previewBox = boxNode
        
        // fill cells in Cube 3D array
        for i in 0...N-1 {
            var layerZ = [[Cell]]()
            for j in 0...N-1 {
                var layerX = [Cell]()
                for k in 0...N-1 {
                    let cell = Cell()
                    cell.setData(i: i, j: j, k: k, state: Cell.cellState.empty);
                    
                    layerX.append(cell)
                }
                layerZ.append(layerX)
            }
            cube.append(layerZ)
        }
    }
    
    func removeLastPreviewCube() {
        previewBox.removeFromParentNode()
    }
    
    func previewCube(translation: float3) {
        previewBox.position = SCNVector3(x: translation.x, y: translation.y, z: translation.z)
        if !previewStarted {
            sceneView.scene.rootNode.addChildNode(previewBox)
        }
    }
    
    func placeCube(translation: float3) {
        
        let GAP: Float = 0.2
        
        // set cell positions in the 3D world
        var xval = translation.x - 0.3
        var yval = translation.y
        var zval = translation.z + 0.3
        
        for i in 0...N-1 {
            for j in 0...N-1 {
                for k in 0...N-1 {
                    let cell = cube[i][j][k]
                    cell.position = SCNVector3(x: xval, y: yval, z: zval)
                    sceneView.scene.rootNode.addChildNode(cell)
                    
                    xval += GAP
                }
                xval -= GAP * Float(N)
                zval -= GAP
            }
            zval += GAP * Float(N)
            yval += GAP
        }
    }
    
    func placeCell(tappedCell: Cell, isUser: Bool) -> String {

        if (isUser) {
            tappedCell.addMove(state: Cell.cellState.sphere)
            tappedCell.state = Cell.cellState.sphere
        }
        else {
            tappedCell.addMove(state: Cell.cellState.cross)
        }
        
        lastPreviewCell = Cell()
        return tappedCell.indexStr
    }
    
    func placeCellOpp(cellIdx: String, isUser: Bool) {
        
        let tappedCell = getCellfromName(cellIndex: cellIdx)
        
        if (isUser) {
            tappedCell.addMove(state: Cell.cellState.sphere)
            tappedCell.state = Cell.cellState.sphere
        }
        else {
            tappedCell.addMove(state: Cell.cellState.cross)
        }
        
        lastPreviewCell = Cell()
    }
    
    func previewCell(tappedCell: Cell) {

        if !tappedCell.isSamePos(lastTappedIdx: lastPreviewCell.index) {

            lastPreviewCell.removeXO()
            
            tappedCell.addMove(state: Cell.cellState.sphere)
            lastPreviewCell = tappedCell
        }
    }
    
    func setPreviewCubeSize()   {
        // update the preview Cube size as user resizes the cube
    }
    
    private func getCellfromName(cellIndex: String) -> Cell {
        
        var cellIndexArr = Array(cellIndex)
        
        let i = Int(String(cellIndexArr[0]))!
        let j = Int(String(cellIndexArr[1]))!
        let k = Int(String(cellIndexArr[2]))!
        
        return cube[i][j][k]
    }
    
}
