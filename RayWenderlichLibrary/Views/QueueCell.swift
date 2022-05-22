import UIKit

class QueueCell: UICollectionViewCell {
  static let reuseIdentifier = String(describing: QueueCell.self)
  
  var isEditing: Bool = false {
    didSet {
      checkboxImageView.isHidden = !isEditing
    }
  }

  override var isSelected: Bool {
    didSet {
      if isSelected{
        checkboxImageView.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large))
      } else  {
        checkboxImageView.image = UIImage(systemName: "checkmark.circle", withConfiguration: UIImage.SymbolConfiguration(scale: .large))
      }
    }
  }

  @IBOutlet weak var thumbnailImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var publishDateLabel: UILabel!
  @IBOutlet weak var checkboxImageView: UIImageView!
}

