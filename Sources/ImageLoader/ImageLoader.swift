import UIKit

public protocol ImageLoading {
    func loadImage(from urlString: String, completion: @escaping (Bool) -> Void)
}

public final class ImageLoader: ImageLoading {
    public static let shared = ImageLoader()
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {}
    
    public func loadImage(from urlString: String, completion: @escaping (Bool) -> Void) {
        if let _ = cache.object(forKey: urlString as NSString) {
            DispatchQueue.main.async {
                completion(true)
            }
            return
        }
        
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            var sucesso = false
            if let data, let image = UIImage(data: data) {
                self?.cache.setObject(image, forKey: urlString as NSString)
                sucesso = true
            }
            
            DispatchQueue.main.async {
                completion(sucesso)
            }
        }.resume()
    }
}
