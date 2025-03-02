import SwiftUI

struct SplashScreen: View {
    @Binding var isShowingSplash: Bool
    @State private var scale = 0.7
    @State private var opacity = 0.0
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "f3b7ad").opacity(0.3),  // Soft pink
                    Color(hex: "93aec1").opacity(0.2)   // Blue-gray
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // App icon or logo
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 80))
                    .foregroundColor(Color(hex: "93aec1"))  // Blue-gray
                    .background(
                        Circle()
                            .fill(Color.white)
                            .frame(width: 150, height: 150)
                            .shadow(color: Color(hex: "93aec1").opacity(0.3), radius: 10)
                    )
                
                // App name
                Text("SwipePedia")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "93aec1"))  // Blue-gray
                
                // Tagline
                Text("Discover Wikipedia, One Swipe at a Time")
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "9dbdba"))  // Sage green
            }
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 0.7)) {
                    scale = 1.0
                    opacity = 1.0
                }
                
                // Dismiss splash screen after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        isShowingSplash = false
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreen(isShowingSplash: .constant(true))
} 