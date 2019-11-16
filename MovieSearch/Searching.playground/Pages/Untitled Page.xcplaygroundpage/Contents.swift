import Foundation

let plistURL = Bundle.main.url(forResource: "QueryParameters", withExtension: "plist")!
let plistData = try! Data(contentsOf: plistURL)
let pldict = NSDictionary(contentsOf: plistURL) as! [String:Any]
let searchDict = pldict["search"] as! [[String:Any]]

struct FieldSpec: Codable, CustomStringConvertible {
    let parameter: String
    let required: Bool
    let options: [String]
    let defaultValue: String
    let notes: String
    
    var description: String {
        var accum = "\(notes) (\(parameter))"
        if required { print(" REQUIRED", terminator: "", to: &accum) }
        if options.count > 0 {
            let optString = options.joined(separator: ", ")
            print(" [ \(optString) ]", terminator: "", to: &accum)
        }
        return accum
    }
    
    func valueIsValid(_ value: String?) -> Bool {
        guard let unwrappedValue = value else {
            return !required
        }
        if options.isEmpty { return true }
        return options.contains(unwrappedValue)
    }
}

struct Params: Codable {
    let title: [FieldSpec]
    func titleParameter(_ tag: String) -> FieldSpec? {
        return title.first { $0.parameter == tag }
    }
    
    let search: [FieldSpec]
    func searchParameter(_ tag: String) -> FieldSpec? {
        return search.first { $0.parameter == tag }
    }
}

let plistCoder = PropertyListDecoder()
do {
    let decodedParams = try plistCoder.decode(Params.self, from: plistData)
    
    //    let searchParams = decodedParams.search
    if let searchSpec = decodedParams.searchParameter("r") {
        print(searchSpec)
        searchSpec.valueIsValid(nil)
        searchSpec.valueIsValid("")
        searchSpec.valueIsValid("json")
        searchSpec.valueIsValid("series")
    }
}
catch {
    print("Failed to decode:", error)
}



