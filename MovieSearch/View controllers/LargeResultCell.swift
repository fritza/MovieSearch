//
//  LargeResultCell.swift
//  MovieSearch
//
//  Created by Fritz Anderson on 11/18/19.
//  Copyright © 2019 Fritz Anderson. All rights reserved.
//

import UIKit
import AlamofireImage

/// A table-view cell specialized to display the summary of an OMDb record.
///
/// The available data are the title, yar, and poster image. The current `.xib` and the outlets here hoped for more.
final class LargeResultCell: UITableViewCell {
    static let cellIdentifier = "bigPosterCell"
    
    /// The `UIView` tags on the labels and image view within the cell.
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
    
    /// The `SearchElement` representing a single item in the results of a search.``
    var representedSearchElement: SearchElement! {
        didSet {
            fillSubviews()
        }
    }
    
    /// Convenience accessor to the `UIImageView` that is to contain the poster image
    private var posterView: UIImageView? {
        return viewWithTag(CellViewTags.thumbnail.rawValue) as? UIImageView
    }
    
    /// The `AlamoFireImage` filter that aspect-fits the poster to the size of the image view.
    private lazy var afFilter: AspectScaledToFitSizeFilter! = {
        if let imageView = posterView {
            let roundedSize = imageView.bounds.size.integral
            let retval = AspectScaledToFitSizeFilter(size: roundedSize)
            return retval
        }
        return nil
    }()

    /// Distribute the data in `representedSearchElement` to the subviews of the cell.
    ///
    /// It's acceptable if `representedSearchElement` is `nil`, as that blanks-out the labels, and the `func` is smart enough to stuff a placeholder into the image view.``
    private func fillSubviews() {
        if viewWithTag(1) == nil { return }
        
        func fillLLabel(_ tag: CellViewTags, with str: String?) {
            assert(CellViewTags.labelTags.contains(tag),
                   "Attempt to set text (\(str ?? "nil")) of a non-label subview (\(tag.rawValue))")
            guard let label = viewWithTag(tag.rawValue) as? UILabel else { preconditionFailure() }
            label.text = str
        }
        
//        cancelImageLoad()
        
        fillLLabel(.title, with: representedSearchElement?.title)
        fillLLabel(.year, with: representedSearchElement?._year)
        fillLLabel(.rating, with: representedSearchElement?.imdbID)
        fillLLabel(.helpfulInfo, with: "For rent.")
        
        if let url = representedSearchElement?.posterURL,
            let imageView = posterView {            
            imageView.af_setImage(
                withURL: url,
                // FIXME: Magic string
                placeholderImage: UIImage(named: "missing film"),
                filter: afFilter
            )
        }
        else {
            #if DEBUG
            if let rse = representedSearchElement {
                print(rse.title, rse.posterURLString )
            }
            #endif
            posterView?.image = UIImage(named: "missing film")
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        fillSubviews()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
//        posterView?.image = nil
        cancelImageLoad()
    }
    
    /// Tells the `posterView` image view to stop loading the current content and make ready for a new image.
    private func cancelImageLoad() {
        posterView?.af_cancelImageRequest()
        posterView?.layer.removeAllAnimations()
        posterView?.image = nil
    }
}
