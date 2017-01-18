//
//  RequestManager.swift
//  Reel
//
//  Created by Konstantin Safronov on 9/8/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire



//#if DEBUG
private let mainPath = "https://testfirebase-62138.firebaseio.com"
//#elseif STAGING
//  private let mainPath = "https://testfirebase-62138.firebaseio.com/relationships"
//#else
//  private let mainPath = "https://testfirebase-62138.firebaseio.com/relationships"
//#endif

private let apiVersion = ""
private let baseContentKey = "data"
private let defaultPath = mainPath + apiVersion
private let reelMemoryThreshold: UInt64 = 4 * UInt64(1024 * 1024)

protocol AccessCredentialsProviding: class {

    var accessToken: String? { get set }
    var exchangeToken: String? { get set }

    func commitCredentialsUpdate(_ update: (AccessCredentialsProviding) -> Void) -> Observable<Bool>

}

protocol RequestRetrier {

    func shouldRetry(error: Error, manager: RequestManager) -> Observable<Bool>

}

extension RequestRetrier {

    func shouldRetry(error: Error, manager: RequestManager) -> Observable<Bool> {
        if let afError = error as? AFError, afError.responseCode == 401 {

            return manager.restoreSession().do(onNext: { authorizationData in
                manager.credentialsProvider?.commitCredentialsUpdate() { _ in
                    //          $0.accessToken = authorizationData.authenticationTokenshouldRetry
                    //          $0.exchangeToken = authorizationData.exchangeToken
                }
            }).catchError({ _ -> Observable<AuthorizationData> in
                Observable.error(error)
            }).map { _ in
                return true
            }
        } else {
            return Observable.error(error)
        }
    }
}

class Retrier: RequestRetrier {}

class RequestManager: Service {

    weak var credentialsProvider: AccessCredentialsProviding?
    fileprivate func headers() -> [String : String] {
        var headers = [String : String]()
        headers["Content-Type"] = "application/json"
        headers["Authorization"] = credentialsProvider?.accessToken.map { "Token token=" + $0 }

        return headers
    }
    var retrier = Retrier()

    // MARK: - Public Methods

    func executeRequest<T: ResponseHandler>(withPath path: String,
                        parameters: [String: Any]? = nil,
                        method: HTTPMethod,
                        encoding: ParameterEncoding,
                        responseHandler: T) -> Observable<T.Value> {
        let request = _executeRequest(withPath: path, parameters: parameters, method: method, encoding: encoding)

        return request.catchError { error -> Observable<DataResponse<Any>> in
            let retrySignal = self.retrier.shouldRetry(error: error, manager: self)

            return retrySignal.flatMapLatest({ shouldRetry -> Observable<DataResponse<Any>> in
                if shouldRetry {
                    return self._executeRequest(withPath: path, parameters: parameters, method: method, encoding: encoding)
                } else {
                    return Observable.error(error)
                }
            })
            }.flatMapLatest({ response -> Observable<T.Value> in
                if case let .success(value) = response.result {
                    return responseHandler.handleResponse(value)
                } else {
                    return Observable.error(RxError.unknown)
                }
            })
    }

    fileprivate func _executeRequest(withPath path: String,
                         parameters: [String: Any]? = nil,
                         method: HTTPMethod,
                         encoding: ParameterEncoding
        ) -> Observable<DataResponse<Any>> {

        return Observable.create({ observer -> Disposable in
            let request = Alamofire.request(
                defaultPath + path,
                method: method,
                parameters: parameters,
                encoding: encoding,
                headers: self.headers()).validate().responseJSON { response in
                    switch response.result {
                    case .success:
                        observer.onNext(response)
                        observer.onCompleted()

                    case .failure(let error):
                        observer.onError(error)//NSError.Network.from(error: error))
                    }

            }

            return Disposables.create {
                request.cancel()
            }
        })
    }

    func executeMultiPartRequest<T, U: ResponseHandler>(withPath path: String,
                                 method: HTTPMethod,
                                 responseHandler: U,
                                 multipartFormData: @escaping ((MultipartFormData) -> Void),
                                 progressBlock: ((Float) -> Void)?) -> Observable<T> where U.Value == T {
        return Observable.create({ [weak self] observer -> Disposable in
            Alamofire.upload(
                multipartFormData: multipartFormData,
                usingThreshold: reelMemoryThreshold,
                to: defaultPath + path,
                method: method,
                headers: self?.headers(),
                encodingCompletion: { response in
                    switch response {

                    case .success (let uploadResponse, _, _):
                        uploadResponse.responseJSON { response in

                            switch response.result {
                            case let .success(value):
                                
                                    _ = responseHandler.handleResponse(value).take(1).subscribe {  event in
                                        switch event {
                                        case .error(let error):
                                            observer.onError(error)

                                        case.next(let object):
                                            observer.onNext(object)

                                        case .completed:
                                            observer.onCompleted()
                                        }
                                    }

                            case let .failure(error):
                                observer.onError(error)

                            }
                        }
                        uploadResponse.uploadProgress { progress in
                            progressBlock?(Float(progress.fractionCompleted))
                        }

                    case .failure(let error as NSError):
                        observer.onError(error)

                    default:
                        break
                    }
            })

            return Disposables.create()
        })
    }
    
    func restoreSession() -> Observable<AuthorizationData> {
        let params = ["refresh_token" : credentialsProvider?.exchangeToken]
        //        let serializer = AuthorizationSerializer(context: NSManagedObjectContext.mr_default())
        //        return executeRequest(withPath: "/users/sessions/restore",
        //                              parameters: params,
        //                              method: HTTPMethod.post,
        //                              encoding: JSONEncoding.default,
        //                              serializer: serializer,
        //                              mapping: UserMapping.inputMapping())
        return Observable.just(AuthorizationData(authenticationToken: "", exchangeToken: "", user: User()))
    }
    
}
