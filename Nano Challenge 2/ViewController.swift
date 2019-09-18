//
//  ViewController.swift
//  Nano Challenge 2
//
//  Created by Stefandi Glivert on 17/09/19.
//  Copyright © 2019 Stefandi Glivert. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    
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
        deviceTextField.text = pickerData[row]
    }
    
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        self.pickUp(deviceTextField)
//    }
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
    @IBAction func submitButton(_ sender: UIButton) {
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
    var myPickerView : UIPickerView!
    
    var pickerData = ["Ipad","Ipad Pro", "Airpods", "Apple Watch Series 3 42mm", "Apple Watch Series 4 40mm", "Apple Watch Series 4 44mm", "Apple Pencil"]
    
    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitBtn.layer.cornerRadius = 16
       reasonTextView.layer.borderWidth = 0.5
        reasonTextView.layer.borderColor = UIColor.gray.cgColor
        showDatePicker()
        self.pickUp(deviceTextField)
        self.pickUp(device2TextField)
        self.pickUp(device3TextField)
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
        self.view.endEditing(true)
    }
    
    @objc func endDatePicker(){
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        endDate.text = formatter.string(from: datePicker.date)
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

}

