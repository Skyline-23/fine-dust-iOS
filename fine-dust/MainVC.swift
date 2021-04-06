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
    
    @IBOutlet weak var Label: UILabel!
    
    // lazy로 선언하여 메모리 관리
    lazy var locationManager = CLLocationManager().then {
        // 배터리에 따른 위치 최적화
        $0.desiredAccuracy = kCLLocationAccuracyBest
        $0.distanceFilter = kCLHeadingFilterNone
        // 권한을 요청
//        $0.requestWhenInUseAuthorization()
    }
    
    // 정보를 담을 struct 설정
    struct userLoaction {
        var latitude: Double!
        var longitude: Double!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        // Struct 저장
        var info = userLoaction()

        //위도 경도 가져오기
        let coor = locationManager.location?.coordinate
        info.latitude = coor?.latitude
        info.longitude = coor?.longitude
        
        if info.latitude != nil {
            
            TM(url: "http://dapi.kakao.com/v2/local/geo/transcoord", longitude: info.longitude!, latitude: info.latitude!) { response in
                info = response
            }
            
            Label.text = "latitude : \(info.latitude!)\nlongitude : \(info.longitude!)"
        }
        else {
            Label.text = "no location"
        }
    }
    
    func TM(url: String, longitude: Double, latitude: Double, handler: @escaping(userLoaction) -> Void) {
        var result = userLoaction()
        let headers:HTTPHeaders = ["Authorization" : "KakaoAK 41b8e7df68905f6788749d919520d22f"]
        let parameters: Parameters = ["x" : longitude, "y" : latitude, "output_coord" : "TM"]
        let alamo = AF.request(url, method: .get,parameters: parameters, encoding: URLEncoding.queryString ,headers: headers)
        alamo.responseJSON() { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let documents = json["documents"].arrayValue
                result.longitude = documents[0]["x"].double
                result.latitude = documents[0]["y"].double
                handler(result)
            case .failure(_):
                let alert = UIAlertController(title: nil, message: "네트워크를 다시 확인해주세요", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
    }
    

}

