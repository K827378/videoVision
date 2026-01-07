//
//  CameraManager.swift
//  VideoVision
//
//  Created by KimRin on 1/7/26.
//

import AVFoundation

class CameraManager {
	private let captureSession = AVCaptureSession()
	
	lazy var previewLayer: AVCaptureVideoPreviewLayer = {
		let layer = AVCaptureVideoPreviewLayer(session: self.captureSession)
		layer.videoGravity = .resizeAspectFill
		return layer
	}()
	
	func checkPermission() {
		// TODO: - 권한 alert
		
	}
	
	func startSession() {
		self.setupCamera()
		// 백그라운드에서 실행
		// TODO: - 세션 설정이 어째서 BG 에서 돌지?
		DispatchQueue.global(qos: .background).async {
			self.captureSession.startRunning()
		}
	}
	
	func stopSession() {
		self.captureSession.stopRunning()
	}
	
	private func setupCamera() {
		self.captureSession.beginConfiguration()
		
		self.captureSession.sessionPreset = .high
		
		if let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
		   let videoInput = try? AVCaptureDeviceInput(device: videoDevice) {
			if self.captureSession.canAddInput(videoInput) {
				self.captureSession.addInput(videoInput)
			}
		}
		
		if let audioDevice = AVCaptureDevice.default(for: .audio),
		   let audioInput = try? AVCaptureDeviceInput(device: audioDevice) {
			
			if self.captureSession.canAddInput(audioInput) {
				self.captureSession.addInput(audioInput)
				print("✅ 마이크 연결 성공")
			}
		} else {
			print("⚠️ 마이크를 찾을 수 없습니다. (시뮬레이터인가요?)")
		}
		
		self.captureSession.commitConfiguration()
		
		
		// ... (아까 작성한 input 연결 로직) ...
		// TODO: -  설정 관련한 객체 정도는 읽어볼것
		//		guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
		//			  let input = try? AVCaptureDeviceInput(device: device) else { return }
		//
		//		if self.captureSession.canAddInput(input) {
		//			self.captureSession.addInput(input)
		//		}
	}
}
