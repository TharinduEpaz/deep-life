//
//  Item.swift
//  deeplife
//
//  Created by Tharindu Epasingha on 2026-04-28.
//

import Foundation
import SwiftData

@Model
final class Project {
    var name: String
    var emoji: String
    var weeklyCount: Int = 0
    var weeklyTarget: Int = 5
    var weekStart: Date = Date()

    init(name: String, emoji: String, weeklyTarget: Int = 5, weeklyCount: Int = 0, weekStart: Date = Project.currentWeekMonday()) {
        self.name = name
        self.emoji = emoji
        self.weeklyTarget = weeklyTarget
        self.weeklyCount = weeklyCount
        self.weekStart = weekStart
    }

    var progress: Double {
        guard weeklyTarget > 0 else { return 0 }
        return min(Double(weeklyCount) / Double(weeklyTarget), 1.0)
    }

    static func currentWeekMonday() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        return calendar.date(from: components)!
    }

    func resetIfNewWeek() {
        let monday = Project.currentWeekMonday()
        if weekStart < monday {
            weeklyCount = 0
            weekStart = monday
        }
    }
}
