//
//  RegistrationViewController.swift
//  Avalon-Print
//
//  Created by Roman Mizin on 12/17/16.
//  Copyright © 2016 Roman Mizin. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController {
    
    @IBOutlet weak var nameTFHeight: NSLayoutConstraint!
    @IBOutlet weak var numTFHeight: NSLayoutConstraint!
    @IBOutlet weak var mailTFHeight: NSLayoutConstraint!
    @IBOutlet weak var passTFHeight: NSLayoutConstraint!
    @IBOutlet weak var repeatPassTFHeight: NSLayoutConstraint!
    @IBAction func closeRegistrationPage(_ sender: Any) {
        dismiss(animated: true, completion: nil)

    }

    
    @IBOutlet var mainView: UIView!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    let noInternet = UIAlertController(title: "Ошибка регистрации", message: "Нету подключения к интернету", preferredStyle: UIAlertControllerStyle.alert )
    
    let invalidEmail = UIAlertController(title: "Ошибка регистрации", message: "Данный E-mail уже используется", preferredStyle: UIAlertControllerStyle.alert )
    
    let regSuccessful = UIAlertController(title: "", message: "Регистрация прошла успешно, можете выполнить вход", preferredStyle: UIAlertControllerStyle.alert )


    @IBOutlet weak var nameSurname: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var repeatPassword: UITextField!
    
    @IBOutlet weak var registrationButton: ButtonMockup!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        if screenSize.height < 667 {
            nameTFHeight.constant = 40
            numTFHeight.constant = 40
            mailTFHeight.constant = 40
            passTFHeight.constant = 40
            repeatPassTFHeight.constant = 40
            
            nameSurname.font = UIFont(name: "HelveticaNeue-Light", size: 14)
            phoneNumber.font = UIFont(name: "HelveticaNeue-Light", size: 14)
            email.font = UIFont(name: "HelveticaNeue-Light", size: 14)
            password.font = UIFont(name: "HelveticaNeue-Light", size: 14)
            repeatPassword.font = UIFont(name: "HelveticaNeue-Light", size: 14)
            
            
        }
        if screenSize.height == 736 {
            nameTFHeight.constant = 55
            numTFHeight.constant = 55
            mailTFHeight.constant = 55
            passTFHeight.constant = 55
            repeatPassTFHeight.constant = 55
            
        }
        
        noInternet.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: { action in
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
        }))
        
        invalidEmail.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: { action in
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
        }))
        
        regSuccessful.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: { action in
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            self.dismiss(animated: true, completion: nil)
        }))

    }
    
    
    @IBAction func nameSurnameEditingChanged(_ sender: Any) {  validateRegistraionData() }
    @IBAction func phoneNumberEditingChanged(_ sender: Any) { validateRegistraionData() }
    @IBAction func emailEditingChanged(_ sender: Any) { validateRegistraionData() }
    @IBAction func passwordEditingChanged(_ sender: Any) { validateRegistraionData() }
    @IBAction func repeatPassEditingChanged(_ sender: Any) { validateRegistraionData() }
    
    
   func validateRegistraionData () {
    let characterSetEmail = NSCharacterSet(charactersIn: "@")
    let characterSetEmail1 = NSCharacterSet(charactersIn: ".")
    let badCharacterSetEmail = NSCharacterSet(charactersIn: "!`~,/?|'\'';:#^&*=")
    let badCharacterSetPhoneNumber = NSCharacterSet(charactersIn: "@$%.><!`~,/?|'\'';:#^&*=_+{}[]")

    
     if (nameSurname.text?.characters.count)! < 2 ||
        (phoneNumber.text?.characters.count)! < 10 ||
        (phoneNumber.text?.characters.count)! > 12 ||
         phoneNumber.text?.rangeOfCharacter(from: badCharacterSetPhoneNumber as CharacterSet, options: .caseInsensitive ) != nil ||
        (email.text?.characters.count)! < 5 ||
         email.text?.rangeOfCharacter(from: characterSetEmail as CharacterSet, options: .caseInsensitive ) == nil ||
         email.text?.rangeOfCharacter(from: characterSetEmail1 as CharacterSet, options: .caseInsensitive ) == nil ||
         email.text?.rangeOfCharacter(from: badCharacterSetEmail as CharacterSet, options: .caseInsensitive ) != nil ||
        (password.text?.characters.count)! < 6 ||
        (password.text != repeatPassword.text) {
        
         registrationButton.isEnabled = false
        
        UIView.animate(withDuration: 0.5, animations: {
            self.registrationButton.alpha = 0.6 })
        
     } else {
        registrationButton.isEnabled = true;
        
        UIView.animate(withDuration: 0.5, animations: {
            self.registrationButton.alpha = 1.0 })
       }
}
    
    
    @IBAction func doRegistrate(_ sender: Any) {
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        
        var request = URLRequest(url: URL(string: "http://mizin-dev.com/registration_api.php")!)
        request.httpMethod = "POST"
        let postString = "name=\(nameSurname.text!)&email=\(email.text!)&password=\(password.text!)&phone_number=\(phoneNumber.text!)"
        
        request.httpBody = postString.data(using: .utf8)
        
        let task1 = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print("ERROR")
               
                UIApplication.shared.endIgnoringInteractionEvents()
                self.present(self.noInternet, animated: true, completion: nil)
                
                
            } else {
                if let content = data {
                    do {
                        
                        let user = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        
                        let phpAnswer = user["result"] as! String
                        let successfull = "OK"
                        let emailAlreadyUsed = "EMAIL_ALREADY_USED"
                        
                        if (phpAnswer == emailAlreadyUsed) {
                            
                            print("EmailAlreadyUsed", "result", user["result"] as Any)
                            UIApplication.shared.endIgnoringInteractionEvents()
                            self.present(self.invalidEmail, animated: true, completion: nil)
                            
                        } else
                    
                        if (phpAnswer == successfull) {
                            UIApplication.shared.endIgnoringInteractionEvents()
                            self.present(self.regSuccessful, animated: true, completion: nil)

                            
                            print("\n\nSuccessfully  registered   ", "  result",  user["result"] as Any, "\n\n")
                            
                        } else { print("****Some shit happened****") }
                        
                    }
                        
                    catch {}
                    
                } else { print("****Something went wrong****") }//if let content
            }
        }//task1
        task1.resume()
  
    }

    
    
    @IBAction func undo(_ sender: Any) {
           dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func closeKeyboard() {
        self.view.endEditing(true)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        closeKeyboard()
    }
}
