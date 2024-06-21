import Foundation

open class PlainCache<T: AnyObject> {
//  private var keysUsedSoFar = Set<String>()
//
//  var count: Int {
//    var count = 0
//
//    for key in keysUsedSoFar where cache.object(forKey: key as NSString) != nil {
//      count += 1
//    }
//
//    return count
//  }

  var cache = NSCache<NSString, T>()

  public init() {}

  public func get(forKey key: String) -> T? {
    cache.object(forKey: NSString(string: key))
  }

  public func set(forKey key: String, item: T) {
    cache.setObject(item, forKey: NSString(string: key))
    //keysUsedSoFar.insert(key)
  }
}
