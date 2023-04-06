import Foundation

final public class EskomSePushAPI {
    private let token: String
    private let offline: Bool
    
    /// The EskomSePush API Authentication token can be obtained from [Gumroad](https://eskomsepush.gumroad.com/l/api)
    /// - parameters:
    ///     - withAPIKey: UUID String - The unique token/key provided by EskomSePush
    ///     - offline: Bool - If true, local JSON resources will be used instead of actively calling the API and incurring token credits. The offline mode will not reflect accurate results.
    ///
    public init(withToken token: String,
                offline: Bool = false) {
        self.token = token
        self.offline = offline
    }

    /// The current and next loadshedding statuses for South Africa and (Optional) municipal overrides
    /// [**GET Status**](https://documenter.getpostman.com/view/1296288/UzQuNk3E#325b0a97-08e5-405b-801a-42e7a79d5ba7:~:text=GET-,Status,-GET)
    /// eskom is the National status
    /// Other keys in the status refer to different municipalities and potential overrides from the National status; most typically present is the key for capetown
    /// - Returns:Status
    public func status() async throws -> Status {
        if offline {
            return try Bundle.module.decode(Status.self, from: Constants.JSON.status)
        } else {
            return try await StatusService().getStatus(with: token)
        }
    }

    /// Obtain the id from Area Find or Area Search and use with this request. This single request has everything you need to monitor upcoming loadshedding events for the chosen suburb.
    /// [**GET Area Information**](https://documenter.getpostman.com/view/1296288/UzQuNk3E#1881472b-c959-4259-b574-177feb5e0cda:~:text=Area-,Information,-GET)
    /// - parameters:
    ///     - id: The area id returned from an area text search or an area GPS search
    /// - Returns:AreaInformation
    /// + ```name & region```: Self-explanatory
    /// + ```events```: A sorted list of events
    ///     + start & end times listing when it will be impacted by load-shedding. Will be an empty list if not impacted
    /// + ```schedule```
    ///     + Raw loadshedding schedule, per stage (1-8)
    ///     + Formatted for display purposes (i.e. 20:00-22:30)
    ///     + Any adjacent events have been merged into a single event (e.g. 12:00-14:30 & 14:00-16:30 become 12:00-16:30)
    ///     + Note: __An empty list means no events for stage stage__
    ///     + Note: __Some municipalities/Regions don't have Stage 5-9 schedules (and there will be 4 records instead of 8 in this list. Stage 5 upwards you can assume Stage 4 schedule impact)__
    public func areaInformation(id: String, testing: Testing? = nil) async throws -> AreaInformation {
        if offline {
            return try Bundle.module.decode(AreaInformation.self, from: Constants.JSON.areaInformation)
        } else {
            return try await AreaInformationService().getAreaInformation(area: id, with: token, test: testing)
        }
    }
    
    /// Find areas based on GPS coordinates (latitude and longitude). The first area returned is typically the best choice for the coordinates - as it's closest to the GPS coordinates provided. However it could be that you are in the second or third area.
    /// [**GET Areas Nearby (GPS)**](https://documenter.getpostman.com/view/1296288/UzQuNk3E#4a9eeeb8-87c2-4088-8236-1ed3626e271d:~:text=GET-,Areas%20Nearby%20(GPS),-GET)
    /// - parameters:
    ///     - lat: GPS latitude coordinates
    ///     - lon: GPS longitude coordinates
    /// - Returns:AreasNearby
    /// + ```count```: Always -1
    /// + ```id```: A unique area id that can be used in the AreaInformation call
    /// + ```name```: Descriptive area name
    /// + ```region```: Descriptive region name ('City of Cape Town' for Status.cities.capeTown or prefixed with 'Eskom Direct' for Status.citites.eskom
    public func areasNearby(latitude lat: Double, longitude lon: Double) async throws -> AreasNearby {
        if offline {
            return try Bundle.module.decode(AreasNearby.self, from: Constants.JSON.areasNearby)
        } else {
            return try await AreasNearbyService().getAreasNearby(latitude: lat, longitude: lon, with: token)
        }
    }
    
    /// Search area based on text
    /// [**GET Areas Search (Text)**](https://documenter.getpostman.com/view/1296288/UzQuNk3E#1986b098-ad88-436c-a5cd-5aa406e2fcf2:~:text=GET-,Areas%20Search%20(Text),-GET)
    /// - parameters:
    ///     - text: Suburb name to search for
    /// - Returns:AreasSearch
    /// + ```id```: A unique area id that can be used in the AreaInformation call
    /// + ```name```: Descriptive area name
    /// + ```region```: Descriptive region name ('Western Cape' for Status.cities.capeTown or prefixed with 'Eskom Direct' for Status.citites.eskom
    public func areasSearch(_ area: String) async throws -> AreasSearch {
        if offline {
            return try Bundle.module.decode(AreasSearch.self, from: Constants.JSON.areasSearch)
        } else {
            return try await AreasSearchService().getAreasSearch(area, with: token)
        }
    }

    /// Find topics created by users based on GPS coordinates (latitude and longitude). Can use this to detect if there is a potential outage/problem nearby.
    /// [**GET Topics Nearby*](https://documenter.getpostman.com/view/1296288/UzQuNk3E#1986b098-ad88-436c-a5cd-5aa406e2fcf2:~:text=GET-,Topics%20Nearby,-GET)
    /// - parameters:
    ///     - lat: GPS latitude coordinates
    ///     - lon: GPS longitude coordinates
    /// - Returns:TopicsNearby
    /// + ```active```: The posters last online date and time
    /// + ```body```: Message text
    /// + ```category```: Topics.category (electricity, water etc)
    /// + ```distance```: The message posters estimated distance in km away from the user
    /// + ```followers```: The posters follower count
    /// + ```timestamp```: Date and time when message was posted
    public func topicsNearby(latitude lat: Double, longitude lon: Double) async throws -> TopicsNearby {
        if offline {
            return try Bundle.module.decode(TopicsNearby.self, from: Constants.JSON.topicsNearby)
        } else {
            return try await TopicsNearbyService().getTopicsNearby(latitude: lat, longitude: lon, with: token)
        }
    }

    //
    //
    //

    /// Check allowance allocated for token provided. Each token is allocated a quota (typically daily usage). Once this usage has been exceeded; requests will be blocked until quota is available again.  Do not share your token. You should only be doing requests from a single IP (not multiple simultaneously). Each individual must have their own token linked to a valid email address.
    ///  **Note**: This call doesn't count towards your quota.
    /// [**GET Check Allowance)**](https://documenter.getpostman.com/view/1296288/UzQuNk3E#10647b8e-c839-4d56-82a2-d9a406ae4f18:~:text=GET-,Check%20allowance,-EskomSePush%20API%202.0)
    /// - Returns:CheckAllowance
    /// + ```count```: Remaining token quota.
    /// + ```limit```: Maximum token count allowed on your subscription [EskomSePush API Subscription](https://eskomsepush.gumroad.com/l/api)
    /// + ```type```: Typically 'Daily' but dependant on your subscription type
    public func checkAllowance() async throws -> CheckAllowance {
        if offline {
            return try Bundle.module.decode(CheckAllowance.self, from: Constants.JSON.allowance)
        } else {
            return try await AllowanceService().checkAllowance(with: token)
        }
    }
    
    private enum Constants {
        enum JSON {
            static let allowance = "checkAllowance.json"
            static let status = "status.json"
            static let areasSearch = "areasSearch.json"
            static let areasNearby = "areasNearby.json"
            static let topicsNearby = "topicsNearby.json"
            static let areaInformation = "areaInformation.json"
        }
    }
}
