//
//  NetStakServerConnection.swift
//  NetStak
//
//  Created by Kent Franks on 2/12/19.
//  Copyright © 2019 Kent Franks. All rights reserved.
//

import Foundation

public typealias executeCompletion = (Result<NetStakResponseProtocol?, NetStakServiceError>) -> Void
public typealias executeGroupCompletion = (Result<[String : NetStakResponseProtocol], NetStakServiceError>) -> Void


public class NetStakServerConnection {
    
    // MARK: - execute methods
    public static func execute(with url: URL, and request: NetStakRequestProtocol, session: NetStakSession, completion: @escaping executeCompletion) {
        var dataTask: URLSessionDataTask?
        if session.environment == .mock {
            guard let jsonData = NetStakMockJsonReader.readJson(with: request.mockFileName) else {
                completion(.failure(.unableToReadMockJson))
                return
            }
            do {
                let response = try request.responseType.init(data: jsonData, urlResponse: nil)
                completion(.success(response))
            } catch {
                completion(.failure(.unableToInitResponseObject))
            }
        } else {
            dataTask = session.defaultSession.dataTask(with: url) {
                (data, responseFromDataTask, error) in
                do {
                    session.activeDataTasks[request.taskId] = nil
                    guard let unwrappedResponse = responseFromDataTask else {
                        completion(.failure(.responseisNil))
                        return
                    }
                    let response = try request.responseType.init(data: data, urlResponse: unwrappedResponse)
                    completion(.success(response))
                } catch {
                    completion(.failure(.unableToInitResponseObject))
                }
            }
            dataTask?.resume()
            session.activeDataTasks[request.taskId] = dataTask
        }
    }
    
    public static func execute(with request: NetStakRequestProtocol, and session: NetStakSession, completion: @escaping executeCompletion) {
        var dataTask: URLSessionDataTask?
        if session.environment == .mock {
            guard let jsonData = NetStakMockJsonReader.readJson(with: request.mockFileName) else {
                completion(.failure(.unableToReadMockJson))
                return
            }
            do {
                let response = try request.responseType.init(data: jsonData, urlResponse: nil)
                completion(.success(response))
            } catch {
                completion(.failure(.unableToInitResponseObject))
            }
        } else {
            guard let url = NetStakURLHelper.buildURL(with: session, request: request) else {
                completion(.failure(.unbuildableURL))
                return
            }
            let urlRequest = NetStakURLRequest.create(with: url, type: request.requestTypeMethod, netStakRequest: request)

            dataTask = session.defaultSession.dataTask(with: urlRequest) {
                (data, responseFromDataTask, error) in
                do {
                    session.activeDataTasks[request.taskId] = nil
                    guard let unwrappedResponse = responseFromDataTask else {
                        completion(.failure(.responseisNil))
                        return
                    }
                    let response = try request.responseType.init(data: data, urlResponse: unwrappedResponse)
                    completion(.success(response))
                } catch {
                    completion(.failure(.unableToInitResponseObject))
                }
            }
            dataTask?.resume()
            session.activeDataTasks[request.taskId] = dataTask
        }
    }

    public static func execute(withMultipleAsyncRequests requests: [NetStakRequestProtocol], and session: NetStakSession, completion: @escaping executeGroupCompletion) {
        var dataTask: URLSessionDataTask?
        var responseDict: [String : NetStakResponseProtocol] = [String : NetStakResponseProtocol]()
        if session.environment == .mock {
            guard let jsonData = NetStakMockJsonReader.readJson(with: requests[0].mockFileName) else {
                completion(.failure(.unableToReadMockJson))
                return
            }
            do {
                let response = try requests[0].responseType.init(data: jsonData, urlResponse: nil)
                responseDict[requests[0].urlPath] = response
                completion(.success(responseDict))
            } catch {
                completion(.failure(.unableToInitResponseObject))
            }
        } else {
            let dispatchGroup = DispatchGroup()
            let unwrappedRequests = requests.compactMap { $0 }
            for request in unwrappedRequests {
                dispatchGroup.enter()
                guard let url = NetStakURLHelper.buildURL(with: session, request: request) else {
                    completion(.failure(.unbuildableURL))
                    return
                }
                let urlRequest = NetStakURLRequest.create(with: url, type: request.requestTypeMethod, netStakRequest: request)
                dataTask = session.defaultSession.dataTask(with: urlRequest) {
                    (data, responseFromDataTask, error) in
                    session.activeDataTasks[request.taskId] = nil
                    do {
                        guard let unwrappedResponse = responseFromDataTask else {
                            if let errorDesc = error?.localizedDescription,  errorDesc == "cancelled" {
                                dispatchGroup.leave()
                                return
                            }
                            completion(.failure(.responseisNil))
                            return
                        }
                        let response = try request.responseType.init(data: data, urlResponse: unwrappedResponse)
                        responseDict[request.urlPath] = response
                        
                    } catch {
                        completion(.failure(.unableToInitResponseObject))
                        dispatchGroup.leave()
                    }
                    dispatchGroup.leave()
                }
                dataTask?.resume()
                session.activeDataTasks[request.taskId] = dataTask
            }
            dispatchGroup.notify(queue: .main) {
                completion(.success(responseDict))
            }
        }
    }
    
    public static func cancelTask(with request: NetStakRequestProtocol, session: NetStakSession) {
        let dataTask = session.activeDataTasks[request.taskId]
        dataTask?.cancel()
    }
    
}
