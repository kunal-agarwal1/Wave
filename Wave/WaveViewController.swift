//
//  WaveViewController.swift
//  Wave
//
//  Created by Kunal Agarwal on 4/13/19.
//  Copyright © 2019 Kunal Agarwal. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion
import AudioToolbox


class WaveViewController: UIViewController, CLLocationManagerDelegate {
    
    var data = [String:Any]()
    var locationManager = CLLocationManager()
    var motionManager = CMMotionManager()
    var data2 = [String:Any]()
    var finalcontact = [String: Any]()
    var review = false
    
    @IBOutlet weak var logOutButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradient = CAGradientLayer()
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")

        logOutButton.layer.cornerRadius = 5;
        logOutButton.backgroundColor = UIColor(white: 0, alpha: 0)
        logOutButton.layer.borderColor = UIColor.white.cgColor
        logOutButton.layer.borderWidth = 3
        logOutButton.titleLabel?.text = "Logout"

        
        gradient.frame = view.bounds
        gradient.colors = [UIColor(red: 38.0/255.0, green: 1.0, blue: 229.0/255.0, alpha: 1.0).cgColor as CGColor,UIColor(red: 17.0/255.0, green: 149.0/255.0, blue: 1.0, alpha: 1.0).cgColor as CGColor]
        
        self.view.layer.insertSublayer(gradient, at: 0)
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()

      //  locationManager.delegate = self

        // For use in foreground
       // self.locationManager.requestWhenInUseAuthorization()

        // Do any additional setup after loading the view.
    }
    
   override func viewDidAppear(_ animated: Bool) {
    print("view did appear")
    senseAcc()
    }
    
    func senseAcc()
    {
        motionManager.accelerometerUpdateInterval = 0.05
        var wave = 0
        var register = true
        var sign = true
        var ox = 0.0
        
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) {(data1,error) in
            if let mydata = data1{
                let x = mydata.acceleration.x
                _ = mydata.acceleration.y
                _ = mydata.acceleration.z
                
                //  print("X VAL: \(x) Y VAL: \(y) Z VAL: \(z)")
                if(register &&  ((ox - x) <= -1.8) || ((ox - x) >= 1.8))
                {
                    wave = wave + 1;
                    print(wave)
                    register = false
                    if(mydata.acceleration.x >= 0.0)
                    {
                        sign = true
                    }
                    else{
                        sign = false
                    }
                }
                if(wave > 4){
                    print("5 WAVES COMPLETE")
                    self.motionManager.stopAccelerometerUpdates()
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    
                    
                    if CLLocationManager.locationServicesEnabled() {
                        self.locationManager.delegate = self
                        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                        print("about to request locatin")
                        self.locationManager.requestLocation()
                    }
                    /*let alertController = UIAlertController(title: "WAVES DONE", message:
                     "", preferredStyle: .alert)
                     alertController.addAction(UIAlertAction(title: "Ok", style: .default))
                     
                     self.present(alertController, animated: true, completion: nil)*/
                }
                if(sign && x < 0)
                {
                    register = true
                }
                if(!sign && x > 0)
                {
                    register = true
                }
                ox = x;
            }
        }
    }
    

    
    @IBAction func onLogout(_ sender: Any) {
        let save = UserDefaults.standard
        save.set(false, forKey: "Is Logged In")
        self.motionManager.stopAccelerometerUpdates()

        self.dismiss(animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            print("Found user's location: \(location)")
        }
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZ"
        let dateStr = formatter.string(from: date)
        let save = UserDefaults.standard
        let id = (save.integer(forKey: "user unique id"))
        print(id)
        
        data = ["id": id, "lat":locValue.latitude,"long":locValue.longitude,"time" :dateStr] 
        
        print(data)
        submitWave()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
        let alertController = UIAlertController(title: "Failed to get Location", message:
            "Please try again later", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default))
        
        self.present(alertController, animated: true, completion: nil)
    }

    
    func submitWave() {
        print("ENTER WAVE ACTION")

        //declare parameter as a dictionary which contains string as key and value combination. considering inputs are valid
        
        
        let jsonData = try? JSONSerialization.data(withJSONObject: data)
        
        //create the url with URL
        let url = URL(string: "https://hackscwave.appspot.com/v1/waveaction?json=")! //change the url
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // insert json data to the request
        request.httpBody = jsonData
        
        
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Could connect to server.", message:
                        "Please try again later", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: .default))
                    self.present(alertController, animated: true, completion: nil)
                    self.senseAcc()
                }
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
                let uniqueid = responseJSON["recieveKey"]
                self.data2 = ["recieveKey":uniqueid ?? -1 , "userid": UserDefaults.standard.integer(forKey: "user unique id") ]
                self.getContact()
            }
        }
      //  self.senseAcc()

        task.resume()
        
    }
    
    func getContact() {
        print("ENTER GET CONTACT")

        //declare parameter as a dictionary which contains string as key and value combination. considering inputs are valid
        
        
        let jsonData = try? JSONSerialization.data(withJSONObject: data2)
        
        //create the url with URL
        let url = URL(string: "https://hackscwave.appspot.com/v1/getcontact?json=")! //change the url
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // insert json data to the request
        request.httpBody = jsonData
        
        print(data2)
       
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
           
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "Could connect to server.", message:
                            "Please try again later", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "Ok", style: .default))
                        self.present(alertController, animated: true, completion: nil)
                        self.senseAcc()
                }
                print(error?.localizedDescription ?? "No data")
                return
            }
            
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
           
            if let responseJSON = responseJSON as? [String: Any] {
              
                if((responseJSON["firstname"] as! String) == "~There is no one around!")
                {

                    let queue = DispatchQueue(label: "qq")
                    queue.async {
                    }
                    DispatchQueue.main.async {
                        if(!self.review)
                        {
                            Thread.sleep(forTimeInterval: 5)
                            print("second call")
                            self.review=true
                            self.getContact()
                        }
                        else{
                        let alertController = UIAlertController(title: "Could not detect a waver nearby.", message:
                            "Please try again later", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "Ok", style: .default))
                        print("its rewind time")
                        self.present(alertController, animated: true, completion: nil)
                        self.senseAcc()
                        }
                    }
                }
                else{
                let queue = DispatchQueue(label: "qq")
                queue.async {
                    self.performSegue(withIdentifier: "WavedSegue", sender: self)
                }
                DispatchQueue.main.async {
                    self.finalcontact = responseJSON
                }
                }
            }
        }
        

        task.resume()
        
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        let dest = segue.destination as! AddContactViewController
        dest.finalContact = finalcontact
        // Pass the selected object to the new view controller.
 

    }
    

}
