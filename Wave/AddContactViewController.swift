//
//  AddContactViewController.swift
//  Wave
//
//  Created by Kunal Agarwal on 4/13/19.
//  Copyright © 2019 Kunal Agarwal. All rights reserved.
//

import UIKit
import Contacts

class AddContactViewController: UIViewController {
    
    let contact = CNMutableContact()
    
    var finalContact = [String:Any]()

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var birthdateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        cardView.layer.cornerRadius = 8
        let gradient = CAGradientLayer()
        addButton.layer.cornerRadius = 5;
        addButton.backgroundColor = UIColor(white: 0, alpha: 0)
        addButton.layer.borderColor = UIColor.white.cgColor
        addButton.layer.borderWidth = 3
        
        gradient.frame = view.bounds
        gradient.colors = [UIColor(red: 38.0/255.0, green: 1.0, blue: 229.0/255.0, alpha: 1.0).cgColor as CGColor,UIColor(red: 17.0/255.0, green: 149.0/255.0, blue: 1.0, alpha: 1.0).cgColor as CGColor]
        
        self.view.layer.insertSublayer(gradient, at: 0)

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(Thread.current)
        nameLabel.text = (finalContact["firstname"] as? String ?? "") + (finalContact["lastname"] as? String ?? "")
        emailLabel.text = (finalContact["email"] as? String ?? "")
        phoneLabel.text = (finalContact["mobile"] as? String ?? "")
        addressLabel.text = (finalContact["address"] as? String ?? "")
        birthdateLabel.text = (finalContact["birthdate"] as? String ?? "")
        reloadInputViews()
    }
    

    @IBAction func onAdd(_ sender: Any) {
        
        contact.givenName = nameLabel.text ?? ""
        contact.familyName = "Appleseed"
        let workEmail = CNLabeledValue(label:"Email  ID", value:(emailLabel.text ?? "") as NSString)
        contact.emailAddresses = [workEmail]
        
        let homeAddress = CNMutablePostalAddress()
        let addrs = addressLabel.text
        homeAddress.street = addrs ?? ""
        homeAddress.city = ""
        homeAddress.state = ""
        homeAddress.postalCode = ""
        contact.postalAddresses = [CNLabeledValue(label:CNLabelHome, value:homeAddress)]

        let bday = birthdateLabel.text ?? ""
        if(bday != ""){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateobj = dateFormatter.date(from: bday)
        let birthday = NSDateComponents()
        birthday.day = Calendar.current.component(.day, from: dateobj!)
        birthday.month = Calendar.current.component(.month, from: dateobj!)
        birthday.year = Calendar.current.component(.year, from: dateobj!)  // You can omit the year value for a yearless birthday
        contact.birthday = birthday as DateComponents
        }
        contact.phoneNumbers = [CNLabeledValue(
            label:CNLabelPhoneNumberiPhone,
            value:CNPhoneNumber(stringValue:"(408) 555-0126"))]
        
        let store = CNContactStore()
        let saveRequest = CNSaveRequest()
        saveRequest.add(contact, toContainerWithIdentifier:nil)
        try! store.execute(saveRequest)
        
        self.dismiss(animated: true, completion: nil)
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
