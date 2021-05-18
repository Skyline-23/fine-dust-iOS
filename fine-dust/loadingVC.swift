//
//  loadingVC.swift
//  fine-dust
//
//  Created by 김부성 on 2021/04/05.
//

import UIKit
import CoreLocation
import OSLog

import Then
import Alamofire
import SwiftyJSON

class loadingVC: UIViewController, CLLocationManagerDelegate {
    
    let key = keys()
    
    // lazy로 선언하여 메모리 관리
    lazy var locationManager = CLLocationManager().then {
        // 10미터 이내의 정확도로 설정을 하여 배터리 관리 최적화
        $0.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        // 거리 위치 변화를 감지하지 않음
        $0.distanceFilter = kCLHeadingFilterNone
        // 권한을 요청
        $0.requestWhenInUseAuthorization()
    }
    var count = 0
    
    // 정보를 담을 struct 설정
    struct userLocation {
        var latitude: Double!
        var longitude: Double!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    
    // 위치 정보가 업데이트 되면 실행되도록 delegate 함수 사용
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        if count == 0 {
            count += 1
            getLocation(location: locations[0]) { [self] info in
                if info.latitude != nil {
                    TM(url: "http://dapi.kakao.com/v2/local/geo/transcoord", longitude: info.longitude!, latitude: info.latitude!) { response in
                        getNearbyMsrstn(url: "http://apis.data.go.kr/B552584/MsrstnInfoInqireSvc/getNearbyMsrstnList", tmX: response.longitude, tmY: response.latitude) { stationName in
                            print(stationName)
                            getfinedust(url: "http://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty", stationName: stationName) { pmvalue, dataTime in
                                print(pmvalue)
                                print(dataTime)
                                presentView()
                            }
                        }
                    }
                }
                else {
                    os_log("no location")
                }
            }
        }
    }
    
    // 뷰 전환하기
    func presentView() {
        if let menuScreen = self.storyboard?.instantiateViewController(withIdentifier: "Main") {
            menuScreen.modalPresentationStyle = .fullScreen
            menuScreen.modalTransitionStyle = .coverVertical
            self.dismiss(animated: false) {
                self.present(menuScreen, animated: true, completion: nil)
            }
        }
    }
    
    func getLocation(location: CLLocation, handler: @escaping(userLocation) -> Void) {
        //위도 경도 가져오기
        var info = userLocation()
        let coord = locationManager.location?.coordinate
        info.latitude = coord?.latitude
        info.longitude = coord?.longitude
        let geoCoder: CLGeocoder = CLGeocoder()
        let local: Locale = Locale(identifier: "Ko-kr") // Korea
        geoCoder.reverseGeocodeLocation(location, preferredLocale: local) { place,error  in
            if let address: [CLPlacemark] = place {
                print("address saved")
                locationInfo.shared.nowLocationName = address.last!.locality!
                handler(info)
            }
        }
    }
    
    // TM좌표로 변환
    func TM(url: String, longitude: Double, latitude: Double, handler: @escaping(userLocation) -> Void) {
        var result = userLocation()
        let headers:HTTPHeaders = ["Authorization" : key.kakaoKey]
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
    
    // 근처 측정소 받아오기
    func getNearbyMsrstn(url: String, tmX: Double, tmY: Double, handler: @escaping(String) -> Void) {
        let parameters: Parameters = [
            "serviceKey" : key.airKoreaKey,
            "tmX" : tmX,
            "tmY" : tmY,
            "returnType" : "json"
        ]
        
        let alamo = AF.request(url, method: .get,parameters: parameters, encoding: URLEncoding.default)
        alamo.responseJSON() { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let stationName = json["response"]["body"]["items"][0]["stationName"].string!
                locationInfo.shared.stationName = stationName
                handler(stationName)
            case .failure(_):
                let alert = UIAlertController(title: nil, message: "네트워크를 다시 확인해주세요", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
    }
    
    // 미세먼지 값 받아오기
    func getfinedust(url: String, stationName: String, handler: @escaping(String, String) -> Void) {
        let parameters: Parameters = [
            "serviceKey" : key.airKoreaKey,
            "stationName" : stationName,
            "dataTerm" : "DAILY",
            "informCode" : "PM10",
            "returnType" : "json"
        ]
        
        let alamo = AF.request(url, method: .get,parameters: parameters, encoding: URLEncoding.default)
        alamo.responseJSON() { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let pm10Value = json["response"]["body"]["items"][0]["pm10Value"].string!
                let dataTime = json["response"]["body"]["items"][0]["dataTime"].string!
                locationInfo.shared.pmValue = pm10Value
                locationInfo.shared.dataTime = dataTime
                handler(pm10Value, dataTime)
            case .failure(_):
                let alert = UIAlertController(title: nil, message: "네트워크를 다시 확인해주세요", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
