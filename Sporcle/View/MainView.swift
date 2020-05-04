import SwiftUI

struct MainView: View {

    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        Group {
            if viewModel.isLoading {
                Text("Loading...")
            } else {
                VStack(alignment: .leading, spacing: 5) {
                    Text(viewModel.title)
                        .font(.title)

                    TextField("Insert word", text: $viewModel.text, onEditingChanged: { _ in
                        self.viewModel.match(word: self.viewModel.text)
                    })
                        .disabled(!viewModel.isRunning)

                    List(viewModel.matchedWords, id: \.description) { word in
                        Text(word)
                    }

                    HStack(alignment: .center) {
                        Text(viewModel.score)
                        Spacer()
                        Text(viewModel.time)
                    }.padding([.top, .bottom])

                    GameButton(action: {
                        self.viewModel.startOrResetGame()
                    }) {
                       Text(viewModel.isRunning ? "Stop" : "Start")
                    }
                }
                .padding()
                .alert(isPresented: $viewModel.shouldShowAlert) {
                    switch viewModel.alertType {
                    case .win:
                        return Alert(title: Text("Congrats!"), message: Text("Yay, you won! Tap OK to restart the game."), dismissButton: .default(Text("OK"), action: {
                            self.viewModel.reset()
                        }))
                    case .lose:
                        return Alert(title: Text("Too bad!"), message: Text("Oh no, It's game over! Tap OK to restart the game."), dismissButton: .default(Text("OK"), action: {
                            self.viewModel.reset()
                        }))
                    case .none, .error:
                        return Alert(title: Text("Error"), message: Text("Could not fetch quizzes. Please, check you Internet connection and try again."))
                    }
                }
            }
        }.onAppear { self.viewModel.loadQuiz() }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(viewModel: GameViewModel(title: "Fruits"))
    }
}
