//
//  KeyboardAvoidance.swift
//  weather
//
//  Created by Gábora Bátor on 2025. 01. 05..
//

//lowkey no idea how it works
import SwiftUI
import Combine

struct KeyboardAvoidance: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0
    private var offset: CGFloat
    
    init(offset: CGFloat = 0) {
        self.offset = offset
    }
    
    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .onReceive(Publishers.keyboardHeight) { self.keyboardHeight = $0 }
            .animation(.easeOut(duration: 0.3), value: keyboardHeight) // Updated to use `animation(_:value:)`
    }
}

extension View {
    func keyboardAvoiding() -> some View {
        self.modifier(KeyboardAvoidance())
    }
}

extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .map { notification -> CGFloat in
                guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return 0 }
                return keyboardFrame.height
            }
        
        let willHide = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ -> CGFloat in
                return 0
            }
        
        return willShow.merge(with: willHide)
            .eraseToAnyPublisher()
    }
}
