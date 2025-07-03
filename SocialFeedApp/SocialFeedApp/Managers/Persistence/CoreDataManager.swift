import CoreData
import UIKit

// MARK: - Менеджер Core Data для работы с постами

final class CoreDataManager {
    
    // Синглтон для глобального доступа
    static let shared = CoreDataManager()
    
    // MARK: - Persistent Container
    
    /// NSPersistentContainer с именем модели "SocialFeedModel"
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SocialFeedModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error \(error)") // сбой при загрузке модели
            }
        }
        return container
    }()
    
    /// Контекст для работы с CoreData (viewContext)
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // MARK: - Общий метод сохранения
    
    /// Сохраняет изменения в контексте, если они есть
    func saveContext() {
        if context.hasChanges {
            try? context.save()
        }
    }

    // MARK: - Работа с постами

    /// Сохраняет массив постов в Core Data, предварительно очищая старые
    func savePosts(_ posts: [Post]) {
        clearPosts()
        for post in posts {
            let entity = CDPost(context: context)
            entity.id = Int64(post.id)
            entity.userId = Int64(post.userId)
            entity.title = post.title
            entity.body = post.body
            entity.liked = false
        }
        saveContext()
    }
    
    /// Загружает все посты из Core Data
    func fetchPosts() -> [CDPost] {
        let request: NSFetchRequest<CDPost> = CDPost.fetchRequest()
        return (try? context.fetch(request)) ?? []
    }
    
    /// Переключает лайк на посте и сохраняет контекст
    func toggleLike(for post: CDPost) {
        post.liked.toggle()
        saveContext()
    }
    
    /// Удаляет все посты из Core Data
    func clearPosts() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CDPost.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try? context.execute(deleteRequest)
        saveContext()
    }
}
