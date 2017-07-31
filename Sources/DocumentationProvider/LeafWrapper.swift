//
//  LeafWrapper.swift
//  DocumentationProvider
//
//  Created by Clément NONN on 30/07/2017.
//

// This is a workaround for embedding the resources in the library

let cssContent = """
    /** Regular */
    @font-face {
        font-family: "San Francisco";
        font-weight: 200;
        src: url("https://applesocial.s3.amazonaws.com/assets/styles/fonts/sanfrancisco/sanfranciscodisplay-thin-webfont.woff");
    }
    @font-face {
        font-family: "SF Mono";
        font-weight: 200;
        src: url("SFMono-Regular.otf");
    }

    * {
        box-sizing: border-box;
    }

    body, html {
        padding: 0;
        margin: 0;
        height: 100%;
    }

    #droplet {
        width: 50px;
        display: inline-block;
        margin-right: 12px;
        float: left;
    }

    .vapor {
        font-weight: 500;
        font-size: 38px;
        vertical-align: middle;
        font-family: 'Quicksand';
    }

    h1, h2, h3, h4 {
        font-family: -apple-system-headline, "San Franscisco", "Helvetica Neue-Light", "Helvetica Neue Light", "Helvetica Neue", Helvetica, Arial, "Lucida Grande", sans-serif;
    }

    .code {
        font-family: "SF Mono", -apple-system-body, "San Franscisco", "Helvetica Neue-Light", "Helvetica Neue Light", "Helvetica Neue", Helvetica, Arial, "Lucida Grande", sans-serif;
    }

    body {
        font-family: -apple-system-body, "San Franscisco", "Helvetica Neue-Light", "Helvetica Neue Light", "Helvetica Neue", Helvetica, Arial, "Lucida Grande", sans-serif;
        background-image: -webkit-linear-gradient(top, #92a8d1 20%, #f6cbca 100%);
        background-color: black;
        background-repeat: no-repeat;
        background-attachment: fixed;
        position: relative;
    }

    .panel {
        background-color: rgb(255, 255, 255);
        background-color: rgba(255, 255, 255, 0.5);
        width: 60%;
        margin: auto;
        margin-top: 20px;
        margin-bottom: 20px;
        padding: 20px;
        float: center;
    }

    header {
        width: 100%;
        padding: 10px;
        height: 80px;
        background-color: rgba(255, 255, 255, 0.7);
    }

    footer {
        width: 100%;
        position:absolute;
        padding: 10px;
        text-align: right;
        background-color: rgba(255, 255, 255, 0.7);
    }

    a {
        text-decoration: none;
    }

    .title {
        text-align: center;
        font-size: 42px;
        vertical-align: middle;
    }
"""

var leafContent = """
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8" />
        <title>#(title)</title>
        <link href="https://fonts.googleapis.com/css?family=Quicksand:400,700,300" rel="stylesheet">
        <style>#raw() { \(cssContent) }</style>
        <meta name="viewport" content="user-scalable=no, initial-scale = 1, minimum-scale = 1, maximum-scale = 1, width=device-width">
    </head>
    <body>
        <header>
        #raw() {
            <svg xmlns="http://www.w3.org/2000/svg" x="0px" y="0px" viewBox="0 -5 48 60" enable-background="new 0 0 48 48" xml:space="preserve" id="droplet">
                <defs>
                    <linearGradient id="linear" x1="0%" y1="0%" x2="0%" y2="100%">
                        <stop offset="0%"   stop-color="#F7CAC9"/>
                        <stop offset="100%" stop-color="#92A8D1"/>
                    </linearGradient>
                </defs>
                <path stroke="url(#linear)" fill="white" fill-opacity="0" stroke-width="3" d="M24.8,0.9c-0.4-0.5-1.2-0.5-1.6,0C19.8,5.3,7.1,22.5,7.1,30.6c0,9.3,7.6,16.9,16.9,16.9s16.9-7.6,16.9-16.9  C40.9,22.5,28.2,5.3,24.8,0.9z"/>
            </svg>
            <span class="title">Documentation</span>
        }
        </header>
        <div class="panel">
            <h2>API v1</h2>
            #loop(definitions, "definition") {
                <p>
                    <h3>#(definition.method) - <span class="code"> #(definition.path)</span></h3>
                    #(definition.description)<br/>
                    #if(definition.hasParameter) {
                        #empty(definition.parameters.path) {
                        } ##else() {
                            <h4>Path Parameters</h4>
                            #loop(definition.parameters.path, "parameter") {
                                <span class="code"> #(parameter.key) </span> : #(parameter.value)<br/>
                            }
                        }
                        #empty(definition.parameters.query) {
                        } ##else() {
                            <br/>
                            <h4>Query Parameters</h4>
                            #loop(definition.parameters.query, "parameter") {
                                <span class="code"> #(parameter.key) </span> : #(parameter.value)<br/>
                            }
                        }
                    }
                </p>
                <hr/>
            }
        </div>
        <footer>
            HTML powered by <a href="https://github.com/vapor/leaf">🍃Leaf</a>.
        </footer>
    </body>
    </html>
"""
