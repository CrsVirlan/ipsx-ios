//
//  ProfileViewController.swift
//  IPSX
//
//  Created by Calin Chitu on 25/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBAction func logoutButtonAction(_ sender: UIButton) {
        
        //TODO (CVI): perform logout request
        UserManager.shared.removeUserDetails()
        performSegue(withIdentifier: "showLandingSegueID", sender: nil)
    }
    
    let cellID = "ETHAddressCellID"
    var userInfo: UserInfo? { return UserManager.shared.userInfo }
    var ethAdresses: [EthAddress] = []
    private var selectedAddress: EthAddress?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedAddress = nil
        if let addresses = userInfo?.ethAddresses {
            ethAdresses = addresses
            tableView.reloadData()
        }
    }
    
    private func updateUI() {
        userImageView.layer.cornerRadius = userImageView.frame.size.height / 2
        userImageView.layer.borderColor  = UIColor.darkBlue.cgColor
        userImageView.layer.borderWidth  = 1
        if let firstName = userInfo?.firstName {
            let lastName = userInfo?.lastName ?? ""
            usernameLabel.text = firstName + " " + lastName
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "walletViewIdentifier", let addController = segue.destination as? AddWalletController {
            addController.ethereumAddress = selectedAddress
        }
    }
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ethAdresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ProfileWalletCell
        let ethAddress = ethAdresses[indexPath.item]
        cell.configure(address: ethAddress)
        return cell
    }
}

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedAddress = ethAdresses[indexPath.item]
        performSegue(withIdentifier: "walletViewIdentifier", sender: self)
    }
}

class ProfileWalletCell: UITableViewCell {
    
    @IBOutlet weak var aliasLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var statsuImageView: UIImageView!
    
    func configure(address: EthAddress) {
        aliasLabel.text = address.alias
        addressLabel.text = address.address
        switch address.validationState {
        case .verified:
            statsuImageView.image = UIImage(named: "walletAccepted")
        case .pending:
            statsuImageView.image = UIImage(named: "walletPending")
        case .rejected:
            statsuImageView.image = UIImage(named: "walletRejected")
        }
    }
    
}
