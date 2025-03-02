import SwiftUI

struct ToastView: View {
    let message: LocalizedStringKey
    
    var body: some View {
        Text(message)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Color(hex: "93aec1"))
                    .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
            )
    }
} 