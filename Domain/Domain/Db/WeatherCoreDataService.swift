import Foundation
import UIKit
import CoreData
import Utils
import Data

public final class WeatherCoreDataService {

    public static let shared = WeatherCoreDataService()
    
    public var locations: [Location] = []
    
    lazy var persistentContainer: NSPersistentContainer = {
        guard let modelURL = Bundle(for: WeatherCoreDataService.self).url(forResource: "WeatherModel", withExtension: "momd"),
              let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to load model WeatherModel")
        }

        let container = NSPersistentContainer(name: "WeatherModel", managedObjectModel: managedObjectModel)
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    public func getAllLocations() {
        let request = Location.fetchRequest()
        if let locations = try? context.fetch(request) {
            self.locations = locations
        }
    }
    
    public func addLocation(locationData: LocationData) {
        let fetchRequest: NSFetchRequest<Location> = Location.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "location == %@", locationData.location ?? String.empty)
        
        do {
            let existingLocations = try context.fetch(fetchRequest)
            if existingLocations.isEmpty {
                let location = Location(context: context)
                location.location = locationData.location
                location.isSelected = true
                location.temperature = locationData.temperature
                location.temperatureRange = locationData.temperatureRange
                location.weatherIcon = locationData.weatherIcon
                
                saveContext()
                getAllLocations()
            } else {
                print("Location \(String(describing: locationData.location)) already exist in db")
            }
        } catch {
            print("Error while checking location: \(error.localizedDescription)")
        }
    }
    
    public func deleteLocation(at index: Int) {
        let locationToDelete = locations[index]
        context.delete(locationToDelete)
        locations.remove(at: index)
        saveContext()
    }
}
