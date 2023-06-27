//
//  Settings.swift
//  Mobile Airtime
//
//  Created by Ali Murad on 11/06/2023.
//

import UIKit

class Settings: UITableViewController, UITextFieldDelegate {
    @IBOutlet var swi: UISwitch!
    
    
    @IBOutlet weak var label: TappableLabel!
    @IBOutlet weak var terms: TappableLabel!
    @IBOutlet weak var pri: TappableLabel!
    
    
    
    override func viewDidLoad() {
        self.navigationItem.title = "Settings"
        
        swi.setOn(UserDefaults.standard.showNotification, animated: true)
        updateView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 85
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Hide the keyboard

    return    true
    }
    @objc func textFieldDidChange(_ textField: UITextField) {
        
     
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        
        _ = NSMutableAttributedString(attributedString: label.attributedText!)
        
        label.isUserInteractionEnabled = true
        terms.isUserInteractionEnabled = true
        pri.isUserInteractionEnabled = true
        
        terms.onTapped = {
            UIApplication.shared.open(URL(string: "https://www.sarmanfarms.com/about/")!, options: [:], completionHandler: nil)
        }
        pri.onTapped = {
            UIApplication.shared.open(URL(string: "https://www.sarmanfarms.com/privacy-policy/")!, options: [:], completionHandler: nil)
        }
        
    


        
        super.viewWillAppear(animated)
        swi.setOn(UserDefaults.standard.showNotification, animated: true)
    }
    
    
    
    
    @IBAction func call(_ sender: UIButton) {
        let phoneNumber = sender.titleLabel?.text ?? "09163090893" // Replace with the desired phone number
               
               if let phoneURL = URL(string: "tel:\(phoneNumber)") {
                   if UIApplication.shared.canOpenURL(phoneURL) {
                       UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
                   } else {
                       // Handle error: Unable to make a phone call
                   }
               }
    }
    
    @IBAction func switchChange(_ sender: Any) {
        UserDefaults.standard.showNotification = (sender as! UISwitch).isOn
        updateView()
    }
    @IBAction func bioSwitchChange(_ sender: Any) {
        UserDefaults.standard.isBiomaticOn = (sender as! UISwitch).isOn
        updateView()
        
    }
    
    func updateView() {
        UIView.animate(withDuration: 0.3) {
        }
        tableView.reloadData()
    }
    
}

class TappableLabel: UILabel {
    var onTapped: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureGestureRecognizer()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureGestureRecognizer()
    }

    private func configureGestureRecognizer() {
        isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped(_:)))
        addGestureRecognizer(tapGesture)
    }

    @objc private func labelTapped(_ gesture: UITapGestureRecognizer) {
        onTapped?()
    }
}
