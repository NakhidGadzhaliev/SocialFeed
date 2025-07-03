import UIKit

// Кастомная ячейка для отображения поста в таблице
final class PostCell: UITableViewCell {
    static let reuseId = "PostCell"
    
    // MARK: - Константы разметки и иконок
    
    private enum Constants {
        static let avatarSize: CGFloat = 40
        static let likeButtonSize: CGFloat = 30
        static let outerPadding: CGFloat = 12
        static let interItemSpacing: CGFloat = 8
        static let verticalSpacing: CGFloat = 4
        
        static let heart = "heart"
        static let heartFill = "heart.fill"
        static let personCrop = "person.crop.circle"
    }
    
    // Коллбек при нажатии на кнопку "лайк"
    var onLikeTapped: (() -> Void)?
    
    // MARK: - UI компоненты
    
    // Аватар пользователя
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = Constants.avatarSize / 2
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: Constants.personCrop) // Плейсхолдер
        return imageView
    }()
    
    // Заголовок поста
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    // Основной текст поста
    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    // Кнопка лайка
    private let likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: Constants.heart), for: .normal)
        button.tintColor = .systemRed
        return button
    }()
    
    // MARK: - Инициализация
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        likeButton.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Конфигурация ячейки

    func configure(with post: CDPost) {
        titleLabel.text = post.title?.firstUppercased
        bodyLabel.text = post.body?.firstUppercased

        // Отображение лайка: заполненное или пустое сердце
        let heartImageName = post.liked ? Constants.heartFill : Constants.heart
        likeButton.setImage(UIImage(systemName: heartImageName), for: .normal)
        
        // Формируем URL для генерации случайного аватара
        let avatarURL = URL(string: "https://i.pravatar.cc/100?u=\(post.id)")
        avatarImageView.image = UIImage(systemName: Constants.personCrop) // временное изображение
        
        // Асинхронно загружаем аватар
        if let url = avatarURL {
            ImageLoader.shared.loadImage(from: url) { [weak self] image in
                self?.avatarImageView.image = image
            }
        }
    }
    
    // MARK: - Обработка действий
    
    // Коллбек при нажатии на кнопку лайка
    @objc private func likeTapped() {
        onLikeTapped?()
    }
    
    // MARK: - Разметка

    private func setupLayout() {
        backgroundColor = .clear
        
        // Добавляем все UI-элементы в contentView
        [avatarImageView, titleLabel, bodyLabel, likeButton].forEach {
            contentView.addSubview($0)
        }
        
        // Констрейнты для всех компонентов ячейки
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.outerPadding),
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.outerPadding),
            avatarImageView.widthAnchor.constraint(equalToConstant: Constants.avatarSize),
            avatarImageView.heightAnchor.constraint(equalToConstant: Constants.avatarSize),
            
            likeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.outerPadding),
            likeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.outerPadding),
            likeButton.widthAnchor.constraint(equalToConstant: Constants.likeButtonSize),
            likeButton.heightAnchor.constraint(equalToConstant: Constants.likeButtonSize),
            
            titleLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: Constants.interItemSpacing),
            titleLabel.trailingAnchor.constraint(equalTo: likeButton.leadingAnchor, constant: -Constants.interItemSpacing),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.outerPadding),
            
            bodyLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            bodyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.outerPadding),
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.verticalSpacing),
            bodyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.outerPadding)
        ])
    }
}
