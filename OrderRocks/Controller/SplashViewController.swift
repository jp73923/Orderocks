//
//  SplashViewController.swift
//  OrderRocks
//
//  Created by user on 01/02/2021.
//

import UIKit

class SplashViewController: UIViewController {
    @IBOutlet var centerConstant: NSLayoutConstraint!
    @IBOutlet var imgFullLogo: UIImageView!
    @IBOutlet var imgLogo: UIImageView!

    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        UIView.animate(withDuration: 1.5, animations: {
            self.centerConstant.constant = -30.0
            self.view.layoutIfNeeded()
        }, completion: { bool in
            self.imgLogo.isHidden = true
            self.imgFullLogo.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.MoveToView()
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: - Custom Functions
    @objc func MoveToView() {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        self.navigationController!.pushViewController(VC, animated: false)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}

