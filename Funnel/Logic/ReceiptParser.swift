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
        if string.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return []
        } else {
            isReceipt = true
            return []
        }
    }
}