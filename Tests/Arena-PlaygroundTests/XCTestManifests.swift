import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Arena_PlaygroundTests.allTests),
    ]
}
#endif
