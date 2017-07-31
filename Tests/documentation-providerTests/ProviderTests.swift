//
//  ProviderTests.swift
//  DocumentationProvider
//
//  Created by Clément NONN on 31/07/2017.
//

import XCTest
import Vapor
import HTTP
@testable import DocumentationProvider

class ProviderTests: XCTestCase {
    static let allTests = [
        ("testProvider", testProvider)
    ]
    
    func testProvider() throws {
        let config = Config([:])
        try config.addProvider(Provider.self)
        let droplet = try Droplet(config: config)
        XCTAssertNotNil(Provider.current, "provider not initialized")
        
        droplet.get("test1") { req in
            return Response(status: .ok)
        }
        try Provider.current.beforeRun(droplet)
        
        let resp = {
            return try droplet.router.respond(to: Request(method: .get, uri: "/docs"))
        }
        XCTAssertNoThrow(try resp(), "droplet doesn't respond to docs")
        
        let response = try resp()
        
        XCTAssertEqual(response.status, .ok, "bad status")
        
        
    }
}
