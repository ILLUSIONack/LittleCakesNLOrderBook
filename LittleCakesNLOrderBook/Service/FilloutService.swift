import Foundation

class FilloutService {
    func fetchSubmissions(completion: @escaping (Result<[Submission], Error>) -> Void) {
        
        let baseURL = ProcessInfo.processInfo.environment["BASE_URL"] ?? ""
        guard let url = URL(string: "\(baseURL)/v1/api/forms/\(ServerConfig.shared.baseURL)/submissions") else {
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
                completion(.failure(
                    NSError(
                        domain: "No data",
                        code: 0,
                        userInfo: nil
                    ))
                )
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("JSON Response: \(jsonString)")
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
