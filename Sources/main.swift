import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

var accounts = Accounts()

accounts.addAccount(username:"cbcdiver", email:"c@d.com", password:"pencil99")
accounts.addAccount(username:"dogs", email:"a@b.com", password:"pencil99")

let server = HTTPServer()
server.serverPort = 8080
server.documentRoot = "webroot"

var routes = Routes()
//*************  /Invalid Paths *************
routes.add(method: .get, uris: ["/json","/json/username","/json/login/{username}","/json/login"]){
    request, response in
    do {
        try response.setBody(json: ["Result":"Error invalid URL path specified"])
        response.setHeader(.contentType, value: "application/json")
        response.completed()
        
    } catch {
        response.setBody(string: "Error handling request: \(error)")
        response.completed()
    }
}

//*************  /json/username/{username} *************
routes.add(method: .get, uri: "/json/username/{username}"){
    request, response in
    do {
        try response.setBody(json: accounts.username(username: request.urlVariables["username"]!))
        response.setHeader(.contentType, value: "application/json")
        response.completed()
        
    } catch {
        response.setBody(string: "Error handling request: \(error)")
        response.completed()
    }
}

//*************  /json/login/{username}/{password} *************
routes.add(method: .get, uri: "/json/login/{username}/{password}"){
    request, response in
    do {
        try response.setBody(json: accounts.loginValid(username: request.urlVariables["username"]!, password: request.urlVariables["password"]!))
        response.setHeader(.contentType, value: "application/json")
        response.completed()
        
    } catch {
        response.setBody(string: "Error handling request: \(error)")
        response.completed()
    }
}

//*************  /json/all *************
routes.add(method: .get, uri: "/json/all"){
    request, response in
    do {
        try response.setBody(json: accounts.dictionary)
        response.setHeader(.contentType, value: "application/json")
        response.completed()
        
    } catch {
        response.setBody(string: "Error handling request: \(error)")
        response.completed()
    }
}

//*************  /json/add *************
routes.add(method: .post, uri: "/json/add") { (request, response) in
    
    // First we extract the required fields from the parameters of this POST
    let username = request.param(name: "username")
    let email = request.param(name: "email")
    let password = request.param(name: "password")
    
    // We need to check for missing fields, so, let us keep an array of the names
    // of the fields which are missing
    var missingFields = [String]()
    
    // If a field is nil, we know it was not present in the POST, so add it to the
    // missing fields array
    if username == nil {
        missingFields.append("Username")
    }
    if ( email == nil ) {
        missingFields.append("Email")
    }
    if ( password == nil ) {
        missingFields.append("Password")
    }
    
    // If we have any missing fields, dump out a JSON string with a message
    // and return, we are done in this case
    if missingFields.count > 0 {
        do {
            try response.setBody(json: ["Result":"The following field(s) are missing: " +
                missingFields.joined(separator: ", ")])
            response.setHeader(.contentType, value: "application/json")
            response.completed()
        } catch {
            response.setBody(string: "Error Generating JSON response: \(error)")
            response.completed()
        }
        return
    }
    
    // Similar to missing fields, we have to check if our fields are in the correct format.
    // Use a bad formats array to track the fields that are not in the correct format
    var badFormats = [String]()
    
    // Using the .isValidName String extension, add the field to the bad format array, if the format
    // is not invalid
    if !(username?.isUserValid())! {
        badFormats.append("Username")
    }
    
    if !(email?.isUserValid())! {
        badFormats.append("Email")
    }
    
    if !(password?.isUserValid())! {
        badFormats.append("Password")
    }
    
    // If we have any badly formatted fields, dump out a JSON string with a message
    // and return, we are done in this case
    if badFormats.count > 0 {
        do {
            try response.setBody(json: ["Result":"The following field(s) are not in the correct format: " +
                badFormats.joined(separator: ", ")])
            response.setHeader(.contentType, value: "application/json")
            response.completed()
        } catch {
            response.setBody(string: "Error Generating JSON response: \(error)")
            response.completed()
        }
        return
    }
    
    // Since we made it here, we have all the fields, and, they are properly formatted, so, let's
    // add the new person to the people array and send a JSON result
    do {
        accounts.addAccount(username: username!, email: email!, password: password!)
        try response.setBody(json: ["Result":"true"])
        response.setHeader(.contentType, value: "application/json")
        response.completed()
    } catch {
        response.setBody(string: "Error Generating JSON response: \(error)")
        response.completed()
    }
}


server.addRoutes(routes)

do {
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}
