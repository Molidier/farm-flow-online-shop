//
//  SceneDelegate.swift
//  FarmerMarketApp
//
//  Created by Saltanat on 30.10.2024.
//

import UIKit
import UserNotifications

class SceneDelegate: UIResponder, UIWindowSceneDelegate, UNUserNotificationCenterDelegate {
	var window: UIWindow?

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = (scene as? UIWindowScene) else { return }

		let window = UIWindow(windowScene: windowScene)
		self.window = window

		// Start with the Welcome Page
		let welcomeVC = WelcomePageViewController()
		let navigationController = UINavigationController(rootViewController: welcomeVC)
		window.rootViewController = navigationController
		window.makeKeyAndVisible()

		requestNotificationAuthorization()
		UNUserNotificationCenter.current().delegate = self
	}

	// MARK: Switch to Buyer Tab Bar
	func switchToBuyerTabBar() {
		let buyerTabBarController = createBuyerTabBarController()
		window?.rootViewController = buyerTabBarController
		window?.makeKeyAndVisible()
	}

	// MARK: Switch to Farmer Tab Bar
	func switchToFarmerTabBar() {
		let farmerTabBarController = createFarmerTabBarController()
		window?.rootViewController = farmerTabBarController
		window?.makeKeyAndVisible()
	}

	// MARK: Notification Authorization
	private func requestNotificationAuthorization() {
		let center = UNUserNotificationCenter.current()
		center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
			if let error = error {
				print("Notification authorization error: \(error)")
			} else {
				print("Permission granted: \(granted)")
			}
		}
	}

	// MARK: Create Buyer Tab Bar Controller
	func createBuyerTabBarController() -> UITabBarController {
		let tabBarController = UITabBarController()

		let mainPageVC = MainPageBuyerViewController()
		mainPageVC.view.backgroundColor = .white
		mainPageVC.tabBarItem = UITabBarItem(title: "Explore", image: UIImage(systemName: "magnifyingglass"), tag: 0)

		let favouriteVC = FavouriteProductsViewController()
		favouriteVC.view.backgroundColor = .white
		favouriteVC.tabBarItem = UITabBarItem(title: "Favourite", image: UIImage(systemName: "heart"), tag: 1)

		let cartVC = CartBuyerViewController()
		cartVC.view.backgroundColor = .white
		cartVC.tabBarItem = UITabBarItem(title: "Cart", image: UIImage(systemName: "cart"), tag: 2)

		let chatsVC = ChatsBuyerViewController()
		chatsVC.view.backgroundColor = .white
		chatsVC.tabBarItem = UITabBarItem(title: "Chats", image: UIImage(systemName: "message"), tag: 3)

		let accountVC = AccountBuyerViewController()
		accountVC.view.backgroundColor = .white
		accountVC.tabBarItem = UITabBarItem(title: "Account", image: UIImage(systemName: "person"), tag: 4)

		tabBarController.viewControllers = [mainPageVC, favouriteVC, cartVC, chatsVC, accountVC]
		return tabBarController
	}

	// MARK: Create Farmer Tab Bar Controller
	func createFarmerTabBarController() -> UITabBarController {
		let tabBarController = UITabBarController()

		let homeVC = MainPageFarmerViewController()
		homeVC.view.backgroundColor = .white
		homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)

		let ordersVC = OrdersFarmerViewController()
		ordersVC.view.backgroundColor = .white
		ordersVC.tabBarItem = UITabBarItem(title: "Orders", image: UIImage(systemName: "cart"), tag: 1)

		let addProductVC = AddProductViewController()
		addProductVC.view.backgroundColor = .white
		addProductVC.tabBarItem = UITabBarItem(title: "Add Product", image: UIImage(systemName: "plus.circle"), tag: 2)

		let chatVC = ChatFarmerViewController()
		chatVC.view.backgroundColor = .white
		chatVC.tabBarItem = UITabBarItem(title: "Chat", image: UIImage(systemName: "message"), tag: 3)

		let accountVC = AccountFarmerViewController()
		accountVC.view.backgroundColor = .white
		accountVC.tabBarItem = UITabBarItem(title: "Account", image: UIImage(systemName: "person"), tag: 4)

		tabBarController.viewControllers = [homeVC, ordersVC, addProductVC, chatVC, accountVC]
		return tabBarController
	}

	// MARK: UNUserNotificationCenterDelegate Methods
	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		completionHandler([.banner, .sound])
	}

	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		completionHandler()
	}
	
	
	func sceneDidDisconnect(_ scene: UIScene) {
		// Called as the scene is being released by the system.
		// This occurs shortly after the scene enters the background, or when its session is discarded.
		// Release any resources associated with this scene that can be re-created the next time the scene connects.
		// The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
	}
	
	func sceneDidBecomeActive(_ scene: UIScene) {
		// Called when the scene has moved from an inactive state to an active state.
		// Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
	}
	
	func sceneWillResignActive(_ scene: UIScene) {
		// Called when the scene will move from an active state to an inactive state.
		// This may occur due to temporary interruptions (ex. an incoming phone call).
	}
	
	func sceneWillEnterForeground(_ scene: UIScene) {
		// Called as the scene transitions from the background to the foreground.
		// Use this method to undo the changes made on entering the background.
	}
	
	func sceneDidEnterBackground(_ scene: UIScene) {
		// Called as the scene transitions from the foreground to the background.
		// Use this method to save data, release shared resources, and store enough scene-specific state information
		// to restore the scene back to its current state.
	}
	
	
	
	
}
