//
//  ViewController.swift
//  Face invaders
//
//  Created by Andy Gray on 31/12/2019.
//  Copyright © 2019 Andy Gray. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var reticule: UIImageView!
    
    let face = SCNNode()
    let leftEye = Eye(color: .red)
    let rightEye = Eye(color: .blue)
    
    let phone = SCNNode(geometry: SCNPlane(width: 1, height: 1))
    let smoothingAmount = 20
    var eyeLookHistory = ArraySlice<CGPoint>()
    
    var targets = [UIImageView]()
    var currentTarget = 0
    var gunshot: AVAudioPlayer?
    
    var startTime = CACurrentMediaTime()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        sceneView.scene.rootNode.addChildNode(face)
        sceneView.scene.rootNode.addChildNode(phone)
        face.addChildNode(leftEye)
        face.addChildNode(rightEye)
        
        // create a master stack view to handle all the other stack views
        let rowStackView = UIStackView()
        rowStackView.translatesAutoresizingMaskIntoConstraints = false

        // force the inner stack views to space themselves equally
        rowStackView.distribution = .fillEqually

        // position the inner stack views vertically
        rowStackView.axis = .vertical

        // and apply 20 points of space between them
        rowStackView.spacing = 20

        for _ in 1...6 {
            // create six columns of stack views
            let colStackView = UIStackView()
            colStackView.translatesAutoresizingMaskIntoConstraints = false

            // also with equally filling and 20 points of space
            colStackView.distribution = .fillEqually
            colStackView.spacing = 20

            // but now with a horizontal layout
            colStackView.axis = .horizontal

            // add the column stack view to the master row stack view
            rowStackView.addArrangedSubview(colStackView)

            for _ in 1...4 {
                // inside each column add four image views with our target
                let imageView = UIImageView(image: UIImage(named: "target"))

                // make it fit inside without squashing the image
                imageView.contentMode = .scaleAspectFit
                imageView.alpha = 0
                
                // add it to our targets array so we can track all the targets we created
                targets.append(imageView)

                // then add it to the current column
                colStackView.addArrangedSubview(imageView)
            }
        }
        
        view.addSubview(rowStackView)

        NSLayoutConstraint.activate([
            rowStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            rowStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            rowStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            rowStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        view.bringSubviewToFront(reticule)
        targets.shuffle()
        
        perform(#selector(createTarget), with: nil, afterDelay: 2)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func update(using anchor: ARFaceAnchor) {
        // pull out how much left and right blink we have
        if let leftBlink = anchor.blendShapes[.eyeBlinkLeft] as? Float,
            let rightBlink = anchor.blendShapes[.eyeBlinkRight] as? Float {

            // if both eyes are simultaneously blinking more than 10%, consider that a shot and exit the method
            if leftBlink > 0.1 && rightBlink > 0.1 {
                fire()
                return
            }
        }
        
        leftEye.simdTransform = anchor.leftEyeTransform
        rightEye.simdTransform = anchor.rightEyeTransform
        
        let points = [leftEye, rightEye].compactMap { eye -> CGPoint? in
            // find where this eye hit the plane
            let hitTest = phone.hitTestWithSegment(from: eye.target.worldPosition, to: eye.worldPosition)

            // convert that to a screen position and send it back
            return hitTest.first?.screenPosition
        }
        
        guard let leftPoint = points.first, let rightPoint = points.last else { return }
        
        let centerPoint = CGPoint(x: (leftPoint.x + rightPoint.x) / 2, y: -(leftPoint.y + rightPoint.y) / 2)
        
        reticule.transform = eyeLookHistory.averageTransform
        
        eyeLookHistory.append(centerPoint)
        eyeLookHistory = eyeLookHistory.suffix(smoothingAmount)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // make sure we have a face anchor
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }

        // push our work to the main thread
        DispatchQueue.main.async {
            // move and rotate the main face node
            self.face.simdTransform = node.simdTransform

            // update our eye positions and directions
            self.update(using: faceAnchor)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let pov = sceneView.pointOfView?.simdTransform else { return }
        phone.simdTransform = pov
    }
    
    @objc func createTarget() {
        
        guard currentTarget < targets.count else {
            endGame()
            return
        }
        
        // pick out the next target to show
        let target = targets[currentTarget]

        // scale it down nice and small
        target.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)

        // then animate it back up with a 0.3 second duration, making it visible at the same time
        UIView.animate(withDuration: 0.3) {
            target.transform = .identity
            target.alpha = 1
        }

        // move on to the next target
        currentTarget += 1
    }
    
    func fire() {
        let reticuleFrame = reticule.superview!.convert(reticule.frame, to: nil)
        
        // create a new array by filtering all our target image views
        let hitTargets = targets.filter { imageView in
            // ignore any targets that are hidden
            if imageView.alpha == 0 { return false }

            // convert this image view's frame into absolute coordinates
            let ourFrame = imageView.superview!.convert(imageView.frame, to: nil)

            // add this to the resulting array if we overlap the reticule
            return ourFrame.intersects(reticuleFrame)
        }
        
        // pull out the first hit target, if we have one
        guard let selected = hitTargets.first else { return }

        // hide that target
        selected.alpha = 0

        // play the gun sound
        if let url = Bundle.main.url(forResource: "shot", withExtension: "wav") {
            gunshot = try? AVAudioPlayer(contentsOf: url)
            gunshot?.play()
        }

        // create another target after a short delay
        perform(#selector(createTarget), with: nil, afterDelay: 1)
    }
    
    func endGame() {
        let timeTaken = Int(CACurrentMediaTime() - startTime)
        let ac = UIAlertController(title: "Game over!", message: "You took \(timeTaken) seconds.", preferredStyle: .alert)
        present(ac, animated: true)

        // automatically finish the score showing after three seconds
        perform(#selector(finish), with: nil, afterDelay: 3)
    }

    @objc func finish() {
        dismiss(animated: true) {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
}

extension SCNHitTestResult {
    var screenPosition: CGPoint {
        
        // size of iPhone X screen in meters
        let physicalSize = CGSize(width: 0.062 / 2, height: 0.135 / 2)
        
        // size of iPhone X screen in points
        let screenResolution = UIScreen.main.bounds.size
        
        let screenX = CGFloat(localCoordinates.x) / physicalSize.width * screenResolution.width
        let screenY = CGFloat(localCoordinates.y) / physicalSize.height * screenResolution.height
        
        return CGPoint(x: screenX, y: screenY)
    }
    
}

extension Collection where Element == CGPoint {
    var averageTransform: CGAffineTransform {
        // start with 0 for both X and Y
        var x: CGFloat = 0
        var y: CGFloat = 0

        // add all our values to the running totals
        for item in self {
            x += item.x
            y += item.y
        }

        // divide the totals by the number of items, and send back an affine transform
        let floatCount = CGFloat(count)
        return CGAffineTransform(translationX: x / floatCount, y: y / floatCount)
    }
}
