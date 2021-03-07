/*
    chatea - messaging mobile app
    Copyright (C) 2015-2021  Luca Cipressi [lucaji][@][mail.ru]

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

//
//  AppDelegate.swift
//  chatea
//
//  Created by Luca Cipressi on 23/04/2017.
//  Updated by Luca Cipressi on 05/08/2017.
//  Updated by Luca Cipressi on 18/11/2018.
//  Open Source adaption edited by Luca Cipressi on 07/03/2021.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

   
    var window: UIWindow?

    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        CTNetworkManager.singleton().networkConnection = true
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
}
