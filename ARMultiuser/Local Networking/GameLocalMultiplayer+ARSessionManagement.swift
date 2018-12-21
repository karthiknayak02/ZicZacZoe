//
//  GameLocalMultiplayer+ARSessionManagement.swift
//  ARMultiuser
//
//  Created by Karthik on 12/12/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation
import UIKit
import ARKit
import MultipeerConnectivity


extension GameLocalMultiplayer {

    // MARK: - Multiuser shared session
    
    func checkMappingStatus(frame: ARFrame) {
        switch frame.worldMappingStatus {
        case .notAvailable, .limited:
            sendMapButton.isEnabled = false
        case .extending:
            sendMapButton.isEnabled = !multipeerSession.connectedPeers.isEmpty
        case .mapped:
            sendMapButton.isEnabled = !multipeerSession.connectedPeers.isEmpty
        }
        mappingStatusLabel.text = frame.worldMappingStatus.description
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    /// - Tag: GetWorldMap
    func shareSession() {
        sceneView.session.getCurrentWorldMap { worldMap, error in
            guard let map = worldMap
                else { print("Error: \(error!.localizedDescription)"); return }
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                else { fatalError("can't encode map") }
            self.startgame = self.multipeerSession.sendToAllPeers(data)
            if self.startgame {
                self.hideButton()
            }
        }
    }
    
    enum MyError: Error {
        case runtimeError(String)
    }
    
    /// - Tag: ReceiveData
    func receivedData(_ data: Data, from peer: MCPeerID) {
        print("<<<<<<<<<<<<<<ReceivedData>>>>>>>>>>>>>>>>")
        
        do {
            if cubePlaced {
                throw MyError.runtimeError("not a world map!")
            }
            
            if let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data) {
                // Run the session with the received world map.
                print("<<<<<<<<<<<<<<Unwrapped>>>>>>>>>>>>>>>>")
                let configuration = ARWorldTrackingConfiguration()
                configuration.planeDetection = .horizontal
                configuration.initialWorldMap = worldMap
                sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
                
                self.startgame = true
                
                // Remember who provided the map for showing UI feedback.
                mapProvider = peer
                return
            }
            //            else
            //                if let anchor = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARAnchor.self, from: data) {
            //                    // Add anchor to the session, ARSCNView delegate adds visible content.
            //                    sceneView.session.add(anchor: anchor)
            //                }
            //                else {
            //                    print("unknown data recieved from \(peer)")
            //            }
        } catch {
            print("can't decode data recieved from \(peer)")
            
            guard let opponentMove = String(data: data, encoding: .utf8) else {
//                sessionInfoLabel.text = "Cannot accept other world maps from other players if cube is already placed"
                return
            }
            
            print(opponentMove)
            
            print("<<<<<<<<<<<<<<Unwrapped opponentMove>>>>>>>>>>>>>>>>")
            cube.placeCellOpp(cellIdx: opponentMove, isUser: false)
            removeValidMove(cellIndex: opponentMove)
            print("Opponent Played: " + opponentMove)
            waiting = false
            
        }
    }
    
    // MARK: - AR session management
    func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        var message: String!
        var messageGame = ""
        
        if !cubePlaced {
            messageGame = "Please place cube or wait"
        }
        else if !waiting && startgame {
            messageGame = "Your turn"
        }
        else if waiting && startgame {
            messageGame = "Waiting on other player"
        }
        gameStatusLabel.text = messageGame
        gameStatusLabel.isHidden = messageGame.isEmpty
        gameStatusLabel.sizeToFit()
        
        switch trackingState {
        case .normal where frame.anchors.isEmpty && multipeerSession.connectedPeers.isEmpty:
            // No planes detected; provide instructions for this app's AR interactions.
            message = "Move around to map the environment, or wait to join a shared session."
            
        case .normal where !multipeerSession.connectedPeers.isEmpty:// && mapProvider == nil:
            let peerNames = multipeerSession.connectedPeers.map({ $0.displayName }).joined(separator: ", ")
            message = "Connected with \(peerNames)."
            
        case .notAvailable:
            message = "Tracking unavailable."
            
        case .limited(.excessiveMotion):
            message = "Tracking limited - Move the device more slowly."
            
        case .limited(.insufficientFeatures):
            message = "Tracking limited - Point the device at an area with visible surface detail, or improve lighting conditions."
            
        case .limited(.initializing) where mapProvider != nil,
             .limited(.relocalizing) where mapProvider != nil:
            message = "Received map from \(mapProvider!.displayName)."
            
        case .limited(.relocalizing):
            message = "Resuming session — move to where you were when the session was interrupted."
            
        case .limited(.initializing):
            message = "Initializing AR session."
            
        default:
            message = ""
            // No feedback needed when tracking is normal and planes are visible.
            // (Nor when in unreachable limited-tracking states.)
            
        }
        
        sessionInfoLabel.text = message
        sessionInfoView.isHidden = message.isEmpty
    }
    
    func loadCubefromPeer(location: float3) {
        cube.placeCube(translation: location)
        cubePlaced = true
        self.player1 = false
        waiting = true
        stopPlaneDetection()
    }

}
