//
//  ListPageViewController.swift
//  Funnel
//
//  Created by Shao-Qian Mah on 28/12/18.
//  Copyright © 2018 Funnel. All rights reserved.
//

import UIKit

class ListPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    // List of all view controllers in UIPageViewController
    lazy var orderedViewControllers: [UIViewController] = {
        return [self.newVc(viewController: "listView"),
                self.newVc(viewController: "compositionView"),
                self.newVc(viewController: "nutritionView")]
    }()
    
    // Initialize page controller dots
    var pageControl = UIPageControl()
    
    //Initialize current page number variable
    var pageNum = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.dataSource = self
        self.delegate = self
        
        // This sets up the first view that will show up on our page control
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
    }
    
    // Runs whenever view is layout, including device orientation change
    override func viewDidLayoutSubviews() {
        
        // Force redrawing of views inside container view so that it matches the size due to change in device orientation
        self.view.setNeedsDisplay()
        
        // Remove all other page controls so there aren't multiple of them
        for view in view.subviews{
            if view is UIPageControl{
                view.removeFromSuperview()
            }
        }
        
        // Create page control
        configurePageControl()
    }
    
    // Function to direct view controller to know which views should be included based on storyboard identifier
    func newVc(viewController: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewController)
    }
    
    // MARK: Data source functions.
    
    // Page swapping functions
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            return orderedViewControllers.last
            // Uncommment the line below, remove the line above if you don't want the page control to loop.
            // return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            return orderedViewControllers.first
            // Uncommment the line below, remove the line above if you don't want the page control to loop.
            // return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    // Indicators
    
    func configurePageControl() {
        // The total number of pages that are available is based on how many available colors we have.
        pageControl = UIPageControl(frame: CGRect(x: 0,y: self.view.frame.size.height - 50,width: self.view.frame.size.width,height: 50))
        self.pageControl.numberOfPages = orderedViewControllers.count
        self.pageControl.currentPage = pageNum
        self.pageControl.tintColor = UIColor.black
        self.pageControl.pageIndicatorTintColor = UIColor.white
        self.pageControl.currentPageIndicatorTintColor = UIColor.black
        self.view.addSubview(pageControl)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        
        //Update page number in page view controller
        pageNum = orderedViewControllers.index(of: pageContentViewController)!
        self.pageControl.currentPage = pageNum
    }
}
