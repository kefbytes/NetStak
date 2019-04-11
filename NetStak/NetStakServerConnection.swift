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
    
    // MARK: - execute methods
    public static func execute(with url: URL, and request: NetStakRequestProtocol, session: NetStakSession, completion: @escaping (executeCompletion)) {
        var dataTask: URLSessionDataTask?
        if session.environment == .mock {
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
            dataTask = session.defaultSession.dataTask(with: url) {
                (data, responseFromDataTask, error) in
                do {
                    session.activeDataTasks[request.taskId] = nil
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
            session.activeDataTasks[request.taskId] = dataTask
        }
    }
    
    public static func execute(with request: NetStakRequestProtocol, and type: NetStakHTTPMethod, session: NetStakSession, completion: @escaping (executeCompletion)) {
        var dataTask: URLSessionDataTask?
        if session.environment == .mock {
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
            guard let url = NetStakURLHelper.buildURL(with: session, request: request) else {
                completion(nil, NetStakServiceError.unbuildableURL)
                return
            }
            let urlRequest = NetStakURLRequest.create(with: url, type: type, netStakRequest: request)

            dataTask = session.defaultSession.dataTask(with: urlRequest) {
                (data, responseFromDataTask, error) in
                do {
                    session.activeDataTasks[request.taskId] = nil
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
            session.activeDataTasks[request.taskId] = dataTask
        }
    }
    
    public static func execute(withMultipleAsyncRequests requests: [NetStakRequestProtocol], and type: NetStakHTTPMethod, session: NetStakSession, completion: @escaping (executeGroupCompletionDifferentTypes)) {
        var dataTask: URLSessionDataTask?
        var responseDict: [String : NetStakResponseProtocol] = [String : NetStakResponseProtocol]()
        if session.environment == .mock {
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
                guard let url = NetStakURLHelper.buildURL(with: session, request: request) else {
                    completion(nil, NetStakServiceError.unbuildableURL)
                    return
                }
                let urlRequest = NetStakURLRequest.create(with: url, type: type, netStakRequest: request)
                dataTask = session.defaultSession.dataTask(with: urlRequest) {
                    (data, responseFromDataTask, error) in
                    session.activeDataTasks[request.taskId] = nil
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
                session.activeDataTasks[request.taskId] = dataTask
            }
            dispatchGroup.notify(queue: .main) {
                completion(responseDict, nil)
            }
        }
    }
    
    public static func cancelTask(with request: NetStakRequestProtocol, session: NetStakSession) {
        let dataTask = session.activeDataTasks[request.taskId]
        dataTask?.cancel()
    }
    
}
