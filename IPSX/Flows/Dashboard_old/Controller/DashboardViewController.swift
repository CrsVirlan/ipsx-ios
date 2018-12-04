//
//  DashboardViewController.swift
//  IPSX
//
//  Created by Cristina Virlan on 18/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import IPSXNetworkingFramework

class DashboardViewController: UIViewController {
    
    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var fullMaskView: UIView!
    @IBOutlet weak var tokensAmountLabel: UILabel!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var proxiesSegmentController: UISegmentedControl!
    @IBOutlet weak var slidableView: UIView!
    @IBOutlet weak var providerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var providerView: ProviderView!
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    var countries: [String] = []
    private var timer: Timer?
    let cellID = "ActivationDetailsCellID"
    var tokenRequests: [TokenRequest]?
    
    var preventPurchase: Bool { return !UserManager.shared.companyVerified && UserManager.shared.userInfo?.hasOptedForLegal == true }
    
    var balance: String = "" {
        didSet {
            DispatchQueue.main.async {
                self.tokensAmountLabel.text = self.balance
            }
        }
    }
    
    var errorMessage: String? {
        didSet {
            if ReachabilityManager.shared.isReachable() {
                toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
            }
        }
    }
    
    
    @IBAction func tokenRequestAction(_ sender: UIButton) {
        
        guard !preventPurchase else {
            self.toast?.showToastAlert("Company Not Validated Message".localized, type: .validatePending, dismissable: false)
            return
        }
        
        self.tokenRequests = UserManager.shared.tokenRequests
        self.performSegue(withIdentifier: "showTokenRequestSegueID", sender: nil)
    }
    
    @IBAction func tokenDepositAction(_ sender: Any) {
        
        guard !preventPurchase else {
            self.toast?.showToastAlert("Company Not Validated Message".localized, type: .validatePending, dismissable: false)
            return
        }
        
        self.tokenRequests = UserManager.shared.tokenRequests
        self.performSegue(withIdentifier: "tokenDepositSegueID", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.layer.cornerRadius = 5
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        providerView.providerDelegate = self
    }
    
    @objc func appWillEnterForeground() {
        updateReachabilityInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: nil)
        updateReachabilityInfo()
        tableView?.setContentOffset(.zero, animated: false)
        
        /*  No need to submit requests:
         - When the user is not yet logged in: Login will be displayed from Tab Bar Controller (this is the first VC)
         */
        if UserManager.shared.isLoggedIn {
            
            if UserManager.shared.userInfo == nil {
                retrieveUserInfo()
            }
            if UserManager.shared.company == nil {
                companyDetails()
            }
            if UserManager.shared.providerSubmissionStatus == nil {
                providerDetails()
            }
            if UserManager.shared.roles == nil {
                userRoles()
            }
            if UserManager.shared.generalSettings == nil {
                generalSettings()
            }
            // After Logout we should load the proxy countries if needed for Test Proxy
            if ProxyManager.shared.proxyCountries == nil && UserManager.shared.hasTestProxyAvailable {
                getProxyCountryList()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
        self.timer?.invalidate()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: slidableView, text: "")
    }
    
    @objc public func reachabilityChanged(_ note: Notification) {
        DispatchQueue.main.async {
            let reachability = note.object as! Reachability
            
            if !reachability.isReachable {
                self.toast?.showToastAlert("No internet connection".localized, dismissable: false)
            } else if self.toast?.currentText == "No internet connection".localized {
                self.toast?.hideToastAlert()
            }
        }
    }
    
    func hideMaskView() {
        UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: 0.95, initialSpringVelocity: 0.5, options: [], animations: {
            let shrink = CGAffineTransform(scaleX: 0.1, y: 0.1);
            let translate = CGAffineTransform(translationX: 0, y: 512)
            self.fullMaskView.transform = shrink.concatenating(translate)
        }, completion: { completed in
            self.fullMaskView.isHidden = true
            //self.tabBarController?.setTabBarVisible(visible: true, animated: true)
        })
    }
    
    func configureProviderView() {
        
        if UserManager.shared.userInfo?.hasOptedForProvider == false {
            hideProviderView()
        }
        else {
            providerViewHeight.constant = 66
            let providerStatus = UserManager.shared.providerSubmissionStatus
            providerView.subbmissionStatus = providerStatus
        }
    }
    
    func hideProviderView() {
        
        DispatchQueue.main.async {
            self.providerView.clipsToBounds = true
            self.providerViewHeight.constant = 0
        }
    }
    
    func updateReachabilityInfo() {
        DispatchQueue.main.async {
            if !ReachabilityManager.shared.isReachable() {
                self.toast?.showToastAlert("No internet connection".localized, dismissable: false)
            } else if self.toast?.currentText == "No internet connection".localized {
                self.toast?.hideToastAlert()
            }
        }
    }
    
