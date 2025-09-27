import Testing
@testable import ImageLoader

@Suite("Image Loader")
@MainActor
struct ImageLoaderTests {
    
    @Test("Returns nil for invalid URL")
    @available(iOS 13.0, *)
    func testInvalidURL() async {
        let loader = ImageLoader.shared
        
        let image = await withCheckedContinuation { continuation in
            loader.loadImage(from: "invalid-url") { img in
                continuation.resume(returning: img)
            }
        }
        
        #expect(image == nil)
    }
    
    @Test("Successfully downloads a valid image")
    @available(iOS 13.0, *)
    func testValidImageDownload() async {
        let loader = ImageLoader.shared
        
        let image = await withCheckedContinuation { continuation in
            loader.loadImage(from: "https://picsum.photos/50") { img in
                continuation.resume(returning: img)
            }
        }
        
        #expect(image != nil)
    }
    
    @Test("Returns cached image on second load")
    @available(iOS 13.0, *)
    func testCacheHit() async {
        let loader = ImageLoader.shared
        let url = "https://picsum.photos/60"
        
        _ = await withCheckedContinuation { continuation in
            loader.loadImage(from: url) { img in
                continuation.resume(returning: img)
            }
        }
        
        let cachedImage = await withCheckedContinuation { continuation in
            loader.loadImage(from: url) { img in
                continuation.resume(returning: img)
            }
        }
        
        #expect(cachedImage != nil)
    }
    
    @Test("Allows canceling a download")
    @available(iOS 13.0, *)
    func testCancelDownload() async {
        let loader = ImageLoader.shared
        let url = "https://picsum.photos/200"
        
        let token = loader.loadImage(from: url) { img in
            #expect(false)
        }
        
        loader.cancelLoad(token!)
        
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        #expect(true)
    }
}
