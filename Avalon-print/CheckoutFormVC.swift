//
//  checkoutFormVC.swift
//  Avalon-Print
//
//  Created by Roman Mizin on 12/11/16.
//  Copyright © 2016 Roman Mizin. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

var orderToFirebaseArray = [AddedItems]()

class CheckoutFormVC: UIViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    @IBOutlet weak var nameSurnameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var commentsTV: UITextView!
    @IBOutlet weak var deliveryAdress: UITextField!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var deliverySwitch: UISwitch!
    @IBOutlet weak var checkOutButton: ButtonMockup!
  
    
    var ordersCount = Int()
  
    override func viewDidLoad() {
        super.viewDidLoad()
         managedObjextContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        commentsTV.clipsToBounds = true
        commentsTV.layer.cornerRadius = 5
        
        mainScrollView.delegate = self
        nameSurnameTF.delegate = self
        emailTF.delegate = self
        phoneTF.delegate = self
        deliveryAdress.delegate = self
        
        self.hideKeyboardWhenTappedAround()

        setFontsForControllers(textfield: [nameSurnameTF,phoneTF, emailTF, deliveryAdress], textview: commentsTV, label: commentsLabel)
        
        localyRetrieveUserData()
      
      
      let countOfO = FIRDatabase.database().reference().child("orders")
      
      countOfO.observe(.value, with: { (snapshot: FIRDataSnapshot!) in
       
        print(snapshot.childrenCount)
        self.ordersCount = Int(snapshot.childrenCount)
        print(self.ordersCount)
      
      })
      
      
    }
 
    
    @IBAction func deliverySwitchStateChanged(_ sender: Any) {
        
        if deliverySwitch.isOn == true {
            
            textfieldState(textField: deliveryAdress, state: true)
          
            
        } else {
            
            textfieldState(textField: deliveryAdress, state: false)
        }
    }
    
    
    @IBAction func dismissOrder(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
  
  
  func orderSent () {
    
      let alert = UIAlertController(title: "Ваш заказ успешно отправлен",
                                    message: "Наш менеджер свяжется с вами в ближайшее время, спасибо за доверие.",
                                    preferredStyle: UIAlertControllerStyle.alert)
    
      alert.addAction(UIAlertAction(title: "Oк", style: UIAlertActionStyle.default) { UIAlertAction in
    
      self.dismiss(animated: true, completion: nil)
    })
    
    self.view.isUserInteractionEnabled = true
    self.present(alert, animated: true, completion: nil)
  }

    
    @IBAction func checkOutButtonClicked(_ sender: Any) {
  
      self.view.isUserInteractionEnabled = false
        ARSLineProgress.showWithProgress(initialValue: 0) { 
         self.view.isUserInteractionEnabled = true
         self.orderSent()
      }
     
      let date = Date()
      let calendar = Calendar.current
   
      let day = calendar.component(.day, from: date)
      let month = calendar.component(.month, from: date)
      let year = calendar.component(.year, from: date)
     
      var monthString = String()
      
      if month == 1 { monthString = "января" }
      if month == 2 { monthString = "февраля" }
      if month == 3 { monthString = "марта" }
      if month == 4 { monthString = "апреля" }
      if month == 5 { monthString = "мая" }
      if month == 6 { monthString = "июня" }
      if month == 7 { monthString = "июля" }
      if month == 8 { monthString = "августа" }
      if month == 9 { monthString = "сентября" }
      if month == 10 { monthString = "октября" }
      if month == 11 { monthString = "ноября" }
      if month == 12 { monthString = "декабря" }
      
     
      //order info
      var orderInfoBlock: FIRDatabaseReference!
      
      orderInfoBlock = FIRDatabase.database().reference().child("orders").child("Заказ № \(ordersCount + 1)")
     
      let orderInfoLabel = "orderInfo"
      let createdAtLabel = "createdAt"
      let createdAtValue = "\(date)"
      let createdAt = orderInfoBlock.child(createdAtLabel)
      createdAt.setValue(createdAtValue)
      
      var deliveryFinal = ""
      
      if deliverySwitch.isOn == true {
        deliveryFinal = deliveryAdress.text!
      } else {
       deliveryFinal =  "Без доставки"
      }
      
      
      let orderInfoContent: NSDictionary = [
                                "orderStatus": "Новый заказ",
                                "dateOfPlacement": ("\(day) \(monthString) \(year)"),
                                "fullPrice": totalprice,
                                "fullNDSPrice": totalNDSprice,
                                "comments": commentsTV.text!,
                                "deliveryAdress": deliveryFinal ]
      
      
          let orderInfo = orderInfoBlock.child(orderInfoLabel) 
      
           orderInfo.setValue(orderInfoContent)
      
      
              //user info to order info
              let userInfoToOrderInfoLabel = "userInfo"
      
              let userInfoToOrderInfoContent: NSDictionary = [ "userEmail": emailTF.text!,
                                                                "userName": nameSurnameTF.text!,
                                                                "userPhone": phoneTF.text!,
                                                                "userUniqueID": FIRAuth.auth()?.currentUser?.uid as Any ]
      
              let userInfoToOrderInfo = orderInfoBlock.child(userInfoToOrderInfoLabel)
              userInfoToOrderInfo.setValue(userInfoToOrderInfoContent)
      
      
    //works
    let worksID = "works"
      
    orderInfoBlock.child(worksID)
    
      for i in(0..<addedItems.count) {
        
        let exactOrderID = "work\(i)"
        
        let works = addedItems[i]
        
        var contentOfWork: NSDictionary = [:]
        
     if works.layoutLink != "" { /* means if it is a shopping card with layout link (without image) */
      
      contentOfWork =  [ "mainData": works.list!,
                         "price": works.price!,
                         "ndsprice": works.ndsPrice!,
                         "printLayoutURL": works.layoutLink! ]
      
      let exactOrder = orderInfoBlock.child("works").child(exactOrderID)
      
      exactOrder.setValue(contentOfWork, withCompletionBlock: { (error, ref) in
        
        ARSLineProgress.updateWithProgress(100)
        
      })
      
     } else { /* means if it is a shopping card with attached print layout image */
        
          let layoutForRow = UIImage(data: works.layoutImage! as Data)
          
          uploadToFirebaseStorageUsingImage(layoutForRow!, completion: { (imageUrl) in
            
            contentOfWork =  [ "mainData": works.list!,
                               "price": works.price!,
                               "ndsprice": works.ndsPrice!,
                               "printLayoutURL": imageUrl ]
            
            let exactOrder = orderInfoBlock.child("works").child(exactOrderID)
            
            exactOrder.setValue(contentOfWork)
            
          })
      }
    }
  }
  
  
  fileprivate var layoutLinksNumber = 0
  /* Number of shopping cards without print Layout images (with layout links) */
  fileprivate func progressCounter ()  {
    
    var layoutLinks = 0
    
    for works in addedItems {
      if works.layoutLink != "" {
        layoutLinks += 1
      }
    }

     layoutLinksNumber = layoutLinks
  }
  

  fileprivate var progressStep = addedItems.count
  fileprivate func uploadToFirebaseStorageUsingImage(_ image: UIImage, completion: @escaping (_ imageUrl: String) -> ()) {
    
    let imageName = UUID().uuidString
    let ref = FIRStorage.storage().reference().child("print_Layouts").child(imageName)
    
    if let uploadData = UIImageJPEGRepresentation(image, 1.0) {
      
      let uploadTask = ref.put(uploadData, metadata: nil, completion: { (metadata, error) in
        
        if error != nil {
          print("Failed to upload image:", error as Any)
          return
        }
        
        if let imageUrl = metadata?.downloadURL()?.absoluteString {
          completion(imageUrl)
        }
        
      })
      
       // gets num of shopping cards without print layout image
       progressCounter()
      
       uploadTask.observe(.progress) { snapshot in
     
        
       let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)/Double(snapshot.progress!.totalUnitCount)
      
       print("\n", percentComplete, "\n")
        let numberOfImages = Double(self.progressStep - self.layoutLinksNumber)
       
        ARSLineProgress.updateWithProgress(CGFloat(percentComplete / numberOfImages ))
        
      }
      
      uploadTask.observe(.success) { snapshot in
        self.progressStep -= 1
        
      }
      
      
      uploadTask.observe(.failure) { snapshot in
        ARSLineProgress.showFail()
        print("Проверьте интернет соединение и попробуйте снова")
        
      }
    }
  }

  
    @IBAction func nameSurnameEditingChanged(_ sender: Any) { validateRegistraionData() }
    @IBAction func phoneNumberEditingChanged(_ sender: Any) { validateRegistraionData() }
    @IBAction func emailEditingChanged(_ sender: Any) { validateRegistraionData() }
    
  
  fileprivate func localyRetrieveUserData () {
     if FIRAuth.auth()?.currentUser != nil && FIRAuth.auth()?.currentUser?.isEmailVerified == true {
      
    var ref: FIRDatabaseReference!
    ref = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!)
    
    ref.observeSingleEvent(of: .value, with: { snapshot in
      
      if !snapshot.exists() { return }
      
      let mainUserData = snapshot.value as? NSDictionary
      
      if let userNameSurname = mainUserData?["name"] as? String  {
        self.nameSurnameTF.text = userNameSurname
     
      }
      
      
      if let userPhoneNumber = mainUserData?["PhoneNumber"] as? String  {
        self.phoneTF.text = userPhoneNumber
      }
      
       self.emailTF.text = FIRAuth.auth()!.currentUser!.email!
       self.validateRegistraionData()
    })
    
     
     } else {
      
       nameSurnameTF.text = ""
       phoneTF.text = ""
       emailTF.text = ""
    }
  }
  
  
    func setFontsForControllers(textfield: [UITextField], textview: UITextView, label: UILabel ) {
         if screenSize.height < 667 {
            textview.font = UIFont(name: "HelveticaNeue-Light", size: 14)
            label.font = UIFont(name: "HelveticaNeue-Light", size: 14)
            
            for textField in textfield {
                textField.font = UIFont(name: "HelveticaNeue-Light", size: 14)
            }
        }
    }
    
    
    
    func textfieldState(textField: UITextField, state: Bool ) {
        
        if state == true {
            
             textField.isEnabled = true
            
             UIView.animate(withDuration: 0.3, animations: {
                textField.alpha = 0.9 })
            
        } else {
            
              textField.isEnabled = false
              textField.text = ""
            
              UIView.animate(withDuration: 0.3, animations: {
                textField.alpha = 0.5 })
        }
    }
    
    
    func validateRegistraionData () {
        let characterSetEmail = NSCharacterSet(charactersIn: "@")
        let characterSetEmail1 = NSCharacterSet(charactersIn: ".")
        let badCharacterSetEmail = NSCharacterSet(charactersIn: "!`~,/?|'\'';:#^&*=")
        let badCharacterSetPhoneNumber = NSCharacterSet(charactersIn: "@$%.><!`~,/?|'\'';:#^&*=_+{}[]")
        
        if (nameSurnameTF.text?.characters.count)! < 2 ||
            (phoneTF.text?.characters.count)! < 10 ||
            (phoneTF.text?.characters.count)! > 20 ||
            phoneTF.text?.rangeOfCharacter(from: badCharacterSetPhoneNumber as CharacterSet, options: .caseInsensitive ) != nil ||
            (emailTF.text?.characters.count)! < 5 ||
            emailTF.text?.rangeOfCharacter(from: characterSetEmail as CharacterSet, options: .caseInsensitive ) == nil ||
            emailTF.text?.rangeOfCharacter(from: characterSetEmail1 as CharacterSet, options: .caseInsensitive ) == nil ||
            emailTF.text?.rangeOfCharacter(from: badCharacterSetEmail as CharacterSet, options: .caseInsensitive ) != nil  {
            
            checkOutButton.isEnabled = false
            
            UIView.animate(withDuration: 0.5, animations: {
                self.checkOutButton.alpha = 0.6 })
            
        } else {
            checkOutButton.isEnabled = true
            
            UIView.animate(withDuration: 0.5, animations: {
                self.checkOutButton.alpha = 1.0 })
        }
    }
    

}


 extension CheckoutFormVC: UIScrollViewDelegate {
  
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isEqual(mainScrollView) else {
            return
        }
        
        if let delegate = transitioningDelegate as? DeckTransitioningDelegate {
            if scrollView.contentOffset.y > 0 {
                // Normal behaviour if the `scrollView` isn't scrolled to the top
                scrollView.bounces = true
                delegate.isDismissEnabled = false
            } else {
                if scrollView.isDecelerating {
                    // If the `scrollView` is scrolled to the top but is decelerating
                    // that means a swipe has been performed. The view and scrollview are
                    // both translated in response to this.
                    view.transform = CGAffineTransform(translationX: 0, y: -scrollView.contentOffset.y)
                    scrollView.transform = CGAffineTransform(translationX: 0, y: scrollView.contentOffset.y)
                } else {
                    // If the user has panned to the top, the scrollview doesnʼt bounce and
                    // the dismiss gesture is enabled.
                    scrollView.bounces = false
                    delegate.isDismissEnabled = true
                }
            }
        }
    }
}


 extension CheckoutFormVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}




