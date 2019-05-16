# GSNetwork

[![CI Status](https://img.shields.io/travis/gloomy.meng.049@gmail.com/GSNetwork.svg?style=flat)](https://travis-ci.org/gloomy.meng.049@gmail.com/GSNetwork)
[![Version](https://img.shields.io/cocoapods/v/GSNetwork.svg?style=flat)](https://cocoapods.org/pods/GSNetwork)
[![License](https://img.shields.io/cocoapods/l/GSNetwork.svg?style=flat)](https://cocoapods.org/pods/GSNetwork)
[![Platform](https://img.shields.io/cocoapods/p/GSNetwork.svg?style=flat)](https://cocoapods.org/pods/GSNetwork)

- [Features](#features)
- [Usage](#usage)
- [Requirements](#requirements)
- [Installation](#installation)
- [License](#license)

## Features

- [ ] Category, SPM installation
- [ ] OAuth interceptor
- [x] etc..

## Usage

A simple network components, simple and clear API usage with only two files. 

Support diverse data structure returns while guaranteeing type checking. 

Unified error types and standard error handling.

Dependent on [Alamofire](https://github.com/Alamofire/Alamofire)

### Define API list 

First, initialized [GSNetwork](https://github.com/GloomyMeng/GSNetwork/blob/master/GSNetwork/Classes/GSNetwork.swift) with a [GSNetworkConfig](https://github.com/GloomyMeng/GSNetwork/blob/master/GSNetwork/Classes/GSNetwork.swift)

```
Network.config(config: GSNetworkConfig.init().then {
    $0.host = ""
    $0.customHeader = [:]
    //..//
})
```

Seconds, for different module need define different [APIRoute](https://github.com/GloomyMeng/GSNetwork/blob/master/GSNetwork/Classes/Protocols.swift)

```
enum UserRoute: APIRoute {
    
    case userInfo(id: String)
    case upateInfo(user: User)
    case logout
    case login(username: String, password: String)
    
    var uri: String {
        switch self {
        case .userInfo(let id):                     return ""
        case .upateInfo(let user):                  return ""
        case .logout:                               return ""
        case .login(let username, let password):    return ""
        }
    }
    
    var parameters: [String : Any] { return [:] }
    
    var method: HTTPMethod {
        switch self {
        case .userInfo(let id):                     return .get
        case .upateInfo(let user):                  return .post
        case .logout:                               return .get
        case .login(let username, let password):    return .get
        }
    }
    
    var encodeType: HTTPEncodeType { return .json }
    
    func customHost() -> String? { return nil }
}
```

Lastly, start requst like this

```
UserRoute.logout.start(success: { (rs: APIReturn<Bool>) in
    // do something...
})
```


## Requirements

- iOS 10.0+ / macOS 10.12+ / tvOS 10.0+ / watchOS 3.0+
- Xcode 10.2+
- Swift 5+

## Installation

### Cocoapods

GSNetwork is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'GSNetwork'
```

## Author

gloomy.meng.049@gmail.com, gloomy.meng.049@gmail.com

## License

GSNetwork is available under the MIT license. See the LICENSE file for more info.
