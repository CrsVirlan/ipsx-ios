//
//  MarketItemController.swift
//  IPSX
//
//  Created by Calin Chitu on 19/11/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class MarketItemController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var progressView: ProgressRoundView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let cellSpacing: CGFloat = 12
    
    fileprivate let reuseIdentifier = "MarketItemCell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let progress = Double(arc4random_uniform(100))
        progressView.progress = progress
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension MarketItemController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
}

class CenteringFlowLayout: UICollectionViewFlowLayout {
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        guard let collectionView = collectionView,
            let layoutAttributesArray = layoutAttributesForElements(in: collectionView.bounds),
            var candidate = layoutAttributesArray.first else { return proposedContentOffset }
        
        layoutAttributesArray.filter({$0.representedElementCategory == .cell }).forEach { layoutAttributes in
            
            if (velocity.x > 0 && layoutAttributes.center.x > candidate.center.x) ||
                (velocity.x <= 0 && layoutAttributes.center.x < candidate.center.x) {
                candidate = layoutAttributes
            }
        }
        
        return CGPoint(x: candidate.center.x - collectionView.bounds.width / 2, y: proposedContentOffset.y)
    }
    
}

//extension MarketItemController: UICollectionViewDelegateFlowLayout {
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//
//        return cellSpacing
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        let frameSize = collectionView.frame.size
//        return CGSize(width: frameSize.width - cellSpacing, height: frameSize.height)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//
//        return UIEdgeInsets(top: 0, left: cellSpacing / 2, bottom: 0, right: cellSpacing / 2)
//    }
//}
