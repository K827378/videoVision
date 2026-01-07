//
//  DIContainer.swift
//  VideoVision
//
//  Created by KimRin on 1/7/26.
//

import Foundation

final class DIContainer {
	let cameraManager = CameraManager()
	let videoPlayerManager = VideoPlayerManager()
	
	func makeFirstScreenVC() -> FirstScreenVC {
		return FirstScreenVC.create(with: self.makeFirstScreenViewModel())
	}
	
	func makeFirstScreenViewModel() -> FirstScreenVM {
		return FirstScreenVM(
			cameraManager: cameraManager,
			videoPlayerManager: videoPlayerManager
		)
	}
}
