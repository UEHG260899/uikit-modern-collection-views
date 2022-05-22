import UIKit

class TutorialCell: UICollectionViewCell {
  static let reuseIdentifier = String(describing: TutorialCell.self)
  
  @IBOutlet weak var thumbnailImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
}
