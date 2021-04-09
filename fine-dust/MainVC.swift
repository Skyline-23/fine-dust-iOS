//
//  ViewController.swift
//  fine-dust
//
//  Created by 김부성 on 2021/04/05.
//

import UIKit
import CoreLocation

import Then
import Alamofire
import SwiftyJSON

class MainVC: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var fineDustLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentLocationLabel.text = "\(locationInfo.shared.nowLocationName!)"
        fineDustLabel.text = "\(locationInfo.shared.pmValue!)㎍/㎥"
        infoLabel.text = "측정시간 : \(locationInfo.shared.dataTime!)\n측정소 위치 : \(locationInfo.shared.stationName!)"
        // Do any additional setup after loading the view.
    }
    

}

