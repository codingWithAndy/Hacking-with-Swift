//
//  ViewController.swift
//  Brain Training
//
//  Created by Andy Gray on 24/12/2019.
//  Copyright © 2019 Andy Gray. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var drawView: DrawingImageView!
    
    var questions = [Question]()
    var digitsModel = Digits()
    var score = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Brain Training"
        tableView.layer.borderColor = UIColor.lightGray.cgColor
        tableView.layer.borderWidth = 1
        drawView.delegate = self
        askQuestion()
    }

    func restartGame(action: UIAlertAction) {
        score = 0
        questions.removeAll()
        tableView.reloadData()
        askQuestion()
    }

    func askQuestion() {
        if questions.count == 20 {
            let ac = UIAlertController(title: "Game over!", message: "You scored \(score)/20.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Play Again", style: .default, handler: restartGame))
            present(ac, animated: true)
            return
        }

        drawView.image = nil
        questions.insert(createQuestion(), at: 0)

        let newIndexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [newIndexPath], with: .right)

        let secondIndexPath = IndexPath(row: 1, section: 0)
        if let cell = tableView.cellForRow(at: secondIndexPath) {
            setText(for: cell, at: secondIndexPath, to: questions[1])
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let currentQuestion = questions[indexPath.row]
        setText(for: cell, at: indexPath, to: currentQuestion)

        return cell
    }

    func setText(for cell: UITableViewCell, at indexPath: IndexPath, to question: Question) {
        if indexPath.row == 0 {
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 48)
        } else {
            cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        }

        if let actual = question.actual {
            cell.textLabel?.text = "\(question.text) = \(actual)"
        } else {
            cell.textLabel?.text = "\(question.text) = ?"
        }
    }

    func createQuestion() -> Question {
        var question = ""
        var correctAnswer = 0

        while true {
            let firstNumber = Int.random(in: 0...9)
            let secondNumber = Int.random(in: 0...9)

            if Bool.random() == true {
                let result = firstNumber + secondNumber

                if result < 10 {
                    question = "\(firstNumber) + \(secondNumber)"
                    correctAnswer = result
                    break
                }
            } else {
                let result = firstNumber - secondNumber

                if result >= 0 {
                    question = "\(firstNumber) - \(secondNumber)"
                    correctAnswer = result
                    break
                }
            }
        }

        return Question(text: question, correct: correctAnswer, actual: nil)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }

    func numberDrawn(_ image: UIImage) {
        let modelSize = 299
        UIGraphicsBeginImageContextWithOptions(CGSize(width: modelSize, height: modelSize), true, 1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: modelSize, height: modelSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        guard let model = try? VNCoreMLModel(for: digitsModel.model) else {
            fatalError("Failed to prepare model for Vision.")
        }

        guard let ciImage = CIImage(image: newImage) else {
            fatalError("Failed to convert UIImage to CIImage.")
        }

        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let prediction = results.first else {
                    fatalError("Failed to make a prediction: \(error?.localizedDescription ?? "Unknown error").")
            }

            DispatchQueue.main.async {
                let result = Int(prediction.identifier) ?? 0
                self?.questions[0].actual = result

                if self?.questions[0].correct == result {
                    self?.score += 1
                }

                self?.askQuestion()
            }
        }

        let handler = VNImageRequestHandler(ciImage: ciImage)

        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                print(error.localizedDescription)
            }
        }
    }

}

