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

    var stopWatch: StopWatch!
    var mock: TimerDelegateMock!

    override func setUp() {
        super.setUp()

        mock = TimerDelegateMock()
        stopWatch = StopWatch(startTime: 5)
        stopWatch.delegate = mock
    }

    override func tearDown() {
        stopWatch = nil
        mock = nil

        super.tearDown()
    }

    func testSouldCountTime() {
        // Given

        // When
        stopWatch.startTimer()

        let asyncExpectation = expectation(description: #function)

        // Then
        let seconds = 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            XCTAssertGreaterThan(self.mock.timeInSeconds, 0)
            asyncExpectation.fulfill()
        }

        wait(for: [asyncExpectation], timeout: 2)
    }

    func testShouldTimeOut() {
        // Given
        let startTime: TimeInterval = 5

        // When
        stopWatch.startTimer()

        let asyncExpectation = expectation(description: #function)

        // Then
        let seconds = startTime
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            XCTAssertTrue(self.mock.timedOutCalled)
            asyncExpectation.fulfill()
        }

        wait(for: [asyncExpectation], timeout: startTime + 1)
    }

}

class TimerDelegateMock: TimerDelegate {
    var timeInSeconds: TimeInterval = 0
    var timedOutCalled = false

    func timer(_ timer: Sporcle.Timer, didUpdateTime timeInSeconds: TimeInterval) {
        self.timeInSeconds = timeInSeconds
    }

    func timedOut(_ timer: Sporcle.Timer) {
        timedOutCalled = true
    }
}
