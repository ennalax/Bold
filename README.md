![Alt text](/GFX/logo.png?raw=true "Bold Logo")

A lightweight and extensible SQLite wrapper written in Swift.  


# Why yet another SQLite wrapper?
I wanted to dive into Swift and writing a SQLite wrapper seemed like a good thing to do. So **Bold** is basically a just for fun project. 


# Simple Example
The example below creates an in-memory database, opens it, creates a table, inserts a row and then queries the table. Please note that the result is closed automatically after a complete iteration by using `for-in`.

    let db = Database(URL:":memory:")
    db.open()
    db.executeUpdate("CREATE TABLE Person (firstName, lastName)")
    
    let args = ["firstName" : "Christian", "lastName" : "Kienle"]
    db.executeUpdate("INSERT INTO Person (firstName, lastName) VALUES (:firstName, :lastName)", arguments:args)
    
    let result = db.executeQuery("SELECT firstName, lastName FROM Person")
    for row in result {
    	if let firstName = row.stringValue("firstName") {
    		println("firstName: \(firstName)")
    	}
    	if let lastName = row.stringValue("lastName") {
    		println("lastName: \(lastName)")
    	}
    }
    
    // The result is automatically closed after a complete iteration.

# Extend Bold: Custom Types
I wanted **Bold** to be easily extensible. There are basically two things that can be extended:

1. Support for custom data types in the input arguments.
2. Support for custom data types when accessing a row.

## Extend Types for Input Arguments
You can support custom data types for input arguments simply by implementing `Bindable`. Lets assume you have a custom class called `UUID` which represents a UUID and you would like to pass UUIDs to **Bold** when inserting a new row. You could implement `Bindable` by doing something like this:

    extension UUID : Bindable {
      public func bindTo(statement:Statement, atIndex:Int32) -> Bool {
  	    let value = stringRepresentation // assume this exists
  	    // call the existing implementation of `bindTo(statement:atIndex:)`
  	    return value.bindTo(statement, atIndex:atIndex)
    }
    
This is all you have to do. Now you could use UUID like this in combination with **Bold**:

	let uuid = UUID()
    db.executeUpdate("INSERT INTO Person (id) VALUES (:id)", arguments:["id" : uuid])
    
## Extend Types for Output Arguments
When you access the contents of a row you access the data by using methods like `stringValue(columnName:)`, `intValue(columnName:)` and so on. If you would like to add support for your own data type (for example a method that uses the binary data in a column to create a `UIImage`) you simply extend `Row`. Let's see how this works with our custom `UUID` class from above.

    extension Row {
        public func UUIDValue(columnName: String) -> UUID? {
        	if let stringValue = stringValue(columnName) {
        		return UUID(stringValue)
        	}
        	return nil
        } 
    }
    
Now you can use `UUIDValue(columnName:)` when accessing the data of your rows.

# Lightweight
**Bold** is lightweight.

