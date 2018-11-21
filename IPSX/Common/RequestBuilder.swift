//
//  RequestBuilder.swift
//  IPSX
//
//  Created by Cristina Virlan on 26/10/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation
import IPSXNetworkingFramework

/// CURRENT ENVIRONMENT (DEV / DEMO):
let environment = Environment.dev

enum Environment: String {
    
    case dev  = "DEV"
    case demo = "DEMO"
}

struct RequestType {
    
    static let getPublicIP = "getPublicIP"
    static let getUserCountryList = "getUserCountryList"
    static let register = "register"
    static let fbRegister = "fbRegister"
    static let getCompany = "getCompany"
    static let getProviderDetails = "getProviderDetails"
    static let submitLegalPersonDetails = "submitLegalPersonDetails"
    
    static let login = "login"
    static let fbLogin = "fbLogin"
    
    static let resetPassword = "resetPassword"
    static let changePassword = "changePassword"
    
    static let retrieveProxies = "retrieveProxies"
    static let createProxy = "createProxy"
    static let retrieveProxyPackages = "retrieveProxyPackages"
    static let retrieveTestProxyPackage = "retrieveTestProxyPackage"
    static let getProxyCountryList = "getProxyCountryList"
    
    static let userInfo = "userInfo"
    static let userRoles = "userRoles"
    static let updateProfile = "updateProfile"
    static let deleteAccount = "deleteAccount"
    static let abortDeleteAccount = "abortDeleteAccount"
    
    static let requestTokens = "requestTokens"
    static let getDepositList = "getDepositList"
    static let createDeposit = "createDeposit"
    static let cancelDeposit = "cancelDeposit"
    
    static let addEthAddress = "addEthAddress"
    static let getEthAddress = "getEthAddress"
    static let updateEthAddress = "updateEthAddress"
    static let deleteEthAddress = "deleteEthAddress"
    
    static let getTokenRequestList = "getTokenRequestList"
    static let enrollTesting = "enrollTesting"
    static let enrollStaking = "enrollStaking"
    static let enrollStakingDetails = "enrollStakingDetails"
    
    static let getSettings = "getSettings"
    static let updateSettings = "updateSettings"
    static let generalSettings = "generalSettings"
}

public struct KeychainKeys {
    
    public static let accessToken   = "ACCESS_TOKEN_KEY"
    public static let facebookToken = "FACEBOOK_TOKEN_KEY"
    public static let userId        = "USER_ID_KEY"
    public static let password      = "USER_PASSWORD"
    public static let email         = "USER_EMAIL"
}

public struct EmailNotifications {
    
    public static let on = "all"
    public static let off = "disable"
}

enum Newsletter {
    case on
    case off
}

public struct Url {
    
    // DEV ENV:
    public static let baseDEVApi    = "https://api.dev.ip.sx/api"
    public static let pacBaseUrlDEV = "https://api.dev.ip.sx/proxy/pac/"
    
    // DEMO ENV:
    public static let baseDEMOApi    = "https://api.ipsx.io/api"
    public static let pacBaseUrlDEMO = "https://demo.ip.sx/proxy/pac/"
    
    public static var baseUrl: String {
        get {
            switch environment {
            case .dev:  return "https://app.dev.ip.sx"
            case .demo: return "https://demo.ip.sx"
            }
        }
    }
    
    public static var baseApi: String {
        get {
            switch environment {
            case .dev:
                return baseDEVApi
            case .demo:
                return baseDEMOApi
            }
        }
    }
    
    public static var pacBaseUrl: String {
        get {
            switch environment {
            case .dev:
                return pacBaseUrlDEV
            case .demo:
                return pacBaseUrlDEMO
            }
        }
    }
    
    public static var faqPageUrl: String {
        get { return baseUrl + "/webview/faq/staking?webview=true" }
    }
    public static var referalCodeUrl: String {
        get { return baseUrl + "/register?referral=" }
    }
    public static var aboutProviderUrl: String {
        get { return baseUrl + "/provider?webview=true" }
    }
    public static var becomeProviderUrl: String {
        get { return baseUrl + "/become-a-provider?webview=true" }
    }
    public static var termsUrl: String {
        get { return baseUrl + "/terms-of-use?webview=true" }
    }
    public static var privacyPolicyUrl: String {
        get { return baseUrl + "/privacy-policy?webview=true" }
    }
    
