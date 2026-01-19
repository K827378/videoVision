#  cameraManager

kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)

데이터 크기 (대역폭):

BGRA: 픽셀당 4바이트 (R,G,B,Alpha). 데이터가 큽니다.

YUV 420: 사람 눈은 밝기(Y)에는 민감하고 색상(UV)에는 둔감합니다. 그래서 색상 정보를 1/4로 줄여서 저장합니다. 픽셀당 평균 1.5바이트 정도입니다. 메모리 대역폭을 절반 이하로 아낄 수 있습니다.

인코딩 호환성 (하드웨어 가속):

나중에 VideoToolbox로 H.264 인코딩을 할 텐데, 아이폰의 하드웨어 인코더는 YUV 포맷을 입력으로 받길 원합니다.

만약 여기서 BGRA로 설정하면? -> [CPU가 BGRA를 YUV로 변환] -> [인코더 전달] 과정이 추가되어 발열과 배터리 소모가 늘어납니다

"메모리 대역폭 절약과 인코더 호환성 때문입니다

```
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
```

	 Timer?
