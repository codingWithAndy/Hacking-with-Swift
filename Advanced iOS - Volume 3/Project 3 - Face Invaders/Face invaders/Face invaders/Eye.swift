//
//  Eye.swift
//  Face invaders
//
//  Created by Andy Gray on 31/12/2019.
//  Copyright © 2019 Andy Gray. All rights reserved.
//

import UIKit
import SceneKit

class Eye: SCNNode {
    let target = SCNNode()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented.")
    }
    
    init(color: UIColor) {
        super.init()

        // create a cylinder with a 0.5cm radius that is 20cm long
        let geometry = SCNCylinder(radius: 0.005, height: 0.2)

        // color it either red or blue depending on how the eye was created
        geometry.firstMaterial?.diffuse.contents = color

        // wrap that in a SceneKit node
        let node = SCNNode(geometry: geometry)

        // rotate it 90 degrees so it faces away from the user
        node.eulerAngles.x = -.pi / 2

        // move it roughly over their eyes
        node.position.z = 0.1

        // make it slightly transparent
        node.opacity = 0.5

        // add the cylinder to the eye node
        addChildNode(node)

        // also add the target node
        addChildNode(target)

        // move the target node one meter away
        target.position.z = 1
    }
    
    

}
