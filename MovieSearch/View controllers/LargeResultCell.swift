//
//  LargeResultCell.swift
//  MovieSearch
//
//  Created by Fritz Anderson on 11/18/19.
//  Copyright © 2019 Fritz Anderson. All rights reserved.
//

import UIKit
import AlamofireImage

class LargeResultCell: UITableViewCell {
    static let cellIdentifier = "bigPosterCell"
    
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
    
    var representedSearchElement: SearchElement! {
        didSet {
            fillSubviews()
        }
    }
    
    var posterView: UIImageView? {
        return viewWithTag(CellViewTags.thumbnail.rawValue) as? UIImageView
    }
    
    lazy var afFilter: AspectScaledToFitSizeFilter! = {
        if let imageView = posterView {
            let roundedSize = imageView.bounds.size.integral
            let retval = AspectScaledToFitSizeFilter(size: roundedSize)
            return retval
        }
        return nil
    }()

    
    func fillSubviews() {
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
            if let rse = representedSearchElement {
                print(rse.title, rse.posterURLString )
            }
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
    
    func cancelImageLoad() {
        posterView?.af_cancelImageRequest()
        posterView?.layer.removeAllAnimations()
        posterView?.image = nil
    }
}
