//
//  FirstScreenVC.swift
//  VideoVision
//
//  Created by KimRin on 1/6/26.
//

import AVFoundation
import UIKit


class FirstScreenVC: UIViewController {
	
	let captureSession = AVCaptureSession()
	
	var previewLayer: AVCaptureVideoPreviewLayer?
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.backgroundColor = .white
		self.setupCamera()
	}
	
	
	
	
	func setupCamera() {
		guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
		
		do {
			// (2) 입력(Input) 생성: 장치에서 데이터를 가져올 통로
			let input = try AVCaptureDeviceInput(device: captureDevice)
			
			// (3) 세션에 입력 추가 (가능한지 확인 후)
			if captureSession.canAddInput(input) {
				captureSession.addInput(input)
			}
			
			// (4) 프리뷰 레이어 설정 및 화면에 추가
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
