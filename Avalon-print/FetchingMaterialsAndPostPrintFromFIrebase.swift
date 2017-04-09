//
//  FetchingMaterialsAndPostPrintFromFIrebase.swift
//  Avalon-Print
//
//  Created by Roman Mizin on 4/9/17.
//  Copyright © 2017 Roman Mizin. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

//var materialsDictionary = [(title: "Выберите материал...", matPrice: 0.0, printPrice: 0.0)]
//var postPrintDictionary = [(title: "Без постпечати", materialCost: 0.0, costOfWork: 0.0)]


struct priceData {
  
  static var materialsDictionary = [(title: "Выберите материал...", matPrice: 0.0, printPrice: 0.0)]
  static var postPrintDictionary = [(title: "Без постпечати", materialCost: 0.0, costOfWork: 0.0)]
  
  static var materialPrice = Double()
  static var printPrice = Double()
  
  static var postPrintMaterialPrice = Double()
  static var postPrintWorkPrice = Double()
  
  static func resetMaterialsAndPostprintDictionaries () {
    
    priceData.materialsDictionary = [(title: "Выберите материал...", matPrice: 0.0, printPrice: 0.0)]
    priceData.postPrintDictionary = [(title: "Без постпечати", materialCost: 0.0, costOfWork: 0.0)]
  }
  
}


func fetchMaterialsAndPostprint(productType: String, postprintTypes: String) {
  
     priceData.resetMaterialsAndPostprintDictionaries()
  
  var ref: FIRDatabaseReference!
  ref = FIRDatabase.database().reference()
  
  
  // Materials
  
  ref.child("Materials").observe(.childAdded, with: { (snapshot) in
    
    if snapshot.key == productType {
      guard let dictionary = snapshot.value as? [String: AnyObject] else {
        return
      }
      
      for (_, value) in dictionary {
        
        if let materialTitle = value["title"],  let materialPrice = value["materialPrice"] , let printPrice = value["printPrice"] {
          
          priceData.materialsDictionary.append(( materialTitle as! String  , materialPrice as! Double  , printPrice as! Double  ))
        }
      }
      print(priceData.materialsDictionary)
    }
    
  }) { (error) in
    print(error.localizedDescription)
  }
  
  
  
  // Post Print
  
  ref.child("Postprint").observe(.childAdded, with: { (snapshot) in
    
    if snapshot.key != "prepressCold" {
      
      guard let dictionary = snapshot.value as? [String: AnyObject] else {
        return
      }
      
      //  for (_, value) in dictionary {
      
      if let postprintTitle = dictionary["title"],  let materialCost = dictionary["materialCost"] , let workCost = dictionary["workCost"] {
        
        priceData.postPrintDictionary.append(( postprintTitle as! String , materialCost as! Double , workCost as! Double ))
      }
      
      // }
    }
    
  }) { (error) in
    print(error.localizedDescription)
  }
}
