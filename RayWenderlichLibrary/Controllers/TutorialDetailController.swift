import UIKit

final class TutorialDetailViewController: UIViewController {
    
    static let identifier = String(describing: TutorialDetailViewController.self)
    
    
    private let tutorial: Tutorial
    
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
        tutorialCoverImageView.image = tutorial.image
        tutorialCoverImageView.backgroundColor = tutorial.imageBackgroundColor
        titleLabel.text = tutorial.title
        publishDateLabel.text = tutorial.formattedDate(using: dateFormatter)
        
        let buttonTitle = tutorial.isQueued ? "Remove from queue" : "Add to queue"
        queueButton.setTitle(buttonTitle, for: .normal)
    }
    
    @IBAction func toggleQueued() {
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
