//
//  VideoWatchingActivity.swift
//  WatchTogether
//
//  Created by Reid Ellis on 2025-03-15.
//

import SwiftUI
import GroupActivities

struct VideoWatchingActivity: GroupActivity {
    static let activityIdentifier = "tnir.ca.WatchTogether.watchTogether"
    
    var title: String {
        return "Watch Together"
    }
    
    // Required by the GroupActivity protocol
    var metadata: GroupActivityMetadata {
        get async {
            var metadata = GroupActivityMetadata()
            // Use a standard activity type
            metadata.type = .generic
            metadata.title = title
            metadata.supportsContinuationOnTV = true
            return metadata
        }
    }
}
