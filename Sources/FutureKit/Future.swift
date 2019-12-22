//
//  Future.swift
//
//  Copyright (c) 2019 Fabio Ferrero. Licensed under the MIT license, as follows:
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation

/// An object that represent an asynchronous operation that will return a value of type `Value` in the future.
public class Future<Value> {
    fileprivate var result: Result<Value, Swift.Error>? {
        // Observe result assignment and report it
        didSet { result.map(report) }
    }
    
    private typealias ResultCallback = (Result<Value, Swift.Error>) -> Void
    private typealias SuccessCallback = (Value) -> Void
    private typealias FailureCallback = (Swift.Error) -> Void
    
    private lazy var callbacks = [(Queue, ResultCallback)]()
    private lazy var onSuccessCallbacks = [(Queue, SuccessCallback)]()
    private lazy var onFailureCallbacks = [(Queue, FailureCallback)]()
    
    public enum Queue { case main; case background }
    
    public func observe(on queue: Queue = .main, with callback: @escaping (Result<Value, Swift.Error>) -> Void) {
        callbacks.append((queue, callback))
        
        // If a result has already been set, call the callback directly
        result.map { result in
            handle(callback: callback, with: result, on: queue)
        }
    }
    
    @discardableResult
    public func onSuccess(on queue: Queue = .main, do callback: @escaping (Value) -> Void) -> Future<Value> {
        onSuccessCallbacks.append((queue, callback))
        
        // If a result has already been set, call the success callback directly
        // only if the result is a success
        result.map { result in
            if case Result.success(let value) = result {
                handle(callback: callback, with: value, on: queue)
            }
        }
        return self
    }
    
    @discardableResult
    public func onFailure(on queue: Queue = .main, do callback: @escaping (Swift.Error) -> Void) -> Future<Value> {
        onFailureCallbacks.append((queue, callback))
        
        // If a result has already been set, call the failure callback directly
        // only if the result is a failure
        result.map { result in
            if case Result.failure(let error) = result {
                handle(callback: callback, with: error, on: queue)
            }
        }
        return self
    }
    
    private func report(result: Result<Value, Swift.Error>) {
        // Call all observed callbacks
        callbacks.forEach { (queue, callback) in
            handle(callback: callback, with: result, on: queue)
        }
        
        // Call all onSuccess callbacks
        if case Result.success(let value) = result {
            onSuccessCallbacks.forEach { queue, callback in
                handle(callback: callback, with: value, on: queue)
            }
        }
        
        // Call all onFailure callbacks
        if case Result.failure(let error) = result {
            onFailureCallbacks.forEach { queue, callback in
                handle(callback: callback, with: error, on: queue)
            }
        }
    }
    
    private typealias Callback<T> = (T) -> Void
    
    private func handle<T>(callback: @escaping Callback<T>, with value: T, on queue: Queue) {
        switch queue {
        case .main: DispatchQueue.main.async { callback(value) }
        case .background: callback(value)
        }
    }
}

public class Promise<Value>: Future<Value> {
    public init(value: Value? = nil) {
        super.init()
        
        // If a value is already given in input, we can report the value directly
        result = value.map { value in Result.success(value) }
    }
    
    public func resolve(with value: Value) {
        result = .success(value)
    }
    
    public func reject(with error: Swift.Error) {
        result = .failure(error)
    }
}
