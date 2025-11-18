//
//  AdHistoryViewModel.swift
//  Environment
//
//  Created by Artem Vasin on 04.11.25.
//

import Combine
import Models

@MainActor
public final class AdHistoryViewModel: ObservableObject {
    public enum PageState {
        case loading
        case display(stats: AdsStats)
        case error(error: APIError)
    }

    @Published public private(set) var state: PageState = .loading

    @Published public private(set) var ads: [SingleAdStats] = []
    @Published public private(set) var stats: AdsStats? = nil

    private var currentOffset: Int = 0
    @Published public private(set) var hasMoreAds: Bool = true

    private var fetchAdsStatsTask: Task<Void, Never>?
    private var fetchAdsListTask: Task<Void, Never>?

    private let apiService: APIService

    public init(apiService: APIService) {
        self.apiService = apiService
    }

    public func loadStats() {
        if let existingTask = fetchAdsStatsTask, !existingTask.isCancelled {
            return
        }

        fetchAdsStatsTask = Task {
            do {
                let result = await apiService.getAdsHistoryStats(userID: AccountManager.shared.userId!)

                try Task.checkCancellation()

                switch result {
                    case .success(let stats):
                        self.stats = stats
                        state = .display(stats: stats)
                    case .failure(let apiError):
                        throw apiError
                }
            } catch is CancellationError {
            } catch {
                state = .error(error: error as! APIError)
            }

            fetchAdsStatsTask = nil
        }
    }

    public func loadAds(reset: Bool) {
        if let existingTask = fetchAdsListTask, !existingTask.isCancelled {
            if reset {
                // Cancel and start a fresh fetch for reset scenarios
                existingTask.cancel()
            } else {
                // Do not run a new task if there is already a task running
                return
            }
        }

        if reset {
            if ads.isEmpty {
                state = .loading
            }

            currentOffset = 0
            hasMoreAds = true
        }

        fetchAdsListTask = Task {
            do {
                let result = await apiService.getAdsHistoryList(userID: AccountManager.shared.userId!, after: currentOffset, amount: 20)

                try Task.checkCancellation()

                switch result {
                    case .success(let fetchedAds):
                        if reset {
                            ads.removeAll()
                        }

                        ads.append(contentsOf: fetchedAds)

                        if fetchedAds.count != 20 {
                            hasMoreAds = false
                        } else {
                            currentOffset += 20
                        }
                    case .failure(let apiError):
                        throw apiError
                }
            } catch is CancellationError {
            } catch {
                state = .error(error: error as! APIError)
                ads = []
            }

            fetchAdsListTask = nil
        }
    }

    func selectAd(id: Int) {
        // Implement logic to select and possibly fetch detailed data for a specific ad.
    }
}