    public static let publicIPArgs           = "/Users/ip"
    public static let registerArgs           = "/Users"
    public static let fbRegisterArgs         = "/Users/social/register/facebook"
    public static let userCountriesArgs      = "/countries"
    public static let proxyCountriesArgs     = "/proxies/countries?access_token=%ACCESS_TOKEN%"
    public static let ethEnrolmentsArgs      = "/Users/%USER_ID%/eths/enrolments?access_token=%ACCESS_TOKEN%"
    public static let ethArgs                = "/Users/%USER_ID%/eths?access_token=%ACCESS_TOKEN%"
    public static let updateEthAddressArgs   = "/Users/%USER_ID%/eths/%ETH_ID%?access_token=%ACCESS_TOKEN%"
    public static let loginArgs              = "/Users/auth"
    public static let fbLoginArgs            = "/Users/social/login/facebook"
    public static let resetPassArgs          = "/Users/reset"
    public static let changePassArgs         = "/Users/%USER_ID%/changePassword?access_token=%ACCESS_TOKEN%"
    public static let submitLegalArgs        = "/Users/%USER_ID%/companies/aws-store?access_token=%ACCESS_TOKEN%"
    public static let proxiesArgs            = "/Users/%USER_ID%/proxies?access_token=%ACCESS_TOKEN%"
    public static let createProxyArgs        = "/Users/%USER_ID%/proxies/create-via-package?access_token=%ACCESS_TOKEN%"
    public static let proxyPackagesArgs      = "/packages/admin/paid?access_token=%ACCESS_TOKEN%"
    public static let proxyTestPackageArgs   = "/packages/admin/test?access_token=%ACCESS_TOKEN%"
    public static let userInfoArgs           = "/Users/%USER_ID%?access_token=%ACCESS_TOKEN%"
    public static let tokenRequestArgs       = "/Users/%USER_ID%/token_requests?access_token=%ACCESS_TOKEN%"
    public static let depositArgs            = "/Users/%USER_ID%/deposits?access_token=%ACCESS_TOKEN%"
    public static let cancelDepositArgs      = "/Users/%USER_ID%/deposits/%DEPOSIT_ID%?access_token=%ACCESS_TOKEN%"
    public static let generalSettingsArgs    = "/settings?access_token=%ACCESS_TOKEN%"
    public static let deleteAccountArgs      = "/Users/%USER_ID%/delete/queue?access_token=%ACCESS_TOKEN%"
    public static let abortDeleteAccountArgs = "/Users/%USER_ID%/delete/queue/cancel?access_token=%ACCESS_TOKEN%"
    public static let enrollTestingArgs      = "/Users/%USER_ID%/testers?access_token=%ACCESS_TOKEN%"
    public static let enrollStakingBulkArgs  = "/Users/%USER_ID%/stakings/bulk?access_token=%ACCESS_TOKEN%"
    public static let enrollStakingArgs      = "/Users/%USER_ID%/stakings?access_token=%ACCESS_TOKEN%"
    public static let metaArgs               = "/Users/%USER_ID%/meta?access_token=%ACCESS_TOKEN%"
    public static let intentionsArgs         = "/Users/%USER_ID%/intentions?access_token=%ACCESS_TOKEN%"
    public static let userRolesArgs          = "/Users/%USER_ID%/roles?access_token=%ACCESS_TOKEN%"
}

