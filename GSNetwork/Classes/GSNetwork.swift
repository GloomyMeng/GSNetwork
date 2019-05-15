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

/// <#Description#>
///
/// - changed: <#changed description#>
public enum NetworkNotifier: String, NotifierType {
    
    case stateChanged
}

// MARK: - GSNetworkConfig

/// <#Description#>
public class GSNetworkConfig: Then {
    
    /// <#Description#>
    public var host = ""
    
    /// <#Description#>
    public var extendParameter: ((Parameters?) -> Parameters?) = { return $0 }
    
    /// <#Description#>
    public var customHeader: () -> [String: String] = { [:] }
    
    /// <#Description#>
    public var failureClosure: APIFailureClosure = { _ in }
    
    /// <#Description#>
    public var interceptor: RequestInterceptor? = nil
}

extension GSNetworkConfig {
    
    var validHost: String? {
        guard let url = URL.init(string: host) else { return nil }
        return url.host
    }
}

// MARK: - GSNetwork

/// <#Description#>
public let Network = GSNetwork.default

/// <#Description#>
public final class GSNetwork {
    
    
    /// <#Description#>
    public static var timeout = 10.0
    
    /// <#Description#>
    public static let `default`: GSNetwork = { return GSNetwork() }()
    
    /// <#Description#>
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
    
    /// <#Description#>
    ///
    /// - Parameter config: <#config description#>
    public func config(config: GSNetworkConfig) {
        self.config = config
        if let host = self.config.validHost {
            self.reachabilityManager = NetworkReachabilityManager(host: host)
            self.reachabilityManager?.listener = {
                self.networkState = $0
            }
            self.reachabilityManager?.startListening()
        }
    }
    
    deinit {
        self.reachabilityManager?.stopListening()
    }
}

// MARK: - APIRoute extensions

extension APIRoute {
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - success: <#success description#>
    ///   - failure: <#failure description#>
    public func start<T: APIRetable>(success: @escaping ((T) -> Void), _ failure: APIFailureClosure? = nil) {
        let failureClosure: (GSNetworkError, DataResponse<T>?) -> Void = { error, resp in
            Async.main {
                failure?(error)
                GSNetwork.default.config.failureClosure(error)
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
