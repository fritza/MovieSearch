//
//  ViewController.swift
//  MovieSearch
//
//  Created by Fritz Anderson on 11/13/19.
//  Copyright © 2019 Fritz Anderson. All rights reserved.
//

import UIKit

class SearchState {
    var title: String?
    var mediaType: MovieTypes = .none
    var year: String?
    
    /// Whether the `year` is valid for a query.
    ///
    /// - returns: `true` if the year is absent or parses into an `Int` between 1850 and 2200.
    var yearIsValid: Bool {
        // Unselected year is valid
        guard let year = year else { return true }
        // FIXME: Cache the formatter.
        let formatter = NumberFormatter()
        guard let decoded = formatter.number(from: year) else {
            return false
        }
        return (1850...2200).contains(decoded.intValue)
    }
}

class FormController: UIViewController {
    // TODO: A state variable.
    // Maybe a class object
    
    var representedSearch = SearchState()

    @IBOutlet weak var queryTypeSelector: UISegmentedControl!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }

    @IBAction func unwindFromTypeSelection(sender: UIStoryboardSegue) {
        guard let pickerController = sender.source as? SelectTypeController else { fatalError() }
        representedSearch.mediaType = pickerController.representedTypes
        
        
    }
    
    // MARK: IBAction
    
    @IBAction func queryTypeChanged(_ sender: Any) {
    }
    
    @IBAction func doPickMedia(sender: UIButton) {
        
    }
    
    let pickMediaSegue = "pick media"
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segID = segue.identifier,
            segID == pickMediaSegue,
            let picker = segue.destination as? SelectTypeController {
            picker.representedTypes = representedSearch.mediaType
        }
    }
}

