//
//  RemoteConfigViewModel.swift
//  RemoteConfig
//
//  Created by Artem Vasin on 10.04.25.
//

import Foundation
import Combine

@MainActor
public final class RemoteConfigViewModel: ObservableObject {
    @frozen
    public enum State {
        case idle
        case loading
        case loaded
        case error(RemoteConfigError)
        case updateRequired(force: Bool, message: String)
    }

    @Published public private(set) var state: State = .idle
    @Published public var showUpdateAlert = false

    private let configService: RemoteConfigProtocol
    private var cancellables = Set<AnyCancellable>()

    public var storeURL: URL? {
        URL(string: configService.string(for: .forceUpdateStoreURL))
    }

    private var currentAppVersion: String {
        Bundle.appVersionBundle
    }

    private var currentBuildNumber: String {
        Bundle.appBuildBundle
    }

    private var fullAppVersion: String {
        "\(currentAppVersion)\(currentBuildNumber)"
    }

    public init(configService: RemoteConfigProtocol = FirebaseRemoteConfigService()) {
        self.configService = configService
        setupConfigUpdateListener()
    }

    public func fetchConfig() async {
        state = .loading
        do {
            try await configService.fetchConfig()
            try await configService.activateConfig()
            state = .loaded
            checkForUpdate()
        } catch {
            state = .error(error as? RemoteConfigError ?? .fetchError(error))
        }
    }

    private func setupConfigUpdateListener() {
        configService.addConfigUpdateListener { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let changed):
                    if changed {
                        self?.checkForUpdate()
                    }
                case .failure(let error):
                    self?.state = .error(error as? RemoteConfigError ?? .configUpdateError(error))
                }
            }
        }
    }

    private func checkForUpdate() {
        let isForceUpdateRequired = configService.bool(for: .isForceUpdateRequired)
        let minVersion = configService.string(for: .forceUpdateCurrentVersion)

        guard fullAppVersion.compare(minVersion, options: .numeric) == .orderedAscending else {
            return
        }

        let message = "There are new features available, please update your app."

        if isForceUpdateRequired {
            state = .updateRequired(force: true, message: message)
        } else {
            showUpdateAlert = true
            state = .updateRequired(force: false, message: message)
        }
    }
}
