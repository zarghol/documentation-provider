//
//  RouteDocument.swift
//  econotouchWS
//
//  Created by Clément NONN on 29/07/2017.
//
//

import Vapor

public struct RouteDocumentation {
    public struct AdditionalInfos {
        var description: String
        var pathParameters: [String: String]
        var queryParameters: [String: String]
        
        var parametersRepresentation: NodeRepresentable {
            return [
                "path" : pathParameters.map { ["key": $0.key, "value": $0.value] },
                "query": queryParameters.map { ["key": $0.key, "value": $0.value] }
            ]
        }
        
        init(description: String, pathParameters: [String: String] = [:], queryParameters: [String: String] = [:]) {
            self.description = description
            self.pathParameters = pathParameters
            self.queryParameters = queryParameters
        }
    }
    
    let host: String
    let method: String
    let path: String
    var additionalInfos: AdditionalInfos
    
    var hasParameter: Bool {
        return additionalInfos.pathParameters.count > 0 || additionalInfos.queryParameters.count > 0
    }
}

extension RouteDocumentation {
    init(route: String) {
        let components = route.components(separatedBy: .whitespaces)
        let host = components[0]
        let method = components[1]
        let path = components[2]
        
        var pathParameters = [String: String]()
        for parameterName in RouteDocumentation.getPathParametersNames(for: path) {
            pathParameters[parameterName] = "no description"
        }

        self.host = host
        self.path = path
        self.method = method
        
        self.additionalInfos = AdditionalInfos(
            description: "no description",
            pathParameters: pathParameters,
            queryParameters: [String: String]()
        )
    }
    
    private static func getPathParametersNames(for path: String) -> [String] {
        var pathParametersComponents = path.components(separatedBy: ":")
        if pathParametersComponents.count > 1 {
            pathParametersComponents.remove(at: 0)
            let pathParametersNames = pathParametersComponents.flatMap { $0.components(separatedBy: "/").first }
            return pathParametersNames
        }
        return []
    }
}

extension RouteDocumentation: NodeRepresentable {
    public func makeNode(in context: Context?) throws -> Node {
        return try [
            "method": method,
            "path": path,
            "description": additionalInfos.description,
            "hasParameter": hasParameter,
            "parameters": additionalInfos.parametersRepresentation
        ].makeNode(in: context)

    }
}
