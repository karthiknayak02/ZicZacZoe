//
//  GameLocal.swift
//  ARKitHorizontalPlaneDemo
//
//  Created by Karthik on 11/30/18.
//  Copyright © 2018 eye_Ohh_ess. All rights reserved.
//

import Foundation
import UIKit
import ARKit
import MultipeerConnectivity


class GameAI {
    
    var cube: Cube!
    var availablePositions: [String] = []
    var sceneView: ARSCNView!
    
    var prevLocation = CGPoint(x: 0, y: 0)
    var cubePlaced: Bool = false
    
    var easyPlayer: EasyAI!
    var hardPlayer: HardAI!
    
    var checker = CheckWinner()
    
    enum aiMode {
        case easy
        case hard
    }
    
    var difficulty: aiMode = aiMode.easy // default to easy
    
    init(sceneView: ARSCNView, difficulty: aiMode) {
        self.sceneView = sceneView
        
        self.cube = Cube(sceneView: sceneView)
        createAvailablePositions()
        
        if difficulty == aiMode.easy {
            easyPlayer = EasyAI()
        }
        else if difficulty == aiMode.hard {
//            hardPlayer = HardAI()
        }
    }
    
    func stopPlaneDetection() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = []               // this tells sceneView to detect horizontal planes
        sceneView.debugOptions = []
        sceneView.session.run(configuration)
    }
    
    private func createAvailablePositions() {
        for i in 0...cube.N-1 {
            for j in 0...cube.N-1 {
                for k in 0...cube.N-1 {
                    self.availablePositions.append(String(i) + String(j) + String(k))
                }
            }
        }
    }
    
    func rePlace() {
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        
        cubePlaced = false
    }
    
    func userTap(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation: CGPoint = recognizer.location(in: sceneView)
        let isTapComplete = recognizer.state == UIGestureRecognizer.State.ended
        
        if !cubePlaced {
            handleCubePlacement(tapLocation: tapLocation, isTapComplete: isTapComplete)
        }
        else {
            handleGameMove(tapLocation: tapLocation, isTapComplete: isTapComplete)
        }
    }
    
    private func handleCubePlacement(tapLocation: CGPoint, isTapComplete: Bool) {
        cube.removeLastPreviewCube()
        
        guard let hitTestResult = sceneView
            .hitTest(tapLocation, types: [.existingPlaneUsingGeometry, .estimatedHorizontalPlane])
            .first
            else { return }
        
        let translation: float3 = hitTestResult.worldTransform.translation
        
        if (isTapComplete) {                // when tap is release we want to place the cube
            rePlace()                       // remove plane
            
            // Place an anchor for a virtual character. The model appears in renderer(_:didAdd:for:).
            let anchor = ARAnchor(name: "panda", transform: hitTestResult.worldTransform)
            sceneView.session.add(anchor: anchor)
            
            cube.placeCube(translation: translation)
            cubePlaced = true
            stopPlaneDetection()

        }
        else if prevLocation != tapLocation {
            prevLocation = tapLocation      // set current tap location to prev
            cube.previewCube(translation: translation)
        }
    }
    
    private func handleGameMove(tapLocation: CGPoint, isTapComplete: Bool) {
        
        let hitTestResults = sceneView.hitTest(tapLocation, options: nil)
        
        guard let tappedNode = hitTestResults.first?.node as? Cell else { return }
        
        if (isTapComplete) && availablePositions.contains(tappedNode.indexStr) {    // when tap is release we want to place the cells
            
            let userMove = cube.placeCell(tappedCell: tappedNode, isUser: true)
            removeValidMove(cellIndex: userMove)
            print("User Played: " + userMove)
            
            // check winner
            if checker.checkGameState(cubeState: cube.cube, pos: userMove) == Cell.cellState.sphere {
                // new view controller or alert that user won!
                print("USER WINS")
            }
            
            // add ai game play here:
            let aiMove = easyPlayer.getMove(availablePositions: availablePositions)
            cube.placeCellOpp(cellIdx: aiMove, isUser: false)
            removeValidMove(cellIndex: aiMove)
            print("Easy Played: " + aiMove)
            
            // check winner
            if checker.checkGameState(cubeState: cube.cube, pos: aiMove) == Cell.cellState.cross {
                // new view controller or alert that AI won!
                print("AI WINS")
            }
            
        }
            
        else if availablePositions.contains(tappedNode.indexStr) {
            cube.previewCell(tappedCell: tappedNode)
        }
    }
    
    func removeValidMove(cellIndex: String) {
        let idx = availablePositions.firstIndex(of: cellIndex)
        availablePositions.remove(at: idx!)
    }
    
}
