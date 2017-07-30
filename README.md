# Documentation Provider 

<a href="LICENSE"><img src="http://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License"></a>
<a href="https://swift.org"><img src="http://img.shields.io/badge/swift-3.1-brightgreen.svg" alt="Swift 3.1"></a>

Allows you to build a documentation page for all your services served via the droplet.
The page is rendered via Leaf.

## Getting Started

1. Add the provider to your droplet.
       import DocumentationProvider
       //...
       try addProvider(DocumentationProvider.Provider.self)
   A new route is now created at **/docs**.
   By default, the documentation displays all routes of the droplet.
2. *(optional)* Provide additional informations to display.

    Implement the protocol `DocumentationInfoProvider` and pass it to the `DocumentationProvider`.

        struct SomeController: DocumentationInfoProvider {
          static var documentation: [String: RouteDocumentation.AdditionalInfos] { 
            return [
              "* POST path/:pathParameter": RouteDocumentation.AdditionalInfos(
                  description: "The Description of the service",
                  pathParameters: ["pathParameter" : "Description of the parameter"],
                  queryParameters: ["queryParameter": "Description of the parameter"]
              ),
              "* GET other": RouteDocumentation.AdditionalInfos(
                  description: "The Description of the service"
              )
            ]
          }
        }
        // ...
        // at route time or any other moment
        DocumentationProvider.Provider.current.provideInfo(SomeController.self)
    
3. That's it ! 🎉🎉

## TODO

- [ ] Parameterized the route
- [ ] Parameterized the log level for warning about the infos providers
- [ ] allow to hide some routes to not display it on the page

## Contribute

Feel free to send PR, or add enhancement ideas with issues !
