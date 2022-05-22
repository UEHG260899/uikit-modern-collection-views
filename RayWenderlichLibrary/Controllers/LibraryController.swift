import UIKit

final class LibraryController: UIViewController {
    typealias TutorialDataSource = UICollectionViewDiffableDataSource<TutorialCollection, Tutorial>
    
    @IBOutlet weak var collectionView: UICollectionView!
    // <Section Type, Item type>
    private var dataSource: TutorialDataSource!
    private let tutorialCollections = DataSource.shared.tutorials
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        self.title = "Library"
        collectionView.collectionViewLayout = configureCollectionViewLaout()
        configuraDataSource()
        configuraSnapshot()
    }
}

// MARK: - CollectionView -

extension LibraryController {
    func configureCollectionViewLaout() -> UICollectionViewCompositionalLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.6), heightDimension: .fractionalHeight(0.3))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .groupPaging
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            section.interGroupSpacing = 10
            
            return section
        }
        
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}

extension LibraryController {
    func configuraDataSource() {
        dataSource = TutorialDataSource(collectionView: self.collectionView, cellProvider: { (collectionView: UICollectionView, indexPath: IndexPath, tutorial: Tutorial) in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TutorialCell.reuseIdentifier, for: indexPath) as? TutorialCell else {
                fatalError("Could not deque cell")
            }
            
            
            cell.titleLabel.text = tutorial.title
            cell.thumbnailImageView.image = tutorial.image
            cell.thumbnailImageView.backgroundColor = tutorial.imageBackgroundColor
            
            return cell
        })
    }
    
    func configuraSnapshot() {
        var currentSnapshot = NSDiffableDataSourceSnapshot<TutorialCollection, Tutorial>()
        
        tutorialCollections.forEach { collection in
            currentSnapshot.appendSections([collection])
            currentSnapshot.appendItems(collection.tutorials)
        }
        
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
}
