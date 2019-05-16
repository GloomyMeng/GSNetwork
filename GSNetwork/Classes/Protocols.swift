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
/// - explicitlyCancelled: only when reset config, will stop all current request and throw error
/// - unknownErrorOccur: Alamofire occur errror, and can't get error detail
/// - afErrorOccur: Alamofire occur errror
/// - apiStatusError: API return date with error code, 'APIErrorRetable' 's 'isValidCode()' used to distinguish between normal and error states
/// - noNetworkError: Start request with no network connect now
public enum GSNetworkError: GSError {
    
    case explicitlyCancelled
    case unknownErrorOccur(error: Error?)
    case afErrorOccur(error: AFError)
    case apiStatusError(reason: APIErrorRetable)
    case noNetworkError
}

/// 'APIErrorRetable' is a protocol to describe the business API return data status.
/// API return always contain 'code' and 'message', can use code to resolve whether the data is use for show or show error content
///
/// For example:
///
///     struct APIErrorCode: APIErrorRetable {
///         var code: Int
///         var message: String
///         var localizedDescription: String { return "Code: \(code), Message: \(message)" }
///
///         func isValidCode() -> Bool { return code == 0 }
///     }
///
public protocol APIErrorRetable: Decodable, ErrorReason {
    
    /// API return status code
    var code: Int { get set }
    
    /// API return status message
    var message: String { get set }
    
    /// Resolve whether the returned data is the correct return data.
    ///
    /// - Returns: true means 'code' is right, false means is wrong
    func isValidCode() -> Bool
}

/// 'APIRetable' is a protocol to describe the bussiness API return data.
///
/// API return data structure include mode list, can like this:
///
///     struct APIReturn<S: Decodable>: APIRetable {
///         typealias T = S
///
///         var error: APIErrorCode?
///         var data: [S]?
///     }
///
/// And if is onle a model, can like this:
///
///     struct APIReturn<S: Decodable>: APIRetable {
///         typealias T = S
///
///         var error: APIErrorCode?
///         var data: S?
///     }
///
/// Or:
///
///     struct APIReturn<S: Decodable>: APIRetable {
///         typealias T = S
///
///         var error: APIErrorCode?
///         var data: [String: S]?
///     }
///
/// The difference is that the former needs a new data model, the latter does not need
///
public protocol APIRetable: Decodable {
    
    /// API return data
    associatedtype T: Decodable
    
    /// API return data status
    associatedtype U: APIErrorRetable
    
    /// API return data status
    var error: U? { get set }
}

// MARK: - HTTPMethod

/// 'HTTPMethod', use this to define http method.
///
/// - Note: Because if use 'Alamofire.HTTPMethod' directly, need add 'import Alamofire' on the top
///
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

// MARK: - HTTPEncodeType

/// A enum used to define how a set of parameters are applied to a URLRequest.
///
/// - url: Creates a url-encoded query string to be set as or appended to any existing URL query string or set as the HTTP body of the URL request. Whether the query string is set or appended to any existing URL query string or set as the HTTP body depends on the destination of the encoding.
/// - json: Uses JSONSerialization to create a JSON representation of the parameters object, which is set as the body of the request. The Content-Type HTTP header field of an encoded request is set to application/json.
/// - custom: Use custom parameter encoding instance which confirm protocol 'ParameterEncoding'
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

// MARK: - APIRoute

/// A closure with 'GSNetworkError'.
public typealias APIFailureClosure = (GSNetworkError) -> Void

/// 'APIRoute' is a protocol for define API, with specific uri, api parameter, api http method, api encode type.
/// Use enum to define API requests for different modules.
///
/// For example:
///
///     enum UserRoute: APIRoute {
///
///         case userInfo(id: String)
///         case upateInfo(user: User)
///         case logout
///         case login(username: String, password: String)
///
///         var uri: String {
///             switch self {
///             case .userInfo(let id):                     return ""
///             case .upateInfo(let user):                  return ""
///             case .logout:                               return ""
///             case .login(let username, let password):    return ""
///             }
///         }
///
///         var parameters: [String : Any] { return [:] }
///
///         var method: HTTPMethod {
///             switch self {
///             case .userInfo(let id):                     return .get
///             case .upateInfo(let user):                  return .post
///             case .logout:                               return .get
///             case .login(let username, let password):    return .get
///             }
///         }
///
///         var encodeType: HTTPEncodeType { return .json }
///
///         func customHost() -> String? { return nil }
///     }
///
public protocol APIRoute {
    
    /// API request url, like "/"
    var uri: String { get }
    
    /// API request parameters
    var parameters: [String : Any] { get }
    
    /// API request method
    var method: HTTPMethod { get }
    
    /// API parameter encode type
    var encodeType: HTTPEncodeType { get }
    
    /// API request custom host
    ///
    /// - Note: default is GSNetwork config's default host
    func customHost() -> String?
}

extension APIRoute {
    
    func customHost() -> String? { return Network.config.host }
}



