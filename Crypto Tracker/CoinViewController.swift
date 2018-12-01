//
//  CoinViewController.swift
//  Crypto Tracker
//
//  Created by Apeksha Sahu on 8/22/18.
//  Copyright © 2018 Apeksha Sahu. All rights reserved.
//

import UIKit
import SwiftChart

private let chartHeight : CGFloat = 300.0
private let imageSize : CGFloat = 100.0
private let priceLabelheight : CGFloat = 25.0


class CoinViewController: UIViewController,CoinDataDelegate {

    var chart = Chart()
    var coin : Coin?
    var priceLAbel = UILabel()
    var yourOwnLabel = UILabel()
    var wordLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let coin = coin {
        CoinData.shared.delegate = self
        edgesForExtendedLayout = []
        view.backgroundColor = UIColor.white
            
        title = coin.symbol
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped))
        chart.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: chartHeight)
        
        chart.yLabelsFormatter = {CoinData.shared.doubleToMoneyString(double: $1)}
        chart.xLabels = [0,5,10,15,20,25,30]
        chart.xLabelsFormatter = {String(Int(round(30 - $1)))}
        view.addSubview(chart)
        
        let imageView = UIImageView(frame: CGRect(x: view.frame.size.width/2 - imageSize/2, y: chartHeight, width: imageSize, height: imageSize))
            imageView.image = coin.image
        view.addSubview(imageView)
        
         priceLAbel.frame = CGRect(x: 0, y: chartHeight + imageSize, width: view.frame.size.width, height: priceLabelheight)
          
        priceLAbel.textAlignment = .center
        view.addSubview(priceLAbel)
        
        yourOwnLabel.frame = CGRect(x: 0, y: chartHeight + imageSize + priceLabelheight * 2, width: view.frame.size.width, height: priceLabelheight)
        yourOwnLabel.textAlignment = .center
        yourOwnLabel.font = UIFont.boldSystemFont(ofSize: 20)
            
            
            wordLabel.frame = CGRect(x: 0, y: chartHeight + imageSize + priceLabelheight * 3, width: view.frame.size.width, height: priceLabelheight)
            wordLabel.textAlignment = .center
            wordLabel.font = UIFont.boldSystemFont(ofSize: 20)
        
           
            view.addSubview(wordLabel)
        
            coin.getHistoricalData()
            newPrices()
        }
        // Do any additional setup after loading the view.
    }

    func newHistory() {
        let series = ChartSeries((coin?.historicalData)!)
        series.area = true
        chart.add(series)
    }
    
    @objc func editTapped(){
     
        let alert = UIAlertController(title: "How much \(coin?.symbol ?? "0") do you own?", message: nil, preferredStyle: .alert)
        alert.addTextField { (textfield) in
            textfield.placeholder = "0.5"
            textfield.keyboardType = .decimalPad
            if self.coin?.amount != 0.0 {
                textfield.text = "\(self.coin?.amount ?? 0)"
            }
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if let text = alert.textFields![0].text {
                if let amount = Double(text) {
                    self.coin?.amount = amount
                    UserDefaults.standard.set(amount, forKey: (self.coin?.symbol)! + "amount")
                    self.newPrices()
                }
            }
        }))
    self.present(alert, animated: true, completion: nil)
    }
    
    
    func newPrices() {
        if let coin = coin {
            priceLAbel.text = coin.priceASString()
            wordLabel.text = coin.amaountAsString()
            yourOwnLabel.text = "You Own: \(String(describing: coin.amount)) \(coin.symbol)"
            view.addSubview(yourOwnLabel)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
