//
//  NetworkManager.swift
//  FarmerMarketApp
//
//  Created by Saltanat on 01.11.2024.
//

import Foundation
import UIKit

class NetworkManager {
	static let shared = NetworkManager()
	private init() {}
	
	func registerFarmer(_ farmer: Farmer, completion: @escaping (Bool, String?) -> Void) {
		guard let url = URL(string: "https://my-django-app8-109965421953.europe-north1.run.app/users/register/farmer/") else {
			completion(false, "Invalid URL")
			return
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		
		do {
			let jsonData = try JSONEncoder().encode(farmer)
			request.httpBody = jsonData
		} catch {
			completion(false, "Failed to encode farmer data")
			return
		}
		
		URLSession.shared.dataTask(with: request) { data, response, error in
			if let error = error {
				completion(false, "Network error: \(error.localizedDescription)")
				return
			}
			
			guard let data = data, let httpResponse = response as? HTTPURLResponse else {
				completion(false, "No response from server")
				return
			}
			
			if httpResponse.statusCode == 201 {
				completion(true, nil)
			} else {
				let responseString = String(data: data, encoding: .utf8) ?? "Unable to decode response"
				completion(false, "Server error: \(responseString)")
			}
		}.resume()

	}

	
	func registerBuyer(_ buyer: Buyer, completion: @escaping (Bool, String?) -> Void) {
		guard let url = URL(string: "https://my-django-app8-109965421953.europe-north1.run.app/users/register/buyer/") else {
			completion(false, "Invalid URL")
			return
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		
		do {
			let jsonData = try JSONEncoder().encode(buyer)
			request.httpBody = jsonData
		} catch {
			completion(false, "Failed to encode buyer data")
			return
		}
		
		URLSession.shared.dataTask(with: request) { data, response, error in
			if let error = error {
				completion(false, "Network error: \(error.localizedDescription)")
				return
			}
			
			guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
				completion(false, "Failed to register buyer")
				return
			}
			
			completion(true, nil)
		}.resume()
	}
	
	// MARK: Sign In
//	func signInUser(phoneNumber: String, password: String, completion: @escaping (Bool, String?) -> Void) {
//		guard let url = URL(string: "https://my-django-app8-109965421953.europe-north1.run.app/api/token/") else {
//			print("Error: Invalid URL")
//			completion(false, "Invalid URL")
//			return
//		}
//
//		var request = URLRequest(url: url)
//		request.httpMethod = "POST"
//		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//		let body: [String: String] = [
//			"phone_number": phoneNumber,
//			"password": password
//		]
//
//		do {
//			let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
//			request.httpBody = jsonData
//		} catch {
//			print("Error: Failed to encode request body - \(error.localizedDescription)")
//			completion(false, "Failed to encode request body")
//			return
//		}
//
//		URLSession.shared.dataTask(with: request) { data, response, error in
//			if let error = error {
//				print("Error: Network error - \(error.localizedDescription)")
//				completion(false, "Network error: \(error.localizedDescription)")
//				return
//			}
//
//			guard let httpResponse = response as? HTTPURLResponse, let data = data else {
//				print("Error: Invalid server response")
//				completion(false, "Invalid server response")
//				return
//			}
//
//			if httpResponse.statusCode == 201 {
//				do {
//					if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String],
//					   let accessToken = jsonResponse["access"],
//					   let refreshToken = jsonResponse["refresh"] {
//						// Store tokens
//						UserDefaults.standard.set(accessToken, forKey: "accessToken")
//						UserDefaults.standard.set(refreshToken, forKey: "refreshToken")
//
//						// Fetch user details to determine the role
//						self.fetchUserDetails(for: accessToken) { role, errorMessage in
//							if let role = role {
//								UserDefaults.standard.set(role, forKey: "userType")
//								completion(true, nil)
//							} else {
//								completion(false, errorMessage ?? "Failed to determine user role")
//							}
//						}
//					} else {
//						completion(false, "Unexpected response format")
//					}
//				} catch {
//					print("Error: Failed to decode JSON - \(error.localizedDescription)")
//					completion(false, "Failed to decode server response")
//				}
//			} else {
//				let responseString = String(data: data, encoding: .utf8) ?? "Unable to decode response"
//				print("Error: Invalid credentials or server error")
//				print("Server Error Response: \(responseString)")
//				completion(false, "Invalid credentials")
//			}
//		}.resume()
//	}

//	func fetchUserDetails(for role: String, completion: @escaping (SignInResponse?, String?) -> Void) {
//		let endpoint: String
//		if role == "farmer" {
//			endpoint = "users/farmer/userpage/"
//		} else if role == "buyer" {
//			endpoint = "users/buyer/userpage/"
//		} else {
//			completion(nil, "Invalid user role")
//			return
//		}
//
//		// Construct the full URL
//		guard let url = URL(string: "http://my-django-app8-109965421953.europe-north1.run.app/\(endpoint)") else {
//			completion(nil, "Invalid URL")
//			return
//		}
//
//		// Retrieve the access token
//		guard let accessToken = UserDefaults.standard.string(forKey: "accessToken") else {
//			completion(nil, "Access token not found")
//			return
//		}
//
//		var request = URLRequest(url: url)
//		request.httpMethod = "GET"
//		request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
//
//		URLSession.shared.dataTask(with: request) { data, response, error in
//			if let error = error {
//				print("Error: \(error.localizedDescription)")
//				completion(nil, "Network error: \(error.localizedDescription)")
//				return
//			}
//
//			guard let httpResponse = response as? HTTPURLResponse else {
//				print("Error: Invalid response from server")
//				completion(nil, "Invalid response from server")
//				return
//			}
//
//			if httpResponse.statusCode == 200 {
//				do {
//					if role == "farmer" {
//						let farmerDetails = try JSONDecoder().decode(Farmer.self, from: data!)
//						let response = SignInResponse(
//							user: self.convertToSignInUser(from: farmerDetails.user),
//							buyer: nil,
//							farmer: farmerDetails
//						)
//						completion(response, nil)
//					} else if role == "buyer" {
//						let buyerDetails = try JSONDecoder().decode(Buyer.self, from: data!)
//						let response = SignInResponse(
//							user: self.convertToSignInUser(from: buyerDetails.user),
//							buyer: buyerDetails,
//							farmer: nil
//						)
//						completion(response, nil)
//					}
//
//				} catch {
//					print("Error decoding user details: \(error.localizedDescription)")
//					completion(nil, "Failed to decode user details")
//				}
//			} else {
//				print("Error: HTTP Status Code - \(httpResponse.statusCode)")
//				completion(nil, "Invalid credentials or server error")
//			}
//		}.resume()
//	}



	
	func fetchFarmerDetails(farmerID: Int, completion: @escaping (Farmer?, Error?) -> Void) {
		guard let url = URL(string: "https://my-django-app8-109965421953.europe-north1.run.app/users/farmer/userpage/") else {
			completion(nil, URLError(.badURL))
			return
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		let body: [String: Int] = ["farmer_id": farmerID]
		
		do {
			request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
		} catch {
			completion(nil, error)
			return
		}
		
		URLSession.shared.dataTask(with: request) { data, response, error in
			if let error = error {
				completion(nil, error)
				return
			}
			
			guard let data = data else {
				completion(nil, URLError(.badServerResponse))
				return
			}
			
			do {
				let farmer = try JSONDecoder().decode(Farmer.self, from: data)
				completion(farmer, nil)
			} catch {
				completion(nil, error)
			}
		}.resume()
	}
	
	func fetchBuyerDetails(buyerID: Int, completion: @escaping (Buyer?, Error?) -> Void) {
		guard let url = URL(string: "https://my-django-app8-109965421953.europe-north1.run.app/users/buyer/userpage/") else {
			completion(nil, URLError(.badURL))
			return
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		let body: [String: Int] = ["buyer_id": buyerID]
		
		do {
			request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
		} catch {
			completion(nil, error)
			return
		}
		
		URLSession.shared.dataTask(with: request) { data, response, error in
			if let error = error {
				completion(nil, error)
				return
			}
			
			guard let data = data else {
				completion(nil, URLError(.badServerResponse))
				return
			}
			
			do {
				let buyer = try JSONDecoder().decode(Buyer.self, from: data)
				completion(buyer, nil)
			} catch {
				completion(nil, error)
			}
		}.resume()
	}
	
	
	
	
	
	func sendOTP(phoneNumber: String, completion: @escaping (Bool) -> Void) {
		guard let url = URL(string: "https://my-django-app8-109965421953.europe-north1.run.app/users/verify-otp/") else { return }
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		
		let parameters: [String: String] = ["phone_number": phoneNumber]
		
		do {
			request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .fragmentsAllowed)
		} catch {
			print("Error encoding OTP request: \(error)")
			completion(false)
			return
		}
		
		URLSession.shared.dataTask(with: request) { _, response, error in
			if let error = error {
				print("Error sending OTP: \(error.localizedDescription)")
				completion(false)
				return
			}
			
			if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 || httpResponse.statusCode == 200 {
				completion(true)
			} else {
				completion(false)
			}
		}.resume()
	}
	
	func verifyOTP(email: String, otp: String, completion: @escaping (Bool, String?) -> Void) {
		guard let url = URL(string: "https://my-django-app8-109965421953.europe-north1.run.app/users/verify-otp/") else {
			completion(false, "Invalid URL")
			return
		}

		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")

		let payload: [String: String] = [
			"email": email,
			"otp": otp
		]

		do {
			request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
		} catch {
			completion(false, "Failed to encode OTP payload")
			return
		}

		URLSession.shared.dataTask(with: request) { data, response, error in
			if let error = error {
				completion(false, "Network error: \(error.localizedDescription)")
				return
			}

			guard let data = data else {
				completion(false, "No response data received")
				return
			}

			do {
				if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
				   let message = jsonResponse["message"] as? String {
					print("Message: \(message)")
					completion(true, nil) 
				} else {
					completion(false, "Unexpected response format")
				}
			} catch {
				print("Decoding Error: \(error.localizedDescription)")
				completion(false, "Failed to parse server response")
			}
		}.resume()
	}
	
	func fetchCategories(completion: @escaping ([Category]?, String?) -> Void) {
		guard let url = URL(string: "https://my-django-app8-109965421953.europe-north1.run.app/products/category/") else {
			completion(nil, "Invalid URL")
			return
		}
		
		let task = URLSession.shared.dataTask(with: url) { data, response, error in
			if let error = error {
				completion(nil, error.localizedDescription)
				return
			}
			
			guard let data = data else {
				completion(nil, "No data received")
				return
			}
			
			do {
				let decoder = JSONDecoder()
				decoder.keyDecodingStrategy = .convertFromSnakeCase
				let categories = try decoder.decode([Category].self, from: data)
				completion(categories, nil)
			} catch {
				completion(nil, "Failed to parse categories: \(error.localizedDescription)")
			}
		}
		task.resume()
	}
	
//	func addProduct(product: Product, image: UIImage?, completion: @escaping (Bool, String?) -> Void) {
//		guard let url = URL(string: "https://my-django-app8-109965421953.europe-north1.run.app/products/product/") else {
//			completion(false, "Invalid URL")
//			return
//		}
//		
//		var request = URLRequest(url: url)
//		request.httpMethod = "POST"
//		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//		
//		do {
//			let encoder = JSONEncoder()
//			encoder.keyEncodingStrategy = .convertToSnakeCase
//			var productData = try encoder.encode(product)
//			
//			if let image = image {
//				if var productDict = try JSONSerialization.jsonObject(with: productData) as? [String: Any] {
//					productDict["image"] = image.jpegData(compressionQuality: 0.7)?.base64EncodedString()
//					productData = try JSONSerialization.data(withJSONObject: productDict)
//				}
//			}
//			
//			request.httpBody = productData
//		} catch {
//			completion(false, "Failed to encode product")
//			return
//		}
//		
//		let task = URLSession.shared.dataTask(with: request) { data, response, error in
//			if let error = error {
//				completion(false, "Network error: \(error.localizedDescription)")
//				return
//			}
//			
//			if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
//				completion(true, nil)
//			} else {
//				completion(false, "Failed to add product")
//			}
//		}
//		task.resume()
//	}
//	
	func addFarm(farm: Farm, completion: @escaping (Bool, String?) -> Void) {
		guard let url = URL(string: "https://my-django-app8-109965421953.europe-north1.run.app/products/farm/") else {
			completion(false, "Invalid URL")
			return
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		
		do {
			let encoder = JSONEncoder()
			encoder.keyEncodingStrategy = .convertToSnakeCase
			let data = try encoder.encode(farm)
			request.httpBody = data
			print("Payload: \(String(data: data, encoding: .utf8) ?? "")")
		} catch {
			completion(false, "Failed to encode farm data")
			return
		}
		
		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			if let error = error {
				print("Network Error: \(error.localizedDescription)")
				completion(false, "Network error: \(error.localizedDescription)")
				return
			}
			
			if let httpResponse = response as? HTTPURLResponse {
				print("Status Code: \(httpResponse.statusCode)")
				
				if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
					completion(true, nil)
				} else {
					let errorMessage = data.flatMap { String(data: $0, encoding: .utf8) } ?? "Unknown error"
					completion(false, "Failed to save farm details: \(errorMessage)")
				}
			} else {
				completion(false, "Invalid response from server")
			}
		}
		task.resume()
	}
	// MARK: Check Farm Exists
	func checkFarmExists(forFarmer farmer: Farmer, completion: @escaping (Bool) -> Void) {
		guard let farmerId = farmer.id,
			  let url = URL(string: "https://my-django-app8-109965421953.europe-north1.run.app/farms/check/") else {
			completion(false)
			return
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		let requestBody: [String: Any] = ["farmer_id": farmerId]
		
		do {
			request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
		} catch {
			print("Error encoding request body: \(error.localizedDescription)")
			completion(false)
			return
		}
		
		URLSession.shared.dataTask(with: request) { data, response, error in
			if let error = error {
				print("Error checking farm existence: \(error.localizedDescription)")
				completion(false)
				return
			}
			
			if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
				completion(true)
			} else {
				completion(false)
			}
		}.resume()
	}
	
	// MARK: Fetch Farm for Farmer
	func fetchFarm(forFarmer farmer: Farmer, completion: @escaping (Farm?) -> Void) {
		guard let farmerId = farmer.id,
			  let url = URL(string: "https://my-django-app8-109965421953.europe-north1.run.app/farms/details/") else {
			completion(nil)
			return
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		let requestBody: [String: Int] = ["farmer_id": farmerId]
		
		do {
			request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
		} catch {
			print("Error encoding request body: \(error.localizedDescription)")
			completion(nil)
			return
		}
		
		URLSession.shared.dataTask(with: request) { data, response, error in
			if let error = error {
				print("Error fetching farm: \(error.localizedDescription)")
				completion(nil)
				return
			}
			
			guard let data = data else {
				completion(nil)
				return
			}
			
			do {
				let farm = try JSONDecoder().decode(Farm.self, from: data)
				completion(farm)
			} catch {
				print("Error decoding farm data: \(error.localizedDescription)")
				completion(nil)
			}
		}.resume()
	}
	
}
