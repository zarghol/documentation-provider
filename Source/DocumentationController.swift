//
//  DocumentationController.swift
//  App
//
//  Created by Clément NONN on 30/07/2017.
//

import Vapor
import LeafProvider

final class DocumentationController {
    let docs: [RouteDocumentation]
    let renderer: ViewRenderer
    
    init(_ documentation: [RouteDocumentation], renderer: ViewRenderer) {
        self.docs = documentation
        self.renderer = renderer
    }
    
    func index(req: Request) throws -> ResponseRepresentable {
        let context: NodeRepresentable = ["definitions": docs]
        guard let renderer = renderer as? LeafRenderer else {
            return try self.renderer.make("doc", context, for: req)
        }
        return try renderer.make(content: leafContent, context, for: req)
    }
}

extension DocumentationController: RouteCollection {
    func build(_ builder: RouteBuilder) throws {
        builder.get(handler: self.index)
    }
}
