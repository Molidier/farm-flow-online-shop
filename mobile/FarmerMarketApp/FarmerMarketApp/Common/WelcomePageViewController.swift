//
//  WelcomePageViewController.swift
//  FarmerMarketApp
//
//  Created by Saltanat on 01.11.2024.
//

import UIKit
import SnapKit

class WelcomePageViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		setupUI()
		
		farmerButton.addTarget(self, action: #selector(farmerButtonTapped), for: .touchUpInside)
		buyerButton.addTarget(self, action: #selector(buyerButtonTapped), for: .touchUpInside)
		SignInButton.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
	}
	
	private let backgroundImageView: UIImageView = {
		let imageView = UIImageView(image: UIImage(named: "farmer"))
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		return imageView
	}()
	
	private let FFlogo: UIImageView = {
		let imageView = UIImageView(image: UIImage(named: "logoFFwhite"))
		imageView.contentMode = .scaleAspectFill
		return imageView
	}()
	
	private let startAsLabel: UILabel = {
		let label = UILabel()
		label.text = "Start as"
		label.font = UIFont.systemFont(ofSize: 26)
		label.textColor = .white
		return label
	}()
	
	private let farmerButton: UIButton = {
		let button = UIButton()
		button.setTitle("Farmer", for: .normal)
		button.setTitleColor(UIColor(red: 13/255, green: 101/255, blue: 59/255, alpha: 1.0), for: .normal)
		button.backgroundColor = .white
		button.layer.cornerRadius = 10
		return button
	}()
	
	private let buyerButton: UIButton = {
		let button = UIButton()
		button.setTitle("Buyer", for: .normal)
		button.setTitleColor(.white, for: .normal)
		button.backgroundColor = UIColor(red: 83/255, green: 177/255, blue: 117/255, alpha: 1.0)
		button.layer.cornerRadius = 10
		return button
	}()
	
	private let orLabel: UILabel = {
		let label = UILabel()
		label.text = "OR"
		label.font = UIFont.systemFont(ofSize: 26)
		label.textColor = .white
		return label
	}()
	
	private let SignInButton: UIButton = {
		let button = UIButton()
		button.setTitle("Sign in", for: .normal)
		button.setTitleColor(.white, for: .normal)
		button.backgroundColor = UIColor(red: 13/255, green: 101/255, blue: 59/255, alpha: 1.0)
		button.layer.cornerRadius = 10
		return button
	}()
	
	private func setupUI() {
		view.addSubview(backgroundImageView)
		view.addSubview(FFlogo)
		view.addSubview(startAsLabel)
		view.addSubview(farmerButton)
		view.addSubview(buyerButton)
		view.addSubview(orLabel)
		view.addSubview(SignInButton)
		
		backgroundImageView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		FFlogo.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
			make.width.equalTo(30)
			make.height.equalTo(30)
		}
		
		startAsLabel.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.top.equalTo(FFlogo.snp.bottom).offset(150)
		}
		farmerButton.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.top.equalTo(startAsLabel.snp.bottom).offset(20)
			make.width.equalToSuperview().multipliedBy(0.8)
			make.height.equalTo(50)
		}
		buyerButton.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.top.equalTo(farmerButton.snp.bottom).offset(20)
			make.width.equalToSuperview().multipliedBy(0.8)
			make.height.equalTo(50)
		}
		orLabel.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.top.equalTo(buyerButton.snp.bottom).offset(20)
		}
		SignInButton.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.top.equalTo(orLabel.snp.bottom).offset(20)
			make.width.equalToSuperview().multipliedBy(0.8)
			make.height.equalTo(50)
		}
	}
	
	@objc private func farmerButtonTapped() {
		let farmerRegistrationVC = FarmerRegistrationViewController()
		navigationController?.pushViewController(farmerRegistrationVC, animated: true)
	}
	@objc private func buyerButtonTapped() {
		let buyerRegistrationVC = BuyerRegistrationViewController()
		navigationController?.pushViewController(buyerRegistrationVC, animated: true)
	}
	@objc private func signInButtonTapped() {
		let signInVC = SignInViewController()
		navigationController?.pushViewController(signInVC, animated: true)
	}
}
