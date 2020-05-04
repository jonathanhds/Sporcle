//
//  StopWatch.swift
//  Sporcle
//
//  Created by Ruann Homem on 06/04/20.
//  Copyright © 2020 Jonathan. All rights reserved.
//

import Foundation

private struct Constants {
    static let ONE_SECOND: TimeInterval = 1.0
    static let START_TIME = ONE_SECOND * 60 * 5
}

protocol TimerDelegate: AnyObject {
    func timer(_ timer: Timer, didUpdateTime timeInSeconds: TimeInterval)
    func timedOut(_ timer: Timer)
}

protocol Timer {
    var timeInSeconds: TimeInterval { get }
    var delegate: TimerDelegate? { get set }

    func startTimer()
    func stopTimer()
    func reset(startTime: TimeInterval)
}

extension Timer {
    func reset(startTime: TimeInterval = Constants.START_TIME) {
        reset(startTime: startTime)
    }
}

class StopWatch: Timer {
    private var timer: Foundation.Timer?

    weak var delegate: TimerDelegate?

    private(set) var timeInSeconds: TimeInterval {
        didSet {
            delegate?.timer(self, didUpdateTime: timeInSeconds)
        }
    }

    init(startTime: TimeInterval = Constants.START_TIME) {
        timeInSeconds = startTime
    }

    deinit {
        stopTimer()
    }

    func reset(startTime: TimeInterval) {
        stopTimer()
        timeInSeconds = startTime
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func startTimer() {
        stopTimer()
        timer = Foundation.Timer.scheduledTimer(withTimeInterval: Constants.ONE_SECOND, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            self.timeInSeconds -= Constants.ONE_SECOND

            if self.timeInSeconds <= 0 {
                self.delegate?.timedOut(self)
                self.stopTimer()
            }
        }
    }
}
