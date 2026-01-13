//
//  PlayingViewController.swift
//  VideoVision
//
//  Created by KimRin on 1/13/26.
//

import AVFoundation
import UIKit


class PlayingViewController: UIViewController {
	private var playerLayer: AVPlayerLayer?
	private let videoContainerView = UIView()
	
	private let playButton = UIButton()
	private let timeSlider = UISlider()
	private let timeLabel = UILabel()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.bindViewModel()
		
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		if let layer = self.playerLayer {
			layer.frame = self.videoContainerView.bounds
		}
		
	}
	
	func bindViewModel() {
		//		// VM의 데이터를 UI에 꽂아넣기 (Binding)
		//
		//		// 1. 슬라이더 업데이트
		//		self.viewModel.$sliderValue
		//			.receive(on: DispatchQueue.main)
		//			.assign(to: \.value, on: timeSlider)
		//			.store(in: &cancellables)
		//
		//		// 2. 버튼 글자 업데이트
		//		self.viewModel.$buttonTitle
		//			.receive(on: DispatchQueue.main)
		//			.sink { [weak self] title in
		//				self?.playButton.setTitle(title, for: .normal)
		//			}
		//			.store(in: &cancellables)
	}
	
	
}

extension PlayingViewController {
	func setupUI() {
		
		//self.playerLayer = self.viewModel.getVideoLayer()
		self.playerLayer?.videoGravity = .resizeAspectFill
		if let layer = self.playerLayer {
			self.videoContainerView.layer.addSublayer(layer)
		}
		
		let uiElements = [
			self.videoContainerView,
			self.playButton,
			self.timeSlider,
			self.timeLabel
		]
		
		uiElements.forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			self.view.addSubview($0)
		}
		
		self.videoContainerView.backgroundColor = .black
		
		
		self.playButton.backgroundColor = .systemBlue
		self.playButton.setTitle("재생", for: .normal)
		//self.playButton.addTarget(self, action: #selector(self.tapPlayButton), for: .touchUpInside)
		
		self.timeLabel.textAlignment = .center
		self.timeLabel.text = "0초 / 0초"
		
		NSLayoutConstraint.activate([
			
			self.videoContainerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
			self.videoContainerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.videoContainerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.videoContainerView.heightAnchor.constraint(equalToConstant: 300),
			
			
			self.timeSlider.topAnchor.constraint(equalTo: self.videoContainerView.bottomAnchor, constant: 20),
			self.timeSlider.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
			self.timeSlider.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
			
			self.timeLabel.topAnchor.constraint(equalTo: self.timeSlider.bottomAnchor, constant: 10),
			self.timeLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
			
			self.playButton.topAnchor.constraint(equalTo: self.timeLabel.bottomAnchor, constant: 10),
			self.playButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
			self.playButton.widthAnchor.constraint(equalToConstant: 100),
			
			
		])
	}
}
