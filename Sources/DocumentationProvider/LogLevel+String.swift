//
//  LogLevel+String.swift
//  DocumentationProvider
//
//  Created by clement on 24/10/2017.
//

import Vapor

extension LogLevel {
    init(strValue: String) {
        for available in LogLevel.all {
            if strValue == available.description {
                self = available
                return
            }
        }
        
        self = .custom(strValue)
    }
}
