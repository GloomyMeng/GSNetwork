//
//  GSNetwork.swift
//  GSNetwork
//
//  Created by Zhendeaini 孟 on 2019/5/15.
//

import Foundation
import GSBasis
import Alamofire
import Then

// MARK: - NetworkNotifier

/// GSNetwork's notification names
///
/// - changed: network status changed. 'notification.object' is a bool value. ture is have network(ethernetOrWiFi, wwan), false is not.
public enum NetworkNotifier: String, NotifierType {
    
    case stateChanged
}

// MARK: - GSNetworkConfig

/// A struct use to config 'GSNetwork', to define property GSNetwork needed
///
/// For example:
///
///     Network.config(config: GSNetworkConfig.init().then {
///         $0.host = ""
///         $0.customHeader = [:]
///         //..//
///     })
public final class GSNetworkConfig: Then {
    
    ///  API request default host
    public var host = ""
    
    /// API request default general parameters
    public var extendParameter: ((Parameters?) -> Parameters?) = { return $0 }
    
    /// API request default general HTTPHeaders
    public var customHeader: () -> [String: String] = { [:] }
    
    /// API request failure closure, use to handle error that occur
    public var failureClosure: APIFailureClosure = { _ in }
    
    /// Request interceptor, use to something what wanted, like oauth1.0 or others
    public var interceptor: RequestInterceptor? = nil
    
    public init() {} 
}

extension GSNetworkConfig {
    
    var validHost: String? {
        guard let url = URL.init(string: host) else { return nil }
        return url.host
    }
}

// MARK: - GSNetwork

/// Aliases for 'GSNetwork.shared'
public let Network = GSNetwork.shared

public final class GSNetwork {
    
    
    /// HTTP request's timeout interval to use when waiting for additional data.
    public static var timeout: TimeInterval {
        set { shared.session.sessionConfiguration.timeoutIntervalForRequest = newValue }
        get { return shared.session.sessionConfiguration.timeoutIntervalForRequest }
    }
    
    /// Shared instance for 'GSNetwork'
    public static let shared: GSNetwork = { return GSNetwork() }()
    
    /// The current states of network reachability.
    public var isReachable: Bool {
        return networkState != .notReachable && networkState != .unknown
    }
    
    internal var config = GSNetworkConfig()
    internal var session: Session { return Session.default }
    internal var reachabilityManager: NetworkReachabilityManager?
    internal var networkState: NetworkReachabilityManager.NetworkReachabilityStatus = .reachable(.wwan) {
        didSet {
            switch networkState {
            case .notReachable, .unknown:
                NetworkNotifier.stateChanged.push(object: false, userInfo: nil)
            case .reachable(_) :
                NetworkNotifier.stateChanged.push(object: true, userInfo: nil)
            }
        }
    }
    
    
    private init() {}
    
    /// Use this method to set config for Network request used.
    ///
    /// - Note: reset config will stop current requests and throw 'GSNetworkError.explicitlyCancelled'
    ///
    /// For example:
    ///
    ///     Network.config(config: GSNetworkConfig.init().then {
    ///         $0.host = ""
    ///         $0.customHeader = [:]
    ///         //..//
    ///     })
    public func config(config: GSNetworkConfig) {
        
        session.cancelRequestsForSessionInvalidation(with: GSNetworkError.explicitlyCancelled)
        self.config = config
        if let host = self.config.validHost {
            self.reachabilityManager = NetworkReachabilityManager(host: host)
            self.reachabilityManager?.listener = {
                self.networkState = $0
            }
            self.reachabilityManager?.startListening()
        }
    }
    
    deinit { self.reachabilityManager?.stopListening() }
}

// MARK: - APIRoute extensions

extension APIRoute {
    
    /// Start Request with APIRoute's instance.
    ///
    /// If need handler error for finish other, like update UI, reset property:
    ///
    ///     UserRoute.login(username: "xxxxx", password: "xxxx").start(success: { (rs: APIReturn<Model>) in
    ///         // do something...
    ///     }) { (error) in
    ///         // do something...
    ///     }
    ///
    /// Or without failure handler
    ///
    ///     UserRoute.logout.start(success: { (rs: APIReturn<Bool>) in
    ///         // do something...
    ///     })
    ///
    /// - Warning: Suggest handler error by GSNetworkConfig's failureClosure. this handler just used when you need to update local code logic.
    ///            like reset properties, refresh UI or others 
    ///
    /// - Parameters:
    ///   - success: Success handler with generic data structure
    ///   - failure: Failure handler with error
    public func start<T: APIRetable>(success: @escaping ((T) -> Void), _ failure: APIFailureClosure? = nil) {
        let failureClosure: (GSNetworkError, DataResponse<T>?) -> Void = { error, resp in
            Async.main {
                failure?(error)
                Network.config.failureClosure(error)
            }
        }
        
        guard Network.isReachable else {
            failureClosure(.noNetworkError, nil)
            return
        }
        
        let url = (customHost() ?? Network.config.host) + uri
        Network.session.request(url, method: method.translate(),
                        parameters: Network.config.extendParameter(parameters),
                        encoding: encodeType.translate(),
                        headers: HTTPHeaders.init(Network.config.customHeader()),
                        interceptor: Network.config.interceptor)
            .responseDecodable { (rs: DataResponse<T>) in
                if let result = rs.value {
                    if let error = result.error, !error.isValidCode() { failureClosure(.apiStatusError(reason: error), rs) }
                    else { success(result) }
                } else {
                    if let error = rs.error?.asAFError { failureClosure(.afErrorOccur(error: error), rs) }
                    else { failureClosure(.unknownErrorOccur(error: rs.error), rs) }
                }
        }
    }
}
