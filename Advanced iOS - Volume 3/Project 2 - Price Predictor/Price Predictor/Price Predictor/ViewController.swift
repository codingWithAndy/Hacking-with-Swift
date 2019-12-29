//
//  ViewController.swift
//  Price Predictor
//
//  Created by Andy Gray on 28/12/2019.
//  Copyright © 2019 Andy Gray. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var numberOfRooms: UISegmentedControl!
    @IBOutlet weak var numberOfBathrooms: UISegmentedControl!
    @IBOutlet weak var garageCapacity: UISegmentedControl!
    @IBOutlet weak var yearBuiltSlider: UISlider!
    @IBOutlet weak var sizeSlider: UISlider!
    @IBOutlet weak var condition: UISegmentedControl!
    @IBOutlet weak var result: UILabel!
    @IBOutlet weak var yearBuiltLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    
    let model = HousePrices()
    
    @IBAction func updatePrediction(_ sender: Any) {
        yearBuiltLabel.text = "Year Built: \(Int(yearBuiltSlider.value))"
        sizeLabel.text = "Size: \(Int(sizeSlider.value))"
        
        do {
            let prediction = try model.prediction(
                bathrooms: Double(numberOfBathrooms.selectedSegmentIndex + 1),
                cars: Double(garageCapacity.selectedSegmentIndex),
                condition: Double(condition.selectedSegmentIndex),
                rooms: Double(numberOfRooms.selectedSegmentIndex + 1),
                size: Double(Int(sizeSlider.value)),
                yearBuilt: Double(Int(yearBuiltSlider.value))
            )
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.maximumFractionDigits = 0
            result.text = formatter.string(from: prediction.value as NSNumber) ?? ""
        } catch {
            print(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let spacing: CGFloat = 30
        stackView.setCustomSpacing(spacing, after: numberOfRooms)
        stackView.setCustomSpacing(spacing, after: numberOfBathrooms)
        stackView.setCustomSpacing(spacing, after: garageCapacity)
        stackView.setCustomSpacing(spacing, after: yearBuiltSlider)
        stackView.setCustomSpacing(spacing, after: sizeSlider)
        stackView.setCustomSpacing(spacing, after: condition)

        updatePrediction(self)
    }


}

