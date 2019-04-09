//
//  ReceiptParser.swift
//  Funnel
//
//  Created by Shao-Qian Mah on 5/4/19.
//  Copyright © 2019 Funnel. All rights reserved.
//

import UIKit

struct Receipt {
    let ingredients: Dictionary<String, Float>
}

class ReceiptParser: NSObject {
   
    // Defaults to not a receipt
    var isReceipt = false
    
    //Setup ingredients dictionary
    var ingredientsDictionary: Dictionary<String, Float> = [:]
    
    func parse(receiptString: String) -> Receipt {
        // Trim all white spaces and newlines away
        if (receiptString.trimmingCharacters(in: .whitespacesAndNewlines) == "" || receiptString == "Empty page!!") {
            // Not a receipt, return empty IngredientsList
        } else {
            // Do additional processing
            isReceipt = true
            
            // Receipt variables
            var totalCost: Float = Float(0)
    
            let regex = try! NSRegularExpression(pattern: "[^a-zA-Z]")
            
            // Strip all whitespaces from each line
            var trimmedLines: Array<String> = []
            for line in receiptString.lines {
                let trimmedLine = line.trimmingCharacters(in: .whitespaces)
                
                // Check if line has numbers and words
                if trimmedLine.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil && trimmedLine.hasNumber() {
                    trimmedLines.append(line)
                    
                    // ** Implement any additional logic here **
                    // Find subtotal
                    if trimmedLine.lowercased().contains("subtotal") {
                        // This line contains the word subtotals
                        totalCost = getCost(line: line) ?? Float(0)
                        break
                    }
                }
            }
            
            // Create dictionary of items and prices
            for i in 0..<trimmedLines.count {
                let price: Float = getCost(line: trimmedLines[i]) ?? Float(0)
                if price >= Float(0) {
                    totalCost -= price
                    if totalCost < Float(0) {
                        break
                    }
                    let item = "lol"
                    ingredientsDictionary[item] = price
                }
            }
            
            
        }
        
        if ingredientsDictionary.isEmpty {
            isReceipt = false
        }
        
        return Receipt(ingredients: ingredientsDictionary)
    }
    
    func getCost(line: String) -> Float? {
        var price = Float(-1.00)
        let lineBySpaces = line.components(separatedBy: " ")
        for word in lineBySpaces {
            // Check for dollar signs
            if word.contains("$") {
                let priceString = word.replacingOccurrences(of: "$", with: "", options: NSString.CompareOptions.literal, range:nil)
                if Float(priceString) != nil  {
                    //Is price
                    price = Float(price)
                }
            //Check if word is a number in itself
            } else if Float(word) != nil {
                // The word is a number, and that is the price
                price = Float(word)!
            }
        }
        
        // Check for errors in OCR of price and correct
        if price > 0 {
            if floor(price) == price && price.truncatingRemainder(dividingBy: 10.0) != 0 {
                return price / 100
            }
        }
        
        // No price found, return nil
        return nil
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
