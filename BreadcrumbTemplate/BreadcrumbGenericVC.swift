//
//  BreadcrumbGenericVC.swift
//  ProjectBase
//
//  Created by Mayes, Arthur E. on 2/2/16.
//  Copyright © 2016 Mayes, Arthur E. All rights reserved.
//

import UIKit

class BreadcrumbGenericVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func next(sender: AnyObject) {
        self.performSegueWithIdentifier("Next", sender: self)
    }
}
