import Foundation
import Lottie
import SwiftUI

struct LottieView: View {
    var animationName: String
    
    private let animationView = LottieAnimationView()
    
    init(animationName: String) {
        self.animationName = animationName
    }
    
    var body: some View {
        GeometryReader { proxy in
            LottieAnimationViewRepresentable(animationView: animationView, animationName: animationName)
                .frame(width: proxy.size.width, height: 150)
                .padding(.bottom, 8)// Use the full screen width from GeometryReader
        }
    }
}

struct LottieAnimationViewRepresentable: UIViewRepresentable {
    let animationView: LottieAnimationView
    var animationName: String
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        animationView.animation = LottieAnimation.named(animationName)
        animationView.contentMode = .scaleAspectFill // Scale to fill the available width
        animationView.loopMode = .loop
        animationView.play()
        view.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set constraints to make the animation fill the width of the parent view
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: view.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update view if needed
    }
}
