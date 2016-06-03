//
//  MainViewController.swift
//  InAppSettingsKitSampleApp
//  http://www.inappsettingskit.com
//
//  Copyright (c) 2009-2010:
//  Luc Vandal, Edovia Inc., http://www.edovia.com
//  Ortwin Gentz, FutureTap GmbH, http://www.futuretap.com
//  All rights reserved.
//
//  It is appreciated but not required that you give credit to Luc Vandal and Ortwin Gentz,
//  as the original authors of this code. You can give credit in a blog post, a tweet or on
//  a info page of your app. Also, the original authors appreciate letting them know if you use this code.
//
//  This code is licensed under the BSD license that is available at: http://www.opensource.org/licenses/bsd-license.php
//

import UIKit
import MessageUI

import InAppSettingsKit

//@objc(MainViewController) 
public class MainViewController: UIViewController, UIPopoverControllerDelegate, IASKSettingsDelegate, UITextViewDelegate {

    struct TableViewConstants {
        static let tableViewCellIdentifier = "customCell"
    }

    @IBOutlet var appSettingsViewController : IASKAppSettingsViewController?
    @IBOutlet var tabAppSettingsViewController : IASKAppSettingsViewController?
    //@IBOutlet public var navigationController : UINavigationController?
    var currentPopoverController : UIPopoverController?
    
    override public func viewDidLoad() {
        //appSettingsViewController.init()
        appSettingsViewController!.delegate = self
        tabAppSettingsViewController!.delegate = self
        let enabled : Bool = NSUserDefaults.standardUserDefaults().boolForKey("AutoConnect")
        appSettingsViewController!.hiddenKeys = enabled ? nil : NSSet.init(objects: "AutoConnectLogin", "AutoConnectPassword") as Set<NSObject>
    }

    @IBAction func showSettingsPush(sender: AnyObject) {
        //[viewController setShowCreditsFooter:NO];   // Uncomment to not display InAppSettingsKit credits for creators.
        // But we encourage you no to uncomment. Thank you!
        self.appSettingsViewController!.showDoneButton = false
        self.appSettingsViewController!.navigationItem.rightBarButtonItem = nil
        self.navigationController!.pushViewController(self.appSettingsViewController!, animated: true)
    }
    @IBAction func showSettingsModal(sender: AnyObject) {
        let aNavController : UINavigationController = UINavigationController.init(rootViewController: self.appSettingsViewController!)
        //self.appSettingsViewController!.showCreditsFooter = false   // Uncomment to not display InAppSettingsKit credits for creators.
        // But we encourage you not to uncomment. Thank you!
        self.appSettingsViewController!.showDoneButton = true
        self.presentViewController(aNavController, animated: true, completion: nil)
    }
    
    func showSettingsPopover(sender: AnyObject) {
        if self.currentPopoverController != nil {
            dismissCurrentPopover()
            return;
        }
                
        self.appSettingsViewController!.showDoneButton = false
        let navController : UINavigationController = UINavigationController.init(rootViewController: self.appSettingsViewController!)
        let popover : UIPopoverController = UIPopoverController.init(contentViewController: navController)
        popover.delegate = self;
        popover.presentPopoverFromBarButtonItem(sender as! UIBarButtonItem, permittedArrowDirections: .Up, animated: false)
        self.currentPopoverController = popover
    }

