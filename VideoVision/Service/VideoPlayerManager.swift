//
//  VideoPlayerManager.swift
//  VideoVision
//
//  Created by KimRin on 1/7/26.
//

import AVFoundation
import Combine

class VideoPlayerManager {
	// TODO: -  어째서 구독 가능한 상태로 만들었는지에대한 합당성 actor로 관리하면 안되?
	@Published var isPlaying: Bool = false
	@Published var currentTime: Double = 0.0
	@Published var duration: Double = 0.0
	
	private var player = AVPlayer()
	private var timeObserver: Any?
	
	func getPlayerLayer() -> AVPlayerLayer {
		let layer = AVPlayerLayer(player: self.player)
		layer.videoGravity = .resizeAspectFill
		return layer
	}
	
	func loadVideo(url: URL) {
		let item = AVPlayerItem(url: url)
		self.player.replaceCurrentItem(with: item)
		
		// 시간 감시자 부착 (내부 로직 캡슐화)
		let interval = CMTime(value: 1, timescale: 10)
		self.timeObserver = self.player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
			self?.currentTime = time.seconds
		}
		
		// 총 길이 체크 (KVO or Async load)
		// ... (duration 세팅 로직)
	}
	
	func play() {
		self.player.play()
		self.isPlaying = true
	}
	
	func pause() {
		self.player.pause()
		self.isPlaying = false
	}
	
	func seek(to seconds: Double) {
		let time = CMTime(seconds: seconds, preferredTimescale: 600)
		self.player.seek(to: time)
	}
}
