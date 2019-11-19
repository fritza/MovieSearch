//
//  FormController.swift
//  MovieSearch
//
//  Created by Fritz Anderson on 11/13/19.
//  Copyright © 2019 Fritz Anderson. All rights reserved.
//

import UIKit
import Alamofire

// MARK: - SearchState

/// Represents the current values that go into an OMDb query: Title, type, and year.
///
/// It validates the content as suitable for transmission, and creates a `Query` to initialize a `ResultsController`..
final class SearchState {
    var title: String = ""
    var mediaType: MediaType = .movie
    var year: String = ""
    
    /// Whether the `year` is valid for a query.
    ///
    /// - returns: `true` if the year is absent or parses into an `Int` between 1850 and 2200.
    var yearIsValid: Bool {
        // Unselected year is valid
        if year.isEmpty { return true }
        // FIXME: Cache the formatter.
        guard let decoded = Constants.plainNumberFormatter.number(from: year) else {
            return false
        }
        return (1850...2200).contains(decoded.intValue)
    }
    
    /// Whether the year is blank/in-range, and the title long enough to be worth searching for.
    var canAllowSearching: Bool {
        return yearIsValid && title.count > 3
    }
    
    /// Return all properties ot default (blank, and year 2000)
    func reset() {
        title = ""
        mediaType = .movie
        year = "2000"
    }
    
    /// The state of the search criteria, expressed as an OMDb query
    var query: Query? {
        guard canAllowSearching else { return nil }
        var retval = Query()
        (retval.s, retval.y, retval.type) = (title, year, mediaType.description)
        return retval
    }
    
    /// The URL derived from the search criteria.
    var queryURL: URL? {
        return query?.url
    }
}

// MARK: - FormController
class FormController: UIViewController {
    // MARK: IBOutlet
    @IBOutlet weak var mediaTypeSelector: UISegmentedControl!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var yearField: UITextField!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    var representedSearch = SearchState()

    // MARK: Populating controls
    
    private func enableSearchButton() {
        searchButton.isEnabled = representedSearch.canAllowSearching
    }
    
    private func resetViews() {
        representedSearch.reset()
        refreshViews()
    }
    
    private func refreshViews() {
        // No views yet? Don't refresh them.
        if mediaTypeSelector == nil { return }
        titleField.text = representedSearch.title
        yearField.text = representedSearch.year
        mediaTypeSelector.selectedSegmentIndex = representedSearch.mediaType.rawValue
        enableSearchButton()
    }
            
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        refreshViews()
    }
    
    // MARK: IBAction
    
    /// Respond to the segmented control by noiting the selected `MediaType`
    @IBAction func queryTypeChanged(_ sender: UISegmentedControl) {
        representedSearch.mediaType = MediaType(rawValue: sender.selectedSegmentIndex)!
    }
    
    /// The **Clear** button
    @IBAction func clearTapped(_ sender: Any) {
        resetViews()
    }
    
    enum Segues: String {
        case toResults = "show results table"
    }
    
    /// Initialize the destinations of the segues out of the view.
    ///
    /// For now, there’s only one: feed `representedSearch.query` to the destination `ResultsController`, which will execute the query and display the results.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier,
            let segueType = Segues(rawValue: id) else {
                fatalError(#function + " Unexpected segue: \(segue.identifier ?? "NONE")")
        }
        switch segueType {
        case .toResults:
            guard let dest = segue.destination as? ResultsController
            else {
                fatalError(#function + " Segue: \(segue.identifier!) was for the wrong destination type.")
            }
            guard let query = representedSearch.query else {
                    fatalError(#function + " Segue: \(segue.identifier!) was hit without a valid query URL.")
            }
            dest.representedQuery = query
        }
    }
}

// MARK: - Text field delegate
extension FormController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == titleField {
            return titleFieldShouldChange(range: range, replacementString: string)
        }
        else if textField == yearField {
            return yearFieldShouldChange(range: range, replacementString: string)
        }
        else { fatalError("Got a delegate call from an unknown field") }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField == titleField {
            representedSearch.title = ""
        }
        else if textField == yearField {
            representedSearch.year = ""
        }
        else { fatalError("Got a delegate call from an unknown field") }
        enableSearchButton()

        return true
    }

    /// Examine a proposed edit to the title field and (always) approve it.
    ///
    /// The purpose is to keep the `representedSearch` and the **Search** button current.
    func titleFieldShouldChange(range: NSRange, replacementString string: String) -> Bool {
        representedSearch.title = titleField
            .contentReplacing(range: range, with: string)
        enableSearchButton()    // FIXME: Appends CR
        return true
    }
    
    /// Examine a proposed edit to the title field and approve numeric changes only
    ///
    /// The purpose is to keep the `representedSearch` and the **Search** button current.
    func yearFieldShouldChange(range: NSRange,
                               replacementString string: String) -> Bool {
        if let ch = string.first,
            !"0123456789".contains(ch) {
                return false
        }
        representedSearch.year = yearField
            .contentReplacing(range: range, with: string)
        enableSearchButton()
        return true
    }
}

// MARK: - UITextField
extension UITextField {
    /// The results of replacing a range in a text field's content with a substitute string.
    /// - Parameters:
    ///   - range: The `NSRange` to be replaced from the field's `text`.
    ///   - str: The `String` to substitute into that range.
    func contentReplacing(range: NSRange, with str: String) -> String {
        let content = (text ?? "") as NSString
        let newContent = content.replacingCharacters(in: range, with: str)
        return newContent
    }
}
