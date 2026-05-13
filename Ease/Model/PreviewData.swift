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
        // 今天：午餐吃了炸雞珍奶，併發嚴重症狀
        MealRecord(
            date: daysAgo(0, hour: 12),
            mealType: .lunch,
            foodTags: [.oily, .sugary, .protein],
            note: "炸雞、珍奶",
            diningType: .takeout,
            eatingHabits: [.eatTooFast],
            symptoms: [.bloating, .nausea, .acidReflux],
            additionalNote: "今天開會太忙吃很快"
        ),
        // 今天：早餐吃麵包配咖啡，輕微泛酸
        MealRecord(
            date: daysAgo(0, hour: 8),
            mealType: .breakfast,
            foodTags: [.bread, .caffeine],
            note: "巧克力吐司、冰美式",
            diningType: .eatOut,
            symptoms: [.acidReflux]
        ),
        // 昨天：晚餐吃火鍋，引發夜咳
        MealRecord(
            date: daysAgo(1, hour: 19),
            mealType: .dinner,
            foodTags: [.protein, .spicy, .heavy, .herbs],
            note: "麻辣火鍋（含洋蔥蒜頭）",
            diningType: .eatOut,
            eatingHabits: [.talkingWhileEating],
            symptoms: [.heartburn, .nightCough, .chestTightness],
            additionalNote: "跟朋友聚餐一直說話，晚上咳得很厲害"
        ),
        // 前天：清淡自煮，狀態良好
        MealRecord(
            date: daysAgo(2, hour: 12),
            mealType: .lunch,
            foodTags: [.grains, .vegetable, .protein],
            note: "水煮雞肉、地瓜、燙青菜",
            diningType: .homeCook,
            symptoms: []
        ),
        // 三天前：宵夜吃了重口味泡麵
        MealRecord(
            date: daysAgo(3, hour: 23),
            mealType: .lateNight,
            foodTags: [.grains, .heavy, .bubbles],
            note: "泡麵、可樂",
            diningType: .takeout,
            eatingHabits: [.sleepingOnStomach],
            symptoms: [.bloating, .burping, .hiccup],
            additionalNote: "吃完就趴睡，肚子很不舒服"
        ),
        // 五天前：下午茶甜食誘發喉球感
        MealRecord(
            date: daysAgo(5, hour: 15),
            mealType: .afternoonTea,
            foodTags: [.sweets, .dairy, .caffeine],
            note: "重乳酪蛋糕、鮮奶茶",
            diningType: .eatOut,
            symptoms: [.globusSensation, .acidReflux]
        ),
        // 七天前：正常的家庭晚餐
        MealRecord(
            date: daysAgo(7, hour: 18),
            mealType: .dinner,
            foodTags: [.grains, .protein, .vegetable],
            note: "家常飯菜、炒空心菜",
            diningType: .homeCook,
            symptoms: []
        )
    ]
}()
