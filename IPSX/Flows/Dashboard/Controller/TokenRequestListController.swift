//
//  TokenRequestListController.swift
//  IPSX
//
//  Created by Calin Chitu on 02/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

//TODO: logic for datasource & update 

class TokenRequestListController: UIViewController {

    let cellID = "TokenRequestCellID"
    var tokenRequests: [TokenRequest] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

extension TokenRequestListController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tokenRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! TokenRequestCell
        cell.configure(tokenRequest: tokenRequests[indexPath.item])
        return cell
    }
}


class TokenRequestCell: UITableViewCell {
    
    @IBOutlet weak var aliasLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var completedView: RoundedView!
    @IBOutlet weak var pendingView: RoundedView!
    
    func configure(tokenRequest: TokenRequest) {
        //TODO (CC): Get the wallet name
        //aliasLabel.text = tokenRequest.ethID
        if let date = tokenRequest.created {
            dateLabel.text = DateFormatter.dateStringForTokenRequests(date: date)
        }
        quantityLabel.text = "Requested: " + tokenRequest.amount
        pendingView.isHidden   = tokenRequest.status != "pending"
        completedView.isHidden = tokenRequest.status != "completed"
    }
}
