//
//  ViewController.swift
//  Nano Challenge 2
//
//  Created by Stefandi Glivert on 17/09/19.
//  Copyright © 2019 Stefandi Glivert. All rights reserved.
//

import UIKit
import LocalAuthentication
import CoreLocation
import UserNotifications

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITextViewDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return  pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(deviceTextField.isEditing){
            deviceTextField.text = pickerData[row]
        }else if(device2TextField.isEditing){
            device2TextField.text = pickerData[row]
        }else if(device3TextField.isEditing){
            device3TextField.text = pickerData[row]
        }
    }
    
    @IBOutlet weak var startDate: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var genderSegmented: UISegmentedControl!
    @IBOutlet weak var reasonTextView: UITextView!
    @IBOutlet weak var deviceTextField: UITextField!
    @IBOutlet weak var device2TextField: UITextField!
    @IBOutlet weak var device3TextField: UITextField!
    @IBOutlet weak var sessionSegmented: UISegmentedControl!
    @IBOutlet weak var endDate: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBAction func submitButton(_ sender: UIButton) {
        if (nameTextField.text == "")
        {
            messageLabel.text = "Fill your Name!"
        }
        else if(nameTextField.text!.count > 25)
        {
            messageLabel.text = "Name cannot be more than 25 Characters"
        }
        else if(deviceTextField.text == "")
        {
            messageLabel.text = "You must fill Device 1"
        }
        else if(device2TextField.text == deviceTextField.text)
        {
            messageLabel.text = "You cannot fill the same device!"
        }
        else if(device2TextField.text != "" && device3TextField.text == device2TextField.text)
        {
             messageLabel.text = "You cannot fill the same device!"
        }
        else if(device3TextField.text == deviceTextField.text)
        {
             messageLabel.text = "You cannot fill the same device!"
        }
        else if(startDate.text == "")
        {
            messageLabel.text = "Fill your Start Date!"
        }
        else if (endDate.text == "")
        {
            messageLabel.text = "Fill your End Date!"
        }
        else if(dateEnd <= dateStart)
        {
            messageLabel.text = "Check Your End Date!!"
        }
        else if(reasonTextView.text == "")
        {
            messageLabel.text = "Enter The Reason!"
        }
        else
        {
            messageLabel.text = ""
            if (auth == false)
            {
                let alert = UIAlertController(title: "Warning", message: "You Must Be Inside Academy To Borrow Device", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else
            {
                let context:LAContext = LAContext()
                
                if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
                {
                    context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Scan To Submit the Form") { (good, error) in
                        if good
                        {
                            print("Success")
                        }
                        else
                        {
                            print("Try Again")
                        }
                    }
                }
            }
        }
    }
    var myPickerView : UIPickerView!
    
    var pickerData = ["Ipad","Ipad Pro", "Airpods", "Apple Watch Series 3 42mm", "Apple Watch Series 4 40mm", "Apple Watch Series 4 44mm", "Apple Pencil"]
    
    let datePicker = UIDatePicker()
    
    var dateStart:Date!
    var dateEnd:Date!
    let locationManager: CLLocationManager = CLLocationManager()
    var auth:Bool = false
    var curretLocation: CLLocation!
    var geoFenceRegion: CLCircularRegion!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitBtn.layer.cornerRadius = 16
       reasonTextView.layer.borderWidth = 0.5
        reasonTextView.layer.borderColor = UIColor.gray.cgColor
        requestPermissionNotifications()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 50
        
        geoFenceRegion = CLCircularRegion(center: CLLocationCoordinate2DMake(-6.302122, 106.652183), radius: 50, identifier: "Apple Academy")
        
        locationManager.startMonitoring(for: geoFenceRegion)
        
//        detectUser()
        showDatePicker()
        self.pickUp(deviceTextField)
        self.pickUp(device2TextField)
        self.pickUp(device3TextField)
        nameTextField.delegate = self
        reasonTextView.delegate = self
    }
    func detectUser()
    {
        if( CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways)
        {
            curretLocation = locationManager.location
        }
        let distanceInMeters = curretLocation.distance(from: CLLocation(latitude: (geoFenceRegion?.center.latitude)!, longitude: (geoFenceRegion?.center.longitude)!))
        if(distanceInMeters <= geoFenceRegion.radius/2)
            {
                auth = true
            }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for currentLocation in locations
        {
            print("\(String(describing: index)): \(currentLocation)")
        }
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Entered : \(region.identifier)")
        postLocalNotifications(eventTitle : "Entered: \(region.identifier)", body: "Hello")
        auth = true
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exited : \(region.identifier)")
        postLocalNotifications(eventTitle : "Exited: \(region.identifier)", body: "See You Next Time")
        auth = false
    }
    func requestPermissionNotifications(){
        let application =  UIApplication.shared
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (isAuthorized, error) in
                if( error != nil ){
                    print(error!)
                }else{
                    if( isAuthorized ){
                        print("authorized")
                        NotificationCenter.default.post(Notification(name: Notification.Name("AUTHORIZED")))
                        self.detectUser()
                    }else{
                        let pushPreference = UserDefaults.standard.bool(forKey: "PREF_PUSH_NOTIFICATIONS")
                        if pushPreference == false {
                            let alert = UIAlertController(title: "Turn on Notifications", message: "Push notifications are turned off.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Turn on notifications", style: .default, handler: { (alertAction) in
                                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                    return
                                }
                                
                                if UIApplication.shared.canOpenURL(settingsUrl) {
                                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                        // Checking for setting is opened or not
                                        print("Setting is opened: \(success)")
                                        self.detectUser()
                                    })
                                }
                                UserDefaults.standard.set(true, forKey: "PREF_PUSH_NOTIFICATIONS")
                            }))
                            alert.addAction(UIAlertAction(title: "No thanks.", style: .default, handler: { (actionAlert) in
                                print("user denied")
                                UserDefaults.standard.set(true, forKey: "PREF_PUSH_NOTIFICATIONS")
                            }))
                            let viewController = UIApplication.shared.keyWindow!.rootViewController
                            DispatchQueue.main.async {
                                viewController?.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
        else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
    }
    
    func postLocalNotifications(eventTitle:String, body:String){
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = eventTitle
        content.body = body
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let notificationRequest:UNNotificationRequest = UNNotificationRequest(identifier: "Region", content: content, trigger: trigger)
        
        center.add(notificationRequest, withCompletionHandler: { (error) in
            if let error = error {
                // Something went wrong
                print(error)
            }
            else{
                print("added")
            }
        })
    }
    
    func showDatePicker(){
        //Formate Date
        datePicker.datePickerMode = .date
        
        //ToolBar
        let toolbarStart = UIToolbar();
        let toolbarEnd = UIToolbar();
        toolbarStart.sizeToFit()
        toolbarEnd.sizeToFit()
        let doneStart = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(startDatePicker));
        let doneEnd = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(endDatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButtonStart = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        let cancelButtonEnd = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbarStart.setItems([cancelButtonStart,spaceButton,doneStart], animated: false)
        toolbarEnd.setItems([cancelButtonEnd,spaceButton,doneEnd], animated: false)
        
        startDate.inputAccessoryView = toolbarStart
        startDate.inputView = datePicker
        
        endDate.inputAccessoryView = toolbarEnd
        endDate.inputView = datePicker
    }
    
    @objc func startDatePicker(){
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        startDate.text = formatter.string(from: datePicker.date)
        dateStart = datePicker.date
        self.view.endEditing(true)
    }
    
    @objc func endDatePicker(){
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        endDate.text = formatter.string(from: datePicker.date)
        dateEnd = datePicker.date
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }

    func pickUp(_ textField : UITextField){
        
        // UIPickerView
        self.myPickerView = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.myPickerView.delegate = self
        self.myPickerView.dataSource = self
        self.myPickerView.backgroundColor = UIColor.white
        textField.inputView = self.myPickerView
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(ViewController.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(ViewController.cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
        
    }
    
    @objc func doneClick() {
        deviceTextField.resignFirstResponder()
        device2TextField.resignFirstResponder()
        device3TextField.resignFirstResponder()
    }
    @objc func cancelClick() {
        deviceTextField.resignFirstResponder()
        device2TextField.resignFirstResponder()
        device3TextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
            return true
        }
        return true
    }

}

