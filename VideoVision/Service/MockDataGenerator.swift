//
//  MockDataGenerator.swift
//  VideoVision
//
//  Created by KimRin on 1/20/26.
//

import CoreVideo
import UIKit

class MockDataGenerator {
	// 가짜 CMSampleBuffer (또는 CVPixelBuffer)를 만들어주는 함수
	
	static func makeMockPixelBuffer() -> CVPixelBuffer? {
		let width = 1080
		let height = 1920
		var pixelBuffer: CVPixelBuffer?
		
		let attributes: [CFString: Any] = [
			kCVPixelBufferCGImageCompatibilityKey: true,
			kCVPixelBufferCGBitmapContextCompatibilityKey: true
		]
		
		let status = CVPixelBufferCreate(
			kCFAllocatorDefault,
			width,
			height,
			kCVPixelFormatType_32BGRA, // 시뮬레이터는 YUV 디버깅이 까다로우니 일단 BGRA로 테스트
			attributes as CFDictionary,
			&pixelBuffer
		)
		
		guard status == kCVReturnSuccess, let buffer = pixelBuffer else { return nil }
		
		// 버퍼에 색칠하기 (매번 다른 색이면 더 좋음 - 움직임 확인용)
		CVPixelBufferLockBaseAddress(buffer, [])
		let data = CVPixelBufferGetBaseAddress(buffer)
		
		// 메모리에 랜덤 데이터 채우기 (노이즈 화면처럼 보임)
		let size = CVPixelBufferGetDataSize(buffer)
		memset(data, Int32.random(in: 0...255), size)
		
		CVPixelBufferUnlockBaseAddress(buffer, [])
		
		return buffer
	}
}
