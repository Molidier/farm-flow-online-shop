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
	let baseURL = "https://my-django-app22-109965421953.europe-north1.run.app/"
	var accessToken: String?
	
	func registerFarmer(_ farmer: Farmer, completion: @escaping (Bool, String?) -> Void) {
		guard let url = URL(string: "\(baseURL)users/register/farmer/") else {
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
				completion(true, "Successful registration")
			} else {
				let responseString = String(data: data, encoding: .utf8) ?? "Unable to decode response"
				completion(false, "Server error: \(responseString)")
			}
		}.resume()
		
	}
	
	
	func registerBuyer(_ buyer: Buyer, completion: @escaping (Bool, String?) -> Void) {
		guard let url = URL(string: "\(baseURL)users/register/buyer/") else {
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
			
			guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 || httpResponse.statusCode == 200 else {
				completion(false, "Failed to register buyer")
				return
			}
			
			completion(true, "Successfully registered!")
		}.resume()
	}
	
	// MARK: - Authenticate User
	func authenticateUser(phoneNumber: String, password: String, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
		let url = URL(string: "\(baseURL)users/login/")!
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		
		let body: [String: Any] = [
			"phone_number": phoneNumber,
			"password": password
		]
		
		do {
			request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
		} catch {
			print("Error serializing JSON: \(error.localizedDescription)")
			completion(.failure(error))
			return
		}
		
		if let bodyString = String(data: request.httpBody!, encoding: .utf8) {
			print("Request Body: \(bodyString)")
		}
		
		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			// Handle network error
			if let error = error {
				print("Network error: \(error.localizedDescription)")
				completion(.failure(error))
				return
			}
			
			// Ensure the response is an HTTPURLResponse
			guard let httpResponse = response as? HTTPURLResponse else {
				let error = NSError(domain: "com.example.error", code: 0, userInfo: [
					NSLocalizedDescriptionKey: "Invalid response from server"
				])
				completion(.failure(error))
				return
			}
			
			print("HTTP Response Code: \(httpResponse.statusCode)")
			
			guard (200...299).contains(httpResponse.statusCode) else {
				let error = NSError(domain: "com.example.error", code: httpResponse.statusCode, userInfo: [
					NSLocalizedDescriptionKey: "Server returned status code \(httpResponse.statusCode)"
				])
				completion(.failure(error))
				return
			}
			
			guard let data = data else {
				let error = NSError(domain: "com.example.error", code: 0, userInfo: [
					NSLocalizedDescriptionKey: "No data received"
				])
				completion(.failure(error))
				return
			}
			
			if let responseString = String(data: data, encoding: .utf8) {
				print("Response Data: \(responseString)")
			}
			
			do {
				let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
				completion(.success(loginResponse))
			} catch let DecodingError.keyNotFound(key, context) {
				print("❌ Key '\(key.stringValue)' not found:", context.debugDescription)
				print("Coding Path:", context.codingPath)
				completion(.failure(NSError(domain: "com.example.error", code: 1, userInfo: [
					NSLocalizedDescriptionKey: "Missing key '\(key.stringValue)' in response."
				])))
			} catch let DecodingError.typeMismatch(type, context) {
				print("❌ Type '\(type)' mismatch:", context.debugDescription)
				print("Coding Path:", context.codingPath)
				completion(.failure(NSError(domain: "com.example.error", code: 2, userInfo: [
					NSLocalizedDescriptionKey: "Type mismatch for type '\(type)'."
				])))
			} catch let DecodingError.valueNotFound(value, context) {
				print("❌ Value '\(value)' not found:", context.debugDescription)
				print("Coding Path:", context.codingPath)
				completion(.failure(NSError(domain: "com.example.error", code: 3, userInfo: [
					NSLocalizedDescriptionKey: "Value not found: \(value)."
				])))
			} catch let DecodingError.dataCorrupted(context) {
				print("❌ Data corrupted:", context.debugDescription)
				print("Coding Path:", context.codingPath)
				completion(.failure(NSError(domain: "com.example.error", code: 4, userInfo: [
					NSLocalizedDescriptionKey: "Data corrupted in JSON response."
				])))
			} catch {
				print("❌ Error decoding response:", error.localizedDescription)
				completion(.failure(error))
			}
		}
		
		task.resume()
	}
	
	
	
	
	
	
	
	func sendOTP(phoneNumber: String, completion: @escaping (Bool) -> Void) {
		guard let url = URL(string: "\(baseURL)users/verify-otp/") else { return }
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
		guard let url = URL(string: "\(baseURL)users/verify-otp/") else {
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
	
	private func addAuthorizationHeader(to request: inout URLRequest) {
		guard let token = accessToken else {
			print("❌ Access token is missing. Authorization header cannot be set.")
			return
		}
		request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
	}
	
	func fetchCategories(completion: @escaping (Result<[Category], Error>) -> Void) {
		guard let url = URL(string: "\(baseURL)products/category/") else {
			completion(.failure(NetworkError.invalidURL))
			return
		}

		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		addAuthorizationHeader(to: &request) 

		URLSession.shared.dataTask(with: request) { data, response, error in
			if let error = error {
				completion(.failure(error))
				return
			}

			guard let data = data else {
				completion(.failure(NetworkError.noData))
				return
			}

			// Log the exact JSON response for debugging
			if let responseString = String(data: data, encoding: .utf8) {
				print("Categories API Raw Response: \(responseString)")
			}

			// Decode the response
			do {
				let categories = try JSONDecoder().decode([Category].self, from: data)
				completion(.success(categories))
			} catch {
				print("❌ Error decoding categories: \(error.localizedDescription)")
				completion(.failure(error))
			}
		}.resume()
	}

	
	
	
	// MARK: - Fetch Products
	func fetchProducts(completion: @escaping (Result<[Product], Error>) -> Void) {
		guard let url = URL(string: "\(baseURL)products/product/") else {
			completion(.failure(NetworkError.invalidURL))
			return
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		addAuthorizationHeader(to: &request)
		
		URLSession.shared.dataTask(with: request) { data, response, error in
			if let error = error {
				completion(.failure(error))
				return
			}
			
			guard let data = data else {
				completion(.failure(NetworkError.noData))
				return
			}
			
			do {
				let products = try JSONDecoder().decode([Product].self, from: data)
				completion(.success(products))
			} catch {
				completion(.failure(error))
			}
		}.resume()
	}
	
	// MARK: - Post Product
	func postProduct(product: Product, completion: @escaping (Result<Void, Error>) -> Void) {
		guard let url = URL(string: "\(baseURL)products/product/") else {
			print("DEBUG: Invalid URL")
			return
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		
		let boundary = UUID().uuidString
		request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
		
		// Add the Authorization header
		addAuthorizationHeader(to: &request)
		
		let httpBody = createMultipartBody(product: product, boundary: boundary)
		request.httpBody = httpBody
		
		print("DEBUG: Starting POST request with URL: \(url)")
		print("DEBUG: HTTP Headers: \(request.allHTTPHeaderFields ?? [:])")
		print("DEBUG: Request Body Size: \(httpBody.count) bytes")
		
		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			if let error = error {
				print("DEBUG: Network error: \(error.localizedDescription)")
				completion(.failure(error))
				return
			}
			
			if let httpResponse = response as? HTTPURLResponse {
				print("DEBUG: HTTP Response Code: \(httpResponse.statusCode)")
				if let data = data, let responseBody = String(data: data, encoding: .utf8) {
					print("DEBUG: Response Body: \(responseBody)")
				}
				
				if httpResponse.statusCode == 201 {
					completion(.success(()))
				} else {
					let errorMessage = "Server responded with status code: \(httpResponse.statusCode)"
					print("DEBUG: \(errorMessage)")
					completion(.failure(NSError(domain: errorMessage, code: httpResponse.statusCode, userInfo: nil)))
				}
			} else {
				print("DEBUG: Invalid response")
				completion(.failure(NSError(domain: "Invalid response", code: 0, userInfo: nil)))
			}
		}
		task.resume()
	}


	private func createMultipartBody(product: Product, boundary: String) -> Data {
		var body = Data()
		
		// Add form fields
		body.append("--\(boundary)\r\n".data(using: .utf8)!)
		body.append("Content-Disposition: form-data; name=\"farmer\"\r\n\r\n".data(using: .utf8)!)
		body.append("\(product.farmer)\r\n".data(using: .utf8)!)
		
		body.append("--\(boundary)\r\n".data(using: .utf8)!)
		body.append("Content-Disposition: form-data; name=\"category\"\r\n\r\n".data(using: .utf8)!)
		body.append("\(product.category)\r\n".data(using: .utf8)!)
		
		body.append("--\(boundary)\r\n".data(using: .utf8)!)
		body.append("Content-Disposition: form-data; name=\"name\"\r\n\r\n".data(using: .utf8)!)
		body.append("\(product.name)\r\n".data(using: .utf8)!)
		
		body.append("--\(boundary)\r\n".data(using: .utf8)!)
		body.append("Content-Disposition: form-data; name=\"price\"\r\n\r\n".data(using: .utf8)!)
		body.append("\(product.price)\r\n".data(using: .utf8)!)
		
		body.append("--\(boundary)\r\n".data(using: .utf8)!)
		body.append("Content-Disposition: form-data; name=\"description\"\r\n\r\n".data(using: .utf8)!)
		body.append("\(product.description)\r\n".data(using: .utf8)!)
		
		body.append("--\(boundary)\r\n".data(using: .utf8)!)
		body.append("Content-Disposition: form-data; name=\"quantity\"\r\n\r\n".data(using: .utf8)!)
		body.append("\(product.quantity)\r\n".data(using: .utf8)!)
		
		// Add image file
		if let imageData = product.image {
			body.append("--\(boundary)\r\n".data(using: .utf8)!)
			body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
			body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
			body.append(imageData)
			body.append("\r\n".data(using: .utf8)!)
		}
		
		body.append("--\(boundary)--\r\n".data(using: .utf8)!)
		print("DEBUG: Multipart body constructed with size: \(body.count) bytes")
		return body
	}
	
	func fetchFarmerProducts(farmerID: Int, completion: @escaping (Result<[Product], Error>) -> Void) {
		guard let url = URL(string: "\(baseURL)products/product/\(farmerID)/") else {
			completion(.failure(NetworkError.invalidURL))
			return
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		addAuthorizationHeader(to: &request)
		
		URLSession.shared.dataTask(with: request) { data, response, error in
			if let error = error {
				print("❌ Network error: \(error.localizedDescription)")
				completion(.failure(error))
				return
			}
			
			guard let data = data else {
				print("❌ No data received from the server")
				completion(.failure(NetworkError.noData))
				return
			}
			
			if let responseString = String(data: data, encoding: .utf8) {
				print("DEBUG: Raw Response - \(responseString)")
			} else {
				print("DEBUG: Unable to decode server response to string.")
			}

			do {
				let json = try JSONSerialization.jsonObject(with: data, options: [])
				print("DEBUG: Decoded JSON Object - \(json)")
			} catch {
				print("DEBUG: JSON Serialization Error - \(error.localizedDescription)")
			}
			
			do {
				let products = try JSONDecoder().decode([Product].self, from: data)
				completion(.success(products))
			} catch {
				print("❌ Decoding error: \(error.localizedDescription)")
				print("DEBUG: Data received - \(data)")
				completion(.failure(error))
			}
		}.resume()
	}
	func fetchMessages(for chatID: Int, completion: @escaping (Result<[Message], Error>) -> Void) {
			guard let url = URL(string: "\(baseURL)chat/\(chatID)/") else {
				completion(.failure(NetworkError.invalidURL))
				return
			}
			
			var request = URLRequest(url: url)
			request.httpMethod = "GET"
			addAuthorizationHeader(to: &request)
			
			URLSession.shared.dataTask(with: request) { data, response, error in
				if let error = error {
					completion(.failure(error))
					return
				}
				
				guard let data = data else {
					completion(.failure(NetworkError.noData))
					return
				}
				
				do {
					let messages = try JSONDecoder().decode([Message].self, from: data)
					completion(.success(messages))
				} catch {
					completion(.failure(error))
				}
			}.resume()
		}
		
	func sendMessage(chatID: Int, message: String, completion: @escaping (Bool) -> Void) {
		guard let url = URL(string: "\(baseURL)chat/\(chatID)/") else {
			completion(false)
			return
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		addAuthorizationHeader(to: &request)
		
		let body: [String: Any] = [
			"message": message
		]
		
		do {
			request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
		} catch {
			completion(false)
			return
		}
		
		URLSession.shared.dataTask(with: request) { _, response, error in
			if let error = error {
				print("Error sending message: \(error.localizedDescription)")
				completion(false)
				return
			}
			
			guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
				completion(false)
				return
			}
			
			completion(true)
		}.resume()
	}
	
	func fetchFarmerChats(completion: @escaping (Result<[Chat], Error>) -> Void) {
		guard let url = URL(string: "\(baseURL)chat/") else {
			completion(.failure(NetworkError.invalidURL))
			return
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		addAuthorizationHeader(to: &request)
		
		URLSession.shared.dataTask(with: request) { data, response, error in
			if let error = error {
				completion(.failure(error))
				return
			}
			
			guard let data = data else {
				completion(.failure(NetworkError.noData))
				return
			}
			
			do {
				let chats = try JSONDecoder().decode([Chat].self, from: data)
				completion(.success(chats))
			} catch {
				completion(.failure(error))
			}
		}.resume()
	}
	
	func fetchAllProducts(completion: @escaping (Result<[Product], Error>) -> Void) {
		guard let url = URL(string: "\(baseURL)products/product/") else {
			completion(.failure(NetworkError.invalidURL))
			print("❌ Invalid URL for fetching products.")
			return
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		addAuthorizationHeader(to: &request)
		
		URLSession.shared.dataTask(with: request) { data, response, error in
			if let error = error {
				print("❌ Network Error: \(error.localizedDescription)")
				completion(.failure(error))
				return
			}
			
			// Validate response and data
			guard let httpResponse = response as? HTTPURLResponse else {
				print("❌ Invalid Response: Not an HTTP URL response.")
				completion(.failure(NetworkError.invalidResponse))
				return
			}
			
			print("✅ HTTP Response Code: \(httpResponse.statusCode)")
			
			guard (200...299).contains(httpResponse.statusCode) else {
				print("❌ Server Error: \(httpResponse.statusCode)")
				completion(.failure(NetworkError.invalidResponse))
				return
			}
			
			guard let data = data else {
				print("❌ No Data Received.")
				completion(.failure(NetworkError.noData))
				return
			}
			
			// Attempt to decode the data
			do {
				let products = try JSONDecoder().decode([Product].self, from: data)
				print("✅ Successfully Decoded Products: \(products.count) items.")
				completion(.success(products))
			} catch {
				print("❌ Decoding Error: \(error.localizedDescription)")
				print("DEBUG: Raw Data - \(String(data: data, encoding: .utf8) ?? "Invalid Data")")
				completion(.failure(error))
			}
		}.resume()
	}
	func fetchFarmer(by id: Int, completion: @escaping (Result<Farmer, Error>) -> Void) {
		guard let url = URL(string: "\(baseURL)farmers/\(id)/") else {
			completion(.failure(NetworkError.invalidURL))
			return
		}

		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		addAuthorizationHeader(to: &request) // Add token if required

		URLSession.shared.dataTask(with: request) { data, response, error in
			if let error = error {
				print("❌ Network error: \(error.localizedDescription)")
				completion(.failure(error))
				return
			}

			guard let data = data else {
				print("❌ No data received.")
				completion(.failure(NetworkError.noData))
				return
			}

			do {
				let farmer = try JSONDecoder().decode(Farmer.self, from: data)
				completion(.success(farmer))
			} catch {
				print("❌ Decoding error: \(error.localizedDescription)")
				completion(.failure(error))
			}
		}.resume()
	}

}

	// MARK: - Network Error Enum
enum NetworkError: LocalizedError {
	case invalidURL
	case noData
	case invalidResponse
	
	var errorDescription: String? {
		switch self {
		case .invalidURL:
			return "The URL is invalid."
		case .noData:
			return "No data was received from the server."
		case .invalidResponse:
			return "The server response was invalid."
		}
	}
}

