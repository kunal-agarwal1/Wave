//
//  InitialViewController.swift
//  Wave
//
//  Created by Kunal Agarwal on 4/13/19.
//  Copyright © 2019 Kunal Agarwal. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {
    
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var bdTextField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var mobileField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var firstNameField: UITextField!
    let datePicker = UIDatePicker()

    var data = [String:String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        showDatePicker()

        let gradient = CAGradientLayer()
        
        goButton.layer.cornerRadius = 5;
        goButton.backgroundColor = UIColor(white: 0, alpha: 0)
        goButton.layer.borderColor = UIColor.white.cgColor
        goButton.layer.borderWidth = 3
        goButton.titleLabel?.text = "Login"
        
        gradient.frame = view.bounds
        gradient.colors = [UIColor(red: 38.0/255.0, green: 1.0, blue: 229.0/255.0, alpha: 1.0).cgColor as CGColor,UIColor(red: 17.0/255.0, green: 149.0/255.0, blue: 1.0, alpha: 1.0).cgColor as CGColor]
        
        self.view.layer.insertSublayer(gradient, at: 0)
        // Do any additional setup after loading the view.
    }
    
 

    func showDatePicker(){
        //Formate Date
        datePicker.datePickerMode = .date
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        bdTextField.inputAccessoryView = toolbar
        bdTextField.inputView = datePicker
        
    }
    
    @objc func donedatePicker(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        bdTextField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: "Is Logged In") == true
        {
            self.performSegue(withIdentifier: "LoginSegue", sender: self)
        }
    }
    
    @IBAction func onDismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    @IBAction func onLogin(_ sender: Any) {
        if(firstNameField.text != "")
        {
            if(lastNameField.text != "")
            {
                if(mobileField.text != "")
                {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd/MM/yyyy"
                    var date = bdTextField.text
                    if date == formatter.string(from: Date())
                    {
                        date = ""
                    }
                    let save = UserDefaults.standard
                    data = ["firstname":firstNameField.text!,
                            "lastname":lastNameField.text!,
                            "mobile":mobileField.text!,
                            "email":emailField.text!,
                            "address":addressField.text!,
                            "birthdate":date
                        ] as! [String:String]
                    print(data)
                    
                    save.set(data, forKey: "user contact info")
                    save.set(true, forKey: "Is Logged In")
                    submitAction()

                }
                else
                {
                    let alertController = UIAlertController(title: "Alert", message:
                        "Please enter a phone number", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: .default))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            else
            {
                let alertController = UIAlertController(title: "Alert", message:
                    "Please enter your Last name", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .default))
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
        else
        {
            let alertController = UIAlertController(title: "Alert", message:
                "Please enter your First Name", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func submitAction() {
        print("ENTER CREATE USER")
        //declare parameter as a dictionary which contains string as key and value combination. considering inputs are valid
        
        
        let jsonData = try? JSONSerialization.data(withJSONObject: data)

        //create the url with URL
        let url = URL(string: "https://97515a89.ngrok.io/v1/createuser?json=")! //change the url
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // insert json data to the request
        request.httpBody = jsonData
        
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
                let uniqueid = responseJSON["id"]
                let save = UserDefaults.standard
                save.set(uniqueid, forKey: "user unique id")
                save.set(true, forKey: "Is Logged In")
                self.performSegue(withIdentifier: "LoginSegue", sender: self)

            }
        }
        
        task.resume()
     
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
