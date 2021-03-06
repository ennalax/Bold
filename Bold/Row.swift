import Foundation

/**
 Represents a row in a result set. You cann add support for custom types just by extending Row. For an example look at boolValue(columnName:) which is simply uses intValue(columnName:) internally.
 */
public struct Row {
  struct Item {
    let columnIndex: Int32
    let columnName: String
    let value: Bindable?
  }
  /// MARK: Properties
  fileprivate let items: [Item]
  fileprivate let _valuesByColumnNames: [String: Bindable?]
  fileprivate let _valuesByColumnIndexes: [Int32: Bindable?]
  /// MARK: Creating Rows
  init(items: [Item]) {
    self.items = items
    var valuesByColumnNames = [String: Bindable?]()
    var valuesByColumnIndexes = [Int32: Bindable?]()

    self.items.forEach { (item) in
      valuesByColumnNames[item.columnName] = item.value
      valuesByColumnIndexes[item.columnIndex] = item.value
    }
    _valuesByColumnNames = valuesByColumnNames
    _valuesByColumnIndexes = valuesByColumnIndexes
  }
  
  public subscript(column: String) -> SQLValue {
    guard let value = _valuesByColumnNames[column] else {
      return SQLValue(nil)
    }
    return SQLValue(value)
  }
  public subscript(columnIndex columnIndex: Int32) -> SQLValue {
    guard let value = _valuesByColumnIndexes[columnIndex] else {
      return SQLValue(nil)
    }
    return SQLValue(value)
  }
}


// MARK: General
extension Row {
  /**
   All column names of the row.
   */
  public var allColumnNames:[String] {
    return self.items.map { $0.columnName }
  }
}

// MARK: Extracting Values
extension Row {
  /**
   Used to get the string value at a specific column in the row.
   :param: columnName The name of the column you want to get the value of.
   :returns: The string stored in the specified column.
   */
  public func stringValue(forColumn columnName:String) -> String? {
    return value(forColumn: columnName)
  }
  
  /**
   Used to get the int value at a specific column in the row.
   :param: columnName The name of the column you want to get the value of.
   :returns: The integer stored in the specified column.
   */
  public func intValue(forColumn columnName:String) -> Int? {
    return value(forColumn: columnName)
  }
  
  /**
   Used to get the double value at a specific column in the row.
   :param: columnName The name of the column you want to get the value of.
   :returns: The double value stored in the specified column.
   */
  public func doubleValue(forColumn columnName:String) -> Double? {
    return value(forColumn: columnName)
  }
  
  /**
   Used to get the data value at a specific column in the row.
   :param: columnName The name of the column you want to get the value of.
   :returns: The data stored in the specified column.
   */
  public func dataValue(forColumn columnName:String) -> Data? {
    return value(forColumn: columnName)
  }
  
  fileprivate func value<T>(forColumn columnName:String) -> T? {
    return _valuesByColumnNames[columnName] as? T
  }
}

// MARK: Convenience
extension Row {
  /**
   Used to get the bool value at a specific column in the row.
   :param: columnName The name of the column you want to get the value of.
   :returns: The boolean value stored in the specified column.
   */
  public func boolValue(forColumn columnName:String) -> Bool? {
    guard let intValue = intValue(forColumn: columnName) else {
      return nil
    }
    switch intValue {
    case 0: return false
    case 1: return true
    default: return nil
    }
  }
}
