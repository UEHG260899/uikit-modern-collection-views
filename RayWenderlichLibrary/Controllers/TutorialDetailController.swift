import UIKit

final class TutorialDetailViewController: UIViewController {
    
    typealias CourseDataSource = UICollectionViewDiffableDataSource<Section, Video>
    
    static let identifier = String(describing: TutorialDetailViewController.self)
    
    
    private let tutorial: Tutorial
    private var dataSource: CourseDataSource!
    
    @IBOutlet weak var tutorialCoverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var publishDateLabel: UILabel!
    @IBOutlet weak var queueButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init?(coder: NSCoder, tutorial: Tutorial) {
        self.tutorial = tutorial
        super.init(coder: coder)
    }
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        self.title = tutorial.title
        collectionView.register(TitleSupplementaryView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: TitleSupplementaryView.reuseIdentifier)
        tutorialCoverImageView.image = tutorial.image
        tutorialCoverImageView.backgroundColor = tutorial.imageBackgroundColor
        titleLabel.text = tutorial.title
        publishDateLabel.text = tutorial.formattedDate(using: dateFormatter)
        
        let buttonTitle = tutorial.isQueued ? "Remove from queue" : "Add to queue"
        queueButton.setTitle(buttonTitle, for: .normal)
        collectionView.collectionViewLayout = configureCollectionViewLayout()
        configureDataSource()
        configureSnapshot()
    }
    
    @IBAction func toggleQueued() {
        tutorial.isQueued.toggle()
        
        UIView.performWithoutAnimation {
            if tutorial.isQueued {
                queueButton.setTitle("Remove from queue", for: .normal)
            } else {
                queueButton.setTitle("Add to queue", for: .normal)
            }
            
            self.queueButton.layoutIfNeeded()
        }
    }
}

extension TutorialDetailViewController {
    func configureCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.2))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10)
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44.0))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            section.boundarySupplementaryItems = [sectionHeader]
            
            return section
            
        }
        
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
    
    func configureDataSource() {
        dataSource = CourseDataSource(collectionView: self.collectionView, cellProvider: { (collectionView: UICollectionView, indexPath: IndexPath, video: Video) in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContentCell.reuseIdentifier, for: indexPath) as? ContentCell else {
                fatalError("COuld not deque ContentCell")
            }
            
            cell.textLabel.text = video.title
            
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
    
    func configureSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Video>()
        
        tutorial.content.forEach { section in
            snapshot.appendSections([section])
            snapshot.appendItems(section.videos)
        }
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
