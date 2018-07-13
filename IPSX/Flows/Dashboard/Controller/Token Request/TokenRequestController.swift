//
//  TokenRequestController.swift
//  IPSX
//
//  Created by Calin Chitu on 02/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class TokenRequestController: UIViewController {

    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var selectedWalletAlias: UILabel!
    @IBOutlet weak var selectedWalletAddress: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dropdownView: UIView!
    @IBOutlet weak var dropdownArrow: UIImageView!
    @IBOutlet weak var dropdownButton: UIButton!
    @IBOutlet weak var dropdownCloseButton: UIButton!
    @IBOutlet weak var dropDownTopConstraint: NSLayoutConstraint! {
        didSet { topConstraint = dropDownTopConstraint }
    }
    
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var walletImageView: UIImageView!
    
    var userInfo: UserInfo? { return UserManager.shared.userInfo }
    var ethAdresses: [EthAddress] = []
    private var selectedAddress: EthAddress?
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?

    var errorMessage: String? {
        didSet {
            toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
        }
    }
    
    @IBAction func submitAction(_ sender: UIButton) {
        
        let ethID  = selectedAddress?.ethID ?? 0
        let amount = amountTextField.text ?? "0"
        let options = UserManager.shared.generalSettings
        let amountInt = Int(amount) ?? 0
        
        guard amountInt >= (options?.depositMin ?? 20), Int(amount)! <= (options?.depositMax ?? 5000) else {
            let min = options?.depositMin ?? 20
            let max = options?.depositMax ?? 5000
            let limitsString = String(format: "Amount Limits Error Message Min %@ Max %@".localized, "\(min)", "\(max)")
            toast?.hideToastAlert() {
                self.toast?.showToastAlert(limitsString, autoHideAfter: 5)
            }
            return
        }
        
        guard ethID != 0 else {
            toast?.showToastAlert("Select Valid ETH Wallet Message".localized, autoHideAfter: 5)
            return
        }
        requestTokens(ethID: ethID, amount: amount)
    }
    
    func requestTokens(ethID: Int, amount: String) {
        
        loadingView?.startAnimating()
        TokenDepositService().requestTokens(ethID: ethID, amount: amount, completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
            case .success(_):
                
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            case .failure(let error):
                
                self.handleError(error, requestType: .requestTokens, completion: {
                    self.requestTokens(ethID: ethID, amount: amount)
                })
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: dropdownView, text: "")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAndSetDefaultAddres()
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
    }
    
    @objc public func reachabilityChanged(_ note: Notification) {
        DispatchQueue.main.async {
            let reachability = note.object as! Reachability
            
            if !reachability.isReachable {
                self.toast?.showToastAlert("No internet connection".localized, dismissable: false)
            } else {
                self.toast?.hideToastAlert()
            }
        }
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func dropdownAction(_ sender: Any) {
        updateDropDown(visible: true)
    }
    
    @IBAction func dropdownCloseAction(_ sender: Any) {
        updateDropDown(visible: false)
    }
    
    private func loadAndSetDefaultAddres() {
        selectedAddress = nil
        if let addresses = UserManager.shared.ethAddresses {
            ethAdresses = addresses.filter { return  $0.validationState == .verified }
            if let defaultAddrID = UserDefaults.standard.loadDelfaultETHAddressID() {
                let matches = ethAdresses.filter { return $0.ethID == defaultAddrID }
                if matches.count == 1 {
                    selectedAddress = matches.first
                } else {
                    selectedAddress = ethAdresses.first
                }
            } else if let firstAddr = ethAdresses.first {
                selectedAddress = firstAddr
            }
            if let validAddress = selectedAddress {
                UserDefaults.standard.storeDelfaultETHAddressID(ethAddressID: validAddress.ethID)
                updateSelectedAddresUI(ethAddres: validAddress)
            } else {
                walletImageView.image = UIImage(named: "walletRejected")
                submitButton.isEnabled = false
            }
            tableView.reloadData()
        }
        if ethAdresses.count < 2 {
            dropdownArrow.isHidden = true
            dropdownButton.isHidden = true
        }
    }
    
    private func updateUI() {
        tableViewBottomConstraint.constant = tableView.frame.size.height
        tableViewTopConstraint.constant = -tableView.frame.size.height
    }
    
    private func updateSelectedAddresUI(ethAddres: EthAddress) {
        selectedWalletAlias.text   = ethAddres.alias
        selectedWalletAddress.text = ethAddres.address
    }
    
    fileprivate func updateDropDown(visible: Bool) {
        dropDownTopConstraint.constant     = visible ? -100 : 0
        tableViewBottomConstraint.constant = visible ?    0 : tableView.frame.size.height
        tableViewTopConstraint.constant    = visible ?    0 : -tableView.frame.size.height
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 0.5, options: [], animations: {
            self.view?.layoutIfNeeded()
            self.tableView.alpha    = visible ? 1 : 0
            self.dropdownView.alpha = visible ? 0 : 1
            self.dropdownCloseButton.alpha = visible ? 1 : 0
            self.backButton.alpha   = visible ? 0 : 1
            self.submitButton.alpha = visible ? 0 : 1
        }, completion: { completed in
        })
    }
}

extension TokenRequestController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ethAdresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: EthWalletCell.cellID, for: indexPath) as! EthWalletCell
        let ethAddress = ethAdresses[indexPath.item]
        cell.configure(address: ethAddress)
        return cell
    }
}

extension TokenRequestController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedAddress = ethAdresses[indexPath.item]
        if let validAddres = selectedAddress {
            UserDefaults.standard.storeDelfaultETHAddressID(ethAddressID: validAddres.ethID)
            updateSelectedAddresUI(ethAddres: validAddres)
        }
        updateDropDown(visible: false)
    }
}

extension TokenRequestController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}

extension TokenRequestController: ErrorPresentable {
    
    func handleError(_ error: Error, requestType: IPRequestType, completion:(() -> ())? = nil) {
        
        switch error {
            
        case CustomError.expiredToken:
            
            LoginService().getNewAccessToken(errorHandler: { error in
                self.errorMessage = "Generic Error Message".localized
                
            }, successHandler: {
                completion?()
            })
        default:
            self.errorMessage = "Generic Error Message".localized
        }
    }
}