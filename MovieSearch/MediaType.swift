//
//  MediaType.swift
//  MovieSearch
//
//  Created by Fritz Anderson on 11/13/19.
//  Copyright © 2019 Fritz Anderson. All rights reserved.
//

import UIKit


enum MediaType: Int, CaseIterable, CustomStringConvertible {
    case movie, series, episode
    
    var description: String {
        switch self {
        case .movie:    return "Movie"
        case .series:   return "Series"
        case .episode:  return "Episode"
        }
    }
}


