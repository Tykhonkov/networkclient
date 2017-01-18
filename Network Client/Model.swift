//
//  Model.swift
//  Network Client
//
//  Created by Ilya Tihonkov on 1/18/17.
//  Copyright © 2017 Ilya Tihonkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

final class Model {

    var myClasses = Variable<[MyCustomClass]>([MyCustomClass]())
    var networkManager = RequestManager(locator: ServiceLocator())

    func requestMyClasses() {

        let responseHandler = DictionaryResponse()

        _ = networkManager.executeRequest(withPath: "/relationships.json",
                                      method: .get,
                                      encoding: JSONEncoding.default,
                                      responseHandler: responseHandler).take(1).subscribe(onNext: { [unowned self] classes in
                                        self.myClasses.value.append(contentsOf: classes)
                                      })

    }

}
