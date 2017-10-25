# Documentation Provider

<a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License"></a>
<a href="https://swift.org"><img src="https://img.shields.io/badge/swift-4.0-brightgreen.svg" alt="Swift 4.0"></a>
<a href="https://circleci.com/gh/zarghol/documentation-provider/tree/master"><img src="https://circleci.com/gh/zarghol/documentation-provider/tree/master.svg?style=svg" alt="CircleCI"></a>

Allows you to build a documentation page for all your services served via the droplet.
The page is rendered via Leaf.

## Getting Started

1. Add the provider to your droplet.

       import DocumentationProvider
       //...
       try addProvider(DocumentationProvider.Provider.self)

   A new route is now created at **/docs**.
   By default, the documentation displays all routes of the droplet.

2. *(optional)* You can use a config file for some changes.

 Here is the configurations available :
 - The path of the doc. Key : `path`. Default value : `/docs`
 - The log levels used only this provider (allows you to use another set of your application). Key: `logLevels`. Default value : `["WARNING", "ERROR", "FATAL"]` Others values available : `"VERBOSE", "DEBUG", "INFO"`

3. *(optional)* Provide additional informations to display, or hide some routes.

    Implement the protocol `DocumentationInfoProvider` and pass it to the `DocumentationProvider`.
    You can also implement `DocumentationInfoHider` separately, on combine them with `DocumentationInfoManager`.

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
        
        extension SomeController: DocumentationInfoHider {
          static var hiddenPath: [String] {
            return ["* GET some/path"]
          }
        }
        // ...
        // at route time or any other moment before running
        DocumentationProvider.Provider.current.provideInfo(SomeController.self)

4. That's it ! 🎉🎉

## TODO

- [x] Add Unit Test (and maybe circleCI)
- [x] Parameterized the route
- [x] Parameterized the log level for warning about the infos providers
- [x] Allow to hide some routes to not display it on the page
- [ ] Allow to use a custom css ? Or at least a custom leaf template, and document the provided context

## Contribute

Feel free to send PR, or add enhancement ideas with issues !
