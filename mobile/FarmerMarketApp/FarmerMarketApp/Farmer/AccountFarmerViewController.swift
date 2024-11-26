import UIKit
import SnapKit

class AccountFarmerViewController: UIViewController {

	private let greetingLabel: UILabel = {
		let label = UILabel()
		label.text = "Hi, Farmer!"
		label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
		label.textColor = .black
		return label
	}()
	
	private let navigationTitleLabel: UILabel = {
		let label = UILabel()
		label.text = "Your Profile"
		label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
		label.textColor = .white
		return label
	}()
	
	private let notificationButton: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(UIImage(systemName: "bell"), for: .normal)
		button.tintColor = .white
		return button
	}()
	
	private let signOutButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle("Sign Out", for: .normal)
		button.backgroundColor = UIColor(red: 102/255, green: 187/255, blue: 106/255, alpha: 1.0)
		button.setTitleColor(.white, for: .normal)
		button.layer.cornerRadius = 8
		button.addTarget(self, action: #selector(signOutTapped), for: .touchUpInside)
		return button
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
	}
	
	private func setupView() {
		view.backgroundColor = .white
		
		setupNavigationBar()
		setupGreetingLabel()
		setupSignOutButton()
	}
	
	private func setupNavigationBar() {
		let navBarView = UIView()
		navBarView.backgroundColor = UIColor(red: 34/255, green: 73/255, blue: 47/255, alpha: 1)

		view.addSubview(navBarView)
		navBarView.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
			make.leading.trailing.equalToSuperview()
			make.height.equalTo(70)
		}

		navBarView.addSubview(navigationTitleLabel)
		navigationTitleLabel.snp.makeConstraints { make in
			make.centerY.equalToSuperview()
			make.leading.equalToSuperview().offset(16)
		}

		navBarView.addSubview(notificationButton)
		notificationButton.snp.makeConstraints { make in
			make.centerY.equalToSuperview()
			make.trailing.equalToSuperview().offset(-16)
		}
	}

	private func setupGreetingLabel() {
		view.addSubview(greetingLabel)
		greetingLabel.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(80)
			make.leading.equalToSuperview().offset(16)
		}
	}
	
	private func setupSignOutButton() {
		view.addSubview(signOutButton)
		signOutButton.snp.makeConstraints { make in
			make.top.equalTo(greetingLabel.snp.bottom).offset(40)
			make.leading.trailing.equalToSuperview().inset(16)
			make.height.equalTo(50)
		}
	}
	
	@objc private func signOutTapped() {
		UserDefaults.standard.set(false, forKey: "isSignedIn")
		
		if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate {
			let welcomeVC = WelcomePageViewController()
			let navigationController = UINavigationController(rootViewController: welcomeVC)
			sceneDelegate.window?.rootViewController = navigationController
			sceneDelegate.window?.makeKeyAndVisible()
		}
	}
}
