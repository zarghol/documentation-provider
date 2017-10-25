//
//  DocumentationView.swift
//  DocumentationProvider
//
//  Created by clement on 25/10/2017.
//


import Vapor
import LeafProvider

enum DocumentationCSS {
    case basic
    case custom(String)
    
    var content: String {
        switch self {
        case .basic:
            return cssContent
            
        case .custom(let customString):
            return customString
        }
    }
}

enum DocumentationBody {
    case basic
    case custom(String)
    
    var content: String {
        switch self {
        case .basic:
            return docsBody
            
        case .custom(let customString):
            return customString
        }
    }
}

enum DocumentationStructure {
    case basic
    case custom(String)
    
    var content: String {
        switch self {
        case .basic:
            return structure
            
        case .custom(let customString):
            return customString
        }
    }
}

enum DocumentationView {
    case customPath(String)
    case basic
    case custom(structure: DocumentationStructure, body: DocumentationBody, css: DocumentationCSS)
    
    func render(with renderer: LeafRenderer, context: NodeRepresentable, for request: Request) throws -> ResponseRepresentable {
        switch self {
        case .basic:
            let content = self.documentationPage(structure: .basic, css: .basic, body: .basic)
            return try renderer.make(content: content, context, for: request)
            
        case .custom(let customContent, let customBody, let customCSS):
            let content = self.documentationPage(structure: customContent, css: customCSS, body: customBody)
            return try renderer.make(content: content, context, for: request)
            
        case .customPath(let path):
            return try renderer.make(path, context, for: request)
        }
    }

    private func documentationPage(structure: DocumentationStructure, css: DocumentationCSS, body: DocumentationBody) -> String {
        return String(format: structure.content, css.content, body.content)
    }
}
