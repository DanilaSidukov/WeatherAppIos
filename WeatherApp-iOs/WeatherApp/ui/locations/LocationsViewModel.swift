import Domain

final class LocationsViewModel {
    
    private let getCoordByGeoUseCase: GetCoordByGeoUseCase
    
    init(getCoordByGeoUseCase: GetCoordByGeoUseCase) {
        self.getCoordByGeoUseCase = getCoordByGeoUseCase
    }
    
    func loadLocations() {
        WeatherCoreDataService.shared.getAllLocations()
    }
    
    func getLocations() -> [Location] {
        return WeatherCoreDataService.shared.locations
    }
    
    func addLocation(city: String) async throws {
        let response = try await self.getCoordByGeoUseCase.execute(city: city)
        WeatherCoreDataService.shared.addLocation(locationData: response)
    }
    
    func deleteLocation(at index: Int) {
        WeatherCoreDataService.shared.deleteLocation(at: index)
    }
}
