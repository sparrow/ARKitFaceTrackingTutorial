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
private let minPositionDistance: Float = 0.0025
private let minScaling: CGFloat = 0.025
private let cellIdentifier = "GlassesCollectionViewCell"
private let glassesCount = 4
private let animationDuration: TimeInterval = 0.25
private let cornerRadius: CGFloat = 10

class ViewController: UIViewController {
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var glassesView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var calibrationView: UIView!
    @IBOutlet weak var calibrationTransparentView: UIView!
    @IBOutlet weak var collectionBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var calibrationBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionButton: UIButton!
    @IBOutlet weak var calibrationButton: UIButton!
    
    private let glassesPlane = SCNPlane(width: planeWidth, height: planeHeight)
    private let glassesNode = SCNNode()
    
    private var scaling: CGFloat = 1
    
    private var isCollecionOpened = false {
        didSet {
            updateCollectionPosition()
        }
    }
    private var isCalibrationOpened = false {
        didSet {
            updateCalibrationPosition()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("Face tracking is not supported on this device")
        }
        
        sceneView.delegate = self
        
        setupCollectionView()
        setupCalibrationView()
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
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionBottomConstraint.constant = -glassesView.bounds.size.height
    }
    
    private func setupCalibrationView() {
        calibrationTransparentView.layer.cornerRadius = cornerRadius
        calibrationBottomConstraint.constant = -calibrationView.bounds.size.height
    }
    
    private func updateGlasses(with index: Int) {
        let imageName = "glasses\(index)"
        glassesPlane.firstMaterial?.diffuse.contents = UIImage(named: imageName)
    }
    
    private func updateCollectionPosition() {
        collectionBottomConstraint.constant = isCollecionOpened ? 0 : -glassesView.bounds.size.height
        UIView.animate(withDuration: animationDuration) {
            self.calibrationButton.alpha = self.isCollecionOpened ? 0 : 1
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateCalibrationPosition() {
        calibrationBottomConstraint.constant = isCalibrationOpened ? 0 : -calibrationView.bounds.size.height
        UIView.animate(withDuration: animationDuration) {
            self.collectionButton.alpha = self.isCalibrationOpened ? 0 : 1
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateSize() {
        glassesPlane.width = scaling * planeWidth
        glassesPlane.height = scaling * planeHeight
    }
    
    // MARK: - Actions
    
    @IBAction func collectionDidTap(_ sender: UIButton) {
        isCollecionOpened = !isCollecionOpened
    }
    
    @IBAction func calibrationDidTap(_ sender: UIButton) {
        isCalibrationOpened = !isCalibrationOpened
    }
    
    @IBAction func sceneViewDidTap(_ sender: UITapGestureRecognizer) {
        isCollecionOpened = false
        isCalibrationOpened = false
    }
    
    @IBAction func upDidTap(_ sender: UIButton) {
        glassesNode.position.y += minPositionDistance
    }
    
    @IBAction func downDidTap(_ sender: UIButton) {
        glassesNode.position.y -= minPositionDistance
    }
    
    @IBAction func leftDidTap(_ sender: UIButton) {
        glassesNode.position.x -= minPositionDistance
    }
    
    @IBAction func rightDidTap(_ sender: UIButton) {
        glassesNode.position.x += minPositionDistance
    }
    
    @IBAction func farDidTap(_ sender: UIButton) {
        glassesNode.position.z += minPositionDistance
    }
    
    @IBAction func closerDidTap(_ sender: UIButton) {
        glassesNode.position.z -= minPositionDistance
    }
    
    @IBAction func biggerDidTap(_ sender: UIButton) {
        scaling += minScaling
        updateSize()
    }
    
    @IBAction func smallerDidTap(_ sender: UIButton) {
        scaling -= minScaling
        updateSize()
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
        
        glassesPlane.firstMaterial?.isDoubleSided = true
        updateGlasses(with: 0)
        
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

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return glassesCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! GlassesCollectionViewCell
        let imageName = "glasses\(indexPath.row)"
        cell.setup(with: imageName)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        updateGlasses(with: indexPath.row)
    }
}

