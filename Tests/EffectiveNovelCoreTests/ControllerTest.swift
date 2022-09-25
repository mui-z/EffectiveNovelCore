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

        controller.load(raw: "abc[e]")

        XCTAssertEqual(controller.state, .prepare)
    }

    func testStart() {
        let expectation = expectation(description: #function)
        let controller = NovelController()

        controller.load(raw: "abc[e]")

        expectation.expectedFulfillmentCount = 4

        let stream = controller.start()
        stream
            .sink { event in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        XCTAssertEqual(controller.state, .running)

        waitForExpectations(timeout: 3)
        XCTAssertEqual(controller.state, .prepare)
    }

    func testInterrupt() {
        let expectation = expectation(description: #function)
        let controller = NovelController()

        controller.load(raw: "abc[e]")

        controller.start()
                  .sink { event in
                      expectation.fulfill()
                      controller.interrupt()
                  }
                  .store(in: &cancellables)

        waitForExpectations(timeout: 1)
        XCTAssertEqual(controller.state, .loadWait)
    }

    func testResume() {
        let expectation = expectation(description: #function)
        let controller = NovelController()

        expectation.expectedFulfillmentCount = 4

        controller.load(raw: "a[tw]b[e]")

        controller.start()
                  .delay(for: 0.001, scheduler: RunLoop.main)
                  .sink { event in
                      expectation.fulfill()

                      if event == .tapWait {
                          controller.resume()
                      }
                  }
                  .store(in: &cancellables)

        waitForExpectations(timeout: 2)

        XCTAssertEqual(controller.state, .prepare)
    }

    func testResumeSetIndex() {
        let expectation = expectation(description: #function)
        let controller = NovelController()

        expectation.expectedFulfillmentCount = 8

        controller.load(raw: "0123[tw]5678[e]")

        controller.start()
                  .delay(for: 0.001, scheduler: RunLoop.main)
                  .sink { event in
                      expectation.fulfill()

                      if event == .tapWait {
                          controller.resume(at: 7)
                      }
                  }
                  .store(in: &cancellables)

        waitForExpectations(timeout: 2)

        XCTAssertEqual(controller.state, .prepare)
    }

    func testShowUntilWaitTag() {
        let expectation = expectation(description: #function)
        let controller = NovelController()

        expectation.expectedFulfillmentCount = 32

        controller.load(raw: "s012345678901234567890123456789[tw]123[e]")

        controller.start()
                  .sink { event in
                      expectation.fulfill()

                      if event == .character(char: "s") {
                          controller.showTextUntilWaitTag()
                      }
                  }
                  .store(in: &cancellables)

        waitForExpectations(timeout: 1)

        XCTAssertEqual(controller.state, .pause)
    }

    func testDelay() {
        let expectation = expectation(description: #function)
        let controller = NovelController()

        expectation.expectedFulfillmentCount = 43

        controller.load(raw: "s[delay speed=1]0123456789012345678901234567890123456789[e]")

        controller.start()
                  .sink { event in
                      expectation.fulfill()
                  }
                  .store(in: &cancellables)

        waitForExpectations(timeout: 1)

        XCTAssertEqual(controller.state, .prepare)
    }

    func testPause() {
        let expectation = expectation(description: #function)
        let controller = NovelController()

        expectation.expectedFulfillmentCount = 12

        controller.load(raw: "[delay speed=1]0123456789[e]")

        controller.start()
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

        waitForExpectations(timeout: 1)

        XCTAssertEqual(controller.state, .prepare)
    }
}