func createRequest(requestType:String, urlParams: [String: String] = [:], bodyParams: Any = "") -> Request {
    
    let body = JSON(bodyParams)
    var url: String = ""
    var httpMethod: String = ""
    let contentType: String = ContentType.applicationJSON
    
    switch requestType {
        
    //Login Requests
        
    case RequestType.login:
        url = Url.baseApi + Url.loginArgs
        httpMethod = "POST"
        
    case RequestType.fbLogin:
        url = Url.baseApi + Url.fbLoginArgs
        httpMethod = "POST"
        
    case RequestType.resetPassword:
        url = Url.baseApi + Url.resetPassArgs
        httpMethod = "POST"
        
    case RequestType.changePassword:
        url = (Url.baseApi + Url.changePassArgs).replaceKeysWithValues(paramsDict: urlParams)
        httpMethod = "POST"
        
    //Register Requests
        
    case RequestType.getPublicIP:
        url = Url.baseApi + Url.publicIPArgs
        httpMethod = "GET"
        
    case RequestType.register:
        url = Url.baseApi + Url.registerArgs
        httpMethod = "POST"
        
    case RequestType.fbRegister:
        url = Url.baseApi + Url.fbRegisterArgs
        httpMethod = "POST"
        
    //User Info Requests
        
    case RequestType.getUserCountryList:
        url = Url.baseApi + Url.userCountriesArgs
        httpMethod = "GET"
        
    case RequestType.getCompany, RequestType.getProviderDetails:
        url = (Url.baseApi + Url.intentionsArgs).replaceKeysWithValues(paramsDict: urlParams)
        httpMethod = "GET"
        
    case RequestType.updateProfile:
        url = (Url.baseApi + Url.userInfoArgs).replaceKeysWithValues(paramsDict: urlParams)
        httpMethod = "PATCH"
        
    case RequestType.userInfo:
        url = (Url.baseApi + Url.userInfoArgs).replaceKeysWithValues(paramsDict: urlParams)
        httpMethod = "GET"
        
    case RequestType.enrollTesting:
        url = (Url.baseApi + Url.enrollTestingArgs).replaceKeysWithValues(paramsDict: urlParams)
        httpMethod = "POST"
        
    case RequestType.enrollStaking:
        url = (Url.baseApi + Url.enrollStakingBulkArgs).replaceKeysWithValues(paramsDict: urlParams)
        httpMethod = "POST"
        
    case RequestType.enrollStakingDetails:
        url = (Url.baseApi + Url.enrollStakingArgs).replaceKeysWithValues(paramsDict: urlParams)
        httpMethod = "GET"
        
    case RequestType.userRoles:
        url = (Url.baseApi + Url.userRolesArgs).replaceKeysWithValues(paramsDict: urlParams)
        httpMethod = "GET"
        
    //Proxy Requests
        
    case RequestType.getProxyCountryList:
        url = (Url.baseApi + Url.proxyCountriesArgs).replaceKeysWithValues(paramsDict: urlParams)
        httpMethod = "GET"
        
    case RequestType.retrieveProxyPackages:
        url = (Url.baseApi + Url.proxyPackagesArgs).replaceKeysWithValues(paramsDict: urlParams)
        httpMethod = "GET"
        
    case RequestType.retrieveTestProxyPackage:
        url = (Url.baseApi + Url.proxyTestPackageArgs).replaceKeysWithValues(paramsDict: urlParams)
        httpMethod = "GET"
        
    case RequestType.retrieveProxies:
        url = (Url.baseApi + Url.proxiesArgs).replaceKeysWithValues(paramsDict: urlParams)
        httpMethod = "GET"
        
    case RequestType.createProxy:
        url = (Url.baseApi + Url.createProxyArgs).replaceKeysWithValues(paramsDict: urlParams)
        httpMethod = "POST"
        
    //ETH addresses Requests
        
    case RequestType.updateEthAddress:
        url = (Url.baseApi + Url.updateEthAddressArgs).replaceKeysWithValues(paramsDict: urlParams)
        httpMethod = "PUT"
        
    case RequestType.deleteEthAddress:
        url = (Url.baseApi + Url.updateEthAddressArgs).replaceKeysWithValues(paramsDict: urlParams)
        httpMethod = "DELETE"
        
    case RequestType.addEthAddress:
        url = (Url.baseApi + Url.ethArgs).replaceKeysWithValues(paramsDict: urlParams)
        httpMethod = "POST"
        
    case RequestType.getEthAddress:
        url = (Url.baseApi + Url.ethEnrolmentsArgs).replaceKeysWithValues(paramsDict: urlParams)
        httpMethod = "GET"
        
    //Token Requests
        
    case RequestType.requestTokens:
        url = (Url.baseApi + Url.tokenRequestArgs).replaceKeysWithValues(paramsDict: urlParams)
        httpMethod = "POST"
        
    case RequestType.getTokenRequestList:
        url = (Url.baseApi + Url.tokenRequestArgs).replaceKeysWithValues(paramsDict: urlParams)
        httpMethod = "GET"
        
    case RequestType.getDepositList:
        url = (Url.baseApi + Url.depositArgs).replaceKeysWithValues(paramsDict: urlParams)
        httpMethod = "GET"
        
    case RequestType.createDeposit:
        url = (Url.baseApi + Url.depositArgs).replaceKeysWithValues(paramsDict: urlParams)
        httpMethod = "POST"
        
    case RequestType.cancelDeposit:
        url = (Url.baseApi + Url.cancelDepositArgs).replaceKeysWithValues(paramsDict: urlParams)
        httpMethod = "PUT"
        
    // Settings
        
    case RequestType.getSettings:
        url = (Url.baseApi + Url.metaArgs).replaceKeysWithValues(paramsDict: urlParams)
        httpMethod = "GET"
        
    case RequestType.updateSettings:
        url = (Url.baseApi + Url.metaArgs).replaceKeysWithValues(paramsDict: urlParams)
        httpMethod = "PUT"
        
    case RequestType.generalSettings:
        url = (Url.baseApi + Url.generalSettingsArgs).replaceKeysWithValues(paramsDict: urlParams)
        httpMethod = "GET"
        
    case RequestType.deleteAccount:
        url = (Url.baseApi + Url.deleteAccountArgs).replaceKeysWithValues(paramsDict: urlParams)
        httpMethod = "DELETE"
        
    case RequestType.abortDeleteAccount:
        url = (Url.baseApi + Url.abortDeleteAccountArgs).replaceKeysWithValues(paramsDict: urlParams)
        httpMethod = "POST"
        
    default:
        break
    }
    
    return Request(url: url, httpMethod: httpMethod, contentType: contentType, body:body, requestType: requestType)
}





