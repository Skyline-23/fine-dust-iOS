//
//  locationModel.swift
//  fine-dust
//
//  Created by 김부성 on 2021/04/06.
//

import Foundation


class locationInfo {
    static let shared = locationInfo()
    
    var nowLocationName: String?
    var longitude: Double?
    var latitude: Double?
    var pmValue: String?
    var dataTime: String?
    var stationName: String?

    private init() { }
}
