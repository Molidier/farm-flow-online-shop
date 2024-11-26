//
//  AccountBuyerViewController.swift
//  FarmerMarketApp
//
//  Created by Saltanat on 21.11.2024.
//

import UIKit
import SnapKit

class AccountBuyerViewController: UIViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		setupUI()
	}

	private let signOutButton: UIButton = {
		let button = UIButton()
		button.setTitle("Sign Out", for: .normal)
		button.backgroundColor = UIColor(red: 255 / 255, green: 59 / 255, blue: 48 / 255, alpha: 1.0) 
		button.layer.cornerRadius = 8
		button.addTarget(self, action: #selector(signOutTapped), for: .touchUpInside)
		return button
	}()

	private func setupUI() {
		view.addSubview(signOutButton)

		signOutButton.snp.makeConstraints { make in
			make.center.equalToSuperview()
			make.width.equalTo(200)
			make.height.equalTo(50)
		}
	}

	@objc private func signOutTapped() {
		UserDefaults.standard.removeObject(forKey: "isSignedIn")
		UserDefaults.standard.removeObject(forKey: "userType")

		let welcomeVC = WelcomePageViewController()
		let navigationController = UINavigationController(rootViewController: welcomeVC)
		if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
			sceneDelegate.window?.rootViewController = navigationController
		}
	}
}
