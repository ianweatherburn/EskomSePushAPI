import XCTest
@testable import EskomSePushAPI

final class EskomSePushAPITests: XCTestCase {
    let esp = EskomSePushAPI(withToken: Constants.API.token,
                             offline: Constants.API.offline)
    
    private enum Constants {
        // Get your own EskomSePush API key here: https://eskomsepush.gumroad.com/l/api
        // Set the offline parameter to True to use local JSON files to test the API. In offline mode, the results wll not be accurate
        enum API {
            static let token = "C4XXXXXX-XXXXXXXX-XXXXXXXX-XXXXXX31"
            static let offline = false
        }
        
        enum Cities {
            static let capeTown: (name:String, nextStages: Int) = ("Cape Town", 8)
            static let eskom: (name: String, nextStages: Int) = ("Eskom", 4)
        }
        
        enum Allowance {
            static let limit = 50
            static let type = "daily"
        }
        
        enum AreasSearch {
            static let count = 10
            static let suburb = "constantia kloof"
        }
        
        enum AreasNearby {
            static let count = 10
            enum Coordinates {
                static let latitude = -26.0269658
                static let longitude = 28.0137339
            }
        }
        
        enum TopicsNearby {
            static let count = 10
            enum Coordinates {
                static let latitude = -26.0269658
                static let longitude = 28.0137339
            }
        }
        
        enum AreaInformation {
            static let areaID = "jhbcitypower2-11-constantiakloof"
            static let name = "Constantia Kloof (11)"
            static let region = "JHB City Power"
            static let eventsCount = 7
            static let daysCount = 7
            
            // Include the &test=current or &test=future to get SAMPLE data returned in the events. current will return a loadshedding event
            // which is occurring right now, and future will return an event starting on the next hour.
            // NOTE: The schedule returned with testing data is NOT accurate data; but only for testing purposes. The area name and
            // source is updated to identify that this is testing data. This test request will not count towards your quota.
            // static let test: Testing? = nil
            static let test: Testing = Testing.current
            static let testing = "TESTING"
        }
    }
    
    // https://documenter.getpostman.com/view/1296288/UzQuNk3E#325b0a97-08e5-405b-801a-42e7a79d5ba7
    func testStatus() async throws {
        var status: Status
        do {
            status = try await esp.status()
            XCTAssertEqual(status.cities.capeTown.name, Constants.Cities.capeTown.name)
            XCTAssertEqual(status.cities.eskom.name, Constants.Cities.eskom.name)
        } catch let error as RequestError {
            XCTFail(error.localizedDescription)
        }
    }
    
    // https://documenter.getpostman.com/view/1296288/UzQuNk3E#1881472b-c959-4259-b574-177feb5e0cda
    func testAreaInformation() async throws {
        var areaInformation: AreaInformation
        
        do {
            areaInformation = try await esp.areaInformation(id: Constants.AreaInformation.areaID,
                                                            testing: Constants.AreaInformation.test)
            if (Constants.AreaInformation.test == .current || Constants.AreaInformation.test == .future) && !Constants.API.offline
            {
                XCTAssertEqual(areaInformation.info.name, "\(Constants.AreaInformation.testing) \(Constants.AreaInformation.name)")
            } else {
                XCTAssertEqual(areaInformation.info.name, Constants.AreaInformation.name)
            }
            XCTAssertEqual(areaInformation.schedule.days.count, Constants.AreaInformation.daysCount)
        } catch let error as RequestError {
            XCTFail(error.localizedDescription)
        }
    }
    
    // https://documenter.getpostman.com/view/1296288/UzQuNk3E#4a9eeeb8-87c2-4088-8236-1ed3626e271d
    func testAreasNearby() async throws {
        var areasNearby: AreasNearby
        
        do {
            areasNearby = try await esp.areasNearby(latitude: Constants.AreasNearby.Coordinates.latitude,
                                                    longitude: Constants.AreasNearby.Coordinates.longitude)
            XCTAssertEqual(areasNearby.areas.count, Constants.AreasNearby.count)
        } catch let error as RequestError {
            XCTFail(error.localizedDescription)
        }
    }
    
    // https://documenter.getpostman.com/view/1296288/UzQuNk3E#1986b098-ad88-436c-a5cd-5aa406e2fcf2
    func testAreasSearch() async throws {
        var areasSearch: AreasSearch
        
        do {
            areasSearch = try await esp.areasSearch(Constants.AreasSearch.suburb)
            XCTAssertEqual(areasSearch.areas.count, Constants.AreasSearch.count)
        } catch let error as RequestError {
            XCTFail(error.localizedDescription)
        }
    }
    
    // https://documenter.getpostman.com/view/1296288/UzQuNk3E#6d6cdae8-64d5-4d03-ab49-d3fa87031cac
    func testTopicsNearby() async throws {
        var topicsNearby: TopicsNearby
        
        do {
            topicsNearby = try await esp.topicsNearby(latitude: Constants.TopicsNearby.Coordinates.latitude,
                                                      longitude: Constants.TopicsNearby.Coordinates.longitude)
            XCTAssertEqual(topicsNearby.topics.count, Constants.TopicsNearby.count)
        } catch let error as RequestError {
            XCTFail(error.localizedDescription)
        }
    }
    
    // https://documenter.getpostman.com/view/1296288/UzQuNk3E#10647b8e-c839-4d56-82a2-d9a406ae4f18
    func testCheckAllowance() async throws {
        var checkAllowance: CheckAllowance
        
        do {
            checkAllowance = try await esp.checkAllowance()
            print("Allowance Count: \(checkAllowance.allowance.count)")
            XCTAssertTrue(checkAllowance.allowance.count >= 0)
            XCTAssertEqual(checkAllowance.allowance.limit, Constants.Allowance.limit)
            XCTAssertEqual(checkAllowance.allowance.type, Constants.Allowance.type)
        } catch let error as RequestError {
            XCTFail(error.localizedDescription)
        }
    }
}
