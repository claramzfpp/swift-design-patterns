////
////  SmartRemoteProblem.swift
////  
////
////  Created by Clara Muniz on 30/01/26.
////
//
//import Foundation
//
//protocol Device {
//    func turnOn()
//    func turnOff()
//    func setVolume(_ volume: Int)
//}
//
//class Radio: Device {
//    func turnOn() {
//        print("Radio is turned on")
//    }
//    
//    func turnOff() {
//        print("Radio is turned off")
//    }
//    
//    func setVolume(_ volume: Int) {
//        print("Radio Volume set to \(volume)")
//    }
//}
//
//class RemoteControl {
//    let device: Device
//    
//    init(device: Device) {
//        self.device = device
//    }
//    
//    func turnOn() {
//        device.turnOn()
//    }
//    
//    func turnOff() {
//        device.turnOff()
//    }
//    
//    func setVolume(_ volume: Int) {
//        device.setVolume(volume)
//    }
//}
//
//class BasicRemote: RemoteControl {
//    
//}
//
//class SmartRemote: RemoteControl {
//    func setMute() {
//        print("Muting the device")
//        setVolume(0)
//    }
//}
//
//let radio = Radio()
//let basicRemote = BasicRemote(device: radio)
//basicRemote.turnOn()
//basicRemote.setVolume(7)
//basicRemote.turnOff()
//
//print("------------------------------")
//
//let smartRemote = SmartRemote(device: radio)
//smartRemote.turnOn()
//smartRemote.setVolume(3)
//smartRemote.setMute()
