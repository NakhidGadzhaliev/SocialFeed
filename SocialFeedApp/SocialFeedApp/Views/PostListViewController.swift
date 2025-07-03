import UIKit

/// Контроллер, отображающий ленту постов с поддержкой pull-to-refresh и лайков.
final class PostListViewController: UIViewController {

    // MARK: - UI Constants

    private enum Constants {
        static let feed = "Посты"
        static let emptyText = "Нет постов \nПотяните вниз, чтобы обновить"
        static let error = "Ошибка"
        static let ok = "OK"
        static let emptyTextColor: UIColor = .gray
        static let backgroundColor: UIColor = .white
        static let navTitleColor: UIColor = .black
    }

    // MARK: - Properties

    private let viewModel = PostListViewModel()

    // Таблица для отображения постов
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = Constants.backgroundColor
        tableView.showsVerticalScrollIndicator = true
        tableView.indicatorStyle = .black
        tableView.register(PostCell.self, forCellReuseIdentifier: PostCell.reuseId)
        return tableView
    }()

    // Pull-to-refresh контрол
    private let refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        return control
    }()

    // Метка, отображающаяся при пустом списке
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.emptyText
        label.textColor = Constants.emptyTextColor
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.backgroundColor

        setupTableView()
        bindViewModel()
        setupNavBar()

        // Загрузка постов при первом запуске
        viewModel.refreshData()
    }

    // MARK: - Setup Methods

    /// Настройка таблицы и её layout
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
        tableView.backgroundView = emptyLabel
        tableView.allowsSelection = false
        refreshControl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    /// Настройка внешнего вида навигационного бара
    private func setupNavBar() {
        title = Constants.feed

        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: Constants.navTitleColor
        ]

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Constants.backgroundColor
        appearance.titleTextAttributes = [.foregroundColor: Constants.navTitleColor]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    /// Подписка на события обновления данных ViewModel
    private func bindViewModel() {
        viewModel.onPostsUpdated = { [weak self] in
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2) {
                    self?.tableView.alpha = 1.0
                }
                
                self?.tableView.reloadData()
                self?.refreshControl.endRefreshing()
                
                // Показываем пустой текст, если нет данных
                let isEmpty = self?.viewModel.posts.isEmpty ?? true
                self?.tableView.backgroundView?.isHidden = !isEmpty
            }
        }

        viewModel.onError = { [weak self] message in
            DispatchQueue.main.async {
                let alert = UIAlertController(
                    title: Constants.error,
                    message: message,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: Constants.ok, style: .default))
                self?.present(alert, animated: true)
            }
        }
    }

    // MARK: - Actions

    /// Обновление данных при pull-to-refresh
    @objc private func refreshPulled() {
        UIView.animate(withDuration: 0.2) {
            self.tableView.alpha = 0.7
        }
        viewModel.refreshData()
    }

}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension PostListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: PostCell.reuseId,
            for: indexPath
        ) as? PostCell else {
            return UITableViewCell()
        }

        let post = viewModel.posts[indexPath.row]
        cell.configure(with: post)

        // Обработка нажатия на кнопку "лайк"
        cell.onLikeTapped = { [weak self] in
            self?.viewModel.toggleLike(at: indexPath.row)
        }

        return cell
    }
}
