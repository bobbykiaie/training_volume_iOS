//MainTabBarController.swift

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let homeViewController = HomeViewController()
        homeViewController.tabBarItem = UITabBarItem(title: "Home", image: nil, tag: 0)
        
        let chartViewController = ChartViewController()
        chartViewController.tabBarItem = UITabBarItem(title: "Chart", image: nil, tag: 1)
        
        viewControllers = [homeViewController, chartViewController]
    }
}
