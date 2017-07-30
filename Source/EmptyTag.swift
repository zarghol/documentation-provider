//
//  EmptyTag.swift
//  Checkout
//
//  Created by Clément Nonn on 15/12/2016.
//
//

import Foundation
import Vapor
import Leaf

class Empty: BasicTag {
    public enum Error: Swift.Error {
        case expected1Argument
    }
    
    let name = "empty"

    public func run(arguments: ArgumentList) throws -> Node? {
        guard arguments.count == 1 else { throw Error.expected1Argument }
        return nil
    }

    public func shouldRender(
        tagTemplate: TagTemplate,
        arguments: ArgumentList,
        value: Node?
    ) -> Bool {
        guard let arg = arguments.first else {
            return true
        }
        
        if let array = arg.array, array.count == 0 {
            return true
        }
        
        if let dico = arg.object, dico.count == 0 {
            return true
        }
        
        return arg.isNull
    }
}
//
//class NamedIndex: BasicTag {
//    let name = "namedIndex"
//
//    func run(arguments: [Argument]) throws -> Node? {
//        guard
//            arguments.count == 3,
//            let array = arguments[0].value?.nodeArray,
//            let index = arguments[1].value?.int,
//            let name = arguments[2].value?.string,
//            index < array.count
//            else { return nil }
//        return .object([name: array[index]])
//    }
//
//    public func render(
//        stem: Stem,
//        context: LeafContext,
//        value: Node?,
//        leaf: Leaf
//        ) throws -> Bytes {
//        guard let value = value else { fatalError("Value must not be nil") }
//        context.push(value)
//        let rendered = try stem.render(leaf, with: context)
//        context.pop()
//
//        return rendered + [.newLine]
//    }
//}
//
//class CountEqual: BasicTag {
//    let name = "countEqual"
//
//    func run(arguments: [Argument]) throws -> Node? {
//        guard arguments.count == 2,
//            let array = arguments[0].value?.nodeArray,
//            let expectedCount = arguments[1].value?.int,
//            array.count == expectedCount else {
//            return nil
//        }
//
//        return Node("ok")
//    }
//}

