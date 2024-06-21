import Foundation

class ItemLoader<T: AnyObject>: ObservableObject {
  @Published var item: T?

  var url: URL
  var cache: PlainCache<T>
  var creator: (Data) -> T?

  init(url: URL, cache: PlainCache<T>, creator: @escaping (Data) -> T?) {
    self.url = url
    self.cache = cache
    self.creator = creator

    Task { [self] in
      do {
        try await load()
      }
      catch let e {
        print(e.localizedDescription)
      }
    }
  }

  func load() async throws {
    item = cache.get(forKey: url.absoluteString)

    if item == nil {
      try await loadFromUrl()
    }
  }

  func loadFromUrl() async throws {
    let urlRequest = URLRequest(url: url)

    let (data, _) = try await URLSession.shared.data(for: urlRequest, delegate: nil)

    DispatchQueue.main.async { [self] in
      item = creator(data)

      if let item = item {
        cache.set(forKey: url.absoluteString, item: item)
      }
    }
  }
}
