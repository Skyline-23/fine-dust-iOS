//
//  loadingVC.swift
//  fine-dust
//
//  Created by 김부성 on 2021/04/05.
//

import UIKit
import CoreLocation

class loadingVC: UIViewController {

    var loactionManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loactionManager.requestWhenInUseAuthorization()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let menuScreen = self.storyboard?.instantiateViewController(withIdentifier: "Main") {
            menuScreen.modalPresentationStyle = .fullScreen
            menuScreen.modalTransitionStyle = .crossDissolve
            self.dismiss(animated: false) {
                self.present(menuScreen, animated: true, completion: nil)
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
