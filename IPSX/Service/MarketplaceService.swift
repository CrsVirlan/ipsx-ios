//
//  MarketplaceService.swift
//  IPSX
//
//  Created by Cristina Virlan on 23/11/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation
import IPSXNetworkingFramework

class MarketplaceService {
    
    func retrieveOffers(completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] = [:] //TODO for filters
        let request = createRequest(requestType: RequestType.getOffers, urlParams: urlParams)
        RequestManager.shared.executeRequest(request: request, completion: { error, data in
            
            guard error == nil else {
                switch error! {
                    
                case RequestError.custom(let statusCode, let responseCode):
                    let customError = generateCustomError(error: error!, statusCode: statusCode, responseCode: responseCode, request: request)
                    completionHandler(ServiceResult.failure(customError))
                    return
                    
                default:
                    completionHandler(ServiceResult.failure(error!))
                    return
                }
            }
            guard let data = data else {
                completionHandler(ServiceResult.failure(RequestError.noData))
                return
            }
            let json = JSON(data)
            let jsonArray = json["offers"].arrayValue
            
            var offers = self.parseOffers(offersJsonArray: jsonArray)
            offers.sort { $0.id < $1.id }
            completionHandler(ServiceResult.success(offers))
        })
    }
    
    private func parseOffers(offersJsonArray: [JSON]) -> [Offer] {
        
        var offers: [Offer] = []
        for offerJson in offersJsonArray {
            
            let status       = offerJson["status"].stringValue
            let offerID      = offerJson["id"].intValue
            let priceIPSX    = offerJson["cost_ipsx"].doubleValue
            let priceDollars = offerJson["cost"].doubleValue
            let durationMin  = offerJson["duration"].stringValue
            let trafficMB    = offerJson["traffic"].stringValue
            
            let proxyJsonArray = offerJson["proxy_items"].arrayValue
            
            let offer = Offer(id: offerID, priceIPSX: priceIPSX, priceDollars: priceDollars, durationMin: durationMin, trafficMB: trafficMB)
            let proxies = self.parseProxyItems(proxyJsonArray: proxyJsonArray)
            offer.setProxies(proxyArray: proxies)
            
            if status == "active" { offers.append(offer) }
        }
        return offers
    }
    
    private func parseProxyItems(proxyJsonArray: [JSON]) -> [Proxy] {
        
        var proxies: [Proxy] = []
        for proxyJson in proxyJsonArray {
            
            let status      = proxyJson["resource"]["status"].stringValue
            let proxyID     = proxyJson["id"].intValue
            let countryName = proxyJson["resource"]["location"]["country"][0]["name"].stringValue
            let sla         = proxyJson["resource"]["sla"].stringValue
            let ipType      = proxyJson["resource"]["ip_version"].intValue
            let proxyType   = proxyJson["resource"]["resource_type"].stringValue
            
            let featuresArray = proxyJson["resource"]["protocol"].arrayValue
            let features = parseFeatures(featuresJsonArray: featuresArray)
            
            let proxy = Proxy(id: proxyID, countryName: countryName, sla: sla, ipType: ipType, proxyType: proxyType, features: features)
            if status == "ready" { proxies.append(proxy) }
        }
        return proxies
    }
    
    /// Example of Return: ["http(s)", "socks5", "shadowsocks", "vpn"]
    private func parseFeatures(featuresJsonArray: [JSON]) -> [String] {
        
        var features: [String] = []
        for featureJson in featuresJsonArray {
            
            let status = featureJson["status"].stringValue
            let name   = featureJson["name"].stringValue
            if status == "on" { features.append(name) }
        }
        return features
    }
  
}
