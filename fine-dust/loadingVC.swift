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
import Then
import Alamofire
import SwiftyJSON

class loadingVC: UIViewController, CLLocationManagerDelegate {
    
    let key = keys()
    let disposebag = DisposeBag()
    
    // lazy로 선언하여 메모리 관리
    lazy var locationManager = CLLocationManager().then {
        // 10미터 이내의 정확도로 설정을 하여 배터리 관리 최적화
        $0.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        // 거리 위치 변화를 감지하지 않음
        $0.distanceFilter = kCLHeadingFilterNone
        // 권한을 요청
        $0.requestWhenInUseAuthorization()
    }
    
    var manager = CLLocationManager()
    
    // 정보를 담을 struct 설정
    struct userLocation {
        var latitude: Double!
        var longitude: Double!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    private func bindUI() {
        manager.rx
            .location
            .subscribe(onNext: { location in
                guard let location = location else { return }
                print("")
            })
            .disposed(by: disposebag)
    }
    
    private func checkLocationAuth() {
        manager.rx
            .didChangeAutorization
            .subscribe(onNext: {_, status in
                switch status {
                case .denied:
                    print("denied")
                case .notDetermined:
                    print("not determined")
                case .restricted:
                    print("restricted")
                case .autorizedAlways, .autorizedWhenInUse:
                    print("good")
                }
            })
            .disposed(by: disposebag)
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
