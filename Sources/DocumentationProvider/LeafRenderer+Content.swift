//
//  LeafRenderer+Content.swift
//  DocumentationProvider
//
//  Created by Clément NONN on 30/07/2017.
//

import Vapor
import LeafProvider
import Leaf

extension LeafRenderer {
    public func make(content: String, _ context: NodeRepresentable, for request: Request) throws -> View {
        var context = try context.makeNode(in: ViewContext.shared)
        try context.set("request", request)
        return try make(content: content, context)
    }
    
    public func make(content: String, _ node: Node) throws -> View {
        return try self.make(content: content, LeafContext(node))
    }
    
    public func make(content: String, _ context: LeafContext) throws -> View {
        let leaf = try stem.spawnLeaf(raw: content)
        let bytes = try stem.render(leaf, with: context)
        return View(data: bytes)
    }
}
