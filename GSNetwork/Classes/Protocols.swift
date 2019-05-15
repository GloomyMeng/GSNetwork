//
//  Protocols.swift
//  GSNetwork
//
//  Created by Zhendeaini 孟 on 2019/5/15.
//

import GSBasis
import Alamofire

// MARK: - APIRetable

/// 'GSNetworkError' is a error type returned by GSNetwork. It encompasses a few different types of errors, each with
/// their own associated reasons
///
/// - unknownErrorOccur: Alamofire occur errror, and can't get error detail
/// - afErrorOccur: Alamofire occur errror
/// - apiStatusError: API return date with error code, 'APIErrorRetable' 's 'isValidCode()' used to distinguish between normal and error states
/// - noNetworkError: Start request with no network connect now
public enum GSNetworkError: GSError {
    
    case unknownErrorOccur(error: Error?)
    case afErrorOccur(error: AFError)
    case apiStatusError(reason: APIErrorRetable)
    case noNetworkError
}

/// <#Description#>
public protocol APIErrorRetable: Decodable, ErrorReason {
    
    /// <#Description#>
    var code: Int { get set }
    
    /// <#Description#>
    var message: String { get set }
    
    /// <#Description#>
    ///
    /// - Returns: <#return value description#>
    func isValidCode() -> Bool
}

/// <#Description#>
public protocol APIRetable: Decodable {
    
    /// <#Description#>
    associatedtype T: Decodable
    
    /// <#Description#>
    associatedtype U: APIErrorRetable
    
    /// <#Description#>
    var error: U? { get set }
}

/// <#Description#>
///
/// - get: <#get description#>
/// - post: <#post description#>
/// - head: <#head description#>
/// - put: <#put description#>
/// - patch: <#patch description#>
/// - delete: <#delete description#>
/// - form: <#form description#>
public enum HTTPMethod {
    case get, post, head, put, patch, delete, form
    
    func translate() -> Alamofire.HTTPMethod {
        switch self {
        case .get:
            return Alamofire.HTTPMethod.get
        case .post:
            return Alamofire.HTTPMethod.post
        case .head:
            return Alamofire.HTTPMethod.head
        case .put:
            return Alamofire.HTTPMethod.put
        case .patch:
            return Alamofire.HTTPMethod.patch
        case .delete:
            return Alamofire.HTTPMethod.delete
        case .form:
            return Alamofire.HTTPMethod.get
        }
    }
}

/// <#Description#>
///
/// - url: <#url description#>
/// - json: <#json description#>
/// - custom: <#custom description#>
public enum HTTPEncodeType {
    
    case url
    case json
    case custom(ParameterEncoding)
    
    func translate() -> ParameterEncoding {
        switch self {
        case .url:                  return URLEncoding.default
        case .json:                 return JSONEncoding.default
        case .custom(let encoder):  return encoder
        }
    }
}

/// <#Description#>
public typealias APIFailureClosure = (GSNetworkError) -> Void

/// <#Description#>
public protocol APIRoute {
    
    /// <#Description#>
    var uri: String { get }
    
    /// <#Description#>
    var parameters: [String : Any] { get }
    
    /// <#Description#>
    var method: HTTPMethod { get }
    
    /// <#Description#>
    var encodeType: HTTPEncodeType { get }
    
    /// <#Description#>
    ///
    /// - Returns: <#return value description#>
    func customHost() -> String?
    
}
