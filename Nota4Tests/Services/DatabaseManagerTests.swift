import XCTest
@testable import Nota4

final class DatabaseManagerTests: XCTestCase {
    
    var dbManager: DatabaseManager!
    
    override func setUp() async throws {
        // Use default database manager
        dbManager = try DatabaseManager.default()
    }
    
    // MARK: - Test 1: Database Initialization
    
    func testDatabaseInitialization() async throws {
        // Verify database manager was created
        XCTAssertNotNil(dbManager)
        
        // Verify queue is available
        let queue = await dbManager.getQueue()
        XCTAssertNotNil(queue)
    }
    
    // MARK: - Test 2: Database Queue Access
    
    func testDatabaseQueueAccess() async throws {
        let queue = await dbManager.getQueue()
        XCTAssertNotNil(queue)
        
        // Verify we can perform a simple query
        try await queue.read { db in
            // Simple query to verify database is working
            _ = try String.fetchAll(db, sql: "SELECT name FROM sqlite_master WHERE type='table'")
        }
    }
    
    // MARK: - Test 3: Database Tables Exist
    
    func testDatabaseTablesExist() async throws {
        let queue = await dbManager.getQueue()
        
        let tables = try await queue.read { db -> [String] in
            try String.fetchAll(db, sql: "SELECT name FROM sqlite_master WHERE type='table'")
        }
        
        // Verify notes table exists
        XCTAssertTrue(tables.contains("notes"), "notes table should exist")
        
        // Verify note_tags table exists
        XCTAssertTrue(tables.contains("note_tags"), "note_tags table should exist")
    }
}