    func generalSettings() {
        
        SettingsService().retrieveSettings(completionHandler: { result in
            
            switch result {
            case .success(let settings):
                UserManager.shared.generalSettings = settings as? GeneralSettings
                
            case .failure(let error):
                
                self.handleError(error, requestType: RequestType.generalSettings, completion: {
                    self.generalSettings()
                })
            }
        })
    }
    
    func companyDetails() {
        
        LegalPersonService().getCompanyDetails(completionHandler: { result in
            
            switch result {
            case .success(let company):
                UserManager.shared.company = company as? Company
                
            case .failure(let error):
                
                self.handleError(error, requestType: RequestType.getCompany, completion: {
                    self.companyDetails()
                })
            }
        })
    }
    
    func providerDetails() {
        
        ProviderService().getProviderStatus(completionHandler: { result in
            
            switch result {
            case .success(let status):
                UserManager.shared.providerSubmissionStatus = status as? ProviderStatus
                DispatchQueue.main.async {
                    self.configureProviderView()
                }
                
            case .failure(let error):
                
                self.handleError(error, requestType: RequestType.getProviderDetails, completion: {
                    self.providerDetails()
                })
            }
        })
    }
    
    func userRoles() {
        
        UserInfoService().getRoles(completionHandler: { result in
            
            switch result {
            case .success(let userRoles):
                UserManager.shared.roles = userRoles as? [UserRoles]
                
            case .failure(let error):
                
                self.handleError(error, requestType: RequestType.userRoles, completion: {
                    self.userRoles()
                })
            }
        })
    }
    
    private func showZeroBalanceToastIfNeeded() {
        
        guard !preventPurchase else {
            return
        }
        
        let balanceValue = UserManager.shared.userInfo?.balance ?? 0
        balance = UserManager.shared.userInfo?.balance?.cleanString ?? "0"
        if balanceValue == 0, UserManager.shared.isLoggedIn {
            toast?.showToastAlert("Balance Empty Info Message".localized, type: .info)
        } else {
            toast?.hideToast()
        }
    }
    
    func retrieveUserInfo() {
        
        loadingView?.startAnimating()
        UserInfoService().retrieveUserInfo(completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
            case .success(let user):
                UserManager.shared.userInfo = user as? UserInfo
                self.balance = UserManager.shared.userInfo?.balance?.cleanString ?? "0"
                self.showZeroBalanceToastIfNeeded()
                
            case .failure(let error):
                self.handleError(error, requestType: RequestType.userInfo, completion: {
                    self.retrieveUserInfo()
                })
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
            
        case "FreeProxySegueID":
            let navController = segue.destination as? UINavigationController
            let destinationVC = navController?.viewControllers.first as? SearchViewController
            destinationVC?.onCountrySelected = { selectedCountry in
            }
            destinationVC?.isProxyFlow = true
            destinationVC?.countries = countries
            
        case "showTokenRequestSegueID":
            let nextVC = segue.destination as? UINavigationController
            let controller = nextVC?.viewControllers.first as? TokenRequestListController
            controller?.tokenRequests = tokenRequests ?? []
            
        default:
            break
        }
    }
    
    @IBAction func proxySegmentAction(_ sender: UISegmentedControl) {
        tableView?.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.tableView?.setContentOffset(.zero, animated: true)
        }
    }
    
    func getProxyCountryList() {
        
        loadingView?.startAnimating()
        ProxyService().getProxyCountryList(completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
            case .success(let countryList):
                ProxyManager.shared.proxyCountries = countryList as? [String]
                
            case .failure(let error):
                self.handleError(error, requestType: RequestType.getProxyCountryList, completion: {
                    self.getProxyCountryList()
                })
            }
        })
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
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    private func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 18
    }
    
    private func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    
    private func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 18))
        headerView.backgroundColor = .clear
        return headerView
    }
    
    private func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 5))
        footerView.backgroundColor = .clear
        return footerView
    }
    
}

extension DashboardViewController: ErrorPresentable {
    
    func handleError(_ error: Error, requestType: String, completion:(() -> ())? = nil) {
        
        switch error {
            
        case CustomError.expiredToken:
            
            LoginService().getNewAccessToken(errorHandler: { error in
                self.errorMessage = "Refresh Data Error Message".localized
                
            }, successHandler: {
                completion?()
            })
        case CustomError.emptyJson: break
        default:
            if requestType == RequestType.getProviderDetails {
                self.hideProviderView()
            }  else {
                self.errorMessage = "Refresh Data Error Message".localized
            }
        }
    }
}

extension DashboardViewController: ProviderDelegate {
    
    func openProviderDetails(hasSubmittedProviderRequest: Bool) {
        
        if hasSubmittedProviderRequest {
            performSegue(withIdentifier: "showAboutProviderSegue", sender: nil)
        }
        else {
            performSegue(withIdentifier: "showBecomeProviderSegue", sender: nil)
        }
    }
}