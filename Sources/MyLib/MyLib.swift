import UIKit

// MARK: - Протокол для делегата
public protocol ButtonCollectionDelegate: AnyObject {
    func didTapButton(withTitle title: String)
}

// MARK: - Ячейка для кнопки
public class ButtonCollectionCell: UICollectionViewCell {
    
    public static let reuseIdentifier = "ButtonCollectionCell"
    
    public weak var delegate: ButtonCollectionDelegate?
    
    public lazy var button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.lightGray, for: .highlighted)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    @objc private func buttonTapped() {
        if let title = button.title(for: .normal) {
            delegate?.didTapButton(withTitle: title)
        }
    }
    
    public func configure(with title: String, backgroundColor: UIColor, textColor: UIColor) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = backgroundColor
        button.setTitleColor(textColor, for: .normal)
    }
}

// MARK: - Основной контроллер для коллекции кнопок
public class ButtonCollectionController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, @preconcurrency ButtonCollectionDelegate {
    
    private var buttonTitles: [String]
    private var buttonBackgroundColor: UIColor
    private var buttonTextColor: UIColor
    private var controllers: [String: UIViewController]
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 150, height: 50)
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ButtonCollectionCell.self, forCellWithReuseIdentifier: ButtonCollectionCell.reuseIdentifier)
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public init(buttonTitles: [String], buttonBackgroundColor: UIColor = .systemBlue, buttonTextColor: UIColor = .white, controllers: [String: UIViewController]) {
        self.buttonTitles = buttonTitles
        self.buttonBackgroundColor = buttonBackgroundColor
        self.buttonTextColor = buttonTextColor
        self.controllers = controllers
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        if let firstTitle = buttonTitles.first {
            displayContent(for: firstTitle)
        }
    }
    
    private func setupView() {
        view.backgroundColor = .white
        view.addSubview(collectionView)
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            collectionView.heightAnchor.constraint(equalToConstant: 70),
            
            containerView.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - UICollectionViewDataSource
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return buttonTitles.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ButtonCollectionCell.reuseIdentifier, for: indexPath) as! ButtonCollectionCell
        cell.configure(with: buttonTitles[indexPath.row], backgroundColor: buttonBackgroundColor, textColor: buttonTextColor)
        cell.delegate = self
        return cell
    }
    
    // MARK: - ButtonCollectionDelegate
    public func didTapButton(withTitle title: String) {
        displayContent(for: title)
    }
    
    private func displayContent(for title: String) {
        if let currentChild = children.first {
            currentChild.willMove(toParent: nil)
            currentChild.view.removeFromSuperview()
            currentChild.removeFromParent()
        }
        
        if let controller = controllers[title] {
            addChild(controller)
            containerView.addSubview(controller.view)
            controller.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                controller.view.topAnchor.constraint(equalTo: containerView.topAnchor),
                controller.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                controller.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                controller.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
            controller.didMove(toParent: self)
        }
    }
}
