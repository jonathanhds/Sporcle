//
//  GameManager.swift
//  Sporcle
//
//  Created by Ruann Homem on 06/04/20.
//  Copyright © 2020 Jonathan. All rights reserved.
//

import Foundation

class GameManager {
    var wordsCount: Int { gameRules.wordsCount }
    var matchedWordsCount: Int { gameRules.matchedWordsCount }

    private var gameRules: GameRules
    private var gameTime: Timer

    private(set) var isRunning = false

    private var score: Int { gameRules.score }

    weak var delegate: GameDelegate?

    init(words: [String]) {
        gameRules = Game(words: words)
        gameTime = StopWatch()
        gameTime.delegate = self
    }

    func start() {
        reset()
        gameTime.startTimer()
    }

    func reset() {
        gameTime.reset()
        gameRules.reset()
        delegate?.game(self, didUpdateScore: score)
    }

    func matchedWord(at indexPath: IndexPath) -> String? {
        gameRules.matchedWord(at: indexPath)
    }

    func match(word: String) {
        guard gameRules.match(word: word) else { return }
        delegate?.game(self, didMatchWord: word)
        checkWinGame()
    }

    private func checkWinGame() {
        guard gameRules.checkWinGame() else { return }

        gameTime.stopTimer()
        delegate?.gameDidWin(self)
    }
}

extension GameManager: TimerDelegate {
    func timer(_ timer: Timer, didUpdateTime timeInSeconds: TimeInterval) {
        delegate?.game(self, didUpdateTime: timeInSeconds)
    }

    func timedOut(_ timer: Timer) {
        delegate?.gameDidLose(self)
    }
}
