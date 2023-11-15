//
//  ImageCell.swift
//  SecuraGallery
//
//  Created by Yury Vozleev on 01.12.2022.
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    static let identifier = "ImageCell"

    @IBOutlet weak var imageView: UIImageView!
    
    public func configure(withImage image : UIImage) {
        imageView.image = image
    }
    
    override func prepareForReuse() {
        imageView.image = nil
    }
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

}
