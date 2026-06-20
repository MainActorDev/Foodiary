import SwiftUI

struct IntStepperField: View {
    @Binding var value: Int
    var range: ClosedRange<Int>
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: { value = max(range.lowerBound, value - 1) }) {
                Image(systemName: "minus")
                    .font(.system(size: 16, weight: .bold))
            }
            .buttonStyle(NBStepperButtonStyle())
            
            Text("\(value)")
                .font(FoodiaryTypography.metric)
                .foregroundColor(FoodiaryDesign.black)
                .frame(minWidth: 48)
            
            Button(action: { value = min(range.upperBound, value + 1) }) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
            }
            .buttonStyle(NBStepperButtonStyle())
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(FoodiaryDesign.white)
                RoundedRectangle(cornerRadius: 12)
                    .stroke(FoodiaryDesign.black, lineWidth: 3)
            }
        )
    }
}
