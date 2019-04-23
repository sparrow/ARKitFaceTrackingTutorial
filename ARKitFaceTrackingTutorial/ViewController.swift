//
//  ViewController.swift
//  ARKitFaceTrackingTutorial
//
//  Created by Evgeniy Antonov on 4/23/19.
//  Copyright © 2019 Evgeniy Antonov. All rights reserved.
//

import UIKit
import ARKit

private let planeWidth: CGFloat = 0.13
private let planeHeight: CGFloat = 0.06
private let nodeYPosition: Float = 0.022

class ViewController: UIViewController {
    @IBOutlet weak var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("Face tracking is not supported on this device")
        }
        
        sceneView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARFaceTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let device = sceneView.device else {
            return nil
        }
        
        let faceGeometry = ARSCNFaceGeometry(device: device)
        let faceNode = SCNNode(geometry: faceGeometry)
        faceNode.geometry?.firstMaterial?.transparency = 0
        
        let glassesPlane = SCNPlane(width: planeWidth, height: planeHeight)
        glassesPlane.firstMaterial?.isDoubleSided = true
        glassesPlane.firstMaterial?.diffuse.contents = UIImage(named: "glasses")
        
        let glassesNode = SCNNode()
        glassesNode.position.z = faceNode.boundingBox.max.z * 3 / 4
        glassesNode.position.y = nodeYPosition
        glassesNode.geometry = glassesPlane

        faceNode.addChildNode(glassesNode)
        
        return faceNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor, let faceGeometry = node.geometry as? ARSCNFaceGeometry else {
            return
        }
        
        faceGeometry.update(from: faceAnchor.geometry)
    }
}

