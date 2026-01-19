//
//  CameraManager.swift
//  VideoVision
//
//  Created by KimRin on 1/7/26.
// NSObject와 Delegate의 상관관계
//


import AVFoundation

class CameraManager: NSObject {
	private let captureSession = AVCaptureSession()
	
	private var simulationTimer: Timer?
	
	var session: AVCaptureSession {
		return self.captureSession
	}
	
	//비디오 아웃풋
	private let videoOutput = AVCaptureVideoDataOutput()
	// 비디오 큐
	private let videoOutputQueue = DispatchQueue(label: "com.video.output")
	
	// 앱 권한 확인
	func checkPermission() {
		switch AVCaptureDevice.authorizationStatus(for: .video) {
		case .authorized:
			self.startSession()
		case .notDetermined:
			AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
				if granted {
					self?.startSession()
				}
				
			}
		case .denied, .restricted:
			// TODO: -  설정유도 알림 ( 설정 알림창 딥링크 유도 )
			print("Permission denied")
		@unknown default:
			break
		}
		
	}
	
	func startSession() {
#if targetEnvironment(simulator)
		print("📱 Simulator Mode: Starting Mock Camera...")
		self.startSimulation()
#else
		// 실기기일 때 기존 로직
		self.setupCamera()
		DispatchQueue.global(qos: .background).async {
			if !self.captureSession.isRunning {
				self.captureSession.startRunning()
			}
		}
#endif
	}
	
	private func startSimulation() {
		// 0.033초 (약 30FPS)마다 타이머 실행
		self.simulationTimer = Timer.scheduledTimer(withTimeInterval: 0.033, repeats: true) { [weak self] _ in
			guard let self = self else { return }
			
			// 1. 가짜 데이터 생성
			guard let mockBuffer = MockDataGenerator.makeMockPixelBuffer() else { return }
			
			// 2. 중요!! 우리가 만든 'Serial Queue'로 작업을 보냄 (실제 카메라 동작 흉내)
			self.videoOutputQueue.async {
				// 3. 델리게이트 직접 호출 (CMSampleBuffer 대신 PixelBuffer를 바로 처리하도록 로직 수정 필요할 수 있음)
				// 편의상 여기서 바로 처리 로직을 호출하거나, Mock용 Delegate 메서드를 만듭니다.
				self.handleMockFrame(buffer: mockBuffer)
			}
		}
	}
	
	
	private func handleMockFrame(buffer: CVPixelBuffer) {
		// 여기에 아까 작성한 처리 로직(Lock -> Print -> Unlock)을 넣으세요.
		
		CVPixelBufferLockBaseAddress(buffer, .readOnly)
		let width = CVPixelBufferGetWidth(buffer)
		let height = CVPixelBufferGetHeight(buffer)
		print("🤖 Mock Frame: \(width)x\(height) | Thread: \(Thread.current)")
		CVPixelBufferUnlockBaseAddress(buffer, .readOnly)
	}
	
	func stopSession() {
		self.captureSession.stopRunning()
	}
	
	
	private func setupCamera() {
		
		self.captureSession.beginConfiguration()
		//화질
		self.captureSession.sessionPreset = .high
		//camera input setting
		if let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
		   let videoInput = try? AVCaptureDeviceInput(device: videoDevice) {
			if self.captureSession.canAddInput(videoInput) {
				self.captureSession.addInput(videoInput)
			}
		}
		
		// mic input setting
		if let audioDevice = AVCaptureDevice.default(for: .audio),
		   let audioInput = try? AVCaptureDeviceInput(device: audioDevice) {
			if self.captureSession.canAddInput(audioInput) {
				self.captureSession.addInput(audioInput)
				print("mic connected")
			}
		}
		
		if self.captureSession.canAddOutput(videoOutput) {
			self.captureSession.addOutput(videoOutput)
			// TODO: -  늦게 들어온 프레임은 버리기 (실시간 방송에서는 지연을 줄이는 게 화질보다 중요) 찾아볼것
			videoOutput.alwaysDiscardsLateVideoFrames = true
			
			// TODO: - 픽셀 포맷 설정 (iOS 화면 출력 및 처리에 가장 많이 쓰이는 BGRA 형식) 내용 서치
			videoOutput.videoSettings = [
				kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)
			]
			
			// TODO: - 	델리게이트 연결 (데이터를 받을 대리자는 self, 처리는 videoOutputQueue에서) 찾아볼것
			videoOutput.setSampleBufferDelegate(self, queue: videoOutputQueue)
			
			
		}
		if let connection = videoOutput.connection(with: .video) {
			
			// 방향(Rotation)
			if #available(iOS 17.0, *) {
				if connection.isVideoRotationAngleSupported(90) {
					connection.videoRotationAngle = 90
				}
			} else {
				// iOS 16 이하 방향(Enum)으로 설정
				if connection.isVideoOrientationSupported {
					connection.videoOrientation = .portrait
				}
			}
			
		}
		self.captureSession.commitConfiguration()
	}
	
	func switchCamera() {
		self.captureSession.beginConfiguration()
		
		guard let currentInput = self.captureSession.inputs.first(where: { ($0 as? AVCaptureDeviceInput)?.device.hasMediaType(.video) ?? false }) as? AVCaptureDeviceInput else {
			self.captureSession.commitConfiguration()
			return
		}
		
		let newPosition: AVCaptureDevice.Position = (currentInput.device.position == .front) ? .back : .front
		
		guard let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition),
			  let newInput = try? AVCaptureDeviceInput(device: newDevice) else {
			self.captureSession.commitConfiguration()
			return
		}
		
		self.captureSession.removeInput(currentInput)
		
		// Output 연결은 그대로 유지되므로 Input만 갈아끼우면 됨
		if self.captureSession.canAddInput(newInput) {
			self.captureSession.addInput(newInput)
		} else {
			self.captureSession.addInput(currentInput)
		}
		
		// 화면 전환 시 오리엔테이션이나 미러링 이슈가 생길 수 있는데, 그건 추후 처리
		self.captureSession.commitConfiguration()
	}
	
	
	func setupSession() {
		
	}
	
	
}


extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
	func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
		print("test")
	}
}
