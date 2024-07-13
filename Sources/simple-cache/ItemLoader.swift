import Foundation

@MainActor
open class ItemLoader<T: AnyObject>: ObservableObject {
  @Published public var item: T?

  var cache: PlainCache<T>
  var creator: (Data) -> T?

  public init(cache: PlainCache<T>, creator: @escaping (Data) -> T?) {
    self.cache = cache
    self.creator = creator
  }

  public func load(url: URL) async throws {
    item = cache.get(forKey: url.absoluteString)

    if item == nil {
      let data = try await fetch(url: url)
      
      item = creator(data)

      if let item = item {
        cache.set(forKey: url.absoluteString, item: item)
      }
    }
  }

  public func fetch(url: URL) async throws -> Data {
    let urlRequest = URLRequest(url: url)

    let (data, _) = try await URLSession.shared.data(for: urlRequest, delegate: nil)

    return data
  }
}
