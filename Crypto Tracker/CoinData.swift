//
//  CoinData.swift
//  Crypto Tracker
//
//  Created by Apeksha Sahu on 8/20/18.
//  Copyright © 2018 Apeksha Sahu. All rights reserved.
//

import UIKit
import Alamofire

class CoinData {
    static let shared = CoinData()
    var coins = [Coin]()
    weak var delegate: CoinDataDelegate?
    
    private init() {
    let symbols = ["BTC","ETH","LTC"]
     
        for symbol in symbols {
            
            let coin = Coin(symbol: symbol)
           
           coins.append(coin)
        }
    }
    
    func html()-> String{
    var html = "<h1> My Crypto Report</h1>"
        html += "<h2> My Net worth: \(networthString()))</h2>"
        html += "<ul>"
        
        for coin in coins {
            if coin.amount != 0.0 {
                html += "<li></li>"
                html += "<li>\(coin.symbol) - I own: \(coin.amount) - valued at : \(doubleToMoneyString(double: coin.amount * coin.price))</li> "
            }
        }
      html += "</ul>"
        return html
    }
    
    func networthString()->String{
        var netWorth = 0.0
        for coin in coins {
            netWorth = netWorth + coin.amount * coin.price
        }
         return doubleToMoneyString(double: netWorth)
    }
    
    
    func getPrices() {
      var listOfSymbols = ""
        for coin in coins {
            listOfSymbols += coin.symbol
            if coin.symbol != coins.last?.symbol {
                 listOfSymbols += ","
            }
        }
      
       //fetchAllRooms(listOfSymbols)
        Alamofire.request("https://min-api.cryptocompare.com/data/pricemulti?fsyms=\(listOfSymbols)&tsyms=USD").responseJSON { (response)
            in
            if let json = response.result.value as? [String:Any] {
                for coin in self.coins {
                    if let coinJSON = json[coin.symbol] as? [String:Double] {
                        if let price = coinJSON["USD"] {
                            coin.price = price
                            UserDefaults.standard.set(price, forKey: coin.symbol)
                        }
                    }
                }
                self.delegate?.newPrices!()
            }
            print(response.result.value as Any)
        }
    }
    
    func doubleToMoneyString(double: Double)-> String{
        let formatter = NumberFormatter()
        
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .currency
        formatter.generatesDecimalNumbers = true
        if let fancyPrice = formatter.string(from: NSNumber(floatLiteral: double)) {
            return fancyPrice
        }else {
            return "Error"
        }
        
    }


}

// With URLSession
/*public func fetchAllRooms(completion: @escaping ([listOfSymbols]?) -> Void) {
    guard let url = URL(string: "https://min-api.cryptocompare.com/data/pricemulti?fsyms=\(listOfSymbols)&tsyms=USD") else {
        completion(nil)
        return
    }
    
    var urlRequest = URLRequest(url: url,
                                cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                timeoutInterval: 10.0 * 1000)
    urlRequest.httpMethod = "GET"
    urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
    
    let task = urlSession.dataTask(with: urlRequest)
    { (data, response, error) -> Void in
        guard error == nil else {
            print("Error while fetching remote rooms: \(String(describing: error)")
                completion(nil)
            return
        }
        
        guard let data = data,
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                print("Nil data received from fetchAllRooms service")
                completion(nil)
                return
        }
        
        guard let rows = json?["rows"] as? [[String: Any]] else {
            print("Malformed data received from fetchAllRooms service")
            completion(nil)
            return
        }
        
        let rooms = rows.flatMap { roomDict in return RemoteRoom(jsonData: roomDict) }
        completion(rooms)
    }
    
    task.resume()
}*/




@objc protocol CoinDataDelegate : class {
   @objc optional func newPrices()
   @objc optional func newHistory()
}



class Coin {
    
    var symbol  = ""
    var image = UIImage()
    var price = 0.0
    var amount = 0.0
    var historicalData = [Double]()
    
    init(symbol: String) {
        self.symbol = symbol
        if  let image = UIImage(named: symbol) {
            self.image = image
        }
        self.price = UserDefaults.standard.double(forKey: symbol)
        self.amount = UserDefaults.standard.double(forKey: symbol + "amount")
        if let history = UserDefaults.standard.array(forKey: symbol + "history") as? [Double] {
            self.historicalData = history
            
        }
    }
    
    func getHistoricalData(){
        
        Alamofire.request("https://min-api.cryptocompare.com/data/histoday?fsym=\(symbol)&tsym=USD&limit=30").responseJSON(completionHandler: { (response) in
            
            
            print(response.result.value as Any)
            if let json = response.result.value as? [String:Any] {
                if let pricesJSON = json["Data"] as? [[String:Double]] {
                 self.historicalData = []
                    for priceJSON in pricesJSON {
                        if let closePrice = priceJSON["close"] {
                            self.historicalData.append(closePrice)
                        }
                    }
                    CoinData.shared.delegate?.newHistory!()
                    UserDefaults.standard.set(self.historicalData, forKey: self.symbol + "history")
                }
            }
            
        })
        
        
    }
    
    
    
    func priceASString()-> String{
        
        if price == 0.0 {
            return "loading..."
        }
        
        return CoinData.shared.doubleToMoneyString(double: price)
    }
    
    func amaountAsString()-> String {
        return CoinData.shared.doubleToMoneyString(double: amount * price)
    }
}

