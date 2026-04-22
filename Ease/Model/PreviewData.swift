//
//  PreviewData.swift
//  Ease
//
//  Created by Peiyun Wu on 2026/4/20.
//

import Foundation

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
