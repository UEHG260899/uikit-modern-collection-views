import UIKit

final class ContentCell: UICollectionViewCell {
  static let reuseIdentifier = String(describing: ContentCell.self)
  @IBOutlet weak var textLabel: UILabel!
}
