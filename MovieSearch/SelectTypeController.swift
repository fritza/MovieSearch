//
//  SelectTypeController.swift
//  MovieSearch
//
//  Created by Fritz Anderson on 11/13/19.
//  Copyright © 2019 Fritz Anderson. All rights reserved.
//

import UIKit

struct MovieTypes: OptionSet {
    let rawValue: Int
    init(rawValue: Int) { self.rawValue = rawValue }
    
    static let none     = MovieTypes(rawValue: 0)
    static let movie    = MovieTypes(rawValue: 1)
    static let series   = MovieTypes(rawValue: 2)
    static let episode  = MovieTypes(rawValue: 4)
}

class SelectTypeController: UITableViewController {
    enum CellNumbers: Int, CaseIterable {
        case movie, series, episode
        
        var type: MovieTypes {
            switch self {
            case .movie:   return .movie
            case .series:  return .series
            case .episode: return .episode
            }
        }
        
        func cell(in controller: SelectTypeController) -> UITableViewCell? {
            return controller.allCells[rawValue]
        }
    }
    
    @IBOutlet weak var movieCell: UITableViewCell!
    @IBOutlet weak var seriesCell: UITableViewCell!
    @IBOutlet weak var episodeCell: UITableViewCell!
    
    lazy var allCells: [UITableViewCell] = {
        assert(movieCell != nil)
        return [movieCell, seriesCell, episodeCell]
    }()
    
    
    func syncToRepresented() {
        guard movieCell != nil else { return }
        for number in CellNumbers.allCases {
            number.cell(in: self)?.accessoryType =  representedTypes.contains(number.type) ? .checkmark : .none
        }
    }
    
    var representedTypes: MovieTypes = .none {
        didSet { syncToRepresented() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        syncToRepresented()
        title = "Result Types"
    }
    
    // MARK: - Table view data source
    // NOTE: These are ignored because it's a static table.
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Force-unwrap: a non-CellNumbers row is fatal.
        let rowType = CellNumbers(rawValue: indexPath.row)!
        let movieType = rowType.type
        
        if representedTypes.contains(movieType) {
            // mutating representedTypes re-syncs the checkmarks
            representedTypes.remove(movieType)
        }
        else {
            representedTypes.insert(movieType)
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
    
}
