//
//  EaseApp.swift
//  Ease
//
//  Created by Peiyun Wu on 2026/4/23.
//

import SwiftUI
import UIKit

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]?
    let excludedActivityTypes: [UIActivity.ActivityType]?
    let onComplete: ((Bool) -> Void)?

    init(
        activityItems: [Any],
        applicationActivities: [UIActivity]? = nil,
        excludedActivityTypes: [UIActivity.ActivityType]? = nil,
        onComplete: ((Bool) -> Void)? = nil
    ) {
        self.activityItems = activityItems
        self.applicationActivities = applicationActivities
        self.excludedActivityTypes = excludedActivityTypes
        self.onComplete = onComplete
    }

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        controller.excludedActivityTypes = excludedActivityTypes
        controller.completionWithItemsHandler = { _, completed, _, _ in
            onComplete?(completed)
        }
        if let popover = controller.popoverPresentationController {
            popover.sourceView = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }?.rootViewController?.view
            popover.sourceRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - View Extension

extension View {
    func shareSheet(
        isPresented: Binding<Bool>,
        activityItems: @escaping () -> [Any],
        excludedTypes: [UIActivity.ActivityType] = [],
        onComplete: ((Bool) -> Void)? = nil
    ) -> some View {
        sheet(isPresented: isPresented) {
            ActivityViewController(
                activityItems: activityItems(),
                excludedActivityTypes: excludedTypes,
                onComplete: { completed in
                    isPresented.wrappedValue = false
                    onComplete?(completed)
                }
            )
        }
    }
}

// MARK: - Default Excluded Types

extension UIActivity.ActivityType {
    static let defaultExcludedTypes: [UIActivity.ActivityType] = [
        .assignToContact,
        .addToReadingList,
        .postToVimeo,
        .postToFlickr,
        .postToTencentWeibo,
        .postToFacebook,
        .postToTwitter,
        .postToWeibo,
        .openInIBooks,
        .markupAsPDF
    ]
}
