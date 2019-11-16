//: [Previous](@previous)

import Foundation

enum Constants {
    static let apiKey = "ef233be4"
    private static let _baseDataRequest = "http://www.omdbapi.com/?apikey={KEY}&"
    static var baseRequest: String = {
        return Constants._baseDataRequest.replacingOccurrences(of: "{KEY}", with: Constants.apiKey)
    }()
}


@dynamicMemberLookup
struct Query {
    static let validTags = [
        "s", "type", "y", "r", "page", "callback", "v"
    ]
    
    var parameters: [String:Any] = ["r": "json", "type": "movie"]
    
    subscript(dynamicMember name: String) -> Any? {
        get { return parameters[name] }
        set {
            precondition(Query.validTags.contains(name))
            var valueToUse = newValue
            if let nv = newValue as? NSString {
                valueToUse = nv.replacingOccurrences(of: " ", with: "+")
            }
            parameters[name] = valueToUse
        }
    }
    
    var isComplete: Bool {
        return self.s != nil
    }
    
    var asDictionary: [String:Any]? {
        return isComplete ? parameters : nil
    }
    
    var urlString: String? {
        guard let dictionary = asDictionary else { return nil }
        
        let urlParams = dictionary.map {
            pair in
            return "\(pair.0)=\(String(describing: pair.1))"
        }
        .joined(separator: "&")
        
        return Constants.baseRequest + urlParams
    }
    
    var url: URL? {
        guard let string = urlString else { return nil }
        return URL(string:string)
    }
}

var q = Query()
q.isComplete
q.s = "Sleeping with"
q.isComplete
q.type = "series"
q.r = "json"
q.y = 1992
q.z = 14

q.urlString

//: [Next](@next)
