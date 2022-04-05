//
//  RetryScanView.swift
//  OrderRocks
//
//  Created by MAC on 07/06/21.
//

import Foundation
import UIKit

class RetryScanView: UIView {
    
    // Mark:- Outlets
    @IBOutlet weak var PopUpView: UIView!
    
    @IBOutlet weak var btnOpenCamera: UIButton!
    // Mark:- IBAction
    
    @IBAction func OpenCamera(_ sender: Any) {
        self.PopUpView.removeFromSuperview()
    }
}

