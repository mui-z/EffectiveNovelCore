//
// Created by osushi on 2022/09/23.
//

import XCTest
import Combine
@testable import EffectiveNovelCore

final class ControllerTest: XCTestCase {

    var cancellables: Set<AnyCancellable> = []

    override func tearDown() {
        cancellables = []
        super.tearDown()
    }

    func testLoad() {
        let controller = NovelController()

        switch controller.load(raw: "[delay speed=1]abc[e]") {
        case .valid:
            XCTAssertEqual(controller.state, .prepare)
        case .invalid:
            XCTFail()
        }

    }

    func testStart() {
        let expectation = expectation(description: #function)
        let controller = NovelController()

        expectation.expectedFulfillmentCount = 4

        let result = controller.load(raw: "abc[e]")

        switch result {
        case .valid(let script):
            controller.start(script: script)
                      .sink { event in
                          expectation.fulfill()
                      }
                      .store(in: &cancellables)

            XCTAssertEqual(controller.state, .running)

            waitForExpectations(timeout: 3)
            XCTAssertEqual(controller.state, .loadWait)

        case .invalid:
            XCTFail()
        }

    }

    func testSetDefaultDelay() {
        let expectation = expectation(description: #function)
        let controller = NovelController()

        expectation.expectedFulfillmentCount = 5
        let result = controller.load(raw: "[setDefaultDelay=123]abc[e]")

        switch result {
        case .valid(let script):
            controller.start(script: script)
                      .sink { event in
                          expectation.fulfill()
                          switch event {
                          case .end:
                              XCTAssertEqual(controller.defaultSpeed, 90.0)
                              XCTAssertEqual(controller.speed, 90.0)
                              XCTAssertEqual(controller.state, .loadWait)

                          default:
                              XCTAssertEqual(controller.defaultSpeed, 123.0)
                              XCTAssertEqual(controller.speed, 123.0)
                              XCTAssertEqual(controller.state, .running)
                          }
                      }
                      .store(in: &cancellables)

            waitForExpectations(timeout: 1)
        case .invalid:
            XCTFail()
        }
    }

    func testInterrupt() {
        let expectation = expectation(description: #function)
        let controller = NovelController()

        let result = controller.load(raw: "abc[e]")

        switch result {
        case .valid(let script):
            controller.start(script: script)
                      .sink { event in
                          expectation.fulfill()
                          controller.interrupt()
                      }
                      .store(in: &cancellables)

            waitForExpectations(timeout: 1)
            XCTAssertEqual(controller.state, .loadWait)

        case .invalid:
            XCTFail()
        }
    }

    func testResume() {
        let expectation = expectation(description: #function)
        let controller = NovelController()

        expectation.expectedFulfillmentCount = 4

        let result = controller.load(raw: "a[tw]b[e]")

        switch result {
        case .valid(let script):
            controller.start(script: script)
                      .delay(for: 0.001, scheduler: RunLoop.main)
                      .sink { event in
                          expectation.fulfill()

                          if event == .tapWait {
                              controller.resume()
                          }
                      }
                      .store(in: &cancellables)

            waitForExpectations(timeout: 2)

            XCTAssertEqual(controller.state, .loadWait)

        case .invalid:
            XCTFail()
        }

    }

    func testResumeSetIndex() {
        let expectation = expectation(description: #function)
        let controller = NovelController()

        expectation.expectedFulfillmentCount = 8

        let result = controller.load(raw: "0123[tw]5678[e]")

        switch result {
        case .valid(let script):
            controller.start(script: script)
                      .delay(for: 0.001, scheduler: RunLoop.main)
                      .sink { event in
                          expectation.fulfill()

                          if event == .tapWait {
                              controller.resume(at: 7)
                          }
                      }
                      .store(in: &cancellables)

            waitForExpectations(timeout: 2)

            XCTAssertEqual(controller.state, .loadWait)
        case .invalid:
            XCTFail()
        }

    }

    func testShowUntilWaitTag() {
        let expectation = expectation(description: #function)
        let controller = NovelController()

        expectation.expectedFulfillmentCount = 37

        let result = controller.load(raw: "[delay speed=100]s01234567890123456789012345678x[tw]abc[e]")

        switch result {

        case .valid(let script):
            controller.start(script: script)
                      .print()
                      .sink { event in
                          expectation.fulfill()

                          switch event {
                          case .character(let char) where char == "s":
                              controller.showTextUntilWaitTag()
                          case .tapWait:
                              controller.resume()
                          default:
                              break
                          }
                      }
                      .store(in: &cancellables)

            waitForExpectations(timeout: 1)

            XCTAssertEqual(controller.state, .loadWait)
        case .invalid:
            XCTFail()
        }
    }

    func testDelay() {
        let expectation = expectation(description: #function)
        let controller = NovelController()

        expectation.expectedFulfillmentCount = 43

        let result = controller.load(raw: "s[delay speed=1]0123456789012345678901234567890123456789[e]")

        switch result {
        case .valid(let script):
            controller.start(script: script)
                      .sink { event in
                          expectation.fulfill()
                      }
                      .store(in: &cancellables)

            waitForExpectations(timeout: 1)

            XCTAssertEqual(controller.state, .loadWait)

        case .invalid:
            XCTFail()
        }
    }

    func testPause() {
        let expectation = expectation(description: #function)
        let controller = NovelController()

        expectation.expectedFulfillmentCount = 12

        let result = controller.load(raw: "[delay speed=50]0123456789[e]")

        switch result {
        case .valid(let script):
            controller.start(script: script)
                      .sink { event in
                          expectation.fulfill()

                          if event == .character(char: "2") {
                              controller.pause()
                              XCTAssertEqual(controller.state, .pause)
                              controller.resume()
                          }
                      }
                      .store(in: &cancellables)


            XCTAssertEqual(controller.state, .running)

            waitForExpectations(timeout: 3)

            XCTAssertEqual(controller.state, .loadWait)
        case .invalid:
            XCTFail()
        }

    }
}
