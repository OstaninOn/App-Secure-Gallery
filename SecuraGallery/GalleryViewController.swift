//
//  GalleryViewController.swift
//  SecuraGallery
//
//  Created by  aleksandr on 1.11.22.

import UIKit
import PhotosUI

class GalleryViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var images: [UIImage] = []
    var imagesPerLine: CGFloat = 4
    let imageSpacing: CGFloat = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        let gesture = UIPinchGestureRecognizer(target: self, action: #selector(changeCountInRow))
        collectionView.addGestureRecognizer(gesture)
    }
  
    private func setupCollectionView() {
        collectionView.register(ImageCell.nib(), forCellWithReuseIdentifier: ImageCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        loadImage()
    }

    @IBAction func pickImage(_ sender: Any) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraSelection = NSLocalizedString("notificationCamera", comment: "the user will see the camera button")
        let cameraAction = UIAlertAction(title: cameraSelection, style: .default) { _ in
            self.showPicker(withSourceType: .camera)
        }
        let photoSelection = NSLocalizedString("notificationPhoto", comment: "the user will see the photo library button")
        let libraryAction = UIAlertAction(title: photoSelection, style: .default) { _ in
      
            var config = PHPickerConfiguration()
            config.selectionLimit = 0

            let phPickerVC = PHPickerViewController(configuration: config)
            phPickerVC.delegate = self
            self.present(phPickerVC, animated: true)
            
            self.showPicker(withSourceType: .photoLibrary)
        }
        
        let cencelSelection = NSLocalizedString("сancelNotificationGallery", comment: "the user will see a cancel button")
        let cancelAction = UIAlertAction(title: cencelSelection, style: .cancel)
        let urlSelection = NSLocalizedString("urlNotification", comment: "the user will see a URL button")
        let urlAction = UIAlertAction(title: urlSelection, style: .default) { [weak self] _ in
            let urlAlertTitl = NSLocalizedString("notificationTitleUrl", comment: "the user will see a notification title url")
            let urlAlert = UIAlertController(title: urlAlertTitl, message: nil, preferredStyle: .alert)
            urlAlert.addTextField{textField in
                textField.placeholder = "https://"
            }
            let acceptUrl = NSLocalizedString("notificationAccept", comment: "the user will see a follow the link button")
            let acceptAction = UIAlertAction(title: acceptUrl, style: .default){_ in
                let text = urlAlert.textFields?.first?.text ?? ""
                guard let url = URL(string: text) else { return }
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url) {
                        DispatchQueue.main.async {
                            guard let newImage = UIImage(data: data) else { return }
                            self?.setImage(newImage)
                        }
                    }
                }
            }
            let cencelSelectionUrl = NSLocalizedString("сancelNotificationUrl", comment: "the user will see a cancel alert url button")
            let cencelAlert = UIAlertAction(title: cencelSelectionUrl, style: .default)
            urlAlert.addAction(acceptAction)
            urlAlert.addAction(cancelAction)
            self?.present(urlAlert, animated: true)
        }

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(cameraAction)
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(libraryAction)
        }

        alert.addAction(urlAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    func setImage(_ image: UIImage, withName name: String? = nil) {
        images.append(image)
     
        let fileName = name ?? UUID().uuidString
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileURL = URL(fileURLWithPath: fileName, relativeTo: directoryURL).appendingPathExtension("jpg")
        guard let data = image.jpegData(compressionQuality: 100) else { return }
        try? data.write(to: fileURL)
        UserDefaults.standard.set(fileName, forKey: "\(images.count)imageName")
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        UserDefaults.standard.set(images.count, forKey: "images.count")
    }
 
    @objc private func changeCountInRow(recognizer : UIPinchGestureRecognizer) {
        if recognizer.state == .ended {
            switch recognizer.scale {
            case 0...1:
                if Int(imagesPerLine) < images.count {
                    imagesPerLine += 1
                }
            default:
                if imagesPerLine > 1 {
                    imagesPerLine -= 1
                }
            }
        }
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    private func loadImage() {

        let count = UserDefaults.standard.integer(forKey: "images.count")
        guard count > 0 else { return }

        for index in 1...count {
            guard let fileName = UserDefaults.standard.string(forKey: "\(index)imageName") else { continue }

            let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            let fileURL = URL(fileURLWithPath: fileName, relativeTo: directoryURL).appendingPathExtension("jpg")

            guard let savedData = try? Data(contentsOf: fileURL),
                  let image = UIImage(data: savedData) else { continue }
            images.append(image)
        }
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    private func showPicker(withSourceType sourceType: UIImagePickerController.SourceType) {
    let pickerController = UIImagePickerController()
    pickerController.delegate = self
    pickerController.allowsEditing = false
    pickerController.mediaTypes = ["public.image"]
    pickerController.sourceType = sourceType
    
    present(pickerController, animated: true)
    }
}
extension GalleryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                if let image = object as? UIImage {
                    self.setImage(image)
                } else if let data = object as? Data,
                let image = UIImage(data: data){
                    self.setImage(image)
                }
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        var name: String?
        if let imageName = info[.imageURL] as? URL {
            name = imageName.lastPathComponent
        }
        setImage(image, withName: name)
        self.presentedViewController?.dismiss(animated: true)
            }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.presentedViewController?.dismiss(animated: true)
        let errorNotification = NSLocalizedString("notificationErrorAlert", comment: "the user will see error notification file not selected")
        let messageError = NSLocalizedString("notificationAlertmessageError", comment: "the user will see error notification")
        let alert = UIAlertController(title: errorNotification, message: messageError, preferredStyle: .alert)
        let messageErrorBack = NSLocalizedString("closeErrorMessage", comment: "the user will see back button message error")
        let okAction = UIAlertAction(title: messageErrorBack, style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}

extension GalleryViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        
        guard let destinationViewController = storyboard.instantiateViewController(withIdentifier: "SchowPhotoViewController") as? SchowPhotoViewController else { return }
        
        destinationViewController.image = images[indexPath.row]
        destinationViewController.modalPresentationStyle = .fullScreen
        present(destinationViewController, animated: true)
    }
}

extension GalleryViewController : UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let index = indexPath.row
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:ImageCell.identifier, for: indexPath) as? ImageCell else { return UICollectionViewCell()}

        cell.configure(withImage: images[index])

        return cell
    }
}

extension GalleryViewController : UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout : UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalHorizontalSpacing = (imagesPerLine - 1) * imageSpacing
        let width = (collectionView.bounds.width - totalHorizontalSpacing) / imagesPerLine
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return imageSpacing
    }

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return imageSpacing
        }

}
