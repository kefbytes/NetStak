//
//  ServerConnection.swift
//  NetStak
//
//  Created by Kent Franks on 2/12/19.
//  Copyright © 2019 Kent Franks. All rights reserved.
//

import Foundation

public typealias executeCompletion = (ResponseProtocol?, Error?) -> Void
public typealias executeGroupCompletion = ([ResponseProtocol]?, Error?) -> Void
public typealias executeGroupCompletionDifferentTypes = ([String : ResponseProtocol]?, Error?) -> Void

public class ServerConnection {
    
    let defaultSession = URLSession(configuration: .default)
    let serverConfig: ServerConfigProtocol
    var activeDataTasks: [String: URLSessionDataTask] = [:]
    
    public init(config: ServerConfigProtocol) {
        self.serverConfig = config
    }
    
    public func execute(with url: URL, and request: RequestProtocol, completion: @escaping (executeCompletion)) {
        var dataTask: URLSessionDataTask?
        if serverConfig.discoMode {
            guard let jsonData = MockJsonReader.readJson(with: request.mockFileName) else {
                completion(nil, ServiceError.unableToReadMockJson)
                return
            }
            do {
                let response = try request.responseType.init(data: jsonData, urlResponse: nil)
                completion(response, nil)
            } catch {
                completion(nil, ServiceError.unableToInitResponseObject)
            }
        } else {
            dataTask = defaultSession.dataTask(with: url) {
                (data, responseFromDataTask, error) in
                do {
                    self.activeDataTasks[request.taskId] = nil
                    guard let unwrappedResponse = responseFromDataTask else {
                        completion(nil, error)
                        return
                    }
                    let response = try request.responseType.init(data: data, urlResponse: unwrappedResponse)
                    completion(response, nil)
                } catch {
                    completion(nil, ServiceError.unableToInitResponseObject)
                }
            }
            dataTask?.resume()
            activeDataTasks[request.taskId] = dataTask
        }
    }
    
    public func execute(with request: RequestProtocol, and type: HTTPMethod, completion: @escaping (executeCompletion)) {
        var dataTask: URLSessionDataTask?
        if serverConfig.discoMode {
            guard let jsonData = MockJsonReader.readJson(with: request.mockFileName) else {
                completion(nil, ServiceError.unableToReadMockJson)
                return
            }
            do {
                let response = try request.responseType.init(data: jsonData, urlResponse: nil)
                completion(response, nil)
            } catch {
                completion(nil, ServiceError.unableToInitResponseObject)
            }
        } else {
            guard let url = URLHelper.buildURL(with: serverConfig, request: request) else {
                completion(nil, ServiceError.unbuildableURL)
                return
            }
            let urlRequest = URLRequestBuilder.create(with: url, type: type)

            dataTask = defaultSession.dataTask(with: urlRequest) {
                (data, responseFromDataTask, error) in
                do {
                    self.activeDataTasks[request.taskId] = nil
                    guard let unwrappedResponse = responseFromDataTask else {
                        completion(nil, error)
                        return
                    }
                    let response = try request.responseType.init(data: data, urlResponse: unwrappedResponse)
                    completion(response, nil)
                } catch {
                    completion(nil, ServiceError.unableToInitResponseObject)
                }
            }
            dataTask?.resume()
            activeDataTasks[request.taskId] = dataTask
        }
    }
    
    public func execute(withMultipleAsyncRequests requests: [RequestProtocol], and type: HTTPMethod, completion: @escaping (executeGroupCompletionDifferentTypes)) {
        var dataTask: URLSessionDataTask?
        var responseDict: [String : ResponseProtocol] = [String : ResponseProtocol]()
        if serverConfig.discoMode {
            guard let jsonData = MockJsonReader.readJson(with: requests[0].mockFileName) else {
                completion(nil, ServiceError.unableToReadMockJson)
                return
            }
            do {
                let response = try requests[0].responseType.init(data: jsonData, urlResponse: nil)
                responseDict[requests[0].urlPath] = response
                completion(responseDict, nil)
            } catch {
                completion(nil, ServiceError.unableToInitResponseObject)
            }
        } else {
            let dispatchGroup = DispatchGroup()
            let unwrappedRequests = requests.compactMap { $0 }
            for request in unwrappedRequests {
                dispatchGroup.enter()
                guard let url = URLHelper.buildURL(with: serverConfig, request: request) else {
                    completion(nil, ServiceError.unbuildableURL)
                    return
                }
                let urlRequest = URLRequestBuilder.create(with: url, type: type)
                dataTask = defaultSession.dataTask(with: urlRequest) {
                    (data, responseFromDataTask, error) in
                    self.activeDataTasks[request.taskId] = nil
                    do {
                        guard let unwrappedResponse = responseFromDataTask else {
                            if let errorDesc = error?.localizedDescription,  errorDesc == "cancelled" {
                                dispatchGroup.leave()
                                return
                            }
                            completion(nil, error)
                            return
                        }
                        let response = try request.responseType.init(data: data, urlResponse: unwrappedResponse)
                        responseDict[request.urlPath] = response
                        
                    } catch {
                        completion(nil, ServiceError.unableToInitResponseObject)
                        dispatchGroup.leave()
                    }
                    dispatchGroup.leave()
                }
                dataTask?.resume()
                activeDataTasks[request.taskId] = dataTask
            }
            dispatchGroup.notify(queue: .main) {
                completion(responseDict, nil)
            }
        }
    }
    
    func cancelTask(with request: RequestProtocol) {
        let dataTask = self.activeDataTasks[request.taskId]
        dataTask?.cancel()
    }
    
}
