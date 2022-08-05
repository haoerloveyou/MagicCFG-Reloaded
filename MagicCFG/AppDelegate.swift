//
//  AppDelegate.swift
//  MagicCFG
//
//  Created by Jan Fabel on 11.06.20.
//  Copyright © 2020 Jan Fabel. All rights reserved.
//

import Cocoa


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
     return true
    }


   
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try Data(contentsOf: Bundle.main.url(forResource: "supportedDevices", withExtension: "json")!)
                supportedDevicesJson = try JSONDecoder().decode([supportedDevicesStruct].self, from: data)
                sleep(2)
                AMRestorableDeviceRegisterForNotifications(DeviceNotificationReceived, nil, nil)

            } catch {
                print(error)
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}


func DeviceNotificationReceived(deviceList: AMRestorableDeviceRef?, Code: Int32, lol:UnsafeMutableRawPointer?) {
    DispatchQueue.global(qos: .background).async {
        switch Code {
        case 1: print("DEVICE OPERATION: __DISCONNECTED")
            g_model.removeAll()
            g_ecid.removeAll()
            g_mode.removeAll()
            NotificationCenter.default.post(name: .detectionTrigger, object: nil)
        case 0: print("DEVICE OPERATION: __CONNECTED")
                getDeviceIdentifiers(deviceList)
        default: break
        }
    }
}



var g_ecid = String()
var g_model = String()
var g_mode = String()
var global_device = String()


@_cdecl("detector_")
func detector_(x: UnsafeMutablePointer<Int8>,y: UnsafeMutablePointer<Int8>,z: UnsafeMutablePointer<Int8>, a: UnsafeMutablePointer<Int8>) {
    /// Make license check here
    
    let ecid = String(cString: x)
    let mode = NSString(string: String(cString: y)).intValue
    let cpid = String(cString: z)
    let bdid = String(cString: a)
    var mod_r = String()

    switch mode {
    case 0: mod_r = "DFU"
    case 1: mod_r = "DFU"
    case 2: mod_r = "Recovery"
    case 3: mod_r = "Recovery"
    case 4: mod_r = "Normal"

    default:
        mod_r = "Unknown"
    }

    if ecid == "" {
        g_ecid.removeAll()
        g_mode.removeAll()
        g_model.removeAll()
        global_device.removeAll()
        NotificationCenter.default.post(name: .detectionTrigger, object: nil)
        return
    } else {
        
        for devices in supportedDevicesJson {
            if cpid == "\(devices.cpid)" && bdid == "\(devices.bdid)" {
                g_ecid = ecid
                g_mode = mod_r
                g_model = devices.productName
                global_device = devices.internalName
                print(g_ecid, g_model, g_mode, global_device)
                NotificationCenter.default.post(name: .detectionTrigger, object: nil)
                return
                }
        }

        
    }
    g_ecid.removeAll()
    g_mode.removeAll()
    g_model.removeAll()
    global_device.removeAll()

    NotificationCenter.default.post(name: .detectionTrigger, object: nil)
    
    
}

extension Notification.Name {
    static let detectionTrigger = Notification.Name("triggerDetector")
    static let arduinoTrigger = Notification.Name("arduino")

}
