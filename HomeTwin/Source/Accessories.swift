import Foundation
import HomeKit

protocol LampDelegate {
    func lampDidUpdate()
}

// Controls both lightbulb and outlet type accessories
class Lamp: NSObject, HMAccessoryDelegate {
    let name: String
    let accessory: HMAccessory
    let powerStateCharacteristic: HMCharacteristic
    var isOn: Bool = false
    var delegate: LampDelegate? = nil
    
    init(name: String, accessory: HMAccessory, powerStateCharacteristic: HMCharacteristic) {
        self.name = name
        self.accessory = accessory
        self.powerStateCharacteristic = powerStateCharacteristic
        self.powerStateCharacteristic.enableNotification(true) { _ in }
        super.init()
        accessory.delegate = self
    }
    
    func update() {
        powerStateCharacteristic.readValue { [weak self] (error) in
            guard let self = self else { return }
            if let _ = error {
                // Unreachable, but has light service so consider it off
                self.isOn = false
            } else if let isOnValue = self.powerStateCharacteristic.value as? Bool {
                self.isOn = isOnValue
            }
            self.delegate?.lampDidUpdate()
        }
    }
    
    func toggle() {
        for service in accessory.services {
            if service.serviceType == HMServiceTypeLightbulb || service.serviceType == HMServiceTypeOutlet {
                for characteristic in service.characteristics {
                    if characteristic.characteristicType == HMCharacteristicTypePowerState {
                        characteristic.readValue { error in
                            if let error = error {
                                print("Error reading value: \(error.localizedDescription)")
                                return
                            }
                            
                            if let currentValue = characteristic.value as? Bool {
                                let newValue = !currentValue
                                characteristic.writeValue(newValue) { error in
                                    if let error = error {
                                        print("Error writing value: \(error.localizedDescription)")
                                    } else {
                                        print("Lamp toggled to \(newValue ? "ON" : "OFF")")
                                    }
                                    self.update()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func accessoryDidUpdateServices(_ accessory: HMAccessory) {
        self.update()
    }
    
    func accessory(_ accessory: HMAccessory, service: HMService, didUpdateValueFor characteristic: HMCharacteristic) {
        self.update()
    }
    
    static func getLampCharacteristic(accessory: HMAccessory) -> HMCharacteristic? {
        for service in accessory.services {
            if service.serviceType == HMServiceTypeLightbulb || service.serviceType == HMServiceTypeOutlet {
                for characteristic in service.characteristics {
                    if characteristic.characteristicType == HMCharacteristicTypePowerState {
                        return characteristic
                    }
                }
            }
        }
        return nil
    }
}

protocol SensorDelegate {
    func sensorDidUpdate()
}

class TemperatureSensor: NSObject, HMAccessoryDelegate {
    let name: String
    let accessory: HMAccessory
    let currentTemperatureCharacteristic: HMCharacteristic // HMCharacteristicTypeCurrentTemperature
    var delegate: SensorDelegate? = nil
    var temperature: Double? = nil
    
    init(name: String, accessory: HMAccessory, currentTemperatureCharacteristic: HMCharacteristic) {
        self.name = name
        self.accessory = accessory
        self.currentTemperatureCharacteristic = currentTemperatureCharacteristic
        self.currentTemperatureCharacteristic.enableNotification(true) { _ in }
        super.init()
        accessory.delegate = self
    }
    
    func update() {
        currentTemperatureCharacteristic.readValue { [weak self] (error) in
            guard let self = self else { return }
            if let value = self.currentTemperatureCharacteristic.value as? Double {
                self.temperature = value
            } else {
                self.temperature = nil
            }
            self.delegate?.sensorDidUpdate()
        }
    }

    static func geTemperatureCharacteristic(accessory: HMAccessory) -> HMCharacteristic? {
        for service in accessory.services {
            for characteristic in service.characteristics {
                if characteristic.characteristicType == HMCharacteristicTypeCurrentTemperature {
                    return characteristic
                }
            }
        }
        return nil
    }
}


