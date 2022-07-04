//
//  ViewController.swift
//  100 Days Of Swift-Challenge Project 3
//
//  Created by Arda Büyükhatipoğlu on 4.07.2022.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var userInputText: UITextField!
    
    var currentWord: String = ""
    var wordArray =  [String]()
    var usedLetters = [Character]()
    var guessCount = 0 {
        didSet {
            DispatchQueue.main.async {
                self.title = "Guess Count: \(self.guessCount) / 7"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global(qos: .userInteractive).async {
            self.loadWordsArray()
            self.changeWord()
        }
        
        DispatchQueue.main.async {
            self.displayWord()
        }
        
    }
    
    ///Loads all words from txt file into an array.
    func loadWordsArray() {
        if let fileUrl = Bundle.main.url(forResource: "words", withExtension: "txt") {
            if let fileContents = try? String(contentsOf: fileUrl) {
                wordArray = fileContents.components(separatedBy: "\n")
            } else {
                print("Error, couldn't load words from txt file.")
            }
        }
    }
    
    ///Changes the current word with a random element from the words array and removes all elements from array: Used Letters.
    func changeWord() {
        
        usedLetters.removeAll() // clear all letters
        if let randomWord = wordArray.randomElement() {
            currentWord = randomWord
        } else {
            currentWord = "Alakazam"
        }
    }
    
    ///Submit a letter.
    @IBAction func submitClicked(_ sender: UIButton) {
        if let inputText = userInputText.text {
            guard (inputText.count == 1) else { return } //Check if input size is 1
            
            if usedLetters.contains(Character(inputText)) { // Checks if the letter is used before
                let ac = UIAlertController(title: "Oops!", message: "Letter already used", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
            } else {
                if !currentWord.contains(Character(inputText)){
                    guessCount += 1
                }
                usedLetters.append(Character(inputText))
                displayWord()
            }
        }
    }
    
    ///Displays the word on screen.
    func displayWord() {
        var wordToShow = ""
        
        for letter in currentWord {
            if usedLetters.contains(letter) {
                wordToShow += String(letter)
            } else {
                wordToShow += "?"
            }
        }
        wordLabel.text = wordToShow
        
        checkSuccess(word: wordToShow)
    }
    
    ///Checks if the user found all the letters in the word
    func checkSuccess(word: String) {
        if word == currentWord {
            gameOver() //User has won.
        } else {
            if guessCount == 7 {
                gameOver(title: "Game Over", message: "You couldn't guess the word in 7 tries.\n The word was: \(currentWord)") // User lost
            }
        }
    }
    
    ///Win or Lose state. Refreshes the game after showing a success or fail message.
    func gameOver(title: String = "Success", message: String = "You guessed the word") {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "New Word", style: .default))
        
        DispatchQueue.global(qos: .userInteractive).async {
            self.changeWord()
            self.guessCount = 0
            
            DispatchQueue.main.async {
                self.present(ac, animated: true)
                self.displayWord()
            }
        }
    }
}
