/// Copyright (c) 2021 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

protocol ImageService {
  func downloadImage(fromURL: URL, completion: @escaping (UIImage?, Error?) -> Void) -> URLSessionDataTask
  func setImage(on: UIImageView, fromURL: URL, withPlaceholder: UIImage?)
}

class ImageClient {
  // MARK: - Static Properties
  static let shared = ImageClient(responseQueue: .main, session: .shared)
  
  // MARK: - Instance Properties
  var cachedImageForURL: [URL: UIImage]
  var cachedTaskForImageView: [UIImageView: URLSessionDataTask]
  
  let responseQueue: DispatchQueue?
  let session: URLSession
  
  // MARK: - Object Lifecycle
  init(responseQueue: DispatchQueue?, session: URLSession) {
    self.cachedImageForURL = [:]
    self.cachedTaskForImageView = [:]
    
    self.responseQueue = responseQueue
    self.session = session
  }
}

extension ImageClient: ImageService {
  func downloadImage(fromURL: URL, completion: @escaping (UIImage?, Error?) -> Void) -> URLSessionDataTask {
    let dataTask = session.dataTask(with: fromURL) { [weak self] data, response, error in
      guard let self = self else { return }
      if let data = data, let image = UIImage(data: data) {
        self.dispatch(image: image, completion: completion)
      } else {
        self.dispatch(error: error, completion: completion)
      }
    }
    dataTask.resume()
    return dataTask
  }
  
  private func dispatch(image: UIImage? = nil, error: Error? = nil, completion: @escaping (UIImage?, Error?) -> Void) {
    guard let responseQueue = responseQueue else {
      completion(image, error)
      return
    }
    responseQueue.async {
      completion(image, error)
    }
  }
  
  func setImage(on: UIImageView, fromURL: URL, withPlaceholder: UIImage?) {
    
  }
}
