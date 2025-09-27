import UIKit

public protocol ImageLoading {
    @discardableResult
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) -> UUID?
    func cancelLoad(_ token: UUID)
}

public final class ImageLoader: ImageLoading {
    public static let shared = ImageLoader()
    
    private let cache = NSCache<NSString, UIImage>()
    private let queue = DispatchQueue(label: "com.imageloader.queue")

    private var pendingRequests = [String: [(UUID, (UIImage?) -> Void)]]()
    
    private var tokenToURL = [UUID: String]()
    
    private let downloadQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "com.imageloader.downloadQueue"
        queue.maxConcurrentOperationCount = 4
        return queue
    }()
    
    private init() {}
    
    @discardableResult
    public func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) -> UUID? {
        
        if let cached = cache.object(forKey: urlString as NSString) {
            DispatchQueue.main.async { completion(cached) }
            return nil
        }
        
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async { completion(nil) }
            return nil
        }
        
        let token = UUID()
        
        queue.sync {
            if pendingRequests[urlString] != nil {
                pendingRequests[urlString]?.append((token, completion))
                tokenToURL[token] = urlString
                return
            } else {
                pendingRequests[urlString] = [(token, completion)]
                tokenToURL[token] = urlString
            }
        }
        
        let operation = BlockOperation { [weak self] in
            guard let self = self else { return }
            
            let task = URLSession.shared.dataTask(with: url) { data, _, _ in
                var image: UIImage? = nil
                if let data, let downloaded = UIImage(data: data) {
                    image = downloaded
                    self.cache.setObject(downloaded, forKey: urlString as NSString)
                }
                
                self.queue.sync {
                    let completions = self.pendingRequests[urlString] ?? []
                    self.pendingRequests[urlString] = nil
                    completions.forEach { (_, completion) in
                        DispatchQueue.main.async { completion(image) }
                    }
                    completions.forEach { (token, _) in
                        self.tokenToURL[token] = nil
                    }
                }
            }
            
            task.resume()
            
            self.queue.sync {
                self.tokenToURL[token] = urlString
            }
        }
        
        downloadQueue.addOperation(operation)
        
        return token
    }
    
    public func cancelLoad(_ token: UUID) {
        queue.sync {
            guard let urlString = tokenToURL[token] else { return }
            if var callbacks = pendingRequests[urlString] {
                callbacks.removeAll { $0.0 == token }
                pendingRequests[urlString] = callbacks.isEmpty ? nil : callbacks
            }
            
            tokenToURL[token] = nil
        }
    }
}
