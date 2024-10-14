import Foundation
import UIKit

final class FilloutService {
    func fetchSubmissions(limit: Int, offset: Int, completion: @escaping (Result<[Submission], Error>) -> Void) {
        
        let baseURL = ProcessInfo.processInfo.environment["BASE_URL"] ?? ""
        guard let url = URL(string: "\(baseURL)/v1/api/forms/\(ServerConfig.shared.baseURL)/submissions?limit=\(limit)&offset=\(offset)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let apiKey = ProcessInfo.processInfo.environment["FILLOUT_API_KEY"] ?? ""
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let submissionResponse = try JSONDecoder().decode(SubmissionResponse.self, from: data)
                completion(.success(submissionResponse.responses))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

extension UIImage {
    func resizedMaintainingAspectRatio(targetSize: CGSize) -> UIImage {
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let scaleFactor = min(widthRatio, heightRatio)
        
        let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
