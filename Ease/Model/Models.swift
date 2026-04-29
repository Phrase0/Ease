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
    case drink = "飲品"
    case dessert = "甜點"
}

enum FoodTag: String, CaseIterable, Hashable, Codable {
    // --- 基礎架構 ---
    case grains = "澱粉"       // 飯、麵、地瓜、土司
    case protein = "肉魚蛋"    // 各類蛋白質
    case vegetable = "蔬菜"    // 葉菜、根莖類
    
    // --- 烹調與調味 ---
    case oily = "油膩"        // 油炸、肥肉、重油
    case spicy = "辛辣"       // 辣椒、胡椒
    case heavy = "重口味"      // 重鹹、勾芡、濃郁
    
    // --- 誘發物 ---
    case acidic = "酸性食"     // 柑橘、番茄、醋、鳳梨
    case herbs = "辛香料"      // 洋蔥、大蒜、薄荷
    case alcohol = "酒精"      // 酒類
    
    // --- 烘焙與甜點 ---
    case bread = "麵包"       // 烘焙、蛋糕、發酵麵點
    case sweets = "甜食"       // 糖果、巧克力、甜點
    case dairy = "奶類"       // 牛奶、起司、鮮奶油
    
    // --- 飲品 ---
    case caffeine = "咖啡因"    // 咖啡、濃茶
    case sugary = "含糖飲"     // 手搖、果汁
    case bubbles = "氣泡飲"     // 可樂、汽水、氣泡水
}

enum EatingHabit: String, CaseIterable, Hashable, Codable {
    case eatTooFast = "吃太快"
    case talkingWhileEating = "一直說話"
    case sleepingOnStomach = "趴睡"
    
}

enum DiningType: String, CaseIterable, Hashable, Codable {
    case eatOut = "外食"
    case takeout = "外帶"
    case homeCook = "自煮"
}

enum Symptom: String, CaseIterable, Hashable, Codable {
    case heartburn = "火燒心"
    case chestTightness = "胸悶"
    case globusSensation = "喉嚨卡"
    case nightCough = "夜咳"
    case bloating = "脹氣"
    case stomachache = "胃痛"
    case diarrhea = "腹瀉"
    case burping = "打飽嗝"
    case hiccup = "打嗝"
    case nausea = "噁心"
    case acidReflux = "泛酸"
    case vomiting = "嘔吐"
    case other = "其他"
    
    var weight: Int {
        switch self {
        case .heartburn:       return 5 // 核心典型症狀，代表強烈不適
        case .chestTightness:  return 4 // 需警覺，有時與心血管混淆，心理壓力較大
        case .globusSensation: return 3 // 慢性發炎指標，影響生活品質
        case .nightCough:      return 4 // 影響睡眠品質，代表夜間逆流嚴重
        case .bloating:        return 1 // 常見輕微不適
        case .stomachache:     return 3 // 中度不適
        case .diarrhea:        return 2 // 腸胃機能失調
        case .burping:         return 1 // 常見輕微不適
        case .hiccup:          return 2 // 神經或橫膈膜刺激
        case .nausea:          return 3 // 中度不適
        case .acidReflux:      return 3 // 典型症狀，代表胃酸已向上逆流
        case .vomiting:        return 5 // 最嚴重的急性症狀
        case .other:           return 1 // 基準分
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
