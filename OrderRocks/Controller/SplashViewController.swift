//
//  SplashViewController.swift
//  OrderRocks
//
//  Created by user on 01/02/2021.
//

import UIKit

class SplashViewController: UIViewController {
    @IBOutlet var imgFullLogo: UIImageView!
    @IBOutlet var imgLogo: UIImageView!
    @IBOutlet var imgWidth: NSLayoutConstraint!
    @IBOutlet var imgheight: NSLayoutConstraint!
    @IBOutlet var imgX: NSLayoutConstraint!

    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imgLogo.isHidden = true
        self.imgFullLogo.isHidden = false
        self.navigationController?.navigationBar.isHidden = true
        UIView.animate(withDuration: 1.0, animations: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                UIView.transition(with: self.imgLogo, duration: 1.0, options: .transitionCrossDissolve, animations: {
                    self.imgLogo.isHidden = false
                })
                UIView.transition(with: self.imgFullLogo, duration: 1.0, options: .transitionCrossDissolve, animations: {
                    self.imgFullLogo.isHidden = true
                })
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    UIView.animate(withDuration: 1.0) {
                        self.imgWidth.constant = 200.0
                        self.imgheight.constant = 200.0
                        self.imgX.constant = 0.0
                        self.view.layoutIfNeeded()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.MoveToView()
                    }
                }
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

