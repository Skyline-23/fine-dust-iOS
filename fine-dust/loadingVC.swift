//
//  loadingVC.swift
//  fine-dust
//
//  Created by 김부성 on 2021/04/05.
//

import UIKit
import CoreLocation

import RxSwift
import RxCocoa
import RxCoreLocation
import Then
import Alamofire
import SwiftyJSON

class loadingVC: UIViewController, CLLocationManagerDelegate {
    
    let key: keys = keys()
    let disposebag: DisposeBag = DisposeBag()
    var info: userLocation = userLocation()
    var cnt: UInt = 0
    
    // lazy로 선언하여 메모리 관리
    lazy var locationManager = CLLocationManager().then {
        // 10미터 이내의 정확도로 설정을 하여 배터리 관리 최적화
        $0.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        // 거리 위치 변화를 감지하지 않음
        $0.distanceFilter = kCLHeadingFilterNone
        // 권한을 요청
        $0.requestWhenInUseAuthorization()
    }
    
    // 정보를 담을 struct 설정
    struct userLocation {
        var latitude: Double!
        var longitude: Double!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.startUpdatingLocation()
        checkLocationAuth()
    }
    
    private func updateLocation() {
        locationManager.rx
            .location
            .subscribe(onNext: {
                self.locationManager.stopUpdatingLocation()
                if self.cnt == 0 {
                    self.cnt += 1
                    guard let location = $0 else { return }
                    print("latitude: \(location.coordinate.latitude) longitude: \(location.coordinate.longitude)")
                    self.info.longitude = location.coordinate.longitude
                    self.info.latitude = location.coordinate.latitude
                }
            })
            .disposed(by: disposebag)
    }
    
    func excute(task: () -> Void) {
        task()
    }
    
    private func checkLocationAuth() {
        locationManager.rx
            .didChangeAuthorization
            .subscribe(onNext: {
                switch $1 {
                case .denied:
                    print("denied")
                case .authorizedAlways, .authorizedWhenInUse:
                    self.excute(task: self.updateLocation)
                case .notDetermined:
                    print("not determined")
                case .restricted:
                    print("restricted")
                @unknown default:
                    break
                }
            }).disposed(by: disposebag)
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
