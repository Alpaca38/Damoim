//
//  NetworkMonitor.swift
//  Damoim
//
//  Created by 조규연 on 9/4/24.
//

import Foundation
import Network
import Combine

final class NetworkMonitor {
    let networkStatus = PassthroughSubject<Bool, Never>()
    var onWifi = true
    var onCellular = true

    private let pathMonitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")

    init() {
        pathMonitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }

            networkStatus.send(path.status == .satisfied)
            onWifi = path.usesInterfaceType(.wifi)
            onCellular = path.usesInterfaceType(.cellular)
        }

        pathMonitor.start(queue: monitorQueue)
    }
}
