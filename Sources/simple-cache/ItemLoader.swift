import Foundation

public class ItemLoader<T: AnyObject>: ObservableObject {
  @Published public var item: T?

  var url: URL
  var cache: PlainCache<T>
  var creator: (Data) -> T?

  public init(url: URL, cache: PlainCache<T>, creator: @escaping (Data) -> T?) {
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

  public func load() async throws {
    item = cache.get(forKey: url.absoluteString)

    if item == nil {
      try await loadFromUrl()
    }
  }

  public func loadFromUrl() async throws {
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
