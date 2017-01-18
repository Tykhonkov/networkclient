//
//  NetworkProtocols.swift
//  Reel
//
//  Created by Konstantin Safronov on 9/8/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation
import Alamofire
import FastEasyMapping
import RxSwift
import CoreData

let backendDate: DateFormatter = {
    let fullDateFormatInput = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    let formatter = DateFormatter()
    formatter.dateFormat = fullDateFormatInput
    return formatter
}()


protocol BaseMapping {
    
    static func inputMapping() -> FEMMapping
    static func outputMapping() -> FEMMapping
}

extension BaseMapping {
  
  static func dateAttributeForProperty(_ property: String, keyPath: String) -> FEMAttribute {
    let dateFormatter = backendDate
    let dateAttribute = FEMAttribute(
      property: property,
      keyPath: keyPath,
      map: { object -> AnyObject? in
        if let object = object as? String {
          return dateFormatter.date(from: object) as AnyObject?
        }
        return nil
      },
      reverseMap: { object -> AnyObject? in
        if let object = object as? Date {
          return dateFormatter.string(from: object) as AnyObject?
        }
        return nil
    })
    return dateAttribute
  }
}

protocol BaseSerializer {

    func mapResponse<T>(_ response: [String : AnyObject],
                     mapping: FEMMapping?,
                     contentKey: String) -> Observable<T>
}

protocol ResponseHandler {

    associatedtype Value

    var baseContentKey: String { get }

    func handleResponse(_ response: Any) -> Observable<Value>

}

extension ResponseHandler {

    var baseContentKey: String { return "data" }

}
