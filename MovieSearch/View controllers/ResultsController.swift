//
//  ResultsController.swift
//  MovieSearch
//
//  Created by Fritz Anderson on 11/17/19.
//  Copyright © 2019 Fritz Anderson. All rights reserved.
//

import UIKit
import AlamofireImage



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
    
    var loader: MovieLoader?
    
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
    
    func setNotifications() {
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
        let cleared =  NotificationCenter.default
                   .addObserver(forName: MovieResultsCleared, object: nil, queue: .main) { _ in
                       self.contentItems = []
        }
        
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
    
    func removeNotifications() {
        for n in notificationHandlers {
            NotificationCenter.default.removeObserver(n)
        }
        notificationHandlers = []
    }
}

// MARK: - Table view injections
extension ResultsController: UITableViewDelegate, UITableViewDataSource {
//    static let cellIdentifier = "simpleListingCell"
    static let cellIdentifier = "bigPosterListingCell"
    
    enum CellViewTags: Int {
        case title = 1
        case year
        case rating
        case helpfulInfo
        case thumbnail = 100
        
        static var labelTags: Set<CellViewTags> = {
            return Set([.title, .year, .rating, .helpfulInfo])
        }()
    }
    
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

/*
 override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
 
 // Configure the cell...
 
 return cell
 }
 */

/*
 // Override to support conditional editing of the table view.
 override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
 // Return false if you do not want the specified item to be editable.
 return true
 }
 */

/*
 // Override to support editing the table view.
 override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
 if editingStyle == .delete {
 // Delete the row from the data source
 tableView.deleteRows(at: [indexPath], with: .fade)
 } else if editingStyle == .insert {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
 
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
 // Return false if you do not want the item to be re-orderable.
 return true
 }
 */

/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */
