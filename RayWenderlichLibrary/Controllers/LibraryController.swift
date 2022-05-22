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
        collectionView.delegate = self
        collectionView.register(TitleSupplementaryView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: TitleSupplementaryView.reuseIdentifier)
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
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
            section.boundarySupplementaryItems = [sectionHeader]
            
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
        
        dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            if let self = self,
                let titleSupplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TitleSupplementaryView.reuseIdentifier, for: indexPath) as? TitleSupplementaryView {
                
                let tutorialCollection = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
                titleSupplementaryView.textLabel.text = tutorialCollection.title
                return titleSupplementaryView
            } else {
                return nil
            }
        }
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

extension LibraryController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let tutorial = dataSource.itemIdentifier(for: indexPath),
           let tutorialDetailController = storyboard?.instantiateViewController(identifier: TutorialDetailViewController.identifier, creator: { coder in
               return TutorialDetailViewController(coder: coder, tutorial: tutorial)
           }) {
            show(tutorialDetailController, sender: nil)
        }
    }
}
