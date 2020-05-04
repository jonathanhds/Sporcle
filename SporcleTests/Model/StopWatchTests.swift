//
//  StopWatchTests.swift
//  SporcleTests
//
//  Created by Jonathan Souza on 28/04/20.
//  Copyright © 2020 Jonathan. All rights reserved.
//

import XCTest
import Foundation
@testable import Sporcle

class StopWatchTests: XCTestCase {

    func testSouldCountTime() {
        // Given
        let stopWatch = StopWatch()
        let mock = TimerDelegateMock()
        stopWatch.delegate = mock

        // When
        stopWatch.startTimer()

        let asyncExpectation = expectation(description: #function)

        // Then
        let seconds = 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            XCTAssertGreaterThan(mock.timeInSeconds, 0)
            asyncExpectation.fulfill()
        }

        wait(for: [asyncExpectation], timeout: 2)
    }

}

class TimerDelegateMock: TimerDelegate {
    var timeInSeconds: TimeInterval = 0

    func timer(_ timer: Sporcle.Timer, didUpdateTime timeInSeconds: TimeInterval) {
        self.timeInSeconds = timeInSeconds
    }

    func timedOut(_ timer: Sporcle.Timer) {}
}
