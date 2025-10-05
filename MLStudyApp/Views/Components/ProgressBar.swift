import SwiftUI

struct ProgressBar: View {
    var progress: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                Capsule()
                    .fill(Color.accentColor)
                    .frame(width: max(CGFloat(progress) * geometry.size.width, 12))
                    .animation(.easeInOut, value: progress)
            }
        }
    }
}

#Preview {
    ProgressBar(progress: 0.5)
        .frame(height: 12)
        .padding()
}
