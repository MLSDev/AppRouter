import Foundation
import UIKit

extension AppRouter {
    /// Utility method to pop topmost viewController
    ///
    /// - parameter animated: defines if popping should be animated
    /// - parameter completion: called after successful popping
    public class func popFromTopNavigation(animated animated: Bool = true, completion: Action? = nil) {
        topViewController()?.navigationController?.popViewController(animated: animated, completion: completion)
    }
}

/// Additional abilities to close / dismiss/ pop controllers
extension UIViewController {
    /// Pop to previous controller in navigation stack. Do nothing if current is first
    ///
    /// - parameter animated: Set this value to true to animate the transition
    /// - parameter completion: Called after transition ends successfully.
    /// - returns: [UIViewCotnroller]? - returns the popped controllers
    public func pop(animated animated: Bool = true, completion: Action? = nil) -> [UIViewController]? {
        guard let stack = navigationController?.viewControllers where stack.count > 1 else {
            AppRouter.print("#[AppRouter] can't pop \"\(String(self))\" when only one controller in navigation stack!")
            return nil
        }
        guard let first = stack.first where first != self else {
            AppRouter.print("#[AppRouter] can't pop from \"\(String(self))\" because it's first in stack!")
            return nil
        }
        var previousViewController = first
        for controller in stack {
            if controller == self {
                return navigationController?.popToViewController(previousViewController, animated: animated, completion: completion)
            } else {
                previousViewController = controller
            }
        }
        return nil
    }

    /// Tries to close viewController by popping to previous in navigation stack or by dismissing if presented
    ///
    /// - parameter animated: If true - transition animated
    /// - parameter completion: Called after transition ends successfully
    /// - returns: returns true if able to close
    public func close(animated animated: Bool = true, completion: Action? = nil) -> Bool {
        if canPop() {
            pop(animated: animated, completion: completion)
        } else if isModal {
            dismissViewControllerAnimated(animated, completion: completion)
        } else {
            AppRouter.print("#[AppRouter] can't close \"\(String(self))\".")
            return false
        }
        return true
    }
    
    private func canPop() -> Bool {
        guard let stack = navigationController?.viewControllers where stack.count > 1 else { return false }
        guard let first = stack.first where first != self else { return false }
        return stack.contains(self)
    }
}

extension UITabBarController {
    /// Tries to find controller of specified type and make it selectedViewController
    ///
    /// - parameter type: required controller type
    /// - returns: True if changed successfully
    public func setSelectedViewController<T: UIViewController>(type: T.Type) -> Bool {
        if let controller = self.getControllerInstance(T) {
            if self.viewControllers?.contains(controller) ?? false {
                self.selectedViewController = controller
            } else if let navController = controller.navigationController where (self.viewControllers?.contains(navController) ?? false) {
                self.selectedViewController = navController
            }
            return true
        }
        return false
    }
}

extension UINavigationController {
    /// Pop to controller of specified type. Do nothing if current is first
    ///
    /// - parameter type: Required type
    /// - parameter animated: Set this value to true to animate the transition
    /// - returns: [UIViewCotnroller]? - returns the popped controllers
    public func popToViewController<T: UIViewController>(type: T.Type, animated: Bool) -> [UIViewController]? {
        guard let controller = self.getControllerInstance(T) else { return nil }
        return popToViewController(controller, animated: animated)
    }
}

/// Provides callback to standart UINavigationController methods
extension UINavigationController {
    /// Adds completion block to standart pushViewController(_, animated:) method
    ///
    /// - parameter viewController: controller to be pushed
    /// - parameter animated: Set this value to true to animate the transition
    /// - parameter completion: Called after transition ends successfully
    public func pushViewController(viewController: UIViewController, animated: Bool, completion: Action?) {
        guard !viewControllers.contains(viewController) else { return AppRouter.print("#[AppRouter] can't push \"\(String(viewController.dynamicType))\", already in navigation stack!") }
        pushViewController(viewController, animated: animated)
        _сoordinator(animated, completion: completion)
    }
    
    /// Adds completion block to standart popViewControllerAnimated method
    ///
    /// - parameter animated: Set this value to true to animate the transition
    /// - parameter completion: Called after transition ends successfully
    /// - returns: the popped controller
    public func popViewController(animated animated: Bool, completion: Action?) -> UIViewController? {
        guard let popped = popViewControllerAnimated(animated) else { return nil }
        _сoordinator(animated, completion: completion)
        return popped
    }
    
    /// Adds completion block to standart popToViewController(_, animated:) method
    ///
    /// - parameter viewController: pops view controllers until the one specified is on top
    /// - parameter animated: Set this value to true to animate the transition
    /// - parameter completion: Called after transition ends successfully
    /// - returns: [UIViewCotnroller]? - returns the popped controllers
    public func popToViewController(viewController: UIViewController, animated: Bool, completion: Action?) -> [UIViewController]? {
        guard let popped = popToViewController(viewController, animated: animated) else { return nil }
        _сoordinator(animated, completion: completion)
        return popped
    }

    /// Allow to pop to controller with specified type
    ///
    /// - parameter type: pops view controllers until the one with specified type is on top
    /// - parameter animated: Set this value to true to animate the transition
    /// - parameter completion: Called after transition ends successfully
    /// - returns: [UIViewCotnroller]? - returns the popped controllers
    public func popToViewController<T: UIViewController>(type: T.Type, animated: Bool, completion: Action?) -> [UIViewController]? {
        guard let popped = popToViewController(type, animated: animated) else { return nil }
        _сoordinator(animated, completion: completion)
        return popped
    }
    
    /// Adds completion block to standart popToRootViewControllerAnimated method
    ///
    /// - parameter animated: Set this value to true to animate the transition
    /// - parameter completion: Called after transition ends successfully
    /// - returns: [UIViewCotnroller]? - returns the popped controllers
    public func popToRootViewController(animated animated: Bool, completion: Action?) -> [UIViewController]? {
        guard let popped = popToRootViewControllerAnimated(animated) else { return nil }
        _сoordinator(animated, completion: completion)
        return popped
    }
    
    private func _сoordinator(animated: Bool, completion: Action?) {
        if let coordinator = transitionCoordinator() where animated {
            coordinator.animateAlongsideTransition(nil) { _ in
                completion?()
            }
        } else {
            completion?()
        }
    }
}