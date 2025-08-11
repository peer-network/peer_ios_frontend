//
//  FeedContentSorting.swift
//  FeedNew
//
//  Created by Artem Vasin on 17.03.25.
//

import SwiftUI
import GQLOperationsUser
import Models

@MainActor
public final class FeedContentSortingAndFiltering: ObservableObject {
    class Storage {
        @AppStorage("feed_sort_time") var sortByTime: FeedContentSortingByTime = .allTime
        @AppStorage("feed_sort_popularity") var sortByPopularity: FeedContentSortingByPopularity = .newest
        @AppStorage("feed_filter_relationship") var filterByRelationship: FeedFilterByRelationship = .all
    }

    public static let shared = FeedContentSortingAndFiltering()

    private let storage = Storage()

    @Published public var sortByTime: FeedContentSortingByTime {
        didSet {
            storage.sortByTime = sortByTime
        }
    }
    @Published public var sortByPopularity: FeedContentSortingByPopularity {
        didSet {
            storage.sortByPopularity = sortByPopularity
        }
    }
    @Published public var filterByRelationship: FeedFilterByRelationship {
        didSet {
            storage.filterByRelationship = filterByRelationship
        }
    }

    private init() {
        sortByTime = storage.sortByTime
        sortByPopularity = storage.sortByPopularity
        filterByRelationship = storage.filterByRelationship
    }
}
