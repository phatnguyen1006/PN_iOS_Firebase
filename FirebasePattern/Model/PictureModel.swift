//
//  PictureModel.swift
//  FirebasePattern
//
//  Created by Phat Nguyen on 09/09/2021.
//

import Foundation

class PictureModel {
    var avatar: String = ""
    
    init(dict: [String: Any]) {
        self.avatar = dict["Avatar"] as? String ?? ""
    }
}
