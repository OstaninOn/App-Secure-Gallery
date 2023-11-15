//
//  ViewController.swift
//  SecuraGallery
//
//  Created by  aleksandr on 1.11.22.

import UIKit
import LocalAuthentication

class ViewController: UIViewController {
    
    @IBOutlet weak var penPin: UIButton!
    
    @IBOutlet weak var showPinButton: UIButton!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var glleryLabel: UILabel!
    
    @IBOutlet weak var pinField: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let password = NSLocalizedString("enterPassword", comment: "the user will see password entry field")
        pinField.placeholder = password
        pinField.layer.shadowOffset = CGSize(width: 5, height: 5)
        pinField.layer.shadowOpacity = 1
        pinField.layer.shadowRadius = 2
        
        glleryLabel.layer.shadowOffset = CGSize(width: 5, height: 5)
        glleryLabel.layer.shadowOpacity = 0.5
        glleryLabel.layer.shadowRadius = 0.8
        glleryLabel.layer.masksToBounds = false
        glleryLabel.layer.cornerRadius = 1
        
        showPinButton.setImage(UIImage(systemName: "eye"), for: .normal)
        showPinButton.setImage(UIImage(systemName: "eye.slash"), for: .selected)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(_ notification: Foundation.Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        
        let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size
        
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.height + scrollView.adjustedContentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: true)
    }

    @objc func keyboardWillHide(_ notification: Foundation.Notification) {
        scrollView.contentInset = .zero
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.height + scrollView.adjustedContentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: true)
        
    }
    
    @IBAction func webButton(_ sender: UIButton) {
        
        guard let url = URL(string: "http://www.google.com") else {
            return
        }
        let vc = WebViewViewController(url: url, title: "Google")
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .custom
        present(navVC, animated: true)
        
        
    }
    
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func penPinGallery(_ sender: Any) {
        
        view.endEditing(true)
        guard pinField.text == "1234" else { return }
        let gallery = GalleryViewController()
       
        let navigation = UINavigationController(rootViewController: gallery)
        navigation.modalPresentationStyle = .automatic
        
        present(navigation, animated: true)
        return
        
    }
   
    @IBAction func showPinn(_ sender: Any) {
        pinField.isSecureTextEntry.toggle()
        showPinButton.isSelected = !pinField.isSecureTextEntry
    }
    
    
    @IBAction func authButtonPressed() {
        
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error
        ) {
            let reason = "требуется идентификация!"
            
            context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            ) { success, error in
                DispatchQueue.main.async {
                    guard success, error == nil else {
                        self.statusLabel.text = "ошибка"
                        self.statusLabel.textColor = .red
                        self.showAlert(title: "ошибка", message: "попробуйте снова")
                        return
                    }
                    
                    self.statusLabel.text = "успешно:\n" + "успешно"
                    self.statusLabel.textColor = .green
                    self.view.endEditing(true)
                    let gallery = GalleryViewController()
                    let navigation = UINavigationController(rootViewController: gallery)
                    navigation.modalPresentationStyle = .fullScreen
                    self.present(navigation, animated: false)
                    
                }
                
            }
            
        } else {
            if let error {
                            showAlert(title: "нет доступа", message: "\(error.localizedDescription)")
                        }
        }
    }
}
extension ViewController {
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "отмена", style: .cancel)
        alert.addAction(dismissAction)
        present(alert, animated: true)
    }
    
}

