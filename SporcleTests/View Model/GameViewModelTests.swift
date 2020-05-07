import XCTest
@testable import Sporcle

class GameViewModelTests: XCTestCase {

    var viewModel: GameViewModel!

    override func setUp() {
        super.setUp()

        viewModel = GameViewModel(service: QuizServiceMock())
    }

    override func tearDown() {
        viewModel = nil

        super.tearDown()
    }

}

class QuizServiceMock: QuizServiceProtocol {
    func loadQuiz(completion: @escaping (Quiz?, Error?) -> Void) {
        completion(nil, nil)
    }
}
