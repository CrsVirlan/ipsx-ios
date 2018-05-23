//
//  LoadingViewController.swift
//  IPSX
//
//  Created by Calin Chitu on 15/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    
    @IBOutlet weak var toastHolderView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    
    let dispatchGroup = DispatchGroup()
    
    //TODO (CVI): add reachability & implement retry for internet connection error (banner) and other errors (alert)
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: toastHolderView, text: "")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        backgroundImageView.createParticlesAnimation()
        if UserManager.shared.isLoggedIn {
            initDataForCurrentUser()
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                self.performSegue(withIdentifier: "TabbarSegueID", sender: self)
            }
        }
    }
    
    func initDataForCurrentUser() {
        
        userCountryList()
        ethAddresses()
        userInfo()
        proxies()
        tokenRequestList()
        proxyCountryList()
        options()
        
        dispatchGroup.notify(queue: .main) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.performSegue(withIdentifier: "TabbarSegueID", sender: self)
            }
        }
    }
    
    func userCountryList() {
        
        dispatchGroup.enter()
        UserInfoService().getUserCountryList(completionHandler: { result in
            
            self.dispatchGroup.leave()
            switch result {
            case .success(let countryList):
                UserManager.shared.userCountries = countryList as? [[String: String]]
                DispatchQueue.main.async { self.progressView.progress += 0.166 }
            case .failure(_):
                print("Generic Error Message".localized)
            }
        })
    }
    
    func ethAddresses() {
        
        dispatchGroup.enter()
        UserInfoService().retrieveETHaddresses(completionHandler: { result in
            
            self.dispatchGroup.leave()
            
            switch result {
            case .success(let ethAddresses):
                UserManager.shared.ethAddresses = ethAddresses as? [EthAddress]
                DispatchQueue.main.async { self.progressView.progress += 0.166 }

            case .failure(let error):
                
                self.handleError(error, requestType: .getEthAddress, completion: {
                    self.ethAddresses()
                })
            }
        })
    }
    
    func userInfo() {
        
        dispatchGroup.enter()
        UserInfoService().retrieveUserInfo(completionHandler: { result in
            
            self.dispatchGroup.leave()
            
            switch result {
            case .success(let user):
                UserManager.shared.userInfo = user as? UserInfo
                DispatchQueue.main.async { self.progressView.progress += 0.166 }

            case .failure(let error):
                
                self.handleError(error, requestType: .userInfo, completion: {
                    self.userInfo()
                })
            }
        })
    }
    
    func proxies() {
        
        dispatchGroup.enter()
        ProxyService().retrieveProxiesForCurrentUser(completionHandler: { result in
            
            self.dispatchGroup.leave()
            
            switch result {
                
            case .success(let proxyArray):
                UserManager.shared.proxies = proxyArray as? [Proxy]
                DispatchQueue.main.async { self.progressView.progress += 0.166 }

            case .failure(let error):
                
                self.handleError(error, requestType: .retrieveProxies, completion: {
                    self.proxies()
                })
            }
        })
    }
    
    func tokenRequestList() {
        
        dispatchGroup.enter()
        ProxyService().getTokenRequestList(completionHandler: { result in
            
            self.dispatchGroup.leave()
            
            switch result {
            case .success(let tokenRequests):
                UserManager.shared.tokenRequests = tokenRequests as? [TokenRequest]
                DispatchQueue.main.async { self.progressView.progress += 0.166 }

            case .failure(let error):
                
                self.handleError(error, requestType: .getTokenRequestList, completion: {
                    self.tokenRequestList()
                })
            }
        })
    }
    
    func proxyCountryList() {
        
        dispatchGroup.enter()
        ProxyService().getProxyCountryList(completionHandler: { result in
            
            self.dispatchGroup.leave()
            
            switch result {
            case .success(let countryList):
                UserManager.shared.proxyCountries = countryList as? [String]
                DispatchQueue.main.async { self.progressView.progress +=  0.166 }

            case .failure(let error):
                
                self.handleError(error, requestType: .getProxyCountryList, completion: {
                    self.proxyCountryList()
                })
            }
        })
    }
    
    func options() {
        
        dispatchGroup.enter()
        OptionsService().retrieveOptions(completionHandler: { result in
            self.dispatchGroup.leave()
            
            switch result {
            case .success(let options):
                UserManager.shared.options = options as? Options
                
            case .failure(let error):
                
                self.handleError(error, requestType: .options, completion: {
                    self.options()
                })
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension LoadingViewController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.addSubview(toastView)
        }
    }
}

extension LoadingViewController: ErrorPresentable {
    
    func handleError(_ error: Error, requestType: IPRequestType, completion:(() -> ())? = nil) {
        
        switch error {
            
        case CustomError.expiredToken:
            
            LoginService().getNewAccessToken(errorHandler: { error in
                print("Generic Error Message".localized)
                
            }, successHandler: {
                completion?()
            })
        default:
            print("Generic Error Message".localized)
        }
    }
}
