import UIKit

class QueuedTutorialController: UIViewController {
    
    enum Section {
        case main
    }
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Tutorial>!
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    
    @IBOutlet var deleteButton: UIBarButtonItem!
    @IBOutlet var updateButton: UIBarButtonItem!
    @IBOutlet var applyUpdatesButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        self.title = "Queue"
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = nil
        
        collectionView.collectionViewLayout = configureCollectionViewLayout()
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureSnapshot()
    }
}

// MARK: - Queue Events -

extension QueuedTutorialController {
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if isEditing {
            navigationItem.rightBarButtonItems = nil
            navigationItem.rightBarButtonItem = deleteButton
        } else {
            navigationItem.rightBarButtonItem = nil
            navigationItem.rightBarButtonItems = [self.applyUpdatesButton, self.updateButton]
        }
        
        collectionView.allowsMultipleSelection = true
        collectionView.indexPathsForVisibleItems.forEach { indexPath in
            guard let cell = collectionView.cellForItem(at: indexPath) as? QueueCell else { return }
            cell.isEditing = isEditing
            
            if !isEditing {
                cell.isSelected = false
            }
        }
    }
    
    @IBAction func deleteSelectedItems() {
        guard let selectedIndexPaths = collectionView.indexPathsForSelectedItems else {
            return
        }
        
        let tutorials = selectedIndexPaths.compactMap { dataSource.itemIdentifier(for: $0) }
        
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.deleteItems(tutorials)
        
        dataSource.apply(currentSnapshot, animatingDifferences: true)
        isEditing.toggle()
    }
    
    @IBAction func triggerUpdates() {
        
    }
    
    @IBAction func applyUpdates() {
    }
}

extension QueuedTutorialController {
    func configureCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        let gropSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(149))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: gropSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Tutorial>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, itemIdentifier: Tutorial) in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QueueCell.reuseIdentifier, for: indexPath) as? QueueCell else {
                fatalError("Could not deque QueueCell")
            }
            
            cell.titleLabel.text = itemIdentifier.title
            cell.thumbnailImageView.image = itemIdentifier.image
            cell.thumbnailImageView.backgroundColor = itemIdentifier.imageBackgroundColor
            cell.publishDateLabel.text = itemIdentifier.formattedDate(using: self.dateFormatter)
            
            return cell
        })
    }
    
    func configureSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Tutorial>()
        snapshot.appendSections([.main])
        
        let queuedTutorials = DataSource.shared.tutorials.flatMap({ $0.queuedTutorials })
        snapshot.appendItems(queuedTutorials)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
