//
//  URLResponseExtensions.swift
//  Wolt
//
//  Created by Awais Akram on 7.7.2024.
//

import Foundation

extension URLResponse {
    
    var httpStatusCode: Int? {
        (self as? HTTPURLResponse)?.statusCode
    }
    
    func isHttpStatusCode(in range: Range<Int>) -> Bool {
        guard let code = httpStatusCode else { return false }
        return range.contains(code)
    }
    
    func isHttpStatusCode(in range: ClosedRange<Int>) -> Bool {
        guard let code = httpStatusCode else { return false }
        return range.contains(code)
    }
    
    func isHttpStatusCode(in array: [Int]) -> Bool {
        guard let code = httpStatusCode else { return false }
        return array.contains(code)
    }
}


