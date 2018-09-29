//
//  Constants.swift
//  HomeTask
//
//  Created by Hao Wu on 29/9/18.
//  Copyright © 2018 S&J. All rights reserved.
//

import Foundation

struct Constants {
    
    // MARK: NotificationKeys
    
    struct NotificationKeys {
        static let SignedIn = "onSignInCompleted"
    }
    
    // MARK: TasksFields, FamilyFields
    
    struct TasksFields {
        static let family = "family"
        static let title = "title"
        static let description = "description"
        static let assignee = "assignee"
        static let due = "due"
        static let imageUrl = "photoUrl"
    }
    
    struct FamilyFields {
        static let family = "family"
        static let name = "name"
    }
}
