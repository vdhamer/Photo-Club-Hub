//
//  String+containsWordUsingNLP.swift
//  Photo Club HubTests
//
//  Created by Peter van den Hamer on 22/02/2025.
//

import Testing
@testable import Photo_Club_Hub

@Suite struct StringContainsWordUsingNLP {

    @Test("String contains word") func stringContainsWord() {
        let bigString = "The quick brown fox jumped over the lazy dog."
        let isFound = bigString.containsWordUsingNLP(targetWord: "fox")
        #expect(isFound == true)
    }

    @Test("String doesn't contain word") func stringDoesNotContainWord() {
        let bigString = "The quick brown fox jumped over the lazy dog."
        let isFound = bigString.containsWordUsingNLP(targetWord: "cat")
        #expect(isFound == false)
    }

    @Test("Target string is superset of one of the words") func targetStringTooBig() {
        let bigString = "The quick brown fox jumped over the lazy dog."
        let isFound = bigString.containsWordUsingNLP(targetWord: "dogs")
        #expect(isFound == false)
    }

    @Test("Target string is subset of one of the words") func targetStringTooSmall() {
        let bigString = "The quick brown fox jumped over the lazy dog."
        let isFound = bigString.containsWordUsingNLP(targetWord: "jump")
        #expect(isFound == false)
    }

}
