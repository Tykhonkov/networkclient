//
//  Misc.swift
//  Network Client
//
//  Created by Ilya Tihonkov on 1/18/17.
//  Copyright © 2017 Ilya Tihonkov. All rights reserved.
//

import Foundation
import FastEasyMapping
import RxSwift

class DictionaryResponse: ResponseHandler {

    func handleResponse(_ response: Any) -> Observable<[MyCustomClass]> {
        guard let dictionary = response as? [String : String] else {
            return Observable.error(RxError.unknown)
        }
        var myClasses = [MyCustomClass]()

        dictionary.forEach { (key,value) in
            myClasses.append(MyCustomClass(key: key, value: value))
        }

        return Observable.just(myClasses)
    }

}


class ArrayResponse<T>: ResponseHandler {

    let serializer: BaseSerializer
    let mapping: FEMMapping

    init(serializer: BaseSerializer, mapping: FEMMapping) {
        self.serializer = serializer
        self.mapping = mapping
    }

    func handleResponse(_ response: Any) -> Observable<[T]> {
        guard let response = response as? [String : AnyObject] else {
            return Observable.error(RxError.unknown)
        }
        return serializer.mapResponse(response, mapping: mapping, contentKey: baseContentKey)
    }
    
}

class MyCustomMapper: BaseMapping {

    class func inputMapping() -> FEMMapping {
        let mapping = FEMMapping(objectClass: MyCustomClass.self)

        return mapping
    }

    class func outputMapping() -> FEMMapping {
        return inputMapping()
    }
    
}

class MyCustomClass {
    
    var key: String
    var value: String

    init(key: String, value: String) {
        self.key = key
        self.value = value
    }

}

public class ServiceLocator {}

open class Service {

    private unowned var locator: ServiceLocator

    public init(locator: ServiceLocator) {
        self.locator = locator
    }

    //At this point all services from surrounding are instantiated

    open func takeOff() {}

    open func prepareToClose() {}

}

class User {}

struct AuthorizationData {
    let authenticationToken: String?
    let exchangeToken: String?
    let user: User?
}
