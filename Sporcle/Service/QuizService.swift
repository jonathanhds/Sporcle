import Foundation

class QuizService {

	private static let queue: DispatchQueue = DispatchQueue(label: "QuizService")

	func loadQuiz(completion: @escaping (Quiz?, Error?) -> Void) {
		let quiz = Quiz(title: "Fruits",
						words: ["Banana", "Apple", "Strawberry", "Orange"])

		QuizService.queue.asyncAfter(deadline: .now() + 3.0) {
			completion(quiz, nil)
		}
	}

}
