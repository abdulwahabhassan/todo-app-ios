//
//  AppDelegate.swift
//  Destini
//
//  Created by Philipp Muellauer on 01/09/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import RealmSwift //import realm

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //print(Realm.Configuration.defaultConfiguration.fileURL) //print location where realm file is stored. View using realm browser
        
        //initialize realm
        do { // the initialization of realm can throw, hence we try it in a do-catch block
            _ = try Realm()
        } catch {
            print("error initializing realm \(error)")
        }
        
        return true
    }


}

