//
//  DocumentatinProvider.swift
//  econotouchWS
//
//  Created by Clément NONN on 29/07/2017.
//
//

import Vapor
import LeafProvider
import Console

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
    
    private let leafRenderer = LeafRenderer(viewsDir: "/")
    
    var view: DocumentationView
    
    let path: String
    
    private let logger: LogProtocol
        
    var hiddenRoute = [String]()
    
    /// Register a Documentation Info Provider.
    public func provideInfo(_ provider: DocumentationInfoProvider.Type) {
        infosProvider.append(provider)
        
        if let hider = provider as? DocumentationInfoHider.Type {
            self.hiddenRoute.append(contentsOf: hider.hiddenPath)
        }
    }
    
    public func hideRoute(_ route: String) {
        self.hiddenRoute.append(route)
    }
    
    public init(config: Config) throws {
        // Cannot resolve logger from config : log-console is not contained in Config.resolvable here...
        let console = try Terminal(config: config)
        self.logger = ConsoleLogger(console)
        
        self.path = config["doc", "path"]?.string ?? "docs"
        self.logger.enabled = config["doc", "logLevels"]?.array?.flatMap({ $0.string }).map { LogLevel(strValue: $0) }
            ?? [.warning, .error, .fatal]
        
        if let viewConfig = config["doc", "view"] {
            if let customPath = viewConfig["customPath"]?.string {
                view = .customPath(customPath)
            } else {
                let customCSS: DocumentationCSS
                if let customCSSContent = viewConfig["customCSS"]?.string {
                    customCSS = .custom(customCSSContent)
                } else {
                    customCSS = .basic
                }
                
                let customBody: DocumentationBody
                if let customBodyContent = viewConfig["customBody"]?.string {
                    customBody = .custom(customBodyContent)
                } else {
                    customBody = .basic
                }
                
                let customStructure: DocumentationStructure
                if let customStructureContent = viewConfig["customStructure"]?.string {
                    customStructure = .custom(customStructureContent)
                } else {
                    customStructure = .basic
                }
                
                view = .custom(structure: customStructure, body: customBody, css: customCSS)
            }
        } else {
            view = .basic
        }
        
        Provider.current = self
        leafRenderer.stem.register(Empty())
        self.logger.info("[DocumentationProvider] doc provider initialized")
    }
    
    public func boot(_ config: Config) throws { }
    
    public func boot(_ droplet: Droplet) throws { }
    
    public func beforeRun(_ droplet: Droplet) throws {
        // Generate documentation
        let infos = try self.generateAdditionalInfos()
        self.logger.info("[DocumentationProvider] infos generated")

        var documentation = [RouteDocumentation]()
        for route in droplet.router.routes where !self.hiddenRoute.contains(route) {
            // Initialize the doc with the path
            var doc = RouteDocumentation(route: route)
            // If additional infos provided for the route, we add it
            if let additionalInfos = infos[route] {
                doc.additionalInfos = additionalInfos
                self.logger.verbose("[DocumentationProvider] additional info added for '\(route)'")
            }  else {
                self.logger.warning("[DocumentationProvider] No additional Info for route : '\(route)'")
            }
            documentation.append(doc)
        }
        
        if self.logger.enabled.contains(.verbose) {
            for hidden in self.hiddenRoute {
                self.logger.verbose("[DocumentationProvider] Route '\(hidden)' is hidden")
            }
        }
        
        // Sort the docs by path then by method
        documentation = documentation.sorted { (left, right) -> Bool in
            left.method < right.method
        }.sorted { (left, right) -> Bool in
            left.path < right.path
        }
        
        self.logger.info("[DocumentationProvider] docs sorted")
        
        try registerController(documentation: documentation, droplet: droplet)
    }
    
    private func registerController(documentation: [RouteDocumentation], droplet: Droplet) throws {
        // use custom renderer if the app use a different one, and with directory for file in the package
        
        let documentationController = DocumentationController(documentation, renderer: leafRenderer, view: view)
        self.logger.info("[DocumentationProvider] controller created")
        
        try droplet.grouped(path).collection(documentationController)
        self.logger.info("[DocumentationProvider] controller added to the group : '\(path)'")
    }
    
    private func generateAdditionalInfos() throws -> [String: RouteDocumentation.AdditionalInfos] {
        var infos = [String: RouteDocumentation.AdditionalInfos]()
        for type in infosProvider {
            // Make sure there is only one documentation for one route
            try infos.merge(type.documentation, uniquingKeysWith: { (old, new) -> RouteDocumentation.AdditionalInfos in
                throw Error.conflictingInfos(old: old, new: new)
            })
        }
        return infos
    }
}

typealias DocumentationInfoManager = DocumentationInfoProvider & DocumentationInfoHider

public protocol DocumentationInfoProvider {
    static var documentation: [String: RouteDocumentation.AdditionalInfos] { get }
}

public protocol DocumentationInfoHider {
    static var hiddenPath: [String] { get }
}

