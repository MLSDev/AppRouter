//
//  AppRouterAccessorsTests.swift
//  AppRouter
//
//  Created by Antihevich on 8/5/16.
//  Copyright © 2016 Artem Antihevich. All rights reserved.
//

import XCTest
@testable import AppRouter

class AppRouterAccessorsTests: XCTestCase {
    
    func testHierarchyAccessors() throws {
        XCTAssertNil(AppRouter.rootViewController)
        XCTAssertNil(AppRouter.topViewController)
        
        let tabBar = AppRouterPresenterTabBarController()
        AppRouter.rootViewController = tabBar
        XCTAssertTrue(AppRouter.rootViewController is AppRouterPresenterTabBarController)
        XCTAssertTrue(AppRouter.topViewController is AppRouterPresenterTabBarController)
        
        tabBar.setViewControllers([AppRouterPresenterNavigationController()], animated: false)
        XCTAssertTrue(AppRouter.rootViewController is AppRouterPresenterTabBarController)
        XCTAssertTrue(AppRouter.topViewController is AppRouterPresenterNavigationController)
        
        try AppRouterPresenterAdditionalController.presenter().fromStoryboard("AppRouterPresenterControllers", initial: false).push(animated: false)
        XCTAssertTrue(AppRouter.rootViewController is AppRouterPresenterTabBarController)
        XCTAssertTrue(AppRouter.topViewController is AppRouterPresenterAdditionalController)
        
        AppRouter.topViewController?.present(AppRouterPresenterBaseController(), animated: false, completion: nil)
        XCTAssertTrue(AppRouter.rootViewController is AppRouterPresenterTabBarController)
        XCTAssertTrue(AppRouter.topViewController is AppRouterPresenterBaseController)
        
        AppRouter.rootViewController = AppRouterPresenterBaseController()
        AppRouter.topViewController?.present(AppRouterPresenterAdditionalController(), animated: false, completion: nil)
        XCTAssertTrue(AppRouter.rootViewController is AppRouterPresenterBaseController)
        XCTAssertTrue(AppRouter.topViewController is AppRouterPresenterAdditionalController)        
    }
    
    func testTabBarAccessors() {
        let tabBar = UITabBarController()
        let nav = NavigationControllerWithExpectations()
        let first = AppRouterPresenterBaseController()
        let second = AppRouterPresenterAdditionalController()
        nav.viewControllers = [first]
        tabBar.viewControllers = [nav, second]
        
        XCTAssertNotNil( tabBar.getControllerInstance(NavigationControllerWithExpectations.self) )
        XCTAssertNotNil( tabBar.getControllerInstance(AppRouterPresenterBaseController.self) )
        XCTAssertNotNil( tabBar.getControllerInstance(AppRouterPresenterAdditionalController.self) )
        XCTAssertNil( tabBar.getControllerInstance(AppRouterPresenterTabBarController.self) )
    }
    
    func testNavAccessors() {
        let nav = UINavigationController()
        let first = AppRouterPresenterBaseController()
        let second = AppRouterPresenterAdditionalController()
        nav.viewControllers = [first, second]
        AppRouter.rootViewController = nav
        
        XCTAssertNotNil( nav.getControllerInstance(AppRouterPresenterBaseController.self) )
        XCTAssertNotNil( nav.getControllerInstance(AppRouterPresenterAdditionalController.self) )
        XCTAssertNil( nav.getControllerInstance(AppRouterPresenterTabBarController.self) )
    }
    
    func testModalFlagAccessor() {
        let nav = UINavigationController()
        let first = AppRouterPresenterBaseController()
        let second = AppRouterPresenterAdditionalController()
        nav.viewControllers = [first]
        AppRouter.rootViewController = nav
        XCTAssertFalse(first.isModal)
        XCTAssertFalse(second.isModal)
        XCTAssertFalse(nav.isModal)
        let expectation =  self.expectation(description: "")
        nav.present(second, animated: false, completion: {
            XCTAssertTrue(second.isModal)
            XCTAssertFalse(first.isModal)
            XCTAssertFalse(nav.isModal)
            expectation.fulfill()
        })
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testModalFlagAccessorWhenEmbeddedInNavigation() {
        let nav = UINavigationController()
        let first = AppRouterPresenterBaseController()
        let second = AppRouterPresenterAdditionalController()
        nav.viewControllers = [first]
        AppRouter.rootViewController = second

        XCTAssertFalse(first.isModal)
        XCTAssertFalse(second.isModal)
        XCTAssertFalse(nav.isModal)
        let expectation =  self.expectation(description: "")
        second.present(nav, animated: false, completion: {
            XCTAssertTrue(first.isModal)
            XCTAssertTrue(nav.isModal)
            XCTAssertFalse(second.isModal)
            expectation.fulfill()
        })
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testModalFlagAccessorWhenEmbeddedInNavigationAndInsideTabBar() {
        let tabBar = UITabBarController()
        let nav = UINavigationController()
        let first = AppRouterPresenterBaseController()
        let second = AppRouterPresenterAdditionalController()
        nav.viewControllers = [first]
        tabBar.viewControllers = [second]
        AppRouter.rootViewController = tabBar
        
        XCTAssertFalse(tabBar.isModal)
        XCTAssertFalse(first.isModal)
        XCTAssertFalse(second.isModal)
        XCTAssertFalse(nav.isModal)
        
        let expectation =  self.expectation(description: "")
        second.present(nav, animated: false, completion: { 
            XCTAssertTrue(first.isModal)
            XCTAssertTrue(nav.isModal)
            XCTAssertFalse(second.isModal)
            expectation.fulfill()
        })
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testTopViewControllerWithCustomContainer() {
        let nav = UINavigationController(rootViewController: SecondController())
        AppRouter.rootViewController = nav
        XCTAssert(AppRouter.topViewController is ThirdController)
    }
    
    func testTopFromEmptyNavigation() {
        let nav = UINavigationController()
        AppRouter.rootViewController = nav
        XCTAssertTrue(AppRouter.topViewController == nav)
        nav.present(FirstController(), animated: false, completion: nil)
        XCTAssertTrue(AppRouter.topViewController is FirstController)
    }
    
    func testTopFromEmptyTabBar() {
        let tab = UITabBarController()
        AppRouter.rootViewController = tab
        XCTAssertTrue(AppRouter.topViewController == tab)
        tab.present(FirstController(), animated: false, completion: nil)
        XCTAssertTrue(AppRouter.topViewController is FirstController)
    }
}

extension SecondController {
    override open func toppestControllerFromCurrent() -> UIViewController? {
        return ThirdController()
    }
}
