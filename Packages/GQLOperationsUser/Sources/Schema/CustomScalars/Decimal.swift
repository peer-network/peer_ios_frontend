// @generated
// This file was automatically generated and can be edited to
// implement advanced custom scalar functionality.
//
// Any changes to this file will not be overwritten by future
// code generation execution.

import ApolloAPI
import Foundation

// All generated code uses this:
public typealias Decimal = Foundation.Decimal

extension Foundation.Decimal: CustomScalarType {
  public init(_jsonValue value: JSONValue) throws {
    switch value {

    case let string as String:
      // If backend ever sends decimals as strings, parse them losslessly
      guard let decimal = Decimal(string: string, locale: Locale(identifier: "en_US_POSIX")) else {
        throw JSONDecodingError.couldNotConvert(value: value, to: Decimal.self)
      }
      self = decimal

    case let number as NSNumber:
      var decimal = number.decimalValue
      var rounded = Decimal()
      NSDecimalRound(&rounded, &decimal, 10, .plain) // 10 = backend's scale
      self = rounded

    default:
      throw JSONDecodingError.couldNotConvert(value: value, to: Decimal.self)
    }
  }

  public var _jsonValue: JSONValue {
    // Send as string to avoid going back through Double and losing precision again.
    NSDecimalNumber(decimal: self).stringValue
  }
}
