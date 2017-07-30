//
//  DocumentationController.swift
//  App
//
//  Created by Clément NONN on 30/07/2017.
//

import Vapor

final class DocumentationController {
    let docs: [RouteDocumentation]
    let renderer: ViewRenderer
    
    init(_ documentation: [RouteDocumentation], renderer: ViewRenderer) {
        self.docs = documentation
        self.renderer = renderer
    }
    
    func index(req: Request) throws -> ResponseRepresentable {
        return try renderer.make("doc.leaf", ["definitions": docs], for: req)
    }
}

extension DocumentationController: RouteCollection {
    func build(_ builder: RouteBuilder) throws {
        builder.get(handler: self.index)
    }
}
