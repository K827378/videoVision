//
//  FilmingViewController.swift
//  VideoVision
//
//  Created by KimRin on 1/6/26.
//

import AVFoundation
import Combine
import UIKit

import SnapKit


class FilmingViewController: UIViewController {
	// MARK: - Properties
	private lazy var cameraLayer: AVCaptureVideoPreviewLayer = {
		let layer = AVCaptureVideoPreviewLayer()
		layer.videoGravity = .resizeAspectFill
		return layer
	}()
	private let cameraContainerView = UIView()
	
	private lazy var switchCameraButton: UIButton = {
		let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold)
		let image = UIImage(systemName: "arrow.triangle.2.circlepath.camera", withConfiguration: config)
		let button = UIButton()
		button.setImage(image, for: .normal)
		button.tintColor = .white
		button.addTarget(self, action: #selector(self.tapSwitchCamera), for: .touchUpInside)
		return button
	}()
	
	private var viewModel: FilmingViewModel!
	private var cancellables = Set<AnyCancellable>()
	
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
		self.cameraLayer.frame = self.cameraContainerView.bounds

	}
	
	@objc func tapSwitchCamera() {
		let generator = UIImpactFeedbackGenerator(style: .medium)
		generator.impactOccurred()
		self.viewModel.didTapSwitchCameraButton()
	}
}

extension FilmingViewController {
	func setupUI() {
		self.view.addSubview(self.cameraContainerView)
		self.view.addSubview(self.switchCameraButton)
		
		self.cameraContainerView.layer.addSublayer(self.cameraLayer)
		self.cameraLayer.session = self.viewModel.captureSession
		
		self.cameraContainerView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		self.switchCameraButton.snp.makeConstraints { make in
			make.top.equalTo(self.view.safeAreaLayoutGuide).offset(20)
			make.right.equalToSuperview().offset(-20)
			make.height.width.equalTo(44)
		}
		
	}
	
}
