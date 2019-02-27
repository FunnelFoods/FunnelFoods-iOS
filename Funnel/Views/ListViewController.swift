//
//  ListViewController.swift
//  Funnel
//
//  Created by Shao-Qian Mah on 29/12/18.
//  Copyright © 2018 Funnel. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {
    
    @IBOutlet weak var buttonStackView: UIStackView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.bringSubviewToFront(buttonStackView)
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
