//
//  String+containsWord.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 27/09/2023.
//

import NaturalLanguage

extension String {

    func containsWordUsingNLP(targetWord: String) -> Bool {
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = self
        let range = self.startIndex..<self.endIndex
        _ = tokenizer.tokens(for: range)

        var foundTarget: Bool = false
        tokenizer.enumerateTokens(in: range) { tokenRange, _ in
            let word = self[tokenRange]
            if word == targetWord {
                foundTarget = true
            }
            return true // stop criterium for enumerator
        }
        return foundTarget
    }
}
