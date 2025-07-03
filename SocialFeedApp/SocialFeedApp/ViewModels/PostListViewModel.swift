import Foundation

/// ViewModel, управляющая загрузкой, сортировкой и отображением списка постов.
final class PostListViewModel {
    
    // MARK: - Constants
    
    private enum Constants {
        /// Сообщение об ошибке при отсутствии интернета
        static let errorMessage = "Нет интернета или сервер не отвечает. Потяните вниз для повторной загрузки."
    }

    // MARK: - Public Properties

    /// Список постов (отсортированный)
    var posts: [CDPost] = []

    /// Коллбэк при обновлении данных (для UI)
    var onPostsUpdated: (() -> Void)?

    /// Коллбэк при ошибке (например, при отсутствии интернета)
    var onError: ((String) -> Void)?

    // MARK: - Dependencies

    private var coreDataManager = CoreDataManager.shared
    private let apiService: APIServiceProtocol
    
    private let pageSize = 25
    private var currentPage = 0
    private var isLoading = false
    private var allLoaded = false
    
    init(apiService: APIServiceProtocol = APIService.shared) {
        self.apiService = apiService
    }

    // MARK: - Public Methods

    /// Вызывается при первом запуске и при pull-to-refresh.
    /// Если кэш пустой — загружает с API, иначе — из CoreData.
    func refreshData() {
        let cachedPosts = coreDataManager.fetchPosts()
        if cachedPosts.isEmpty {
            fetchPostsFromAPI()
        } else {
            posts = sortPosts(cachedPosts)
            onPostsUpdated?()
        }
    }

    /// Загружает посты с сервера.
    /// В случае успеха — сохраняет в CoreData и обновляет список.
    /// В случае ошибки — загружает из кэша и отправляет сообщение об ошибке.
    func fetchPostsFromAPI() {
        apiService.fetchPosts { [weak self] result in
            switch result {
            case .success(let posts):
                self?.coreDataManager.savePosts(posts)
                self?.loadFromCoreData()
            case .failure:
                self?.loadFromCoreData()
                self?.onError?(Constants.errorMessage)
            }
        }
    }

    /// Загружает и сортирует посты из локального хранилища.
    func loadFromCoreData() {
        posts = sortPosts(coreDataManager.fetchPosts())
        DispatchQueue.main.async {
            self.onPostsUpdated?()
        }
    }

    /// Переключает лайк у выбранного поста и обновляет список.
    func toggleLike(at index: Int) {
        let post = posts[index]
        coreDataManager.toggleLike(for: post)
        DispatchQueue.main.async {
            self.onPostsUpdated?()
        }
    }

    // MARK: - Private Methods

    /// Сортирует посты: лайкнутые первыми, остальные — по убыванию id.
    private func sortPosts(_ posts: [CDPost]) -> [CDPost] {
        return posts.sorted { lhs, rhs in
            if lhs.liked == rhs.liked {
                return lhs.id > rhs.id
            }
            return lhs.liked && !rhs.liked
        }
    }
}
