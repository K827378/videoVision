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
	
	func makeFirstScreenVC() -> FilmingViewController {
		return FilmingViewController.create(with: self.makeFirstScreenViewModel())
	}
	
	func makeFirstScreenViewModel() -> FilmingViewModel {
		return FilmingViewModel(
			cameraManager: cameraManager,
			videoPlayerManager: videoPlayerManager
		)
	}
}
