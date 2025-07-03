import Foundation
import Alamofire

// MARK: - Протокол для моков и удобной подмены зависимостей

protocol APIServiceProtocol {
    /// Загружает список постов с сервера
    func fetchPosts(completion: @escaping (Result<[Post], Error>) -> Void)
}

// MARK: - Основная реализация API-сервиса

final class APIService: APIServiceProtocol {
    private enum Constants {
        static let baseURL = "https://jsonplaceholder.typicode.com"
    }
    // Синглтон для глобального доступа
    static let shared = APIService()
    
    // Приватная сессия Alamofire с кастомной конфигурацией
    private let session: Session
    
    // MARK: - Инициализация
    
    private init() {
        // Конфигурация сессии: стандартная + установка таймаута запроса
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10 // секунды
        session = Session(configuration: configuration)
    }
    
    // MARK: - Методы API
    
    /// Загружает список постов через GET-запрос
    func fetchPosts(completion: @escaping (Result<[Post], Error>) -> Void) {
        let endpoint = "/posts"
        let url = Constants.baseURL + endpoint

        session.request(url)
            .validate() // проверка кода ответа (200–299)
            .responseDecodable(of: [Post].self) { response in
                switch response.result {
                case .success(let posts):
                    completion(.success(posts))
                case .failure(let error):
                    print("❌ API Error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
    }
}
