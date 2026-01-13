//
//  FirstScreenVM.swift
//  VideoVision
//
//  Created by KimRin on 1/7/26.
//

import AVFoundation
import Combine
import Foundation

final class FilmingViewModel {
	let cameraManager: CameraManager
	
	
	// VC가 구독할 데이터 (Output)
//	@Published var sliderValue: Float = 0.0
//	@Published var timeString: String = "00:00"
//	@Published var buttonTitle: String = "재생"
	
	var captureSession: AVCaptureSession {
		return self.cameraManager.session
	}
	
	private var cancellables = Set<AnyCancellable>()
	
	init(
		cameraManager: CameraManager,
		videoPlayerManager: VideoPlayerManager
	) {
		self.cameraManager = cameraManager
		
//		self.bindManagers()
	}
	
	// TODO: - 테스트용
	func viewDidLoad() {
//		// 테스트용 URL (나중에는 외부에서 주입받을 수도 있음)
//		guard let url = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4") else { return }
//		

//		self.videoManager.loadVideo(url: url)
//		
//		self.videoManager.play()
	}
	
	
	// Manager의 데이터를 UI용 데이터로 변환 (Transform)
//	private func bindManagers() {
//		// 시간 데이터 -> 슬라이더 값 & 텍스트로 변환
//		self.videoManager.$currentTime
//			.combineLatest(self.videoManager.$duration)
//			.sink { [weak self] (current, duration) in
//				guard duration > 0 else { return }
//				self?.sliderValue = Float(current / duration)
//				self?.timeString = String(format: "%.0f / %.0f", current, duration)
//			}
//			.store(in: &cancellables)
//		
//		// 재생 상태 -> 버튼 글자 변환
//		self.videoManager.$isPlaying
//			.map { $0 ? "일시정지" : "재생" }
//			.assign(to: &$buttonTitle)
//	}
	
	// VC에서 들어오는 입력 (Input)
//	func didTapPlayButton() {
//		if self.videoManager.isPlaying {
//			self.videoManager.pause()
//		} else {
//			self.videoManager.play()
//		}
//	}
	
//	func getVideoLayer() -> AVPlayerLayer {
//		return self.videoManager.getPlayerLayer()
//	}
	
}

extension FilmingViewModel {
	func startCamera() {
		self.cameraManager.startSession()
	}
	
	func didTapSwitchCameraButton() {
		self.cameraManager.switchCamera()
	}
	
	func capturePhoto() {
		
	}
}
