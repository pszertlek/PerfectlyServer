//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

// An example request handler.
// This 'handler' function can be referenced directly in the configuration below.
func handler(request: HTTPRequest, response: HTTPResponse) {
	// Respond with a simple message.
    var string = "start:";
    if let accesptEncoding = request.header(.acceptEncoding) {
        string = string + accesptEncoding
    }
    let htmlString = "<html><title>Hello, world!</title><body>Hello, world!</body></html>"
    response.setHeader(.contentType, value: "application/json")
	response.appendBody(string: htmlString + string)
	// Ensure that response.completed() is called when your processing is done.
    let d: [String:Any] = ["a":1, "b":0.1,"c":true,"d":[2,3,4,3]]
    do {
        try response.setBody(json: d)
    } catch {
        
    }
	response.completed()
}

func sendImage(request: HTTPRequest, response: HTTPResponse) {
    let docRoot = request.documentRoot
    for (cookieName, cookieValue) in request.cookies {
        print("\(cookieName),\(cookieValue)")
    }
    let cookie = HTTPCookie(name: "cookie-name", value: "the value", domain: nil, expires: .session, path: "/", secure: false, httpOnly: false, sameSite: nil)
    response.addCookie(cookie)
    do {
        let mrPebbles = File("\(docRoot)/mr_pebbles.jpg")
        let imageSize = mrPebbles.size
        let imageBytes = try mrPebbles.readSomeBytes(count: imageSize)
        response.setHeader(.contentType, value: MimeType.forExtension("jpg"))
        response.setHeader(.contentLength, value: "\(imageBytes.count)")
        response.setBody(bytes: imageBytes)
    } catch {
        response.status = .internalServerError
        response.setBody(string: "Error handling request: \(error)")
    }
    response.completed()
}

// Configuration data for an example server.
// This example configuration shows how to launch a server
// using a configuration dictionary.


let confData = [
	"servers": [
		// Configuration data for one server which:
		//	* Serves the hello world message at <host>:<port>/
		//	* Serves static files out of the "./webroot"
		//		directory (which must be located in the current working directory).
		//	* Performs content compression on outgoing data when appropriate.
		[
			"name":"localhost",
			"port":8181,
			"routes":[
				["method":"get", "uri":"/", "handler":handler],
				["method":"get", "uri":"/**", "handler":PerfectHTTPServer.HTTPHandler.staticFiles,
				 "documentRoot":"./webroot",
				 "allowResponseFilters":true]
			],
			"filters":[
				[
				"type":"response",
				"priority":"high",
				"name":PerfectHTTPServer.HTTPFilter.contentCompression,
				]
			]
		]
	]
]

do {
	// Launch the servers based on the configuration data.
	try HTTPServer.launch(configurationData: confData)
} catch {
	fatalError("\(error)") // fatal error launching one of the servers
}

