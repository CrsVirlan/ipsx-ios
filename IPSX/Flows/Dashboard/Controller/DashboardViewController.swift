//
//  DashboardViewController.swift
//  IPSX
//
//  Created by Cristina Virlan on 18/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController {
    
    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var tokensAmountLabel: UILabel!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var proxiesSegmentController: UISegmentedControl!
    @IBOutlet weak var slidableView: UIView!
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    var countries: [String] = []
    var showAmountAlert = true
    private var timer: Timer?
    let cellID = "ActivationDetailsCellID"
    var selectedProxy: Proxy? = nil
    var tokenRequests: [TokenRequest]?
    
    var balance: String = "" {
        didSet {
            DispatchQueue.main.async {
                self.tokensAmountLabel.text = self.balance
            }
        }
    }
    var errorMessage: String? {
        didSet {
            toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
       }
    }
    var proxies: [Proxy] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }
    }
    var filteredProxies: [Proxy] {
        get {
            let filterString = proxiesSegmentController.selectedSegmentIndex == 0 ? "active" : "expired"
            return proxies.filter { $0.proxyDetails?.status == filterString }
         }
    }
    
    @IBAction func unwindToDashboard(segue:UIStoryboardSegue) { }
    
    @IBAction func tokenRequestAction(_ sender: UIButton) {
        
        let maxTokenRequests = UserManager.shared.options?.maxTokenRequests ?? 5
        var noOfTokenRequests: Int = 1
        
        if let tokenRequests = UserManager.shared.tokenRequests {
            for tokenRequest in tokenRequests {
                if tokenRequest.isFromToday() {
                    noOfTokenRequests = noOfTokenRequests + 1
                }
            }
        }
        if noOfTokenRequests < maxTokenRequests {
            self.tokenRequests = UserManager.shared.tokenRequests
            self.performSegue(withIdentifier: "showTokenRequestSegueID", sender: nil)
        } else {
            let formatedMessage = String(format: "Max %@ Token Requests Error Message".localized, "\(maxTokenRequests)")
            self.errorMessage = formatedMessage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
     }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateData()
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(self.updateData), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.timer?.invalidate()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: slidableView, text: "")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        selectedProxy = nil
        updateProxyDataSource()
        let balanceValue = UserManager.shared.userInfo?.balance ?? 0
        balance = "\(balanceValue)"
        if balanceValue == 0, showAmountAlert == true {
            showAmountAlert = false
            toast?.showToastAlert("Balance Empty Info Message".localized, type: .info)
        }
    }
    
    @objc func updateData() {
        retrieveUserInfo()
        retrieveProxiesForCurrentUser()
    }
    
    func retrieveUserInfo() {
        
        loadingView.startAnimating()
        UserInfoService().retrieveUserInfo(completionHandler: { result in
            
            self.loadingView.stopAnimating()
            switch result {
            case .success(let user):
                UserManager.shared.userInfo = user as? UserInfo
                self.balance = "\(UserManager.shared.userInfo?.balance ?? 0)"
                
            case .failure(let error):
                self.handleError(error, requestType: .userInfo, completion: {
                    self.retrieveUserInfo()
                })
            }
        })
    }
    
    func retrieveProxiesForCurrentUser() {
        
        loadingView.startAnimating()
        ProxyService().retrieveProxiesForCurrentUser(completionHandler: { result in
            
            self.loadingView.stopAnimating()
            switch result {
            case .success(let proxyArray):
                UserManager.shared.proxies = proxyArray as? [Proxy]
                self.updateProxyDataSource()
                
            case .failure(let error):
                self.handleError(error, requestType: .retrieveProxies, completion: {
                    self.retrieveProxiesForCurrentUser()
                })
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
            
        case "FreeProxySegueID":
            let navController = segue.destination as? UINavigationController
            let destinationVC = navController?.viewControllers.first as? SearchViewController
            destinationVC?.isProxyFlow = true
            destinationVC?.countries = countries
            destinationVC?.proxy = selectedProxy
            
        case "ProxyDetailsSegueiID":
            let nextVC = segue.destination as? ProxyDetailsViewController
            nextVC?.proxy = selectedProxy
            nextVC?.presentedFromDashboard = true
            
        case "showTokenRequestSegueID":
            toast?.hideToastAlert()
            let nextVC = segue.destination as? UINavigationController
            let controller = nextVC?.viewControllers.first as? TokenRequestListController
            controller?.tokenRequests = tokenRequests ?? []
            
        default:
            break
        }
    }
    
    @IBAction func proxySegmentAction(_ sender: UISegmentedControl) {
        tableView?.reloadData()
    }
    
    func updateProxyDataSource() {
        
        proxies = UserManager.shared.proxies ?? []
        if UserManager.shared.hasTestProxyAvailable {
            let testProxy = ProxyService().retrieveTestProxy()
            proxies.insert(testProxy, at: 0)
        }
    }
}

extension DashboardViewController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}

extension DashboardViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredProxies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ProxyActivationDetailsCell
        cell.cellContentView.shadow = true
        cell.configure(proxy: filteredProxies[indexPath.item])
        
        return cell
    }
}

extension DashboardViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedProxy = filteredProxies[indexPath.item]
        
        if selectedProxy?.isTestProxy == true {
            
            selectedProxy?.proxyDetails?.startDate = Date()
            selectedProxy?.proxyDetails?.endDate   = Date().addingTimeInterval(3600)
            countries = UserManager.shared.proxyCountries ?? []
            self.performSegue(withIdentifier: "FreeProxySegueID", sender: self)
        }
        else {
            performSegue(withIdentifier: "ProxyDetailsSegueiID", sender: self)
        }
    }
}

extension DashboardViewController: ErrorPresentable {
    
    func handleError(_ error: Error, requestType: IPRequestType, completion:(() -> ())? = nil) {
        
        switch error {
            
        case CustomError.expiredToken:
            
            LoginService().getNewAccessToken(errorHandler: { error in
                self.errorMessage = "Refresh Data Error Message".localized
                
            }, successHandler: {
                completion?()
            })
        default:
            self.errorMessage = "Refresh Data Error Message".localized
        }
    }
}
