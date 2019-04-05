# NetStak
A KefBytes service layer module

NetStak includes class named NetStakBaseUrls:

```swift
public class NetStakBaseUrls {
    public static let shared = NetStakBaseUrls()
    public var dev: String?
    public var qa: String?
    public var uat: String?
    public var prod: String?
}
```
You will need to set that values for whichever environments you need to use. I typically add a function in AppDelegate extension to do so.
```swift
extension AppDelegate {
    private func setBaseUrls() {
        let baseUrls = NetStakBaseUrls.shared
        baseUrls.dev = "https://swapi.co/api"
        baseUrls.qa = "https://swapi.co/api"
        baseUrls.uat = "https://swapi.co/api"
        baseUrls.prod = "https://swapi.co/api"
    }
}
```
Then this gets called from didFinishLaunchingWithOptions. If you want to do it at some other point that it fine you will just need to set them before you make your first service call.

In tandom with the method I often use schemes to programmatically set the environment variable in NetStakSession.
```swift
let session = NetStakSession.shared
  #if Dev
    session.environment = .dev
  #elseif Prod
    session.environment = .prod
  #endif
```
With this combination I can then switch schemes and have the baseUrl changed dynamically due to the baseUrl function in NetStakEnvironment enum.
```swift
func baseURL() -> String {
  let baseUrls = NetStakBaseUrls.shared
    switch self {
      case .dev:
        return baseUrls.dev ?? ""
      case .qa:
        return baseUrls.qa ?? ""
      case .uat:
        return baseUrls.uat ?? ""
      case .prod:
        return baseUrls.prod ?? ""
      case .mock:
        return ""
  }
}
```
