//
//  ReceiptParser.swift
//  Funnel
//
//  Created by Shao-Qian Mah on 5/4/19.
//  Copyright © 2019 Funnel. All rights reserved.
//

import UIKit

struct Receipt {
    let ingredients: Array<Ingredient>
    let total: Price
}

struct Price {
    var cost: Float
    let currency: String
}

struct Ingredient {
    let name: String
    let price: Price
}

class ReceiptParser: NSObject {
    
    func parse(receiptString: String) -> Receipt? {
        // Trim all white spaces and newlines away
        if (receiptString.trimmingCharacters(in: .whitespacesAndNewlines) == "" || receiptString == "Empty page!!") {
            // Not a receipt
            return nil
        } else {
            
            // Receipt variables
            var ingredientsList: Array<Ingredient> = []
            var totalCost: Price?
            
            // Strip all whitespaces from each line
            var trimmedLines: Array<String> = []
            for line in receiptString.lines {
                let trimmedLine = line.trimmingCharacters(in: .whitespaces)
                
                // Check if line has numbers and words
                if trimmedLine.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil && trimmedLine.hasNumber() {
                    trimmedLines.append(line)
                    
                    // ** Implement any additional logic here!!! **
                    
                    // Always check if a line is a subtotal first
                    if let subtotal = getSubtotal(line: line) {
                        // This is a subtotal!
                        totalCost = subtotal
                        break
                    } else {
                        // This line is not a subtotal, so try to get items and costs from this line and append the results to the ingredients dictionary
                        if let ingredient = getIngredient(line: line) {
                            ingredientsList.append(ingredient)
                        }
                    }
                }
            }
            
            print(trimmedLines)
            print(ingredientsList)
            
            // Return statements
            if ingredientsList.isEmpty {
                return nil
            } else {
                if totalCost != nil {
                    return Receipt(ingredients: ingredientsList, total: totalCost!)
                } else {
                    // No subtotal was found, calculate our own subtotal
                    var total = Price(cost: 0.00, currency: ingredientsList[0].price.currency)
                    for ingredient in ingredientsList {
                        total.cost += ingredient.price.cost
                    }
                    return Receipt(ingredients: ingredientsList, total: total)
                }
            }
        }
    }
    
    func getSubtotal(line: String) -> Price? {
        let keywords: Array<String> = ["subtotal"]
        
        for word in keywords {
            if line.lowercased().contains(word.lowercased()) {
                if let total = getPrice(line: line) {
                    return total
                }
            }
        }
        return nil
    }
    
    func getIngredient(line: String) -> Ingredient? {
        // This line has a cost, so it must have an item associated with it, therefore, call getItem on the line
        if let price = getPrice(line: line), let item = getItem(line: line) {
            return Ingredient(name: item, price: price)
        } else {
            return nil
        }
    }
    
    func getItem(line: String) -> String? {
        if let cost = getPrice(line: line) {
            // Cost is not nil! So you can get an item from the line
            var item: String?
            let lineBySpaces = line.components(separatedBy: " ")
            var costWord: String = ""
            
            for word in lineBySpaces {
                if word.contains(cost.currency) || Float(word) == cost.cost {
                    costWord = word
                }
            }
            
            item = line.replacingOccurrences(of: costWord, with: "").trimmingCharacters(in: .whitespaces)
            
            return item
            
        } else {
            return nil
        }
    }
    
    func getPrice(line: String) -> Price? {
        let ignores = ["special", "kg"] // Ignore any line with these words in it, all lower case
        let locale = Locale.current
        let currencySymbol = locale.currencySymbol!
        let keywords = ["$", "£", "€", currencySymbol] // Checks if there are numbers after these symbols
        
        // Default price
        var cost: Float?
        var currency: String?
        
        // Check if there are ignores and do not do anything with these lines
        for word in ignores {
            if line.lowercased().contains(word.lowercased()) {
                return nil
            }
        }
        
        // Continue processing because everything is G
        let lineBySpaces = line.components(separatedBy: " ")
        
        for word in lineBySpaces {
            for keyword in keywords {
                if word.contains(keyword) {
                    currency = keyword
                    
                    // Replace the dollar signs with an empty string and check if the following characters form a number
                    let costString = word.replacingOccurrences(of: keyword, with: "", options: NSString.CompareOptions.literal, range:nil)
                    if Float(costString) != nil {
                        cost = Float(costString)
                    }
                }
                  else if Float(word) != nil { // Also check if the word itself is a price
                    // No currency provided, so use locale currency
                    currency = currencySymbol
                    cost = Float(word)
                }
            }
        }
        
        // Check for errors in OCR of price and correct
        if cost != nil {
            let cost = cost!
            if floor(cost) == cost && cost.truncatingRemainder(dividingBy: 10.0) != Float(0) && currency != nil {
                return Price(cost: cost/100, currency: currency!)
            }
        }
        
        if cost != nil && currency != nil {
            return Price(cost: cost!, currency: currency!)
        } else {
            return nil
        }
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
