/*
See LICENSE folder for this sample’s licensing information.

Abstract:
ARSCNViewDelegate methods for the Game Scene View Controller.
*/

import ARKit
import os.log

extension ViewController: ARSCNViewDelegate, ARSessionDelegate {
    
    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if mode == gameMode.local {
            if let name = anchor.name, name.hasPrefix("panda") && !localMultiplayer.cubePlaced {
                localMultiplayer.loadCubefromPeer(location: anchor.transform.translation)
                //            localMultiplayer.cube.placeCube(translation: anchor.transform.translation)
            }
        }
    }
    
    // MARK: - ARSessionDelegate
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        if mode == gameMode.local {
            localMultiplayer.updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
        }
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if mode == gameMode.local {
            localMultiplayer.checkMappingStatus(frame: frame)
        }
    }
    
    // MARK: - ARSessionObserver
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay.
        sessionInfoLabel.text = "Session was interrupted"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required.
        sessionInfoLabel.text = "Session interruption ended"
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user.
        sessionInfoLabel.text = "Session failed: \(error.localizedDescription)"
        resetTracking(nil)
    }
    
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true
    }
    
}
