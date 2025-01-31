// Copyright (c) 2014-present, Facebook, Inc. All rights reserved.
//
// You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
// copy, modify, and distribute this software in source code or binary form for use
// in connection with the web services and APIs provided by Facebook.
//
// As with any software that integrates with the Facebook platform, your use of
// this software is subject to the Facebook Developer Principles and Policies
// [http://developers.facebook.com/policy/]. This copyright notice shall be
// included in all copies or substantial portions of the software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import XCTest

class ChooseContextDialogTests: XCTestCase, ContextDialogDelegate {

  var dialogDidCompleteSuccessfully = false
  var dialogDidCancel = false
  var dialogError: NSError?
  let validCallbackURL = URL(string: "fbabc123://gaming/contextchoose/?context_id=123456789")

  override func setUp() {
    super.setUp()

    dialogDidCompleteSuccessfully = false
    dialogDidCancel = false
    dialogError = nil
    ApplicationDelegate.shared.application(
      UIApplication.shared,
      didFinishLaunchingWithOptions: [:]
    )
    Settings.appID = "abc123"
  }

  override func tearDown() {
    super.tearDown()

    GamingContext.current().identifier = nil
  }

  func testDialogCompletesSucessfully() throws {
    let dialog = try XCTUnwrap(SampleContextDialogs.chooseContextDialogWithoutContentValues(delegate: self))
    dialog.show()
    let dialogURLOpenerDelegate = try XCTUnwrap(dialog as? URLOpening)
    dialogURLOpenerDelegate
      .application(UIApplication.shared, open: validCallbackURL, sourceApplication: "", annotation: nil)

    XCTAssertNotNil(dialog)
    XCTAssertTrue(dialogDidCompleteSuccessfully)
    XCTAssertFalse(dialogDidCancel)
    XCTAssertNil(dialogError)
  }

  func testDialogCancels() throws {
    let dialog = try XCTUnwrap(SampleContextDialogs.chooseContextDialogWithoutContentValues(delegate: self))
    dialog.show()
    let dialogURLOpenerDelegate = try XCTUnwrap(dialog as? URLOpening)
    dialogURLOpenerDelegate.applicationDidBecomeActive(UIApplication.shared)

    XCTAssertNotNil(dialog)
    XCTAssertFalse(dialogDidCompleteSuccessfully)
    XCTAssertTrue(dialogDidCancel)
    XCTAssertNil(dialogError)
  }

  func testShowDialogWithoutSettingAppID() throws {
    let appIDErrorMessage = "App ID is not set in settings"
    let content = ChooseContextContent()
    let dialog = ChooseContextDialog(content: content, delegate: self)
    Settings.appID = nil
    dialog.show()

    let dialogError = try XCTUnwrap(dialogError)
    XCTAssertNotNil(dialog)
    XCTAssertEqual(CoreError.errorUnknown.rawValue, dialogError.code)
    XCTAssertEqual(appIDErrorMessage, dialogError.userInfo[ErrorDeveloperMessageKey] as? String)
  }

  func testShowDialogWithInvalidSizeContent() throws {
    let appIDErrorMessage = "The minimum size cannot be greater than the maximum size"
    let contentErrorName = "minParticipants"
    let dialog = try XCTUnwrap(SampleContextDialogs.showChooseContextDialogWithInvalidSizes(delegate: self))
    dialog.show()

    let dialogError = try XCTUnwrap(dialogError)
    XCTAssertNotNil(dialog)
    XCTAssertNotNil(dialogError)
    XCTAssertEqual(CoreError.errorInvalidArgument.rawValue, dialogError.code)
    XCTAssertEqual(appIDErrorMessage, dialogError.userInfo[ErrorDeveloperMessageKey] as? String)
    XCTAssertEqual(contentErrorName, dialogError.userInfo[ErrorArgumentNameKey] as? String)
  }

  func testShowDialogWithNullValuesInContent() throws {
    let dialog = try XCTUnwrap(SampleContextDialogs.chooseContextDialogWithoutContentValues(delegate: self))
    dialog.show()

    XCTAssertNotNil(dialog)
    XCTAssertFalse(dialogDidCompleteSuccessfully)
    XCTAssertFalse(dialogDidCancel)
    XCTAssertNil(dialogError)
  }

  // MARK: - Delegate Methods

  func contextDialogDidComplete(_ contextDialog: ContextWebDialog) {
    dialogDidCompleteSuccessfully = true
  }

  func contextDialog(_ contextDialog: ContextWebDialog, didFailWithError error: Error) {
    dialogError = error as NSError
  }

  func contextDialogDidCancel(_ contextDialog: ContextWebDialog) {
    dialogDidCancel = true
  }
}
