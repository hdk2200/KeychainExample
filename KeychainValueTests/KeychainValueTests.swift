@testable import KeychainValue
import XCTest

final class KeychainValueTests: XCTestCase {
  var keychain: KeychainValue!

  let serviceName = "testServic"
  override func setUpWithError() throws {
    keychain = KeychainValue(service: serviceName)
    try keychain.removeAll()
  }

  override func tearDownWithError() throws {
    keychain = nil
  }

  func testSetGet() throws {
    try keychain.set("testkey", value: "12345")
    let val = try keychain.get("testkey")
    XCTAssertEqual(val, "12345")
  }

  func testInsertUpdate() throws {
    let keychain = KeychainValue()

    try keychain.set("myKey", value: "12345")
    let newVal = try keychain.get("myKey")
    XCTAssertEqual(newVal, "12345")

    try keychain.set("myKey", value: "67890")
    let updatedVal = try keychain.get("myKey")
    XCTAssertEqual(updatedVal, "67890")
  }

  func testInsertDelete() throws {
    let keychain = KeychainValue()

    try keychain.set("myKey", value: "12345")
    let newVal = try keychain.get("myKey")
    XCTAssertEqual(newVal, "12345")

    try keychain.set("myKey2", value: "67890")
    let myKey2Val = try keychain.get("myKey2")
    XCTAssertEqual(myKey2Val, "67890")

    try keychain.remove("myKey")
    let deletedVau = try keychain.get("myKey")
    XCTAssertNil(deletedVau)

    let remainVal = try keychain.get("myKey2")
    XCTAssertEqual(remainVal, "67890")
  }

  func testInsertRemoveAll() throws {
    let keychain = KeychainValue()

    for keyid in 0...10 {
      try keychain.set("myKey\(keyid)", value: "val\(keyid)")
    }

    try keychain.removeAll()

    for keyid in 0...10 {
      let val = try keychain.get("myKey\(keyid)")
      XCTAssertNil(val)
    }
  }

  func testGetWithNonStringData() {
    let key = "testKey"
    let intValue = 999

    let data = withUnsafeBytes(of: intValue) { Data($0) }
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: serviceName,
      kSecAttrAccount as String: key,
      kSecValueData as String: data
    ]

    let status = SecItemAdd(query as CFDictionary, nil)
    guard status == errSecSuccess else {
      XCTFail("\(status)")
      return
    }

    XCTAssertThrowsError(try keychain.get(key)) { error in
      guard case KeychainValueError.dataConvert = error else {
        XCTFail("\(error)")
        return
      }
    }
  }
}
