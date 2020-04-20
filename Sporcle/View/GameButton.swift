import SwiftUI

struct GameButton<Content: View>: View {

    let action: () -> Void

    let content: Content

    init(action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.action = action
        self.content = content()
    }

    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                self.content
                    .foregroundColor(.white)
                    .padding(10.0)
                Spacer()
            }
        }.background(Color.orange)
    }
}

struct GameButton_Previews: PreviewProvider {
    static var previews: some View {
        GameButton(action: {}) {
            Text("Start")
        }.previewLayout(.sizeThatFits)
    }
}
