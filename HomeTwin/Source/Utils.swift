import Foundation
import MapboxMaps

class Utils {

    static func getCoordinateBoundsFromPlist() -> CoordinateBounds? {
        if let swlatitude = Bundle.main.object(forInfoDictionaryKey: "swLatitude") as? NSNumber,
           let swlongitude = Bundle.main.object(forInfoDictionaryKey: "swLongitude") as? NSNumber,
           let nelatitude = Bundle.main.object(forInfoDictionaryKey: "neLatitude") as? NSNumber,
           let nelongitude = Bundle.main.object(forInfoDictionaryKey: "neLongitude") as? NSNumber {
            let sw = CLLocationCoordinate2D(latitude: swlatitude.doubleValue, longitude: swlongitude.doubleValue)
            let ne = CLLocationCoordinate2D(latitude: nelatitude.doubleValue, longitude: nelongitude.doubleValue)
            return CoordinateBounds(southwest: sw, northeast: ne)
        }
        return nil
    }

    static func loadFileFromBundle(fileName: String, fileType: String) -> String {
        guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: fileType) else {
            print("File not found in bundle")
            return ""
        }

        do {
            return try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            print("Error loading file: \(error)")
            return ""
        }
    }
    
}
