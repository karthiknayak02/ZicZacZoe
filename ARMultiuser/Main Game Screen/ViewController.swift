/*

Abstract:
Main view controller for the AR experience.
*/

import UIKit
import SceneKit
import ARKit
import MultipeerConnectivity

class ViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var sessionInfoView: UIView!
    @IBOutlet weak var sessionInfoLabel: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var sendMapButton: UIButton!
    @IBOutlet weak var mappingStatusLabel: UILabel!
    @IBOutlet weak var gameStatusLabel: UILabel!
    
    var localMultiplayer: GameLocalMultiplayer!
    var AIsingleplayer: GameAI!
    
    enum gameMode {
        case single
        case local
        case online
    }
    
    var mode: gameMode = gameMode.single // default to localMultiplayer
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if mode == gameMode.single {
            self.hideAllLabels()
            self.AIsingleplayer =  GameAI(sceneView: sceneView, difficulty: GameAI.aiMode.easy)
        }
        else if mode == gameMode.local {
            self.localMultiplayer =  GameLocalMultiplayer(sessionInfoView: sessionInfoView, sessionInfoLabel: sessionInfoLabel, sceneView: sceneView, sendMapButton: sendMapButton, mappingStatusLabel: mappingStatusLabel, gameStatusLabel: gameStatusLabel)
        }
        else if mode == gameMode.online {
            // add code @dagmawi
        }
        
        addTapGestureToSceneView()
    }
    
    func hideAllLabels() {
        sessionInfoView.isHidden = true
        sessionInfoLabel.isHidden = true
        sendMapButton.isHidden = true
        mappingStatusLabel.isHidden = true
        mappingStatusLabel.isHidden = true
        gameStatusLabel.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard ARWorldTrackingConfiguration.isSupported else {
            fatalError("ARKit is not available on this device.") // For details, see https://developer.apple.com/documentation/arkit
        }
        
        configureLighting()
        setUpSceneView()
    }
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    func setUpSceneView() {
        // Start the view's AR session.
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        
        // Set a delegate to track the number of plane anchors for providing UI feedback.
        sceneView.session.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Prevent the screen from being dimmed after a while as users will likely
        // have long periods of interaction without touching the screen or buttons.
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's AR session.
        sceneView.session.pause()
    }
    
    // This function assign the long press gesture with 0 delay to take advantage of on release functionality
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(tapAction))
        tapGestureRecognizer.minimumPressDuration = 0
        tapGestureRecognizer.delegate = self
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // This function is called when the tap gesture is activated
    @objc func tapAction(withGestureRecognizer recognizer: UIGestureRecognizer) {
        
        if mode == gameMode.single {
            AIsingleplayer.userTap(withGestureRecognizer: recognizer)
        }
        else if mode == gameMode.local {
            localMultiplayer.userTap(withGestureRecognizer: recognizer)
        }
        else if mode == gameMode.online {
            // add code @dagmawi
        }
    }
    
    /// - Tag: GetWorldMap
    @IBAction func shareSession(_ button: UIButton) {
        
        if mode == gameMode.local {
            localMultiplayer.shareSession()
        }
        
    }
    
    @IBAction func resetTracking(_ sender: UIButton?) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        if mode == gameMode.local {
            localMultiplayer.rePlace()
        }
        
    }

}

extension ViewController: UIGestureRecognizerDelegate {
    //New Functionality
    //Author: Yacob
    //Delegate function Allows view to recognize multiple gestures simultaneously
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

