import Foundation
import HomeKit
import MapboxMaps

class HomeController: NSObject {
    
    var homeManager: HMHomeManager!
    var lamps: [Lamp] = []
    var sensors: [TemperatureSensor] = []
    var map: MapboxMap? {
        didSet {
            updateStates()
        }
    }
    let source = Utils.loadFileFromBundle(fileName: "home", fileType: "geojson")
    var selectedLevel = 0
    private var mapTapQuery: Cancelable?

    override init() {
        super.init()
        homeManager = HMHomeManager()
        homeManager.delegate = self
    }
        
    // Handle interactions on map:
    // - Turn lamp on/off
    // - Change level
    func mapTapped(_  context: InteractionContext) {
        mapTapQuery?.cancel()
        mapTapQuery = map?.queryRenderedFeatures(with: context.point, options: RenderedQueryOptions(layerIds: ["lamps", "staircase"], filter: nil)) { [self] result in
            mapTapQuery = nil
            switch result {
            case .success(let queryResult):
                for result in queryResult {
                    if result.layers.contains("staircase") {
                        selectedLevel = selectedLevel == 0 ? 1 : 0
                        updateStates()
                        break;
                    } else if let properties = result.queriedFeature.feature.properties, let nameValue = properties["name"], let name = nameValue?.string {
                        if let lamp = lamps.first(where: { $0.name == name }) {
                            lamp.toggle()
                            break;
                        }
                    }
                }
            case .failure(_):
                return
            }
        }
    }

    // Send source update to the map based on the state of the accessories
    private func updateStates() {
        guard let map = map else { return }
        if lamps.isEmpty { return }
        
        var updatedSource = source
        for lamp in lamps {
            updatedSource = updatedSource.replacingOccurrences(of: "\"name\": \"\(lamp.name)\"", with: "\"name\": \"\(lamp.name)\", \"isOn\": \(lamp.isOn)")
        }
        
        for sensor in sensors {
            if let temperature = sensor.temperature {
                updatedSource = updatedSource.replacingOccurrences(of: "\"name\": \"\(sensor.name)\"", with: "\"name\": \"\(sensor.name)\", \"temperature\": \(temperature)")
            } else {
                updatedSource = updatedSource.replacingOccurrences(of: "\"name\": \"\(sensor.name)\"", with: "\"name\": \"\(sensor.name)\", \"temperature\": \"\"")
            }
        }

        updatedSource = updatedSource.replacingOccurrences(of: "\"level\":", with: "\"selected-level\": \(selectedLevel), \"level\":")
        
        map.updateGeoJSONSource(withId: "home", data: .string(updatedSource))
    }
}

extension HomeController: HMHomeManagerDelegate {

    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        guard let primaryHome = manager.homes.first else {
            print("No homes found.")
            return
        }
        let accessories = primaryHome.accessories
        guard !accessories.isEmpty else {
            print("No accessories found in \(primaryHome.name).")
            return
        }
        lamps = []
        sensors = []
        for accessory in accessories {
            let name = "\(accessory.room?.name ?? "NA") - \(accessory.name)"
            if let chr = Lamp.getLampCharacteristic(accessory: accessory) {
                let lamp = Lamp(name: name, accessory: accessory, powerStateCharacteristic: chr)
                lamps.append(lamp)
                lamp.delegate = self
                lamp.update()
            } else if let chr = TemperatureSensor.geTemperatureCharacteristic(accessory: accessory) {
                let sensor = TemperatureSensor(name: name, accessory: accessory, currentTemperatureCharacteristic: chr)
                sensors.append(sensor)
                sensor.delegate = self
                sensor.update()
            }
        }
        updateStates()
    }

}

extension HomeController: LampDelegate {
    func lampDidUpdate() { self.updateStates() }
}

extension HomeController: SensorDelegate {
    func sensorDidUpdate() { self.updateStates() }
}
