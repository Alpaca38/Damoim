//
//  RelativeDateManager.swift
//  Damoim
//
//  Created by 조규연 on 8/18/24.
//

import Foundation

final class RelativeDateManager {
    private init() { }
    static let shared = RelativeDateManager()
    
    private let relativeDateFormatter = {
        let dateFormatter = RelativeDateTimeFormatter()
        dateFormatter.dateTimeStyle = .named
        dateFormatter.unitsStyle = .abbreviated
        return dateFormatter
    }()
    
    private let isoDateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    private let now = Date()
    
    func toAgo(createdAt: String) -> String {
        guard let date = isoDateFormatter.date(from: createdAt) else { return "toAgoError" }
        return relativeDateFormatter.localizedString(for: date, relativeTo: now)
    }
    
}
