
import UIKit

class ImageCell: UICollectionViewCell {
    
    static let identifier = "ImageCell"

    
    @IBOutlet weak var selectLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectLabel.layer.cornerRadius = 15
        self.selectLabel.layer.masksToBounds = true
        self.selectLabel.layer.borderColor = UIColor.white.cgColor
        self.selectLabel.layer.borderWidth = 1.0
        self.selectLabel.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }

    
    var isEditing: Bool = false {
        didSet {
            selectLabel.isHidden = !isEditing
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isEditing {
                selectLabel.text = isSelected ? "✓" : ""
            }
        }
    }
    
    
    public func configure(withImage image : UIImage) {
        imageView.image = image
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        selectLabel.isHidden = !isEditing
        imageView.image = nil
    }
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
}
