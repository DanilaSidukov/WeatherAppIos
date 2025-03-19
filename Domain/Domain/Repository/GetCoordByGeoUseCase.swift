import Foundation
import OSLog
import Data

public class GetCoordByGeoUseCase: GetCoordByGeoUseCaseProtocol {
    
    public init() {
        
    }
    
    public func execute(city: String) async throws -> LocationData {
        return try await LocationRepository.shared.getLocationData(city: city)
    }
}

