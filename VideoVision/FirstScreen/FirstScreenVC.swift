//
//  FirstScreenVC.swift
//  VideoVision
//
//  Created by KimRin on 1/6/26.
//

import AVFoundation
import UIKit


class FirstScreenVC: UIViewController {
	// MARK: - Properties
	private var player: AVPlayer?
	private var playerLayer: AVPlayerLayer?
	
	private let videoContainerView = UIView()
	private let playButton = UIButton()
	private let timeSlider = UISlider()
	private let timeLabel = UILabel()
	
	// ⚠️ 메모리 관리를 위해 Observer 토큰을 저장하는 변수
	private var timeObserver: Any?
	
	private var previewLayer: AVCaptureVideoPreviewLayer?
	private let captureSession = AVCaptureSession()
	
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.backgroundColor = .white
		//self.setupCamera()
		self.setupPlayer()
		self.setupUI()       // UI 배치
		
	}
	
	// 레이아웃이 확정된 시점에 레이어 크기 업데이트
	override func viewDidLayoutSubviews() {
			super.viewDidLayoutSubviews()
			
			// 컨테이너 뷰의 크기에 딱 맞게 레이어 크기 조절
			if let playerLayer = self.playerLayer {
				playerLayer.frame = self.videoContainerView.bounds
			}
		}
	
	deinit {
			if let token = self.timeObserver {
				self.player?.removeTimeObserver(token)
				self.timeObserver = nil
			}
			print("FirstScreenVC 메모리 해제 완료")
		}
	
}

// MARK: - Playing
// URL을 받아서 AVPlayer에 넣고 AVPlayer를 AVPlayerLayer에 넣어 비율과 사이즈 조정후 view위 얹은후 AVPlayer재생하면 영상 재생이된다.

extension FirstScreenVC {
	// Player의 설정
	func setupPlayer() {
			guard let url = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4") else { return }
			
			// 1. 플레이어(엔진) 생성
			self.player = AVPlayer(url: url)
			
			// 2. 레이어(스크린) 생성 및 연결
			self.playerLayer = AVPlayerLayer(player: self.player)
			self.playerLayer?.videoGravity = .resizeAspectFill
			
			// ⚠️ 여기서 frame을 잡아도 되지만, 안전하게 viewDidLayoutSubviews에서 잡는 게 정석임.
			// 일단 계층 구조에 추가
			self.videoContainerView.layer.addSublayer(self.playerLayer!)
			
			// 3. 재생 시작
			self.player?.play()
			self.playButton.setTitle("일시정지", for: .normal)
			
			// 4. 감시자 부착
			self.addTimeObserver()
			self.addLoopObserver()
		}
	
	func addTimeObserver() {
			// 1초 단위로 보고 (반응성을 높이려면 value: 1, timescale: 10 등으로 0.1초 단위 권장)
			let interval = CMTime(value: 1, timescale: 1)
			
			self.timeObserver = self.player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
				// 여기서는 closure 내부라 self가 optional이므로 unwrapping 필요
				guard let self = self, let duration = self.player?.currentItem?.duration else { return }
				
				let currentSeconds = time.seconds
				let totalSeconds = duration.seconds
				
				// NaN(Not a Number) 방지: 총 시간이 0이거나 무한대면 계산 안 함
				guard totalSeconds.isFinite && totalSeconds > 0 else { return }
				
				self.timeSlider.value = Float(currentSeconds / totalSeconds)
				self.timeLabel.text = String(format: "%.0f초 / %.0f초", currentSeconds, totalSeconds)
			}
		}
	
	func addLoopObserver() {
			NotificationCenter.default.addObserver(self,
												   selector: #selector(self.videoDidEnd),
												   name: .AVPlayerItemDidPlayToEndTime,
												   object: self.player?.currentItem)
		}
		
		@objc func videoDidEnd() {
			print("🔄 영상 끝! 다시 처음부터!")
			self.player?.seek(to: .zero)
			self.player?.play()
		}
		
		// User Action
		@objc func tapPlayButton() {
			if self.player?.rate == 0 {
				self.player?.play()
				self.playButton.setTitle("일시정지", for: .normal)
			} else {
				self.player?.pause()
				self.playButton.setTitle("재생", for: .normal)
			}
		}
		
		@objc func sliderChanged() {
			guard let duration = self.player?.currentItem?.duration else { return }
			let totalSeconds = duration.seconds
			let targetTime = Double(self.timeSlider.value) * totalSeconds
			
			// 끊김 없이 부드럽게 탐색하려면 preferredTimescale을 높게 설정
			let time = CMTime(seconds: targetTime, preferredTimescale: 600)
			self.player?.seek(to: time)
		}
	
	// 길이조회
	func checkDuration() {
		guard let duration = player?.currentItem?.duration else { return }
		
		if duration.isIndefinite {
			print("이 영상은 끝이 없는 라이브입니다.")
		} else {
			let totalSeconds = duration.seconds
			print("이 영상은 총 \(totalSeconds)초 짜리입니다.")
		}
	}

}

// MARK: - Filming
extension FirstScreenVC {
	func setupCamera() {
		guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
		
		do {
			
			let input = try AVCaptureDeviceInput(device: captureDevice)
			if captureSession.canAddInput(input) {
				captureSession.addInput(input)
			}
			
			previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
			previewLayer?.videoGravity = .resizeAspectFill
			previewLayer?.frame = view.frame
			if let previewLayer = previewLayer {
				view.layer.addSublayer(previewLayer)
			}
			
			// (5) 세션 시작 (백그라운드 스레드에서 실행 권장)
			DispatchQueue.global(qos: .background).async {
				self.captureSession.startRunning()
			}
		} catch {
			print("카메라 설정 에러")
		}
	}
}

extension FirstScreenVC {
	func setupUI() {
			self.view.backgroundColor = .white
			
			let uiElements = [self.videoContainerView, self.playButton, self.timeSlider, self.timeLabel]
			uiElements.forEach {
				$0.translatesAutoresizingMaskIntoConstraints = false
				self.view.addSubview($0)
			}
			
			self.videoContainerView.backgroundColor = .black
			
			self.playButton.backgroundColor = .systemBlue
			self.playButton.setTitle("재생", for: .normal)
			self.playButton.addTarget(self, action: #selector(self.tapPlayButton), for: .touchUpInside)
			
			self.timeSlider.addTarget(self, action: #selector(self.sliderChanged), for: .valueChanged)
			
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
				
				self.playButton.topAnchor.constraint(equalTo: self.timeLabel.bottomAnchor, constant: 20),
				self.playButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
				self.playButton.widthAnchor.constraint(equalToConstant: 100)
			])
		}
}
