//
//  ContactUS.swift
//  SarmanFarms
//
//  Created by Ali Murad on 30/06/2023.
//

import UIKit
import JGProgressHUD


class ContactUS: UIViewController, UITextViewDelegate {
    
    @IBOutlet var textView: UITextView!
    @IBOutlet var name: UITextField!
    @IBOutlet var email: UITextField!
    let hud = JGProgressHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Contact Us"
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.gray.cgColor
        textView.delegate = self
        textView.text = "Write a message"
        textView.textColor = UIColor.lightGray
        hud.textLabel.text = "Loading"
    }
    func textViewDidBeginEditing(_ textView: UITextView) {

        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {

        if textView.text == "" {

            textView.text = "Write a message"
            textView.textColor = UIColor.lightGray
        }
    }
    
    @IBAction func submit(_ sender: UIButton) {
        hud.show(in: view)
        submitRequest(name: name.text!, email: email.text! , message: textView.text!) {message in
            
            DispatchQueue.main.async {
                self.hud.dismiss()
                let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                    
                    // Add an action
                    let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
                        // Handle OK button tap
                        self.textView.text = ""
                        self.name.text = ""
                        self.email.text = ""
                    }
                    alertController.addAction(okAction)
                    
                    
                    // Present the alert controller
                    if let topViewController = UIApplication.shared.keyWindow?.rootViewController {
                        topViewController.present(alertController, animated: true, completion: nil)
                    }
            }
        }
    }
    

    func submitRequest(name: String, email: String, message: String, completion: @escaping(String)-> Void) {
        let url = URL(string: "https://www.sarmanfarms.com/wp-admin/admin-ajax.php")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Set request headers
        request.setValue("application/json, text/javascript, */*; q=0.01", forHTTPHeaderField: "Accept")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("en-GB,en-US;q=0.9,en;q=0.8", forHTTPHeaderField: "Accept-Language")
        request.setValue("multipart/form-data; boundary=----WebKitFormBoundaryXRBuqPnH20JRIvDB", forHTTPHeaderField: "Content-Type")
        request.setValue("woosw_key_ori=5L20GZ; woosw_key=ZE5F5Z", forHTTPHeaderField: "Cookie")
        request.setValue("https://www.sarmanfarms.com", forHTTPHeaderField: "Origin")
        request.setValue("https://www.sarmanfarms.com/contact/", forHTTPHeaderField: "Referer")
        request.setValue("\"Not.A/Brand\";v=\"8\", \"Chromium\";v=\"114\", \"Google Chrome\";v=\"114\"", forHTTPHeaderField: "Sec-Ch-Ua")
        request.setValue("?0", forHTTPHeaderField: "Sec-Ch-Ua-Mobile")
        request.setValue("\"macOS\"", forHTTPHeaderField: "Sec-Ch-Ua-Platform")
        request.setValue("empty", forHTTPHeaderField: "Sec-Fetch-Dest")
        request.setValue("cors", forHTTPHeaderField: "Sec-Fetch-Mode")
        request.setValue("same-origin", forHTTPHeaderField: "Sec-Fetch-Site")
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36", forHTTPHeaderField: "User-Agent")
        request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        
        // Set request body (form data)
        let formData = """
        ------WebKitFormBoundaryXRBuqPnH20JRIvDB
        Content-Disposition: form-data; name="post_id"

        464
        ------WebKitFormBoundaryXRBuqPnH20JRIvDB
        Content-Disposition: form-data; name="form_id"

        a9d9a45
        ------WebKitFormBoundaryXRBuqPnH20JRIvDB
        Content-Disposition: form-data; name="referer_title"

        Contact - SarmanFarms
        ------WebKitFormBoundaryXRBuqPnH20JRIvDB
        Content-Disposition: form-data; name="queried_id"

        464
        ------WebKitFormBoundaryXRBuqPnH20JRIvDB
        Content-Disposition: form-data; name="form_fields[name]"

        \(name)
        ------WebKitFormBoundaryXRBuqPnH20JRIvDB
        Content-Disposition: form-data; name="form_fields[email]"

        \(email)
        ------WebKitFormBoundaryXRBuqPnH20JRIvDB
        Content-Disposition: form-data; name="form_fields[message]"

        \(message)
        ------WebKitFormBoundaryXRBuqPnH20JRIvDB
        Content-Disposition: form-data; name="action"

        elementor_pro_forms_send_form
        ------WebKitFormBoundaryXRBuqPnH20JRIvDB
        Content-Disposition: form-data; name="referrer"

        https://www.sarmanfarms.com/contact/
        ------WebKitFormBoundaryXRBuqPnH20JRIvDB--
        """
        
        request.httpBody = formData.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion("Thank you for contacting us")
                return
            }
            
            // Process the response data
            if let data = data {
                if let responseString = String(data: data, encoding: .utf8) {
                    completion("You request is successfully received")
                }
            }
        }
        
        task.resume()
    }

    
    
}
