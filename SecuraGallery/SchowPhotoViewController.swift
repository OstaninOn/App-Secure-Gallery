
//  SchowPhotoViewController.swift
//  SecuraGallery
//
//  Created by  aleksandr on 3.12.22.


import Foundation
import UIKit

class SchowPhotoViewController: UIViewController, UIScrollViewDelegate {
    let size : CGFloat = 60
    var image = UIImage()

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUp()
    }
    private func setUp() {
        imageView.image = image
        scrollView.delegate = self
    }

    @IBAction func dismissVC(_ sender: Any) {
        dismiss(animated: true)
    }
    

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

}
