//
//  NetworkViewController.swift
//  Damoim
//
//  Created by 조규연 on 9/5/24.
//

import UIKit
import Combine
import SnapKit

class NetworkViewController: BasePostViewController {

    private let networkMonitor = NetworkMonitor()
    private var cancellables = Set<AnyCancellable>()
    private var networkStatusBar: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNetworkStatusSubscription()
    }

    // 네트워크 상태 변화를 구독하는 메서드
    private func setupNetworkStatusSubscription() {
        networkMonitor.networkStatus
            .receive(on: DispatchQueue.main) // UI 업데이트는 메인 스레드에서 실행
            .sink { [weak self] isConnected in
                self?.handleNetworkStatus(isConnected: isConnected)
            }
            .store(in: &cancellables)
    }

    // 네트워크 상태에 따라 네트워크 바를 보여주거나 숨기는 메서드
    private func handleNetworkStatus(isConnected: Bool) {
        if isConnected {
            removeNetworkStatusBar() // 네트워크가 연결되면 바 제거
        } else {
            showNetworkStatusBar() // 네트워크가 끊기면 바 표시
        }
    }

    // 빨간색 네트워크 상태 바를 표시하는 메서드
    private func showNetworkStatusBar() {
        guard networkStatusBar == nil else { return } // 이미 바가 있다면 표시하지 않음
        
        let statusBarHeight: CGFloat = 44.0
        let statusBar = UIView(frame: CGRect(x: 0, y: 44, width: view.bounds.width, height: statusBarHeight))
        statusBar.backgroundColor = .red
        
        let label = UILabel(frame: statusBar.bounds)
        label.text = "네트워크 연결이 해제되었습니다. 네트워크 상태를 확인해주세요."
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 14)

        statusBar.addSubview(label)
        view.addSubview(statusBar)
        
        // 네트워크 상태 바 저장
        networkStatusBar = statusBar
    }

    // 빨간색 네트워크 상태 바를 제거하는 메서드
    private func removeNetworkStatusBar() {
        networkStatusBar?.removeFromSuperview()
        networkStatusBar = nil
    }
}
