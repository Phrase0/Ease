//
//  Models.swift
//  Ease
//
//  Created by Peiyun Wu on 2026/4/20.
//

import Foundation

// MARK: - Enums

enum MealType: String, CaseIterable, Hashable, Codable {
    case fasting = "空腹"
    case breakfast = "早餐"
    case brunch = "早午餐"
    case lunch = "午餐"
    case afternoonTea = "下午茶"
    case dinner = "晚餐"
    case lateNight = "宵夜"
    case drink = "飲料"
}

enum FoodTag: String, CaseIterable, Hashable, Codable {
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

enum EatingHabit: String, CaseIterable, Hashable, Codable {
    case eatTooFast = "吃太快"
    case talkingWhileEating = "一直說話"
    case noRestAfterMeal = "無休息"
    case sleepingOnStomach = "趴睡"
}

enum DiningType: String, CaseIterable, Hashable, Codable {
    case eatOut = "外食"
    case takeout = "外帶"
    case homeCook = "自煮"
}

enum Symptom: String, CaseIterable, Hashable, Codable {
    case bloating = "脹氣"
    case burping = "打飽嗝"
    case hiccup = "打嗝"
    case nausea = "想吐"
    case acidReflux = "泛酸"
    case vomiting = "嘔吐"
    case other = "其他"

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

struct MealRecord: Identifiable, Equatable, Hashable, Codable {
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
        f.dateFormat = "hh:mm"
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
