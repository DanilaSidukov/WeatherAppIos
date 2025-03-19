import Utils
import Domain
import UIKit

extension Location {
    
    func convertToLocationItemView() -> LocationItemView {
        return LocationItemView(
            location: self.location ?? String.empty,
            isSelected: self.isSelected,
            temperature: self.temperature ?? String.empty,
            temperatureRange: self.temperatureRange ?? String.empty,
            weatherIcon: UIImage(named: self.weatherIcon ?? "ic_cloud_black_with_sun")!
        )
    }
}
