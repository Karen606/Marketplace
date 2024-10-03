//
//  ProductFormViewController.swift
//  Marketplace
//
//  Created by Karen Khachatryan on 02.10.24.
//

import UIKit
import Combine
import PhotosUI

class ProductFormViewController: UIViewController {
    @IBOutlet weak var nameTextField: BaseTextField!
    @IBOutlet weak var quantityTextField: BaseTextField!
    @IBOutlet weak var priceTextField: PricesTextField!
    @IBOutlet weak var marketplacesTableView: UITableView!
    @IBOutlet weak var tableViewHeightConst: NSLayoutConstraint!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: BaseButton!
    @IBOutlet weak var selectMarketplaceLabel: UILabel!
    @IBOutlet weak var warehouseQuantityLabel: UILabel!
    private let viewModel = ProductFormViewModel.shared
    private var cancellables: Set<AnyCancellable> = []
    @IBOutlet weak var photoButton: UIButton!
    var completion: (() -> ())?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        subscribe()
    }
    
    func setupUI() {
        marketplacesTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        setNavigationBackButton()
        setNavigationMenuButton()
        nameTextField.delegate = self
        quantityTextField.delegate = self
        priceTextField.baseDelegate = self
        marketplacesTableView.register(UINib(nibName: "ProductFormTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductFormTableViewCell")
        marketplacesTableView.delegate = self
        marketplacesTableView.dataSource = self
        selectMarketplaceLabel.font = .lightItalic(size: 14)
        warehouseQuantityLabel.font = .lightItalic(size: 14)
        photoButton.layer.cornerRadius = 5
        photoButton.layer.borderWidth = 1
        photoButton.layer.borderColor = #colorLiteral(red: 0.3664839864, green: 0.3629186153, blue: 0.3831521273, alpha: 1).cgColor
        photoButton.layer.masksToBounds = true
        cancelButton.layer.cornerRadius = 20
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.buttonBlue.cgColor
        cancelButton.layer.masksToBounds = true
        cancelButton.titleLabel?.font = .semibold(size: 16)
        saveButton.titleLabel?.font = .semibold(size: 16)
    }
    
    private func updateTableViewHeight(newSize: CGSize) {
        tableViewHeightConst.constant = newSize.height
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            if let newSize = change?[.newKey] as? CGSize {
                updateTableViewHeight(newSize: newSize)
            }
        }
    }
    
    func subscribe() {
        viewModel.$selectedMarketplaces
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedMarketplaces in
                guard let self = self else { return }
                if selectedMarketplaces.count != self.viewModel.previousSelectedMarketplacesCount {
                    self.marketplacesTableView.reloadData()
                    self.viewModel.previousSelectedMarketplacesCount = selectedMarketplaces.count
                }
                self.validate()
            }
            .store(in: &cancellables)
        
        viewModel.$product
            .receive(on: DispatchQueue.main)
            .sink { [weak self] product in
                guard let self = self else { return }
                self.validate()
            }
            .store(in: &cancellables)
        
        viewModel.$isEditing
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEditing in
                guard let self = self else { return }
                if isEditing {
                    self.nameTextField.text = viewModel.product.name
                    self.priceTextField.text = "\(viewModel.product.price ?? 0)$"
                    self.quantityTextField.text = "\(viewModel.product.quantity ?? 0)"
                    if let data = viewModel.product.photo {
                        self.photoButton.setImage(UIImage(data: data), for: .normal)
                    }
                    self.marketplacesTableView.reloadData()
                }
                self.validate()
            }
            .store(in: &cancellables)
    }
    
    func validate() {
        let validProduct = (viewModel.product.name?.isValid ?? false) && viewModel.product.id != nil && viewModel.product.photo != nil && viewModel.product.price != nil && priceTextField.isValidPrice() && viewModel.product.quantity != nil
        let validMarketplace = viewModel.selectedMarketplaces.contains { model in
            return (model.id == nil || !(model.name?.isValid ?? false) || model.product?.remainder == nil)
        }
        self.saveButton.isEnabled = (validProduct && !validMarketplace)
    }
    
    @objc func clickedAddProductToMarketplace() {
        viewModel.addMarketplace()
    }
    @IBAction func handleTapGesture(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func chooseProductPhoto(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: "Select Image", message: "Choose a source", preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                self.requestCameraAccess()
            }))
        }
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
            self.requestPhotoLibraryAccess()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func clickedCancel(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickedSave(_ sender: UIButton) {
        viewModel.saveProduct { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.showErrorAlert(message: error.localizedDescription)
            } else {
                completion?()
//                ProductsViewModel.shared.fecthMarketplaces()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    deinit {
        viewModel.clear()
    }
}

extension ProductFormViewController: UITextFieldDelegate {
    
}

extension ProductFormViewController: PriceTextFielddDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let value = textField.text else { return }
        switch textField {
        case priceTextField:
            viewModel.product.price = priceTextField.formatNumber()
        case nameTextField:
            viewModel.product.name = value
        case quantityTextField:
            viewModel.product.quantity = Int(value)
        default:
            break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == priceTextField, let value = textField.text, !value.isEmpty {
            priceTextField.text! += "$"
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == priceTextField, let value = textField.text, !value.isEmpty && value.last == "$" {
            priceTextField.text?.removeLast()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == priceTextField {
            return priceTextField.textField(textField, shouldChangeCharactersIn: range, replacementString: string)
        } else {
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
}

extension ProductFormViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.selectedMarketplaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductFormTableViewCell", for: indexPath) as! ProductFormTableViewCell
        cell.setupData(marketplaceInfo: viewModel.selectedMarketplaces[indexPath.row], index: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 60))
        let button = UIButton(type: .custom)
        button.imageView?.contentMode = .center
        button.setImage(UIImage(named: "Add"), for: .normal)
        button.setTitleColor(.baseBlue, for: .normal)
        button.addTarget(self, action: #selector(clickedAddProductToMarketplace), for: .touchUpInside)
        button.frame = CGRect(x: (footerView.frame.width/4) - 33, y: (footerView.frame.height - 30) / 2, width: 80, height: 30)
        footerView.addSubview(button)
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60
    }
    
}

extension ProductFormViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func requestCameraAccess() {
            let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
            switch cameraStatus {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        self.openCamera()
                    }
                }
            case .authorized:
                openCamera()
            case .denied, .restricted:
                showSettingsAlert()
            @unknown default:
                break
            }
        }
        
        private func requestPhotoLibraryAccess() {
            let photoStatus = PHPhotoLibrary.authorizationStatus()
            switch photoStatus {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { status in
                    if status == .authorized {
                        self.openPhotoLibrary()
                    }
                }
            case .authorized:
                openPhotoLibrary()
            case .denied, .restricted:
                showSettingsAlert()
            case .limited:
                break
            @unknown default:
                break
            }
        }
        
        private func openCamera() {
            DispatchQueue.main.async {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.sourceType = .camera
                    imagePicker.allowsEditing = true
                    self.present(imagePicker, animated: true, completion: nil)
                }
            }
        }
        
        private func openPhotoLibrary() {
            DispatchQueue.main.async {
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.sourceType = .photoLibrary
                    imagePicker.allowsEditing = true
                    self.present(imagePicker, animated: true, completion: nil)
                }
            }
        }
        
        private func showSettingsAlert() {
            let alert = UIAlertController(title: "Access Needed", message: "Please allow access in Settings", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                }
            }))
            present(alert, animated: true, completion: nil)
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                photoButton.setImage(editedImage, for: .normal)
            } else if let originalImage = info[.originalImage] as? UIImage {
                photoButton.setImage(originalImage, for: .normal)
            }
            if let imageData = photoButton.imageView?.image?.jpegData(compressionQuality: 1.0) {
                let data = imageData as Data
                viewModel.product.photo = data
            }
            picker.dismiss(animated: true, completion: nil)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
}
