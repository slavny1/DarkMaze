//
//  LottieView.swift
//  DarkMaze
//
//  Created by Viacheslav on 15/06/23.
//

import Foundation
import Lottie
import SwiftUI

struct LottieView: UIViewRepresentable {
    var animationView = LottieAnimationView()
    var name: String
    var loop: LottieLoopMode

    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView()

        animationView.animation = LottieAnimation.named(name)
        animationView.contentMode = .scaleAspectFill
        animationView.play()
        animationView.loopMode = loop
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {    }
}
