//
//  ResultsController.swift
//  MovieSearch
//
//  Created by Fritz Anderson on 11/17/19.
//  Copyright © 2019 Fritz Anderson. All rights reserved.
//

import UIKit
import AlamofireImage


/// A table controller displaying the results of an OMDb query.
///
/// The `Query` pushed into `representedQuery` is converted into paginated subqueries.
/// The results of these are added to `contentItems`, an array of `SearchElement` results,
/// and in turn are displayed in the table.
/// - bug: Adding results is kind of jerky at the moment,
/// - bug: There is only one sort order supported.
/// - bug: The order is year > title; it'd be nice to turn that into a section dictionary.
class ResultsController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var contentItems: [SearchElement] = [] {
        didSet {
            self.tableView?.reloadData()
        }
    }
    
    #if DEBUG
    var listOfURLs: String {
        let listing = contentItems
            .map { $0.posterURLString }
            .sorted()
            .joined(separator: "\n")
        return listing
    }
    
    func printURLs() {
       // print(listOfURLs)
    }
    #endif
    
    /// The object that handles the fetch of a queery page
    private var loader: MovieLoader?
    
    /// The non-derived source of the contents of the view. Setting `representedQuery` truggers a data fetch and a table refresh.
    var representedQuery: Query? {
        didSet {
            guard let qry = representedQuery else {
                loader = nil
                return
            }
            loader = MovieLoader(query: qry)
            loader?.start()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNotifications()
        
        let nib = UINib(nibName: "LargeResultCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: LargeResultCell.cellIdentifier)
        
        // FIXME: Orphan notification handlers
        // On view did disappear: Remove the handlers
        // On did appear, reenable the handers _and_ ask the loader
        
        self.tableView.reloadData()
    }
    
    var notificationHandlers: [NSObjectProtocol] = []

}

// MARK: - Fetched results
extension ResultsController {
    
    /**
     Install notification handlers for
     
     The handlers respond to
     * arriving records
     * completion of the load
     * clearing the results list
     * reporting errors
     
     - bug: The handlers should be installed at did-show, and uninstalled at will-hide. (At did-show, the installer should check the loader to see whether it needs to catch up on records that had arrived in tthe mesn time.
 */
    func setNotifications() {
        // New records have arrived
        let arrived = NotificationCenter.default
            .addObserver(forName: MovieResultsArrived, object: nil, queue: .main) { notice in
                guard let loader = notice.object as? MovieLoader else {
                    fatalError()
                }
                self.contentItems = loader.searchResults
                    .sorted { (lhs, rhs) -> Bool in
                        if lhs.year > rhs.year { return true }
                        if lhs.year == rhs.year && lhs.title < rhs.title { return true }
                        return false
                    }
                self.title = "\(loader.initialCount) results"
        }
        
        /// All pages were retrieved successfully
        let completed = NotificationCenter.default
            .addObserver(forName: MovieFetchCompleted, object: nil, queue: .main) { notice in
                guard let loader = notice.object as? MovieLoader else {
                    fatalError()
                }

                #if DEBUG
                self.printURLs()
                #endif
                
                self.title = "\(self.contentItems.count) results"
                
                if loader.initialCount == 0 {
                    let alert = UIAlertController(title: "Done", message: "OMDb has no matching movies for you.", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default,
                                           handler: nil)
                    alert.addAction(ok)
                    self.present(alert,
                                 animated: true,
                             completion: nil)
                }
        }
        
        // Ignoring MovieFetchCompleted for now, all I'm doing is updating the listing as it comes in.
        
        // The loader cleared its contents.
        let cleared =  NotificationCenter.default
                   .addObserver(forName: MovieResultsCleared, object: nil, queue: .main) { _ in
                       self.contentItems = []
        }
        
        // An error has escaped the loader. Post an alert to describe it.
        let errored = NotificationCenter.default
            .addObserver(forName: MovieFetchFailed, object: nil, queue: .main) { notice in
                
                var title = "Sorry"
                var message = "An error has occurred in the loading of your movies. It was unexpected, so we can't tell you exactly why."
                
                if let error = notice.userInfo?[fetchErrorKey] as? Error {
                    title = "Error"
                    message = error.localizedDescription
                }
                
                message += "\n\nThe list shows you what the app got so far."
                
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default,
                                       handler: nil)
                alert.addAction(ok)
                self.present(alert,
                             animated: true,
                             completion: nil)
                self.contentItems = []
        }
        
        notificationHandlers = [arrived, completed, cleared, errored]
    }
    
    /// Remive the notification handlers installed by `setNotifications()`
    func removeNotifications() {
        for n in notificationHandlers {
            NotificationCenter.default.removeObserver(n)
        }
        notificationHandlers = []
    }
}

// MARK: - Table view injections
extension ResultsController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return contentItems.isEmpty ? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        assert(!contentItems.isEmpty)
        // FIXME: handles only the single-page case.
        return contentItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = contentItems[indexPath.row]
        
        let tvc = tableView
            .dequeueReusableCell(
                withIdentifier: LargeResultCell.cellIdentifier,
                for: indexPath)
        let cell = tvc as! LargeResultCell
        cell.representedSearchElement = item
        return cell
    }
    
}
