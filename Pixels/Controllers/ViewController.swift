//
//  ViewController.swift
//  Pixels
//
//  Created by ARCHER on 27/05/2023.
//

import UIKit
import AVFoundation
import Combine
class ViewController: UIViewController {
    
    
    // MARK: - Properties
    private var viewModel = ImagesViewModel()
    private var isLoading = false
    private var cancelabes = [AnyCancellable]()
    private var captureSession: AVCaptureSession!
    private var stillImageOutput: AVCapturePhotoOutput!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private let captureButton : UIButton = {
        let button  = UIButton(frame: .zero)
        button.setImage(UIImage(named: "shutter"), for: .normal)
        button.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout:ImagesCollectionLayout())
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        return collectionView
        
    }()
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupCamera()
        setupPreviewLayer()
        setupCaptureButton()
        fetchPhotos()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubview(captureButton)
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -20),
            captureButton.heightAnchor.constraint(equalToConstant: 80),
            captureButton.widthAnchor.constraint(equalToConstant: 80),
            
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 10),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -100),
            collectionView.heightAnchor.constraint(equalToConstant: view.frame.height/4),
            collectionView.widthAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startCaptureSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopCaptureSession()
    }
    
    // MARK: - Setup Methods
    private func setupPermisions(){}
    private func setupCollectionView(){
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        DispatchQueue(label: "cameraSetupQueue").async { [weak self] in
            guard let self = self,
                  let backCamera = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: backCamera) else {
                print("Unable to access camera")
                return
            }
            
            self.stillImageOutput = AVCapturePhotoOutput()
            
            if self.captureSession.canAddInput(input) && self.captureSession.canAddOutput(self.stillImageOutput) {
                self.captureSession.addInput(input)
                self.captureSession.addOutput(self.stillImageOutput)
            }
        }
    }
    
    private func setupPreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection?.videoOrientation = .portrait
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
        
    }
    
    private func setupCaptureButton() {
        captureButton.addTarget(self, action: #selector(captureButtonPressed), for: .touchUpInside)
        
    }
    private func fetchPhotos() {
        isLoading = true

        viewModel.fetchPhotos { [weak self] images, hasMoreImages in
            // Handle the fetched images and update the UI accordingly
            DispatchQueue.main.async {
                // Update UI with the fetched images
                // Example: reload collection view data
                self?.collectionView.reloadData()

                self?.isLoading = false

                if hasMoreImages {
                    self?.fetchPhotos()
                }
            }
        }
    }

    private func resetPaginationAndReload() {
        viewModel.resetPagination() // Reset the pagination count
        collectionView.reloadData() // Reload the collection view from start
        fetchPhotos() // Fetch new images
    }
    
    // MARK: - Capture Methods
    
    private func startCaptureSession() {
        DispatchQueue(label: "captureSessionQueue").async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    private func stopCaptureSession() {
        DispatchQueue(label: "captureSessionQueue").async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }
    
    @objc private func captureButtonPressed() {
        let settings = AVCapturePhotoSettings()
        
        if let photoOutputConnection = stillImageOutput.connection(with: .video) {
            photoOutputConnection.videoOrientation = .portrait
        }
        
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension ViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) else {
            print("Error capturing photo: \(error?.localizedDescription ?? "")")
            return
        }
        // Show the captured image briefly
        showImageAnimated(image:image)
        
        // Save or display the captured image
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
        
        }
    }
    func showImageAnimated(image:UIImage){
        let capturedImageView = UIImageView(image: image) // Replace "placeholder" with the actual image captured
        capturedImageView.contentMode = .scaleAspectFit
        capturedImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(capturedImageView)
        
        NSLayoutConstraint.activate([
            capturedImageView.topAnchor.constraint(equalTo: view.topAnchor),
            capturedImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 50),
            capturedImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -50),
            capturedImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIView.animate(withDuration: 0.5, animations: {
                capturedImageView.alpha = 0.0
                capturedImageView.transform = CGAffineTransform(translationX: -self.collectionView.bounds.width, y: 0)
            }) { (_) in
                capturedImageView.removeFromSuperview()
            }
        }
    }
}
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageViewController  = ImageViewController(fullSizeImage: viewModel.imageAt(indexPath: indexPath))
        navigationController?.pushViewController(imageViewController, animated: true)
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // Return the number of sections in your collection view (e.g., 1 if you have only one section)
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Return the total number of images you have to display
        return viewModel.totalImages()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        // Configure the cell with the corresponding image
        cell.imageView.image = viewModel.imageAt(indexPath: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Return the desired size for each item in the collection view
        let itemWidth = 30
        let itemHeight = 30
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        // Return the minimum line spacing between items
        return 10
    }
    
}
extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let visibleHeight = scrollView.bounds.height

        if offsetY > contentHeight - visibleHeight {
            fetchPhotos()
        }
    }
}
