//
//  ViewController.swift
//  Fridgr
//
//  Created by James Fong on 2018-04-30.
//  Copyright © 2018 James Fong. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision

class ViewController: UIViewController, ARSCNViewDelegate {

    static let colorScheme = "3498db"
    var visionRequests = [VNRequest]()
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var detectedTextView: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        sceneView.delegate = self
        self.configureVisionRequests()
        self.iterateFrames()
    }

    func configureView() {
        self.detectedTextView.backgroundColor = UIColor.clear
    }
    
    func configureVisionRequests(){
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else { return }
        let request = VNCoreMLRequest(model: model, completionHandler: { (request, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let result = request.results else { return }
            
            DispatchQueue.main.async {
                guard let food = result.first as? VNClassificationObservation else { return }
                self.detectedTextView.text = food.identifier
            }
        })
        request.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop
        visionRequests = [request]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin]
        sceneView.automaticallyUpdatesLighting = true
        //options later might use: resetTracking, removeExistingAnchors
        sceneView.session.run(configuration, options:[])
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateImageFrame(){
        guard let pixelBuffer = self.sceneView.session.currentFrame?.capturedImage else { return }
        do {
            try VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform(visionRequests)
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func iterateFrames(){
        DispatchQueue.global(qos: .userInitiated).async {
            self.updateImageFrame()
            self.iterateFrames()
        }
    }
    
    @IBAction func addPressed(_ sender: Any) {
        
    }
    
    
}

