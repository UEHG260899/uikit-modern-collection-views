import UIKit

class QueuedTutorialController: UIViewController {
    
    static let badgeElementKind = "badge-element-kind"
    
    
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
    
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        self.title = "Queue"
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = nil
        
        collectionView.collectionViewLayout = configureCollectionViewLayout()
        collectionView.register(BadgeSupplementaryView.self,
                                forSupplementaryViewOfKind: QueuedTutorialController.badgeElementKind,
                                withReuseIdentifier: BadgeSupplementaryView.reuseIdentifier)
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureSnapshot()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { [weak self] _ in
            guard let self = self else {
                return
            }
            
            self.triggerUpdates()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { [weak self] in
                guard let self = self else {
                    return
                }
                
                self.applyUpdates()
            }
        })
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
        let indexPaths = collectionView.indexPathsForVisibleItems
        let randomIndexPath = indexPaths[Int.random(in: 0..<indexPaths.count)]
        let tutorial = dataSource.itemIdentifier(for: randomIndexPath)
        tutorial?.updateCount = 3
        
        let badgeView = collectionView.supplementaryView(forElementKind: QueuedTutorialController.badgeElementKind, at: randomIndexPath)
        badgeView?.isHidden = false
    }
    
    @IBAction func applyUpdates() {
        let tutorials = dataSource.snapshot().itemIdentifiers
        
        if var firstTutorial = tutorials.first,
           tutorials.count > 2 {
            let tutorialsWithUpdates = tutorials.filter { $0.updateCount > 0 }
            
            var currentSnapshot = dataSource.snapshot()
            tutorialsWithUpdates.forEach { tutorial in
                if tutorial != firstTutorial {
                    currentSnapshot.moveItem(tutorial, beforeItem: firstTutorial)
                    firstTutorial = tutorial
                    tutorial.updateCount = 0
                }
                
                if let indexPath = dataSource.indexPath(for: tutorial) {
                    let badgeView = collectionView.supplementaryView(forElementKind: QueuedTutorialController.badgeElementKind, at: indexPath)
                    badgeView?.isHidden = true
                }
            }
            
            dataSource.apply(currentSnapshot, animatingDifferences: true)
        }
    }
}

extension QueuedTutorialController {
    func configureCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        
        let anchorEdges: NSDirectionalRectEdge = [.top, .trailing]
        let offset = CGPoint(x: 0.3, y: -0.3)
        let badgeAnchor = NSCollectionLayoutAnchor(edges: anchorEdges, fractionalOffset: offset)
        
        let badgeSize = NSCollectionLayoutSize(widthDimension: .absolute(20), heightDimension: .absolute(20))
        let badge = NSCollectionLayoutSupplementaryItem(layoutSize: badgeSize, elementKind: QueuedTutorialController.badgeElementKind, containerAnchor: badgeAnchor)
        
        
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize, supplementaryItems: [badge])
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
        
        dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            
            guard let self = self,
                  let tutorial = self.dataSource.itemIdentifier(for: indexPath),
                  let badgeView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: BadgeSupplementaryView.reuseIdentifier, for: indexPath) as? BadgeSupplementaryView else {
                return nil
            }
            
            if tutorial.updateCount > 0 {
                badgeView.isHidden = false
            } else {
                badgeView.isHidden = true
            }
            
            return badgeView
        }
    }
    
    func configureSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Tutorial>()
        snapshot.appendSections([.main])
        
        let queuedTutorials = DataSource.shared.tutorials.flatMap({ $0.queuedTutorials })
        snapshot.appendItems(queuedTutorials)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
