//
//  FutureSaved.swift
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

protocol Savable {}

protocol Database {
    func save<S: Savable>(_ savable: S, callback: @escaping (Result<S, Error>) -> Void)
}

extension Future where Value: Savable {
    func saved(in database: Database) -> Future<Value> {
        return chained { value in
            let promise = Promise<Value>()
            
            database.save(value) { result in
                switch result {
                case .success(let value):
                    promise.resolve(with: value)
                case .failure(let error):
                    promise.reject(with: error)
                }
            }
            
            return promise
        }
    }
}
