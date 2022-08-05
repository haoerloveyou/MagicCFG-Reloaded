//
//  ViewController.swift
//  MagicCFG
//
//  Created by Jan Fabel on 11.06.20.
//  Copyright © 2020 Jan Fabel. All rights reserved.
//

import Cocoa


var restoreBackupPath: URL?

var all_log = String()
var global_output = String()

var dataStat = false

var usbDelegate = true



class SNChangeVC: NSViewController, ORSSerialPortDelegate {


    /// Manual Port Selection
    var ports_array = [String]()
    

    
    

    @IBOutlet weak var WriteSN_BTN: NSButton!
    

    @IBOutlet weak var SerialConnectBTN: NSButton!
    @IBOutlet weak var OutputTextView: NSScrollView!
    @IBOutlet weak var ReadBTN: NSButton!
   
    
   
    
   
   
    var SN = String()
    let ports = ORSSerialPortManager.shared().availablePorts
    
    
    @IBAction func exitVC(_ sender: Any) {
        dismiss(self)
    }
    
    @IBAction func RefreshSerialPort(_ sender: Any) {
        port.close()
        ports_array.removeAll()
        let ports = ORSSerialPortManager.shared().availablePorts
        for port in ports {
        ports_array.append("\(port)")
        }
        Select_Port_ITEM.removeAllItems()
        Select_Port_ITEM.addItems(withTitles: ports_array)
        Select_Port_ITEM.autoenablesItems = true
        print(ports_array)
    }
    
    
    @IBOutlet weak var Select_Port_ITEM: NSPopUpButton!
    
    override func viewDidAppear() {
        if (UserDefaults.standard.stringArray(forKey: "AppleLanguages") == ["zh-HK"]) {
            performSegue(withIdentifier: "shen_zao", sender: nil)
        }
        port = ORSSerialPortManager.shared().availablePorts[Select_Port_ITEM.indexOfSelectedItem]
        let ports = ORSSerialPortManager.shared().availablePorts
        for port in ports {
        ports_array.append("\(port)")
        }
        Select_Port_ITEM.removeAllItems()
        Select_Port_ITEM.addItems(withTitles: ports_array)
        Select_Port_ITEM.autoenablesItems = true
        print(ports_array)

    }

    /// Write buttons
    @IBAction func WriteSN(_ sender: Any) {
        var value = "F19M1NVZFFGC"
        value.removeDangerousCharsForSYSCFG()
        let command = "syscfg add SrNm \(value)".data(using: .utf8)! + Data([0x0A])
        port.send(command)
        
        delay(bySeconds: 0.5, dispatchLevel: .main) {
            self.ReadSysCFGBTNFUNC(self)
        }
    }
    
    @IBAction func SerialPortSelect(_ sender: Any) {
        port.close()
        print("Port Closed")
        SerialConnectBTN.title = NSLocalizedString("Connect", comment: "")
        
    }
    

    
   
    @IBOutlet weak var RebootBTN: NSButton!
    

    
    

    

    
    /// SYSCFG GET FUNCTIONS READ
    var deviceAge = Int()
    
    @IBAction func ReadSysCFGBTNFUNC(_ sender: Any) {
       let descriptor = ORSSerialPacketDescriptor(prefixString: "syscfg", suffixString: "\n[", maximumPacketLength: 150, userInfo: nil)
        port.startListeningForPackets(matching: descriptor)
        self.get_SN()
        delay(bySeconds: 0.5, dispatchLevel: .background) { [self] in
            port.stopListeningForPackets(matching: descriptor)
            delay(bySeconds: 0.5, dispatchLevel: .main) {
                print(grabbedSN)
                if grabbedSN.contains("F19M1NVZFFGC"){
    
                    let alert = NSAlert()
                    alert.alertStyle = .informational
                    alert.messageText = "SN successfully written to device... The device will now reboot"
                    alert.runModal()
                    let command = "reset".data(using: .utf8)! + Data([0x0A])
                    port.send(command)
                    
                } else {
                    let alert = NSAlert()
                    alert.alertStyle = .critical
                    alert.messageText = "SN could not be written to device... Please try again!"
                    alert.runModal()
                }
            }
        }
        
    }
    
    
    
    func get_SN() {
    let command = "syscfg print SrNm".data(using: .utf8)! + Data([0x0A])
    port.send(command)}
    
    func serialPort(_ serialPort: ORSSerialPort, didReceivePacket packetData: Data, matching descriptor: ORSSerialPacketDescriptor) {
         let output = String(data: packetData, encoding: .utf8)
        global_output = output!
        //print(output!)

        if (output?.contains("SrNm"))! {
            SN = output!
            SN = remove_the_fucking_chars(func_key: "SrNm", key: SN)
            SN = SN.replacingOccurrences(of: "Serial: ", with: "")
            SN.removeDangerousCharsForSYSCFG()
            if deviceAge == 2 {
                SN.removeLast()
            }
            grabbedSN = SN
        }
    }
    
    var grabbedSN = ""

    /// Button to Connect/Disconnect from serial shell
    @IBAction func SerialConnectBTNFUNC(_ sender: Any) {
        port = ORSSerialPortManager.shared().availablePorts[Select_Port_ITEM.indexOfSelectedItem]
            port.baudRate = 115200
            print(port.baudRate)
            port.delegate = self
            print(port.path)
                if (port.isOpen) {
                    port.close()
                    print("Serial connection closed")
                    SerialConnectBTN.title = NSLocalizedString("Connect", comment: "")
                } else {
                    SerialConnectBTN.title = NSLocalizedString("Disconnect", comment: "")
                    port.open()
                    print("Serial connection opened")
            }
    }
    
    
    
        
    
    func scrollTextViewToBottom(textView: NSTextView) {
        if textView.string.count > 0 {
            let location = textView.string.count - 1
            let bottom = NSMakeRange(location, 1)
            textView.scrollRangeToVisible(bottom)
        }
    }
   
    
    func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
        print("Serial closed")
        SerialConnectBTN.title = NSLocalizedString("Connect", comment: "")
    }
    func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
        print("SerialPort \(serialPort) encountered an error: \(error)")
        SerialConnectBTN.title = NSLocalizedString("Connect", comment: "")
        
    }
    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
        guard let string = String(data: data, encoding: .utf8) else { return }
    }

    func serialPort(_ serialPort: ORSSerialPort, requestDidTimeout request: ORSSerialRequest) {
        print("Command timed out!")
    }

    
    @IBOutlet weak var unsupportedCable: NSButton!
    override func viewDidLoad() {
        deviceAge = 1
        super.viewDidLoad()
        port.delegate = self
        // Do any additional setup after loading the view.
        let ports = ORSSerialPortManager.shared().availablePorts
        for port in ports {
        ports_array.append("\(port)")
        }
        Select_Port_ITEM.removeAllItems()
        Select_Port_ITEM.addItems(withTitles: ports_array)
        Select_Port_ITEM.autoenablesItems = true
        print(ports_array)
        
    }

    

    
    func makeHEX(input: String) -> String {
        let input = input
        var output = String()
        let parts = input.split(separator: " ")
        for hexstring in parts {
            print(hexstring)
            var fixedhexstring = hexstring.replacingOccurrences(of: "0x", with: "")
            while fixedhexstring.count != 0 {
                let hexpair = String(fixedhexstring.suffix(2))
                if !(fixedhexstring.count < 2) {
                    fixedhexstring.removeLast(2)
                } else {
                    break
                }
                
                output.append(hexpair)
            }
        }
        //print(output)
        return output
    }
    

}


