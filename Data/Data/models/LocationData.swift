
public struct LocationData {
    public let location: String?
    public let temperature: String?
    public let temperatureRange: String?
    public let weatherIcon: String?
    
    public init(
        location: String? = nil,
        temperature: String? = nil,
        temperatureRange: String? = nil,
        weatherIcon: String? = nil
    ) {
        self.location = location
        self.temperature = temperature
        self.temperatureRange = temperatureRange
        self.weatherIcon = weatherIcon
    }
}
