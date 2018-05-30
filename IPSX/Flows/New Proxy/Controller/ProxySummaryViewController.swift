//
//  ProxySummaryViewController.swift
//  IPSX
//
//  Created by Cristina Virlan on 26/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class ProxySummaryViewController: UIViewController {
    
    let proxyPackCellID = "ProxyPackCellID"
    var proxy: Proxy?
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    //TODO (CC): add loadingView
    @IBOutlet weak var loadingView: CustomLoadingView!
    
    //TODO (CC): add toast alert
    var toast: ToastAlertView?
    var errorMessage: String? {
        didSet {
            toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
        }
    }
    
    @IBAction func BackButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func CancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureUI()
    }
        
    func configureUI() {
        
        let deviceHeight = UIScreen.main.bounds.height
        if deviceHeight <= 568 {
            bottomConstraint.constant = bottomConstraint.constant - 70
        }
    }
    
    @IBAction func confirmOrderAction(_ sender: Any) {
        
        loadingView?.startAnimating()
        IPService().getPublicIPAddress(completion: { error, ipAddress in
            
            self.loadingView?.stopAnimating()
            guard let ipAddress = ipAddress, error == nil else {
                
                self.errorMessage = "Generic Error Message".localized
                return
            }
            self.createProxy(userIP: ipAddress, proxy: self.proxy)
        })
    }
    
    func createProxy(userIP: String, proxy: Proxy?) {
        
        self.loadingView?.startAnimating()
        ProxyService().createProxy(userIP: userIP, proxy: proxy, completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
                
            case .success(let proxy):
                
                DispatchQueue.main.async {
                    self.proxy = proxy as? Proxy
                    self.performSegue(withIdentifier: "ProxyDetailsSegueiID", sender: self)
                }
                
            case .failure(let error):
                self.handleError(error, requestType: .createProxy, completion: {
                    self.createProxy(userIP: userIP, proxy: proxy)
                })
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProxyDetailsSegueiID" {
            let nextVC = segue.destination as? ProxyDetailsViewController
            nextVC?.proxy = proxy
        }
    }
}

extension ProxySummaryViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0: return 1
            case 1: return 3
            default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
            
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: proxyPackCellID, for: indexPath) as! ProxyPackCell
            guard let selectedProxyPack = proxy?.proxyPack else { return UITableViewCell() }
            cell.configure(proxyPack: selectedProxyPack)
            return cell

        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProxyDetailsCell.cellID, for: indexPath) as! ProxyDetailsCell
            
            switch indexPath.row {
            case 0:
                let startDate = proxy?.proxyDetails?.startDate?.dateToString(format: "dd MMM yyyy") ?? "20 Apr 2018"
                let startHour = proxy?.proxyDetails?.startDate?.dateToString(format: "HH:mm") ?? "12:00"
                cell.configure(title: "Start Date".localized, value: startDate, additionalDetail: startHour)
                return cell
                
            case 1:
                let endDate = proxy?.proxyDetails?.endDate?.dateToString(format: "dd MMM yyyy") ?? "20 Apr 2018"
                let endHour = proxy?.proxyDetails?.endDate?.dateToString(format: "HH:mm") ?? "12:00"
                cell.configure(title: "End Date".localized, value: endDate, additionalDetail: endHour)
                return cell
                
            case 2:
                cell.configure(title: "Country".localized, value: proxy?.proxyDetails?.country)
                return cell
                
            default:
                return UITableViewCell()
            }
        default:
            return UITableViewCell()
        }
        
    }
}

extension ProxySummaryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 88
        case 1:
            return UITableView.IPSXTableViewDefault.smallRowHeight
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var title = ""
        switch section {
            case 0: title = "Package".localized
            case 1: title = "Other Details".localized
            default: return nil
        }
        return tableView.standardHeaderView(withTitle: title)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.IPSXTableViewDefault.sectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}

extension ProxySummaryViewController: ErrorPresentable {
    
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











