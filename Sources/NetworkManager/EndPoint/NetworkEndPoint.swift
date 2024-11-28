//
//  NetworkEndPoint.swift
//  NetworkManager
//
//  Created by Hoorad on 11/28/24.
//


import Foundation

enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
    case PATCH
}


protocol ApiEndpoint {
    
    var baseURLString: String { get }
    var apiPath: String { get }
    var apiVersion: String? { get }
    var separatorPath: String? { get }
    var path: String { get }
    var headers: [String: String]? { get }
    var queryForCall: [URLQueryItem]? { get }
    var params: [String: Any]? { get }
    var method: HTTPMethod { get }
    var customDataBody: Data? { get }
}

extension ApiEndpoint {
    
    var urlString: String{

        var urlComponents = URLComponents(string: baseURLString)
        var longPath = "/"
        longPath.append(apiPath)

        if let apiVersion = apiVersion {
            longPath.append("/")
            longPath.append(apiVersion)
        }
        if let separatorPath = separatorPath {
            longPath.append("/")
            longPath.append(separatorPath)
        }
        longPath.append("/")
        longPath.append(path)
        urlComponents?.path = longPath

        if let queryForCalls = queryForCall {
            urlComponents?.queryItems = [URLQueryItem]()
            for queryForCall in queryForCalls {
                urlComponents?.queryItems?.append(URLQueryItem(name: queryForCall.name, value: queryForCall.value))
            }
        }

        guard let url = urlComponents?.url else { return URLRequest(url: URL(string: baseURLString)!).description }
        return url.description
    }
    
    var makeRequest: URLRequest {
        var urlComponents = URLComponents(string: baseURLString)
        var longPath = "/"
        longPath.append(apiPath)

        if let apiVersion = apiVersion {
            longPath.append("/")
            longPath.append(apiVersion)
        }
        if let separatorPath = separatorPath {
            longPath.append("/")
            longPath.append(separatorPath)
        }
        longPath.append("/")
        longPath.append(path)
        urlComponents?.path = longPath

        if let queryForCalls = queryForCall {
            urlComponents?.queryItems = [URLQueryItem]()
            for queryForCall in queryForCalls {
                urlComponents?.queryItems?.append(URLQueryItem(name: queryForCall.name, value: queryForCall.value))
            }
        }

        guard let url = urlComponents?.url else { return URLRequest(url: URL(string: baseURLString)!) }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        if let headers = headers {
            for header in headers {
                request.addValue(header.value, forHTTPHeaderField: header.key)
            }
        }

        if let params = params {

            let jsonData = try? JSONSerialization.data(withJSONObject: params, options: [])
            request.httpBody = jsonData
        }

        if let customDataBody = customDataBody {
            request.httpBody = customDataBody
        }

        return request
    }

    private func getPostString(params:[String:Any]) -> String {

        var data = [String]()
        for(key, value) in params {

            data.append(key + "=\(value)")
        }

        return data.map { String($0) }.joined(separator: "&")
    }

    // Model To Parameter
    private func modelToParameter<T: Codable>(model: T) -> [String: Any]?{

        do {

            var json: [String: Any]? = [:]
            let jsonEncoder: JSONEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(model)
            json = (try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any])

            return json
        } catch{

            return nil
        }
    }
}
