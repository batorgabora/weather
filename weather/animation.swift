//
//  animation.swift
//  weather
//
//  Created by Gábora Bátor on 2024. 12. 11..
//

import SwiftUI

struct ShakeEffect: GeometryEffect {
    var travelDistance: CGFloat = 7.5 // How far to shake
    var shakesPerUnit: CGFloat = 3  // Number of shakes
    var animatableData: CGFloat // Animation progress
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        // Calculate the x-offset for the shake effect
        let translation = travelDistance * sin(animatableData * .pi * shakesPerUnit)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}