    public override func awakeFromNib() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(settingDidChange), name: kIASKAppSettingChanged, object: nil)
        let enabled : Bool = NSUserDefaults.standardUserDefaults().boolForKey("AutoConnect")
        //	self.tabAppSettingsViewController.hiddenKeys = enabled ? nil : [NSSet setWithObjects:@"AutoConnectLogin", @"AutoConnectPassword", nil];
        var keys : NSArray = ["AutoConnectLogin", "AutoConnectPassword"]
        var keysSet : NSSet = NSSet.init(objects: keys)
        self.tabAppSettingsViewController!.hiddenKeys = enabled ? nil : keysSet as Set<NSObject>
                    
        if ((UIDevice.currentDevice().userInterfaceIdiom == .Pad)) {
            var actionBarButtonItem: UIBarButtonItem {
                return UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(MainViewController.showSettingsPopover(_:)))
            }
            self.navigationItem.rightBarButtonItem = actionBarButtonItem
        }
    }

    // Mark - View Lifecycle
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if self.currentPopoverController != nil {
            dismissCurrentPopover()
        }
    }
    
    func dismissCurrentPopover() {
        self.currentPopoverController!.dismissPopoverAnimated(true)
        self.currentPopoverController = nil
    }

    // Mark - IASKAppSettingsViewControllerDelegate protocol

    public func settingsViewControllerDidEnd(sender: IASKAppSettingsViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)

        // your code here to reconfigure the app for changed settings
    }
    
    // optional delegate method for handling mail sending result
    //- (void)settingsViewController:(id<IASKViewController>)settingsViewController mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {

    @objc public func settingsViewController(settingsViewController: IASKViewController, mailComposeController controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError) {

        var detail : String = ""
        var cancelLabel : String = ""

        let mailMsgResultCancelled = "cancelled, not sent."
        let mailMsgResultSaved     = "saved by you."
        let mailMsgResultSent      = "sent."
        let mailMsgResultFailed    = "lost in failed send attempt."
        let mailMsgResultNotSent   = "not sent."
        let mailMsgCancelOK        = "OK"
        let mailMsgCancelEditLater = "Edit Draft Later"

        switch (result) {
        case MFMailComposeResultSent:
            detail = mailMsgResultSent
            cancelLabel = mailMsgCancelOK
        break
        case MFMailComposeResultCancelled:
            detail = mailMsgResultCancelled
            cancelLabel = mailMsgCancelOK
        break
        case MFMailComposeResultSaved:
            detail = mailMsgResultSaved
            cancelLabel = mailMsgCancelEditLater
        break
        case MFMailComposeResultFailed:
            detail = mailMsgResultFailed
            cancelLabel = mailMsgCancelOK
        break
        default:
            detail = mailMsgResultNotSent
            cancelLabel = mailMsgCancelOK
        }
        let message : String = "Mail was: \(detail)"
        let alertText : String = "Mail Result\n\n\(message)"
        // ideally, a one button alert would be nice...
        print("message: \(message): status: \(alertText)")
    }
    public func settingsViewController(settingsViewController: IASKViewController, tableView: UITableView, heightForHeaderForSection section: NSInteger) -> CGFloat {
        let key : NSString = settingsViewController.settingsReader.keyForSection(section)
        if key == "IASKLogo" {
            return UIImage.init(imageLiteral: "Icon.png").size.height + 25.0
        } else if key == "IASKCustomHeaderStyle" {
            return 55.0
        }
        return 0
    }
    
    public func settingsViewController(settingsViewController: IASKViewController, tableView: UITableView, viewForHeaderForSection section: NSInteger) -> UIView? {
        let key : NSString = settingsViewController.settingsReader!.keyForSection(section)
        if key == "IASKLogo" {
            let imageView : UIImageView = UIImageView.init(image: UIImage.init(imageLiteral: "Icon.png"))
            imageView.contentMode = .Center
            return imageView
        } else if key == "IASKCustomHeaderStyle" {
            let label : UILabel = UILabel.init(frame: CGRectZero)
            label.backgroundColor = UIColor.clearColor()
            label.textAlignment = .Center
            label.textColor = UIColor.redColor()
            label.shadowColor = UIColor.whiteColor()
            label.shadowOffset = CGSizeMake(0, 1)
            label.numberOfLines = 0
            label.font = UIFont.boldSystemFontOfSize(16.0)
            
            //figure out the title from settingsbundle
            label.text = settingsViewController.settingsReader!.titleForSection(section)
            
            return label
        }
        return nil
    }
    
    public func tableView(tableView: UITableView!, heightForSpecifier specifier: IASKSpecifier!) -> CGFloat {
        if specifier.key() == "customCell" {
            return 44*3
        }
        return 0
    }
    
    public func tableView(tableView: UITableView!, cellForSpecifier specifier: IASKSpecifier!) -> UITableViewCell! {
        var cell : CustomViewCell = tableView.dequeueReusableCellWithIdentifier(specifier!.key())
        if !cell {
            cell = NSBundle.mainBundle().loadNibNamed("CustomViewCell", owner: self, options:nil)
        }
        let ud = NSUserDefaults.standardUserDefaults()
        cell.textView.text = ud.objectForKey(specifier.key()) != nil ? ud.objectForKey(specifier.key()) : specifier.defaultStringValue
        cell.textView.delegate = self
        cell.setNeedsLayout()
        return cell
    }

    // Mark - kIASKAppSettingChanged notification
    func settingDidChange(notification: NSNotification) {
        if notification.userInfo?.keys.first == "AutoConnect" {
            let activeController : IASKAppSettingsViewController = notification.object as! IASKAppSettingsViewController
            let enabled : Bool = (notification.userInfo?["AutoConnect"]!.boolValue)!
            var keys : NSArray = ["AutoConnectLogin", "AutoConnectPassword"]
            var keysSet : NSSet = NSSet.init(objects: keys)
            activeController.hiddenKeys = enabled ? nil : keysSet as Set<NSObject>
        }
    }

    // Mark - UITextViewDelegate (for CustomViewCell)
    @objc public func textViewDidChange(textView: UITextView) {
        let ud = NSUserDefaults.standardUserDefaults()
        let nc = NSNotificationCenter.defaultCenter()
        ud.setObject(textView.text, forKey: "customCell")
        nc.addObserver(self, selector: #selector(settingDidChange), name: kIASKAppSettingChanged, object: nil)
        let changedText : [ NSObject : AnyObject ] = [ "customCell" as NSObject: textView.text as AnyObject ]
        nc.postNotificationName(kIASKAppSettingChanged, object: self, userInfo: changedText)
    }

    // Mark - UIPopoverControllerDelegate
    public func popoverControllerDidDismissPopover(popoverController: UIPopoverController) {
        self.currentPopoverController = nil
    }

    // Mark -
    public func settingsViewController(sender: IASKAppSettingsViewController, buttonTappedForSpecifier specifier: IASKSpecifier) {
        if specifier.key() == "ButtonDemoAction1" {
            let alert : UIAlertView = UIAlertView.init(title: "Demo Action 1 called", message: nil, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        } else if specifier.key() == "ButtonDemoAction2" {
            let ud = NSUserDefaults.standardUserDefaults()
            let newTitle : String = ud.objectForKey(specifier.key() as String) == "Logout" ? "Login" : "Logout"
            ud.setValue(newTitle, forKeyPath: specifier.key())
        }
    }
    
    public override func didReceiveMemoryWarning() {
        // Releases the view if it doesn't have a superview.
        super.didReceiveMemoryWarning()
        
        // Release any cached data, images, etc that aren't in use.
        self.appSettingsViewController = nil
    }
}