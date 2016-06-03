//
//  InAppSettingsKitSampleAppAppDelegate.m
//  InAppSettingsKitSampleApp
//  http://www.inappsettingskit.com
//
//  Copyright (c) 2009-2010:
//  Luc Vandal, Edovia Inc., http://www.edovia.com
//  Ortwin Gentz, FutureTap GmbH, http://www.futuretap.com
//  Manuel "StuFF mc" Carrasco Molina, http://www.pomcast.biz
//  All rights reserved.
//
//  It is appreciated but not required that you give credit to Luc Vandal and Ortwin Gentz,
//  as the original authors of this code. You can give credit in a blog post, a tweet or on
//  a info page of your app. Also, the original authors appreciate letting them know if you use this code.
//
//  This code is licensed under the BSD license that is available at: http://www.opensource.org/licenses/bsd-license.php
//
//	Settings Icon (also used in App Icon) thanks to http://glyphish.com/

import UIKit

@UIApplicationMain
class AppDelegate : UIResponder, UIApplicationDelegate {
    var window : UIWindow?
    var tabBarController : UITabBarController?
    
    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        
        self.window = UIWindow()
        self.tabBarController = UITabBarController()
        let arr = UINib(nibName: "MainWindow", bundle: nil).instantiateWithOwner(nil, options: nil)
        self.window!.rootViewController = arr[0] as? UIViewController
        self.window!.addSubview(self.tabBarController!.view)
        self.window!.makeKeyAndVisible()
        return true
    }
    
}

