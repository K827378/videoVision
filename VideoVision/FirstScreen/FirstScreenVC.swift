//
//  FirstScreenVC.swift
//  VideoVision
//
//  Created by KimRin on 1/6/26.
//

import AVFoundation
import Combine
import UIKit


class FirstScreenVC: UIViewController {
	// MARK: - Properties
	
	private var viewModel: FirstScreenVM!
	private var cancellables = Set<AnyCancellable>()
	
	private var playerLayer: AVPlayerLayer?
	private var cameraLayer: AVCaptureVideoPreviewLayer?
	
	private let videoContainerView = UIView()
	private let cameraContainerView = UIView()
	
	private let playButton = UIButton()
	private let timeSlider = UISlider()
	private let timeLabel = UILabel()
	private let switchCameraButton = UIButton()
	
	class func create(with viewModel: FirstScreenVM) -> FirstScreenVC {
		let vc = FirstScreenVC()
		vc.viewModel = viewModel
		return vc
	}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		
		self.setupUI()       // UI 배치
		self.bindViewModel()
		
		self.viewModel.viewDidLoad()
		self.viewModel.startCamera()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		if let layer = self.playerLayer {
			layer.frame = self.videoContainerView.bounds
		}
		
		if let cLayer = self.cameraLayer {
			cLayer.frame = self.cameraContainerView.bounds
		}
	}
	
	func bindViewModel() {
		// VM의 데이터를 UI에 꽂아넣기 (Binding)
		
		// 1. 슬라이더 업데이트
		self.viewModel.$sliderValue
			.receive(on: DispatchQueue.main)
			.assign(to: \.value, on: timeSlider)
			.store(in: &cancellables)
		
		// 2. 버튼 글자 업데이트
		self.viewModel.$buttonTitle
			.receive(on: DispatchQueue.main)
			.sink { [weak self] title in
				self?.playButton.setTitle(title, for: .normal)
			}
			.store(in: &cancellables)
	}
	
	@objc func tapPlayButton() {
		// 로직은 VM에게 위임
		self.viewModel.didTapPlayButton()
	}
	
	@objc func tapSwitchCamera() {
		// 버튼 눌렀을 때 햅틱(진동) 피드백 주면 더 리얼합니다.
		let generator = UIImpactFeedbackGenerator(style: .medium)
		generator.impactOccurred()
		
		// VM에게 요청
		self.viewModel.didTapSwitchCameraButton()
	}
}

extension FirstScreenVC {
	func setupUI() {
		self.view.backgroundColor = .white
		
		// 1. 비디오 레이어 가져오기
		self.playerLayer = self.viewModel.getVideoLayer()
		self.playerLayer?.videoGravity = .resizeAspectFill
		if let layer = self.playerLayer {
			self.videoContainerView.layer.addSublayer(layer)
		}
		
		// 2. [추가] 카메라 레이어 가져오기
		self.cameraLayer = self.viewModel.getCameraLayer()
		self.cameraLayer?.videoGravity = .resizeAspectFill
		if let layer = self.cameraLayer {
			self.cameraContainerView.layer.addSublayer(layer)
		}
		
		// 3. UI 추가
		let uiElements = [
			self.videoContainerView,
			self.cameraContainerView, // [추가]
			self.playButton,
			self.timeSlider,
			self.timeLabel
		]
		
		uiElements.forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			self.view.addSubview($0)
		}
		
		// 4. 속성 설정
		self.videoContainerView.backgroundColor = .black
		self.cameraContainerView.backgroundColor = .darkGray // 로딩 전 색상
		
		self.playButton.backgroundColor = .systemBlue
		self.playButton.setTitle("재생", for: .normal)
		self.playButton.addTarget(self, action: #selector(self.tapPlayButton), for: .touchUpInside)
		
		self.timeLabel.textAlignment = .center
		self.timeLabel.text = "0초 / 0초"
		
		let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold)
		let image = UIImage(systemName: "arrow.triangle.2.circlepath.camera", withConfiguration: config)
		self.switchCameraButton.setImage(image, for: .normal)
		self.switchCameraButton.tintColor = .white // 잘 보이게 흰색
		self.switchCameraButton.addTarget(self, action: #selector(self.tapSwitchCamera), for: .touchUpInside)
		
		self.view.addSubview(self.switchCameraButton)
		self.switchCameraButton.translatesAutoresizingMaskIntoConstraints = false
		
		// 5. 레이아웃 (Nintendo DS 스타일)
		NSLayoutConstraint.activate([
			// 상단: 비디오 (높이 300 고정)
			self.videoContainerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
			self.videoContainerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.videoContainerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.videoContainerView.heightAnchor.constraint(equalToConstant: 300),
			
			// 중단: 컨트롤러
			self.timeSlider.topAnchor.constraint(equalTo: self.videoContainerView.bottomAnchor, constant: 20),
			self.timeSlider.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
			self.timeSlider.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
			
			self.timeLabel.topAnchor.constraint(equalTo: self.timeSlider.bottomAnchor, constant: 10),
			self.timeLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
			
			self.playButton.topAnchor.constraint(equalTo: self.timeLabel.bottomAnchor, constant: 10),
			self.playButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
			self.playButton.widthAnchor.constraint(equalToConstant: 100),
			
			// 하단: 카메라 (나머지 꽉 채우기) 🔥
			self.cameraContainerView.topAnchor.constraint(equalTo: self.playButton.bottomAnchor, constant: 20),
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
