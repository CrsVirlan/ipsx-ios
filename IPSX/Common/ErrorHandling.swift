//
//  ErrorHandling.swift
//  IPSX
//
//  Created by Cristina Virlan on 26/10/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation
import CVINetworkingFramework

protocol ErrorPresentable {
    
    func handleError(_ error: Error, requestType: String, completion: (() -> ())?)
}

public enum CustomError: Error {
    
    case invalidJson
    case statusCodeNOK(Int)
    case expiredToken
    case otherError(Error)
    case invalidParams
    case alreadyExists
    case notFound
    case wrongPassword
    case loginFailed
    case invalidLogin
    case userDeleted
    case notPossible
    case notSuccessful
    
    public var errorDescription: String? {
        
        switch self {
            
        case .invalidLogin:
            return "Email not confirmed"
            
        case .notPossible:
            return "Can't reset password from IPSX app"
            
        case .notSuccessful:
            return "Request result: success = false"
            
        case .invalidJson:
            return "Error parsing the JSON response from the server."
            
        case .statusCodeNOK(let statusCode):
            return "Error status code:" + "\(statusCode)"
            
        case .otherError(let err):
            return err.localizedDescription
            
        default:
            return self.localizedDescription
        }
    }
}

func generateCustomError(error: Error, statusCode: Int, responseCode: String, request: Request) -> Error {
    
    let requestType = request.requestType ?? ""
    var customError: Error?
    
    switch error {
        
    case RequestError.custom(statusCode, responseCode):
        
        switch statusCode {
            
        case 401:
            
            switch requestType {
                
            case RequestType.login:    customError = CustomError.loginFailed
            case RequestType.register: customError = CustomError.statusCodeNOK(statusCode)
            default: customError = CustomError.expiredToken
            }
            
        case 402:
            
            switch requestType {
                
            case RequestType.changePassword: customError = CustomError.wrongPassword
            case RequestType.deleteAccount:  customError = CustomError.wrongPassword
            default: customError = CustomError.statusCodeNOK(statusCode)
            }
            
        case 403:
            
            switch requestType {
                
            case RequestType.login:         customError = CustomError.invalidLogin
            case RequestType.resetPassword: customError = CustomError.notPossible
            default: customError = CustomError.statusCodeNOK(statusCode)
            }
            
        case 405:
            
            switch requestType {
                
            case RequestType.login, RequestType.fbLogin, RequestType.resetPassword: customError = CustomError.userDeleted
                
            default: customError = CustomError.statusCodeNOK(statusCode)
            }
            
        case 429:
            
            switch requestType {
                
            case RequestType.fbLogin: customError = CustomError.notFound
            default: customError = CustomError.statusCodeNOK(statusCode)
            }
            
        case 430:
            
            switch requestType {
                
            case RequestType.addEthAddress, RequestType.fbRegister, RequestType.register: customError = CustomError.alreadyExists
                
            default: customError = CustomError.statusCodeNOK(statusCode)
            }
            
        default: customError = CustomError.statusCodeNOK(statusCode)
        }
        
    default:
        return error
    }
    
    if let customError = customError {
        
        print("\n")
        print(NSDate(), "Request type: \(requestType)", "ERROR:",customError, "\nError Description:",customError.localizedDescription, "\n")
        
        return customError
    }
    return error
}
