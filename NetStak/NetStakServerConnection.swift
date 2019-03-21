//
//  NetStakServerConnection.swift
//  NetStak
//
//  Created by Kent Franks on 2/12/19.
//  Copyright © 2019 Kent Franks. All rights reserved.
//

import Foundation

public typealias executeCompletion = (NetStakResponseProtocol?, Error?) -> Void
public typealias executeGroupCompletion = ([NetStakResponseProtocol]?, Error?) -> Void
public typealias executeGroupCompletionDifferentTypes = ([String : NetStakResponseProtocol]?, Error?) -> Void

public class NetStakServerConnection {
    
    let defaultSession = URLSession(configuration: .default)
    let serverConfig: NetStakServerConfigProtocol
    var activeDataTasks: [String: URLSessionDataTask] = [:]
    
    public init(config: NetStakServerConfigProtocol) {
        self.serverConfig = config
    }
    
    public func execute(with url: URL, and request: NetStakRequestProtocol, completion: @escaping (executeCompletion)) {
        var dataTask: URLSessionDataTask?
        if serverConfig.discoMode {
            guard let jsonData = NetStakMockJsonReader.readJson(with: request.mockFileName) else {
                completion(nil, NetStakServiceError.unableToReadMockJson)
                return
            }
            do {
                let response = try request.responseType.init(data: jsonData, urlResponse: nil)
                completion(response, nil)
            } catch {
                completion(nil, NetStakServiceError.unableToInitResponseObject)
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
                    completion(nil, NetStakServiceError.unableToInitResponseObject)
                }
            }
            dataTask?.resume()
            activeDataTasks[request.taskId] = dataTask
        }
    }
    
    public func execute(with request: NetStakRequestProtocol, and type: NetStakHTTPMethod, completion: @escaping (executeCompletion)) {
        var dataTask: URLSessionDataTask?
        if serverConfig.discoMode {
            guard let jsonData = NetStakMockJsonReader.readJson(with: request.mockFileName) else {
                completion(nil, NetStakServiceError.unableToReadMockJson)
                return
            }
            do {
                let response = try request.responseType.init(data: jsonData, urlResponse: nil)
                completion(response, nil)
            } catch {
                completion(nil, NetStakServiceError.unableToInitResponseObject)
            }
        } else {
            guard let url = NetStakURLHelper.buildURL(with: serverConfig, request: request) else {
                completion(nil, NetStakServiceError.unbuildableURL)
                return
            }
            let urlRequest = NetStakURLRequest.create(with: url, type: type)

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
                    completion(nil, NetStakServiceError.unableToInitResponseObject)
                }
            }
            dataTask?.resume()
            activeDataTasks[request.taskId] = dataTask
        }
    }
    
    public func execute(withMultipleAsyncRequests requests: [NetStakRequestProtocol], and type: NetStakHTTPMethod, completion: @escaping (executeGroupCompletionDifferentTypes)) {
        var dataTask: URLSessionDataTask?
        var responseDict: [String : NetStakResponseProtocol] = [String : NetStakResponseProtocol]()
        if serverConfig.discoMode {
            guard let jsonData = NetStakMockJsonReader.readJson(with: requests[0].mockFileName) else {
                completion(nil, NetStakServiceError.unableToReadMockJson)
                return
            }
            do {
                let response = try requests[0].responseType.init(data: jsonData, urlResponse: nil)
                responseDict[requests[0].urlPath] = response
                completion(responseDict, nil)
            } catch {
                completion(nil, NetStakServiceError.unableToInitResponseObject)
            }
        } else {
            let dispatchGroup = DispatchGroup()
            let unwrappedRequests = requests.compactMap { $0 }
            for request in unwrappedRequests {
                dispatchGroup.enter()
                guard let url = NetStakURLHelper.buildURL(with: serverConfig, request: request) else {
                    completion(nil, NetStakServiceError.unbuildableURL)
                    return
                }
                let urlRequest = NetStakURLRequest.create(with: url, type: type)
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
                        completion(nil, NetStakServiceError.unableToInitResponseObject)
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
    
    func cancelTask(with request: NetStakRequestProtocol) {
        let dataTask = self.activeDataTasks[request.taskId]
        dataTask?.cancel()
    }
    
}