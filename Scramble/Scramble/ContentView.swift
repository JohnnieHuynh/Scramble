//
//  ContentView.swift
//  Scramble
//
//  Created by Johnny Huynh on 6/16/22.
//

import SwiftUI

struct ContentView: View {
    @State private var enteredWords = [String]()
    @State private var originalWord = ""
    @State private var liveWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMsg = ""
    @State private var showingError = false
    @State private var score = 0
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $liveWord)
                        .autocapitalization(.none)
                }
                
                Section {
                    ForEach(enteredWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
                
                Section {
                    Text("Score: \(score)")
                }
            }
            .navigationTitle(originalWord)
            .onSubmit(addWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("Understood", role: .cancel) { }
            } message: {
                Text(errorMsg)
            }
            .toolbar {
                Button("Restart", action: resetGame)
            }
            
        }
    }
    
    func addWord() {
        let answer = liveWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        //Extra validation
        guard isOriginal(word: answer) else {
            wordError(title: "Word already used", message: "Enter original word.")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "All letters must originate from \(originalWord) + must be 3 letters long")
            return
        }
        
        guard isOffical(word: answer) else {
            wordError(title: "Word not official", message: "Word must be original")
            return
        }
        
        withAnimation {
            enteredWords.insert(answer, at: 0)
            //Add to score
            score += answer.count
        }
        
        liveWord = ""
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy:
                "\n")
                originalWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle")
    }
    
    //Func that checks that word is new
    func isOriginal(word: String) -> Bool {
        //Check for previous entered words
        !enteredWords.contains(word)
    }
    
    //Func for check letters are valid
    func isPossible(word: String) -> Bool {
        //Copy of original word
        var tempWord = originalWord
        
        //Word is less than 3 letters
        if (word.count < 3) {
            return false
        }
        
        //Check that each letter in the players word exists in the orignal word
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                //letter wasn't found and the entered word doesnt count
                return false
            }
        }
        
        //Every letter is good
        return true
    }
    
    //Check string that is an actual word
    func isOffical(word: String) -> Bool {
        if (word == originalWord) {
            return false
        }
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMsg = message
        showingError = true
    }
    
    func resetGame() {
        //Intialize all values
        score = 0
        
        //Empty word arr
        enteredWords.removeAll()
        
        //Recall startgame (gets new word)
        startGame()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
