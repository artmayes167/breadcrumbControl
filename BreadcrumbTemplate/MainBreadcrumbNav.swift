//
//  MainBreadcrumbNav.swift
//  ProjectBase
//
//  Created by Mayes, Arthur E. on 2/2/16.
//  Copyright © 2016 Mayes, Arthur E. All rights reserved.
//

import UIKit

class MainBreadcrumbNav: UIViewController, BreadcrumbDelegate, BreadcrumbDataSource {
    
    var bCViewController : BreadcrumbCollectionViewController?
    var navControl : BreadcrumbChildNavVC?
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toBreadcrumb" {
            self.bCViewController = segue.destinationViewController as? BreadcrumbCollectionViewController
            self.bCViewController!.breadcrumbDataSource = self
            self.bCViewController!.breadcrumbDelegate = self
        } else if segue.identifier == "toNav" {
            self.navControl = segue.destinationViewController as? BreadcrumbChildNavVC
        }
    }
    
    var index = 1
    
    func originalBreadcrumbs() -> NSMutableArray {
        return ["Page 1"]
    }
    
    func selectedCrumb(path: NSIndexPath, breadcrumb: NSString) {
        if self.bCViewController?.arrayOfItems.count > path.item {
            self.index = path.item + 1
            
            self.navControl?.popToViewController((navControl?.viewControllers[path.item])!, animated: true)
        }
    }
    
    @IBAction func addOne(sender: AnyObject) {
        self.index++
        self.bCViewController?.addBreadcrumb("\(sender.title!!)")
    }
    
    @IBAction func subtractOne(sender: AnyObject) {
        if self.index > 0 {
            self.bCViewController?.removeBreadcrumb("\(sender.title!!)")
            self.index--
        }
    }
}

extension MainBreadcrumbNav : UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        if self.navControl?.viewControllers.indexOf(viewController) > self.index - 1 {
            self.addOne(viewController)
        }
    }
}
