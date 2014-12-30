import Foundation

/**
  Represents a result set. You usually do not interact with the result set directly but you can.
*/
public class ResultSet {
  let statement:Statement
  
  // MARK: Creating
  public init(statement:Statement) {
    self.statement = statement
  }
  
  // MARK: General
  /**
    Moves the cursor to the next row in the result set. Before you can access anything in the result set you have to call next at least once.
  
    :returns: true if there is another row, false if there isn't or if an error occurred.
  */
  public func next() -> Bool {
    return step() == SQLITE_ROW
  }
  
  /**
    Closes the result set.
  
    :returns: true if the result set could be closed, otherwise false.
  */
  public func close() -> Bool {
    return statement.close()
  }
  
  /**
    Returns the number of columns in the result set.
  */
  public var columnCount:Int32 {
    return sqlite3_column_count(statement.statementHandle)
  }

  internal func step() -> Int32 {
    return sqlite3_step(statement.statementHandle)
  }
}

// MARK: Get a row representation
extension ResultSet {
  /**
    Gets the current row.
  */
  public var row:Row {
    var valuesByColumnNames = [String:Bindable?]()
    for index in 0...columnCount {
      let rawColumnName = sqlite3_column_name(statement.statementHandle, index)
      let columnName = String.fromCString(rawColumnName)
      let value = self.value(index)
      if let columnName = columnName {
        valuesByColumnNames[columnName] = value
      }
    }
    return Row(valuesByColumnNames:valuesByColumnNames)
  }
}

// MARK: Getting values
extension ResultSet {
  /**
    Used to get the string value of the column at a specific column in the current row.
    :param: columnIndex The index of the column.
    :returns: The string value of the column at the specified column in the current row.
  */
  public func stringValue(columnIndex:Int32) -> String {
    let text = sqlite3_column_text(statement.statementHandle, columnIndex)
    return String.fromCString(UnsafePointer<CChar>(text))!
  }
  
  /**
    Used to get the32 string value of the column at a specific column in the current row.
    :param: columnIndex The index of the column.
    :returns: The int32 value of the column at the specified column in the current row.
  */
  public func int32Value(columnIndex:Int32) -> Int32 {
    let value:Int32 = sqlite3_column_int(statement.statementHandle, columnIndex)
    return value
  }
  
  /**
    Used to get the int value of the column at a specific column in the current row.
    :param: columnIndex The index of the column.
    :returns: The int value of the column at the specified column in the current row.
  */
  public func intValue(columnIndex:Int32) -> Int {
    let value = int32Value(columnIndex)
    return Int(value)
  }
  
  /**
    Used to get the double value of the column at a specific column in the current row.
    :param: columnIndex The index of the column.
    :returns: The double value of the column at the specified column in the current row.
  */
  public func doubleValue(columnIndex:Int32) -> Double {
    let value = sqlite3_column_double(statement.statementHandle, columnIndex)
    return value
  }
  
  /**
    Used to get the data value of the column at a specific column in the current row.
    :param: columnIndex The index of the column.
    :returns: The data value of the column at the specified column in the current row.
  */
  public func dataValue(columnIndex:Int32) -> NSData {
    let rawData:UnsafePointer<Void> = sqlite3_column_blob(statement.statementHandle, columnIndex)
    let size:Int = Int(sqlite3_column_bytes(statement.statementHandle, columnIndex))
    let value = NSData(bytes: rawData, length: size)
    return value
  }
  
  internal func value(columnIndex:Int32) -> Bindable? {
    let columnType = sqlite3_column_type(statement.statementHandle, columnIndex)
    if columnType == SQLITE_TEXT {
      return stringValue(columnIndex)
    }
    if columnType == SQLITE_INTEGER {
      return intValue(columnIndex)
    }
    if columnType == SQLITE_FLOAT {
      return doubleValue(columnIndex)
    }
    if columnType == SQLITE_NULL {
      return nil
    }
    if columnType == SQLITE_BLOB {
      return dataValue(columnIndex)
    }
    return nil
  }
}