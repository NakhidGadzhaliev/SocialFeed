import UIKit

/// Класс-одиночка для загрузки и кэширования изображений из сети.
final class ImageLoader {

    // MARK: - Properties

    static let shared = ImageLoader()

    /// Кэш изображений в памяти, ключом является URL.
    private let cache = NSCache<NSURL, UIImage>()

    private init() {}

    // MARK: - Public Methods

    /// Загружает изображение по URL с кэшированием.
    /// - Parameters:
    ///   - url: URL изображения.
    ///   - completion: Замыкание, вызываемое с изображением или `nil`, если загрузка не удалась.
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        // Проверка, есть ли изображение в кэше
        if let cachedImage = cache.object(forKey: url as NSURL) {
            completion(cachedImage)
            return
        }

        // Загрузка изображения из сети
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard
                let self = self,
                let data = data,
                let image = UIImage(data: data)
            else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            // Сохраняем изображение в кэш
            self.cache.setObject(image, forKey: url as NSURL)

            // Возвращаем результат на главном потоке
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}
