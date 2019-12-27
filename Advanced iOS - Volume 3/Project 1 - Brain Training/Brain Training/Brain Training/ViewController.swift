//
//  ViewController.swift
//  Brain Training
//
//  Created by Andy Gray on 24/12/2019.
//  Copyright © 2019 Andy Gray. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var drawView: DrawingImageView!
    
    var questions = [Question]()
    var score = 0
    var digitsModel = Digits()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "Brain Training"
        tableView.layer.borderColor = UIColor.lightGray.cgColor
        tableView.layer.borderWidth = 1
        drawView.delegate = self
        askQuestion()
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let currentQuestion = questions[indexPath.row]
        setText(for: cell, at: indexPath, to: currentQuestion)

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
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
    
    func askQuestion() {
        // clear any previous iamge
        drawView.image = nil

        // create a question and insert it into our array so that it appears at the top of the table
        questions.insert(createQuestion(), at: 0)

        let newIndexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [newIndexPath], with: .right)

        // try to find the second cell in our table; this was the top cell a moment ago, and needs to be changed
        let secondIndexPath = IndexPath(row: 1, section: 0)
        if let cell = tableView.cellForRow(at: secondIndexPath) {
            // update this cell so that it shows the user's answer in the correct font
            setText(for: cell, at: secondIndexPath, to: questions[1])
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }

    func numberDrawn(_ image: UIImage) {
        askQuestion()
    }

    

}

