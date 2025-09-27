import Testing

@testable import ImageLoader

@Suite("Image Loader")
@MainActor
struct ImageLoaderTests {
    @Test("Returns false for invalid URL")
    @available(iOS 13.0, *)
    func testInvalidURL() async {
        let loader = ImageLoader.shared
        
        let didSet = await withCheckedContinuation { continuation in
            loader.loadImage(from: "invalid-url") { success in
                continuation.resume(returning: success)
            }
        }
        
        #expect(didSet == false)
    }
    
    @Test("Successfully downloads a valid image")
    @available(iOS 13.0, *)
    func testValidImageDownload() async {
        let loader = ImageLoader.shared
        
        let didSet = await withCheckedContinuation { continuation in
            loader.loadImage(from: "https://picsum.photos/50") { success in
                continuation.resume(returning: success)
            }
        }
        
        #expect(didSet == true)
    }
    
    @Test("Returns true for cached image on second load")
    @available(iOS 13.0, *)
    func testCacheHit() async {
        let loader = ImageLoader.shared
        let url = "https://picsum.photos/60"
        
        _ = await withCheckedContinuation { continuation in
            loader.loadImage(from: url) { success in
                continuation.resume(returning: success)
            }
        }
        
        let didSetCache = await withCheckedContinuation { continuation in
            loader.loadImage(from: url) { success in
                continuation.resume(returning: success)
            }
        }
        
        #expect(didSetCache == true)
    }
}
