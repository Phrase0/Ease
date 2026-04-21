//
//  MockData.swift
//  Ease
//
//  Created by Peiyun Wu on 2026/4/20.
//

import Foundation

// MARK: - Enums

enum MealType: String, CaseIterable, Hashable {
    case breakfast = "早餐"
    case brunch = "早午餐"
    case lunch = "午餐"
    case afternoonTea = "下午茶"
    case dinner = "晚餐"
    case lateNight = "宵夜"
    case drink = "飲料"
}

enum FoodTag: String, CaseIterable, Hashable {
    case rice = "飯"
    case noodle = "麵"
    case bread = "麵包"
    case sweet = "甜食"
    case coffee = "咖啡"
    case bubbleTea = "手搖飲"
    case carbonated = "碳酸"
    case alcohol = "酒精"
    case highCalorie = "高熱量"
    case heavyOil = "重油"
    case heavySalty = "重鹹"
    case spicy = "辣"
}

enum EatingHabit: String, CaseIterable, Hashable {
    case eatTooFast = "吃太快"
    case talkingWhileEating = "一直說話"
    case noRestAfterMeal = "無休息"
    case sleepingOnStomach = "趴睡"
}

enum DiningType: String, CaseIterable, Hashable {
    case eatOut = "外食"
    case takeout = "外帶"
    case homeCook = "自煮"
}

enum Symptom: String, CaseIterable, Hashable {
    case bloating = "脹氣"
    case burping = "打飽嗝"
    case hiccup = "打嗝"
    case nausea = "想吐"
    case acidReflux = "泛酸"
    case vomiting = "嘔吐"
    case other = "其他"

    var emoji: String {
        switch self {
        case .bloating:   return "😖"
        case .burping:    return "🫧"
        case .hiccup:     return "💨"
        case .nausea:     return "🤢"
        case .acidReflux: return "🔥"
        case .vomiting:   return "🤮"
        case .other:      return "😶"
        }
    }

    var weight: Int {
        switch self {
        case .bloating:   return 1
        case .burping:    return 1
        case .hiccup:     return 2
        case .nausea:     return 3
        case .acidReflux: return 2
        case .vomiting:   return 5
        case .other:      return 1
        }
    }
}

// MARK: - Model

struct MealRecord: Identifiable, Equatable {
    let id: UUID
    let date: Date
    let mealType: MealType
    let foodTags: [FoodTag]
    let note: String
    let diningType: DiningType?
    let eatingHabits: [EatingHabit]
    let symptoms: [Symptom]
    let otherSymptom: String?
    let additionalNote: String?

    init(
        id: UUID = UUID(),
        date: Date,
        mealType: MealType,
        foodTags: [FoodTag] = [],
        note: String = "",
        diningType: DiningType? = nil,
        eatingHabits: [EatingHabit] = [],
        symptoms: [Symptom] = [],
        otherSymptom: String? = nil,
        additionalNote: String? = nil
    ) {
        self.id = id
        self.date = date
        self.mealType = mealType
        self.foodTags = foodTags
        self.note = note
        self.diningType = diningType
        self.eatingHabits = eatingHabits
        self.symptoms = symptoms
        self.otherSymptom = otherSymptom
        self.additionalNote = additionalNote
    }

    var hasSymptoms: Bool { !symptoms.isEmpty }

    var displayDate: String { date.formatted(date: .long, time: .omitted) }
    var displayTime: String {
        let f = DateFormatter()
        f.dateFormat = "h:mm"
        return f.string(from: date)
    }

    var displayAmPm: String {
        let f = DateFormatter()
        f.dateFormat = "a"
        f.locale = Locale(identifier: "en_US")
        return f.string(from: date)
    }

    var foodSummary: String {
        var parts: [String] = []
        if !foodTags.isEmpty {
            parts.append(foodTags.prefix(3).map(\.rawValue).joined(separator: "、"))
        }
        if !note.isEmpty { parts.append(note) }
        return parts.joined(separator: " · ")
    }
}

// MARK: - Mock Data

let mockRecords: [MealRecord] = {
    let cal = Calendar.current
    let now = Date()
    func daysAgo(_ d: Int, hour: Int = 12) -> Date {
        cal.date(bySettingHour: hour, minute: 0, second: 0, of:
            cal.date(byAdding: .day, value: -d, to: now)!)!
    }
    return [
        MealRecord(date: daysAgo(0, hour: 12), mealType: .lunch,
                   foodTags: [.highCalorie, .spicy], note: "炸雞、珍奶",
                   diningType: .takeout, symptoms: [.bloating, .nausea],
                   additionalNote: "吃很快"),
        MealRecord(date: daysAgo(0, hour: 8), mealType: .breakfast,
                   foodTags: [.bread, .coffee], note: "吐司、美式",
                   diningType: .eatOut, symptoms: [.acidReflux]),
        MealRecord(date: daysAgo(1, hour: 19), mealType: .dinner,
                   foodTags: [.noodle, .spicy], note: "麻辣燙",
                   diningType: .eatOut, symptoms: [.bloating, .vomiting, .nausea],
                   additionalNote: "很辣很油"),
        MealRecord(date: daysAgo(2, hour: 12), mealType: .lunch,
                   foodTags: [.rice], note: "清粥小菜",
                   diningType: .homeCook, symptoms: []),
        MealRecord(date: daysAgo(3, hour: 23), mealType: .lateNight,
                   foodTags: [.carbonated, .heavyOil], note: "泡麵、可樂",
                   diningType: .takeout, symptoms: [.bloating, .burping],
                   additionalNote: "太晚吃了"),
        MealRecord(date: daysAgo(5, hour: 15), mealType: .afternoonTea,
                   foodTags: [.bubbleTea, .sweet], note: "珍珠奶茶",
                   diningType: .takeout, symptoms: [.acidReflux]),
        MealRecord(date: daysAgo(7, hour: 18), mealType: .dinner,
                   foodTags: [.rice], note: "家常菜",
                   diningType: .homeCook, symptoms: []),
    ]
}()
