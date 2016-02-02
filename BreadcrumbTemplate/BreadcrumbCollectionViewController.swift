//
//  BreadcrumbCollectionViewController.swift
//  AEMBreadcrumbs
//
//  Created by Arthur Mayes on 11/2/15.
//  Copyright © 2015 Arthur Mayes. All rights reserved.
//

import UIKit

private let reuseIdentifier = "breadcrumb"

protocol BreadcrumbDelegate
{
    /**
    Called whenever the user selects a breadcrumb from the breadcrumb controller
    
    - Parameter path:   the indexPath selected in the collectionView-- useful with, for example, an array of view controllers
    - Parameter breadcrumb: the display name of the view controller, passed for the programmer's convenience
    */
    
    func selectedCrumb(path : NSIndexPath, breadcrumb : NSString)
}

protocol BreadcrumbDataSource
{
    
    /**
    Should include the names of all view controllers on the navigation stack when the breadcrumb controller is initially displayed
    - Returns: An initial mutable array of view controller names for display
    */
    
    func originalBreadcrumbs() -> NSMutableArray
}

    /**
    The direction from which the breadcrumb trail should expand.  Default value is FromRight.

    - Parameter FromLeft:   will be a left-aligned breadcrumb trail that expands to the right
    - Parameter FromRight: will be a right-aligned breadcrumb trail that expands to the left
    */

enum ExpansionDirection {
    case FromLeft
    case FromRight
}


class BreadcrumbCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var breadcrumbDelegate : BreadcrumbDelegate?
    var breadcrumbDataSource : BreadcrumbDataSource?
    
    /**
    An array of view controller names for display.  Populated by the originalBreadcrumbs() function
    */
    
    lazy var arrayOfItems : NSMutableArray = {
        return self.breadcrumbDataSource?.originalBreadcrumbs() ?? []
    }()
    
    /**
    The speed at which the breadcrumbs populate/depopulate.  Default value is 0.5.
    */
    
    var animationSpeed = 0.5
    
    
    /**
     The direction from which the breadcrumb trail should expand.  Default value is FromRight.
     
     - Parameter FromLeft:   will be a left-aligned breadcrumb trail that expands to the right
     - Parameter FromRight: will be a right-aligned breadcrumb trail that expands to the left
     */
    
    var expansionDirection = ExpansionDirection.FromRight
    
    private var widths : CGFloat! = 0.0
    private var ready = true
    
    /**
    Call from the delegate whenever the user navigates to a new view controller
    - Parameter breadcrumb: the display name for the view controller
    */
    
    func addBreadcrumb(breadcrumb : NSString!) {
        self.arrayOfItems.addObject(breadcrumb)
        self.widths = 0.0
        if self.ready {
            self.ready = false
            UIView.animateWithDuration(self.animationSpeed, animations: { () -> Void in
                (self.collectionView?.performBatchUpdates({ () -> Void in
                    let ip : NSIndexPath = NSIndexPath.init(forItem: self.arrayOfItems.count - 1, inSection: 0)
                        self.collectionView?.insertItemsAtIndexPaths([ip])
                    }, completion: nil))!
                }, completion: { (Bool) -> Void in
                    let count = self.arrayOfItems.count - 1
                    if count > 0 {
                        let ip = NSIndexPath.init(forItem: count, inSection: 0)
                        self.collectionView?.scrollToItemAtIndexPath(ip, atScrollPosition: UICollectionViewScrollPosition.Right, animated: true)
                    }
                    self.ready = true
            })
        }
        
    }
    
    /**
    Call whenever the user navigates away from a view controller, via a non-breadcrumb means
    - Parameter breadcrumb: the display name for the view controller
    */
    
    func removeBreadcrumb(breadcrumb : NSString) {
        if self.arrayOfItems.containsObject(breadcrumb) {
            let index = self.arrayOfItems.indexOfObject(breadcrumb)
            var array : [NSIndexPath] = []
            var end = self.arrayOfItems.count - 1
            while end >= index {
                let ip : NSIndexPath = NSIndexPath.init(forItem:end, inSection: 0)
                array.append(ip)
                self.arrayOfItems.removeObjectAtIndex(end)
                end--
            }
            self.widths = 0.0
            UIView.animateWithDuration(self.animationSpeed, animations: { () -> Void in
                (self.collectionView?.performBatchUpdates({ () -> Void in
                    (self.collectionView?.deleteItemsAtIndexPaths(array))!
                    }, completion: nil))!
                }) { (Bool) -> Void in
                    let count = self.arrayOfItems.count - 1
                    if count > 1 {
                        let ip = NSIndexPath.init(forItem: count, inSection: 0)
                        self.collectionView?.scrollToItemAtIndexPath(ip, atScrollPosition: UICollectionViewScrollPosition.Right, animated: true)
                    }
            }
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        var frameWidth = self.widths;
        if frameWidth > size.width {
            frameWidth = size.width
        }
        self.leftPadding = size.width - frameWidth
        
        [coordinator.animateAlongsideTransition({ (UIViewControllerTransitionCoordinatorContext) -> Void in
            self.collectionView?.reloadData()
            let count = self.arrayOfItems.count - 1
            if count > 1 {
                let ip = NSIndexPath.init(forItem: count, inSection: 0)
                self.collectionView?.scrollToItemAtIndexPath(ip, atScrollPosition: UICollectionViewScrollPosition.Right, animated: false)
            }
            }, completion: { (UIViewControllerTransitionCoordinatorContext) -> Void in
                
        })]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayOfItems.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! BreadcrumbCell
    
        cell.label.text = (self.arrayOfItems[indexPath.row] as! String)
        cell.label.sizeToFit()
        cell.label.frame = CGRectMake(8, 0, cell.label.frame.size.width, collectionView.frame.size.height)
    
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.item < self.arrayOfItems.count - 1 {
            self.removeBreadcrumb((self.arrayOfItems[indexPath.item + 1]) as! NSString)
            self.breadcrumbDelegate?.selectedCrumb(indexPath, breadcrumb: self.arrayOfItems[indexPath.row] as! NSString)
        }
    }
    
    private var leftPadding : CGFloat = 0.0
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        self.widths = 0.0
        let label = UILabel.init()
        label.text = self.arrayOfItems[indexPath.row] as? String
        label.sizeToFit()
        let size = CGSizeMake(label.frame.size.width + 16, collectionView.frame.size.height)
        
        if self.expansionDirection == ExpansionDirection.FromRight {
            self.widths = self.widths + (size.width + 8.0)
            let width = self.view.superview!.superview!.frame.size.width
            var frameWidth = self.widths;
            if frameWidth > width {
                frameWidth = width
            }
            if indexPath.row == self.arrayOfItems.count - 1 {
                self.leftPadding = width - frameWidth
            }
        }
        return size
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets
    {
        if self.expansionDirection == ExpansionDirection.FromRight {
            return UIEdgeInsetsMake(0, self.leftPadding, 0, 0)
        } else {
            return UIEdgeInsetsMake(0, 0, 0, 0)
        }
    }
}

@IBDesignable class BreadcrumbCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBInspectable var cornerRadius : CGFloat = 0 {
        didSet {
            self.clipsToBounds = true
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth : CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor : UIColor = UIColor.clearColor() {
        didSet {
            self.layer.borderColor = borderColor.CGColor
        }
    }
    
}
