
public protocol GetCoordByGeoUseCaseProtocol {
    
    func execute(city: String) async throws -> LocationData
}
