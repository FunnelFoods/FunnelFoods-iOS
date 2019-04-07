//
//  ReceiptParser.swift
//  Funnel
//
//  Created by Shao-Qian Mah on 5/4/19.
//  Copyright © 2019 Funnel. All rights reserved.
//

import UIKit

struct Receipt {
    let ingredients: Dictionary<String, Double>
}

class ReceiptParser: NSObject {
   
    // Defaults to not a receipt
    var isReceipt = false
    
    //Setup ingredients dictionary
    var ingredientsDictionary: Dictionary<String, Double> = [:]
    
    func parse(receiptString: String) -> Receipt {
        // Trim all white spaces and newlines away
        if (receiptString.trimmingCharacters(in: .whitespacesAndNewlines) == "" || receiptString == "Empty page!!") {
            // Not a receipt, return empty IngredientsList
        } else {
            // Do additional processing
            isReceipt = true
            
            let range = NSRange(location: 0, length: receiptString.utf16.count)
            let regex = try! NSRegularExpression(pattern: "[^a-zA-Z]")
            let receiptByLine = receiptString.lines
            
            // Strip all whitespaces from each line
            var trimmedLines: Array<String> = []
            for line in receiptByLine {
                let trimmedLine = line.trimmingCharacters(in: .whitespaces)
                
                // Check if line has numbers and words
                if trimmedLine.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil && trimmedLine.hasNumber() {
                    // ** Implement additional logic here **
                    
                    // Find subtotal
                    if trimmedLine.lowercased().contains("subtotal") {
                        // This line contains the word subtotals
                    }
                }
            }
            
            
        }
        
        return Receipt(ingredients: ingredientsDictionary)
    }
}

extension String {
    var lines: [String] {
        var result: [String] = []
        enumerateLines { line, _ in result.append(line) }
        return result
    }
    
    func hasNumber() -> Bool {
        if self == "" {
            return false
        } else {
            var checkList: Array<Bool> = []
            for char in self {
                if char.isNumber {
                    checkList.append(true)
                }
            }
            if checkList.contains(true) {
                return true
            } else {
                return false
            }
        }
    }
    
    func isAlphanumeric() -> Bool {
        return self.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil && self != ""
    }
    
    func isAlphanumeric(ignoreDiacritics: Bool = false) -> Bool {
        if ignoreDiacritics {
            return self.range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil && self != ""
        }
        else {
            return self.isAlphanumeric()
        }
    }
}
