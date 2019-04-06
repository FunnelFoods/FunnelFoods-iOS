//
//  ReceiptParser.swift
//  Funnel
//
//  Created by Shao-Qian Mah on 5/4/19.
//  Copyright © 2019 Funnel. All rights reserved.
//

import UIKit

class ReceiptParser: NSObject {
   
    // Defaults to not a receipt
    var isReceipt = false
    
    func parse(string: String) -> Array<Any> {
        // Trim all white spaces and newlines away
        if (string.trimmingCharacters(in: .whitespacesAndNewlines) == "" || string == "Empty page!!") {
            return []
        } else {
            // Do additional processing
            isReceipt = true
            return []
        }
    }
}
