//
//  GameTimer.swift
//  Sporcle
//
//  Created by Ruann Homem on 06/04/20.
//  Copyright © 2020 Jonathan. All rights reserved.
//

import Foundation

private struct Constants {
    static let ONE_SECOND: TimeInterval = 1.0
    static let GAME_START_TIME = ONE_SECOND * 60 * 5
}

protocol GameTimerDelegate: AnyObject {
    func game(_ game: GameTime, didUpdateTime timeInSeconds: TimeInterval)
    func gameDidLose(_ game: GameTime)
}

protocol GameTime {
    var timeInSeconds: TimeInterval { get }
    var delegate: GameTimerDelegate? { get set }

    func startTimer()
    func stopTimer()
    func reset()
}

class GameTimer: GameTime {
    private var timer: Timer?

    weak var delegate: GameTimerDelegate?

    private(set) var timeInSeconds: TimeInterval {
        didSet {
            delegate?.game(self, didUpdateTime: timeInSeconds)
        }
    }

    init() {
        timeInSeconds = Constants.GAME_START_TIME
    }

    deinit {
        stopTimer()
    }

    func reset() {
        stopTimer()
        timeInSeconds = Constants.GAME_START_TIME
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: Constants.ONE_SECOND, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            self.timeInSeconds -= Constants.ONE_SECOND

            if self.timeInSeconds <= 0 {
                self.delegate?.gameDidLose(self)
                self.stopTimer()
            }
        }
    }
}
