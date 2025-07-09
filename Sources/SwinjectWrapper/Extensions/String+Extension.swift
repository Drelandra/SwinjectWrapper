//
//  File.swift
//  
//
//  Created by Andre Elandra on 04/05/24.
//

import Foundation

extension String: @retroactive LocalizedError {
    public var errorDescription: String? { return self }
}
