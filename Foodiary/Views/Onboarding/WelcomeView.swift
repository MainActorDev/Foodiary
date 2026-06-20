import SwiftUI

struct WelcomeView: View {
    var onGetStarted: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Text("🥗")
                .font(.system(size: 64))
                .padding(.bottom, 12)
            
            Text("Foodiary")
                .font(FoodiaryTypography.display)
                .foregroundColor(FoodiaryDesign.black)
                .padding(.bottom, 8)
            
            Text("Plan your meals around a simple daily calorie target.")
                .font(FoodiaryTypography.body)
                .foregroundColor(FoodiaryDesign.mutedFg)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
            
            Button(action: onGetStarted) {
                Text("GET STARTED")
            }
            .buttonStyle(NBButtonStyle())
            .padding(.horizontal, 60)
            .padding(.bottom, 32)
            
            Text("This app gives calorie estimates only — not medical or nutrition advice.")
                .font(.system(size: 11))
                .foregroundColor(FoodiaryDesign.mutedFg)
                .multilineTextAlignment(.center)
                .italic()
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FoodiaryDesign.background)
    }
}
