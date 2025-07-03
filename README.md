# 📱 Social Feed App

Приложение представляет собой простую ленту постов, получаемую из сети, с возможностью лайкать посты, кэшировать данные и работать в оффлайн-режиме.

---

## 🧱 Архитектура

Проект реализован по архитектуре **MVVM (Model - View - ViewModel)** с использованием `CoreData` для локального хранилища и `Alamofire` для работы с сетью.

### Компоненты:

- **Model:**
  - `Post` — модель для API.
  - `CDPost` — NSManagedObject-модель для Core Data.
- **ViewModel:**
  - `PostListViewModel` — управляет загрузкой, сортировкой, кэшированием и состоянием UI.
- **View (UIKit):**
  - `PostListViewController` — отображает список постов в `UITableView`.
  - `PostCell` — кастомная ячейка с поддержкой лайков.
- **Сторонние зависимости:**
  - `Alamofire` — загрузка данных из сети.
- **Хранение данных:**
  - `CoreDataManager` — обёртка над `NSPersistentContainer`, сохраняет и извлекает данные локально.
- **Утилиты:**
  - `ImageLoader` — кэширует и загружает аватары пользователей.
  - Расширение `String+firstUppercased`.

---

## ⚙️ Используемые технологии

- `Swift`
- `UIKit`
- `MVVM`
- `Alamofire`
- `CoreData`
- `NSCache` (для кэширования изображений)
- `URLSession` (через Alamofire)
- `UITableView` + Pull-to-Refresh
- `UINavigationController`

---

## 🛠 Инструкция по сборке

1. **Склонируйте репозиторий:**

```bash
git clone https://github.com/your-username/social-feed-app.git
