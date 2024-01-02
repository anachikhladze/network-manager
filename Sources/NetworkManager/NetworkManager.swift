// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit

@available(iOS 13.0.0, *)
public actor NetworkManager {
        
    public static let shared = NetworkManager()
    
    private init() {}
    
    private func downloadData(fromURL urlString: String) async throws -> Data {
        
        guard let url = URL(string: urlString) else { throw GHError.invalidURL }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHError.invalidResponse
        }
        
        return data
    }
    
    private func decodeData<T: Decodable>(with data: Data) async throws -> T {
        do {
            let decoder = JSONDecoder()
            let object = try decoder.decode(T.self, from: data)
            return object
        } catch {
            throw GHError.invalidData
        }
    }
    
    public func fetchData<T: Decodable>(fromURL urlString: String) async throws -> T {
        do {
            let data = try await downloadData(fromURL: urlString)
            let decodedData: T = try await decodeData(with: data)
            return decodedData
        } catch {
            throw error
        }
    }
    
    public func fetchImage(fromURL urlString: String) async throws -> UIImage {
        do {
            let data = try await downloadData(fromURL: urlString)
            guard let image = UIImage(data: data) else {
                throw GHError.invalidData
            }
            return image
        } catch {
            throw error
        }
        
    }
}


enum GHError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
