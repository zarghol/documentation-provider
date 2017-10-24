//
//  DocumentatinProvider.swift
//  econotouchWS
//
//  Created by Clément NONN on 29/07/2017.
//
//

import Vapor
import LeafProvider

public final class Provider: Vapor.Provider {
    public enum Error: Swift.Error {
        case conflictingInfos(old: RouteDocumentation.AdditionalInfos, new: RouteDocumentation.AdditionalInfos)
    }
    
    /// The current provider initialized by the Droplet
    ///
    /// Use it for provide custom informations
    static public private(set)var current: Provider!
    
    public static let repositoryName = "documentation-provider"
    
    private(set) var infosProvider = [DocumentationInfoProvider.Type]()
    
    private let view = LeafRenderer(viewsDir: "/")
    
    let path: String
    
    private let logger: LogProtocol
    
    /// Register a Documentation Info Provider.
    public func provideInfo(_ provider: DocumentationInfoProvider.Type) {
        infosProvider.append(provider)
    }
    
    public init(config: Config) throws {
        self.logger = try config.resolveLog()
        
        guard let docConfig = config["doc"] else {
            throw ConfigError.missingFile("doc")
        }
        
        self.path = docConfig["path"]?.string ?? "docs"
        self.logger.enabled = docConfig["logLevels"]?.array?.flatMap({ $0.string }).map { LogLevel(strValue: $0) }
            ?? [.warning, .error, .fatal]

        Provider.current = self
        view.stem.register(Empty())
    }
    
    public func boot(_ config: Config) throws { }
    
    public func boot(_ droplet: Droplet) throws { }
    
    public func beforeRun(_ droplet: Droplet) throws {
        // Generate documentation
        let infos = try self.generateAdditionalInfos()

        var documentation = [RouteDocumentation]()
        for route in droplet.router.routes {
            // Initialize the doc with the path
            var doc = RouteDocumentation(route: route)
            // If additional infos provided for the route, we add it
            if let additionalInfos = infos[route] {
                doc.additionalInfos = additionalInfos
            }  else {
                droplet.log.info("[DocumentationProvider] No additional Info for route : '\(route)'")
            }
            documentation.append(doc)
        }
        
        // Sort the docs by path then by method
        documentation = documentation.sorted { (left, right) -> Bool in
            left.method < right.method
        }.sorted { (left, right) -> Bool in
            left.path < right.path
        }
        
        try registerController(documentation: documentation, droplet: droplet)
    }
    
    private func registerController(documentation: [RouteDocumentation], droplet: Droplet) throws {
        // use custom renderer if the app use a different one, and with directory for file in the package
        
        let documentationController = DocumentationController(documentation, renderer: view)
        
        try droplet.grouped(path).collection(documentationController)
    }
    
    private func generateAdditionalInfos() throws -> [String: RouteDocumentation.AdditionalInfos] {
        var infos = [String: RouteDocumentation.AdditionalInfos]()
        for type in infosProvider {
            try infos.merge(type.documentation, uniquingKeysWith: { (old, new) -> RouteDocumentation.AdditionalInfos in
                throw Error.conflictingInfos(old: old, new: new)
            })
        }
        return infos
    }
}

public protocol DocumentationInfoProvider {
    static var documentation: [String: RouteDocumentation.AdditionalInfos] { get }
}

