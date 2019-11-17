//: [Previous](@previous)

import Foundation


struct RatingItem: Decodable {
    let source: String
    let value: String
}

struct ExtendedInfo: Decodable {
    var title: String // Title
    var year: Int // Year
    var rated: String // Rated
    var released: String // Released    // Apparently dd MMM yyyy <- check M with the Unicode site, it's tricky
    var runtime: String // Runtime        // Can this be parsed from "103 min" to a Measurement? DON'T
    var genre: String // Genre            // CSV, delimiter: ", "
    var director: String // Director    // probably CSV, delimiter: ", "
    var writer: String // Writer    // probably CSV, delimiter: ", "
    var actors: String // Actors    // probably CSV, delimiter: ", "
    var plot: String // Plot - text
    var language: String // Language
    var country: String // Country
    var awards: String // Awards - do not parse
    var poster: String // Poster -> computed var yielding String -> URL?
    var ratings: [RatingItem]
    // IMDB content:
    var metascore: String // Metascore
    var imdbRating: String // imdbRating
    var imdbVotes: String // imdbVotes
    var imdbID: String // imdbID
    
    var type: String // Type - maybe. provide a computed var for the MediaType enum
    var dVD: String // DVD
    var boxOffice: String // BoxOffice
    var production: String // Production
    var website: String // Website
    var response: String // Response
}

struct ResponsePacket: Decodable {
    let search: [ExtendedInfo]
    let totalResults: Int
    let response: Bool
}

let formatter: NumberFormatter = {
    let retval = NumberFormatter()
    return retval
}()

func numberOrZero(from str: String) -> Int {
    return formatter.number(from: str)?.intValue ?? 0
}

struct SearchElement: Decodable {
    let title: String // "Title"
    let _year: String      // "Year" -> reported as String
    let imdbID: String
    let type: String // "Type"
    let posterURLString: String // "Poster"
    
    var year: Int {
        return numberOrZero(from: _year)
    }
    
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case _year = "Year"
        case imdbID
        case type = "Type"
        case posterURLString = "Poster"
    }
}

struct SearchResponse: Decodable {
    var search: [SearchElement]    // "Search"
    let _totalResults: String
    let _response: String // key is "Response"
    
    var totalResults: Int { return numberOrZero(from: _totalResults) }
    var response: Bool { return _response.lowercased().hasPrefix("t") }
    
    enum CodingKeys: String, CodingKey {
        case search = "Search"
        case _totalResults = "totalResults"
        case _response = "Response"
    }
}



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
q.s = "Sleeping with the enemy"
q.isComplete
q.r = "json"

let url = q.url!
let request = URLRequest(url: url)
let session = URLSession(configuration: .default)
let task = session.dataTask(with: url) { (data, response, error) in
    if let error = error {
        print("Error!", error)
        return
    }
    if let data = data {
        guard let str = String(data: data, encoding: .utf8) else {
            print("didn't decode?")
            return
        }
        
        let decoder = JSONDecoder()
        do {
            let result = try decoder.decode(SearchResponse.self, from: data)
            print("result count =", result.totalResults, "\t",
                "response is \(result.response)")
            dump(result)
        }
        catch {
            print("Didn't decode:", error)
        }
    }
}
task.resume()

//: [Next](@next)
