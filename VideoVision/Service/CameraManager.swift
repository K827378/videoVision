//
//  CameraManager.swift
//  VideoVision
//
//  Created by KimRin on 1/7/26.
//


import AVFoundation

class CameraManager: NSObject {
	private let captureSession = AVCaptureSession()
	// 외부(ViewModel -> VC)에서 접근할 수 있는 용도
	var session: AVCaptureSession {
		return self.captureSession
	}
	
	// 데이터를 밖으로
	private let videoOutput = AVCaptureVideoDataOutput()
	// 영상 데이터 처리를 담당
	// "com.video.output"은 그냥 이름표
	private let videoOutputQueue = DispatchQueue(label: "com.video.output")
	
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
		// TODO: -  설정 관련한 객체 정도는 읽어볼것
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
				print("mic connected")
			}
		} else {
			print("no mic?)")
		}
		
		self.captureSession.commitConfiguration()
		
	}
	
	func switchCamera() {
		// 세션 변경 시작
		self.captureSession.beginConfiguration()
		
		// 1. 현재 비디오 입력 찾기
		guard let currentInput = self.captureSession.inputs.first(where: { ($0 as? AVCaptureDeviceInput)?.device.hasMediaType(.video) ?? false }) as? AVCaptureDeviceInput else {
			self.captureSession.commitConfiguration()
			return
		}
		
		// 2. 반대 방향 찾기
		let newPosition: AVCaptureDevice.Position = (currentInput.device.position == .front) ? .back : .front
		
		guard let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition),
			  let newInput = try? AVCaptureDeviceInput(device: newDevice) else {
			self.captureSession.commitConfiguration()
			return
		}
		
		// 3. 갈아끼우기
		self.captureSession.removeInput(currentInput)
		if self.captureSession.canAddInput(newInput) {
			self.captureSession.addInput(newInput)
		} else {
			self.captureSession.addInput(currentInput) // 실패 시 복구
		}
		
		self.captureSession.commitConfiguration()
	}
}
