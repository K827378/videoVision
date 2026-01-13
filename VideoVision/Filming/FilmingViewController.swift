//
//  FirstScreenVC.swift
//  VideoVision
//
//  Created by KimRin on 1/6/26.
//

import AVFoundation
import Combine
import UIKit


class FilmingViewController: UIViewController {
	// MARK: - Properties
	
	private var viewModel: FilmingViewModel!
	private var cancellables = Set<AnyCancellable>()
	

	private var cameraLayer: AVCaptureVideoPreviewLayer?
	

	private let cameraContainerView = UIView()
	

	private let switchCameraButton = UIButton()
	
	class func create(with viewModel: FilmingViewModel) -> FilmingViewController {
		let vc = FilmingViewController()
		vc.viewModel = viewModel
		return vc
	}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		
		self.setupUI()

		
		self.viewModel.viewDidLoad()
		self.viewModel.startCamera()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		
		if let cLayer = self.cameraLayer {
			cLayer.frame = self.cameraContainerView.bounds
		}
	}
	

	
	
	@objc func tapSwitchCamera() {
	
		let generator = UIImpactFeedbackGenerator(style: .medium)
		generator.impactOccurred()
		
		// VM에게 요청
		self.viewModel.didTapSwitchCameraButton()
	}
}

extension FilmingViewController {
	func setupUI() {
		self.view.backgroundColor = .white
		

		

		self.cameraLayer = self.viewModel.getCameraLayer()
		self.cameraLayer?.videoGravity = .resizeAspectFill
		if let layer = self.cameraLayer {
			self.cameraContainerView.layer.addSublayer(layer)
		}
		
		
		self.view.addSubview(self.cameraContainerView)
		self.cameraContainerView.translatesAutoresizingMaskIntoConstraints = false
		self.cameraContainerView.backgroundColor = .darkGray // 로딩 전 색상

//		
		let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold)
		let image = UIImage(systemName: "arrow.triangle.2.circlepath.camera", withConfiguration: config)
		self.switchCameraButton.setImage(image, for: .normal)
		self.switchCameraButton.tintColor = .white // 잘 보이게 흰색
		self.switchCameraButton.addTarget(self, action: #selector(self.tapSwitchCamera), for: .touchUpInside)
		
		
		self.view.addSubview(self.switchCameraButton)
		self.switchCameraButton.translatesAutoresizingMaskIntoConstraints = false
		

		NSLayoutConstraint.activate([

			self.cameraContainerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
			self.cameraContainerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.cameraContainerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.cameraContainerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
			
			self.switchCameraButton.topAnchor.constraint(equalTo: self.cameraContainerView.topAnchor, constant: 20),
			self.switchCameraButton.trailingAnchor.constraint(equalTo: self.cameraContainerView.trailingAnchor, constant: -20),
			self.switchCameraButton.widthAnchor.constraint(equalToConstant: 44),
			self.switchCameraButton.heightAnchor.constraint(equalToConstant: 44)
		])
	}
	
}
