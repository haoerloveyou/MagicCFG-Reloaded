import Cocoa
import RNCryptor
import ZIPFoundation
import Kronos


var ecid_for_restore = String()


var supportedDevicesJson = [supportedDevicesStruct]()


class PurpleViewController: NSViewController, NSAlertDelegate {
    
    
    var temp_block = false
    
    
    @IBOutlet weak var ProgressB: NSProgressIndicator!
    
    @IBOutlet weak var OutputLBL: NSTextField!
    @IBOutlet var OutPutLogField: NSTextView!
    
    @IBOutlet weak var OutputFieldGlobal: NSScrollView!

    
    var connectedDeviceModel = String()
    var deviceDetectionHandler:Bool = true
    var runTask = true
        
    
    @IBAction func DismissVie(_ sender: Any) {
        deviceDetectionHandler = false
        runTask = false
        self.dismiss(sender)
        usbDelegate = false
    }

    @objc func deviceDetection(_ notification: Notification) {
        
        if deviceDetectionHandler == false { return }
    
        if g_ecid != "" && g_mode != "Normal" {
            DispatchQueue.main.async { [self] in
                self.ConnectedString.stringValue = "\(g_model) in \(g_mode) | \(g_ecid)"
                GoBTN.isEnabled = true
                connectedDeviceModel = global_device
                
            }
        } else {
        DispatchQueue.main.async { [self] in
            self.ConnectedString.stringValue = "Waiting for device in DFU Mode"
            GoBTN.isEnabled = false
            connectedDeviceModel = ""
        }
        }
    }
            

    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Clock.sync(completion:  { date, offset in
            print(date)
        })
        
        var windowFrame = self.view.frame
        windowFrame.size = NSMakeSize(450, 333)
        self.view.window?.setFrame(windowFrame,display: true, animate: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceDetection(_:)), name: .detectionTrigger, object: nil)

        ProgressB.doubleValue = 0
        ProgressB.minValue = 0
        ProgressB.maxValue = 100
        //self.CircProgress.progress = 1
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try Data(contentsOf: Bundle.main.url(forResource: "supportedDevices", withExtension: "json")!)
                supportedDevicesJson = try JSONDecoder().decode([supportedDevicesStruct].self, from: data)
            } catch {
                print(error)
            }
        }

        self.GoBTN.isEnabled = false
        NotificationCenter.default.post(name: .detectionTrigger, object: nil)

    }
        
    @IBAction func Go(_ sender: Any) {
        Go_now()
    }
    
    @IBOutlet weak var pwnItem: NSTextField!
    @IBOutlet weak var DownloadItem: NSTextField!
    @IBOutlet weak var PatchItem: NSTextField!
    @IBOutlet weak var Stage1Item: NSTextField!
    @IBOutlet weak var Stage2Item: NSTextField!
    @IBOutlet weak var Stage3Item: NSTextField!
    @IBOutlet weak var CleanItem: NSTextField!
    
    func progSetString(stat:Int) {
        DispatchQueue.main.async { [self] in
            switch stat {
            case 0: ConnectedString.font = .systemFont(ofSize: 17, weight: .heavy)
                pwnItem.font = .systemFont(ofSize: 13, weight: .regular)
                DownloadItem.font = .systemFont(ofSize: 13, weight: .regular)
                PatchItem.font = .systemFont(ofSize: 13, weight: .regular)
                Stage1Item.font = .systemFont(ofSize: 13, weight: .regular)
                Stage2Item.font = .systemFont(ofSize: 13, weight: .regular)
                Stage3Item.font = .systemFont(ofSize: 13, weight: .regular)
                CleanItem.font = .systemFont(ofSize: 13, weight: .regular)
            case 1: ConnectedString.font = .systemFont(ofSize: 13, weight: .regular)
                pwnItem.font = .systemFont(ofSize: 17, weight: .heavy)
                DownloadItem.font = .systemFont(ofSize: 13, weight: .regular)
                PatchItem.font = .systemFont(ofSize: 13, weight: .regular)
                Stage1Item.font = .systemFont(ofSize: 13, weight: .regular)
                Stage2Item.font = .systemFont(ofSize: 13, weight: .regular)
                Stage3Item.font = .systemFont(ofSize: 13, weight: .regular)
                CleanItem.font = .systemFont(ofSize: 13, weight: .regular)
            case 2: ConnectedString.font = .systemFont(ofSize: 13, weight: .regular)
                pwnItem.font = .systemFont(ofSize: 13, weight: .regular)
                DownloadItem.font = .systemFont(ofSize: 17, weight: .heavy)
                PatchItem.font = .systemFont(ofSize: 13, weight: .regular)
                Stage1Item.font = .systemFont(ofSize: 13, weight: .regular)
                Stage2Item.font = .systemFont(ofSize: 13, weight: .regular)
                Stage3Item.font = .systemFont(ofSize: 13, weight: .regular)
                CleanItem.font = .systemFont(ofSize: 13, weight: .regular)
            case 3: ConnectedString.font = .systemFont(ofSize: 13, weight: .regular)
                pwnItem.font = .systemFont(ofSize: 13, weight: .regular)
                DownloadItem.font = .systemFont(ofSize: 13, weight: .regular)
                PatchItem.font = .systemFont(ofSize: 17, weight: .heavy)
                Stage1Item.font = .systemFont(ofSize: 13, weight: .regular)
                Stage2Item.font = .systemFont(ofSize: 13, weight: .regular)
                Stage3Item.font = .systemFont(ofSize: 13, weight: .regular)
                CleanItem.font = .systemFont(ofSize: 13, weight: .regular)
            case 4: ConnectedString.font = .systemFont(ofSize: 13, weight: .regular)
                pwnItem.font = .systemFont(ofSize: 13, weight: .regular)
                DownloadItem.font = .systemFont(ofSize: 13, weight: .regular)
                PatchItem.font = .systemFont(ofSize: 13, weight: .regular)
                Stage1Item.font = .systemFont(ofSize: 17, weight: .heavy)
                Stage2Item.font = .systemFont(ofSize: 13, weight: .regular)
                Stage3Item.font = .systemFont(ofSize: 13, weight: .regular)
                CleanItem.font = .systemFont(ofSize: 13, weight: .regular)
            case 5: ConnectedString.font = .systemFont(ofSize: 13, weight: .regular)
                pwnItem.font = .systemFont(ofSize: 13, weight: .regular)
                DownloadItem.font = .systemFont(ofSize: 13, weight: .regular)
                PatchItem.font = .systemFont(ofSize: 13, weight: .regular)
                Stage1Item.font = .systemFont(ofSize: 13, weight: .regular)
                Stage2Item.font = .systemFont(ofSize: 17, weight: .heavy)
                Stage3Item.font = .systemFont(ofSize: 13, weight: .regular)
                CleanItem.font = .systemFont(ofSize: 13, weight: .regular)
            case 6: ConnectedString.font = .systemFont(ofSize: 13, weight: .regular)
                pwnItem.font = .systemFont(ofSize: 13, weight: .regular)
                DownloadItem.font = .systemFont(ofSize: 13, weight: .regular)
                PatchItem.font = .systemFont(ofSize: 13, weight: .regular)
                Stage1Item.font = .systemFont(ofSize: 13, weight: .regular)
                Stage2Item.font = .systemFont(ofSize: 13, weight: .regular)
                Stage3Item.font = .systemFont(ofSize: 17, weight: .heavy)
                CleanItem.font = .systemFont(ofSize: 13, weight: .regular)
            case 7: ConnectedString.font = .systemFont(ofSize: 13, weight: .regular)
                pwnItem.font = .systemFont(ofSize: 13, weight: .regular)
                DownloadItem.font = .systemFont(ofSize: 13, weight: .regular)
                PatchItem.font = .systemFont(ofSize: 13, weight: .regular)
                Stage1Item.font = .systemFont(ofSize: 13, weight: .regular)
                Stage2Item.font = .systemFont(ofSize: 13, weight: .regular)
                Stage3Item.font = .systemFont(ofSize: 13, weight: .regular)
                CleanItem.font = .systemFont(ofSize: 17, weight: .heavy)
            case 8: ConnectedString.font = .systemFont(ofSize: 17, weight: .heavy)
                pwnItem.font = .systemFont(ofSize: 17, weight: .heavy)
                DownloadItem.font = .systemFont(ofSize: 17, weight: .heavy)
                PatchItem.font = .systemFont(ofSize: 17, weight: .heavy)
                Stage1Item.font = .systemFont(ofSize: 17, weight: .heavy)
                Stage2Item.font = .systemFont(ofSize: 17, weight: .heavy)
                Stage3Item.font = .systemFont(ofSize: 17, weight: .heavy)
                CleanItem.font = .systemFont(ofSize: 17, weight: .heavy)
            default:
                ConnectedString.font = .systemFont(ofSize: 13, weight: .regular)
                    pwnItem.font = .systemFont(ofSize: 13, weight: .regular)
                    DownloadItem.font = .systemFont(ofSize: 13, weight: .regular)
                    PatchItem.font = .systemFont(ofSize: 13, weight: .regular)
                    Stage1Item.font = .systemFont(ofSize: 13, weight: .regular)
                    Stage2Item.font = .systemFont(ofSize: 13, weight: .regular)
                    Stage3Item.font = .systemFont(ofSize: 13, weight: .regular)
                    CleanItem.font = .systemFont(ofSize: 13, weight: .regular)
            }
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    @IBAction func Cancel(_ sender: Any) {
        runTask = false
    }
    
    @IBOutlet weak var USBSERIAL: NSButton!
    
    
    
    func getBootchain() {
        if !runTask {DispatchQueue.main.async {
            self.ConnectedString.stringValue = NSLocalizedString("Canceled", comment: "");
            sleep(3)};self.progSetString(stat: 0); deviceDetectionHandler = true; return }
        
        DispatchQueue.main.async {
            self.progSetString(stat: 2)
            self.ProgressB.doubleValue = 30
        }

        do {
        
        var iBSS_data = Data()
        var iBEC_data = Data()
        var Diags_data = Data()
 

            if !runTask {DispatchQueue.main.async {
                self.ConnectedString.stringValue = NSLocalizedString("Canceled", comment: "")}; deviceDetectionHandler = true; return }
            
            // Sending iBSS
            DispatchQueue.main.async {
                self.ConnectedString.stringValue = NSLocalizedString("Sending iBSS...", comment: "")
                self.ProgressB.doubleValue = 50
                self.progSetString(stat: 4)
            }
            
                let ibss_size = iBSS_data.count
                            if ibss_size < 5 {
                                print("iBSS skipped")
                            } else {
                                iBSS_data.withUnsafeMutableBytes({ (bytes: UnsafeMutablePointer<UInt8>) -> Void in
                                    printDeviceInfo()
                                    
                                    if connectedDeviceModel == "P101" || connectedDeviceModel == "P105" || connectedDeviceModel == "K93" || connectedDeviceModel == "K93A" || connectedDeviceModel == "N41" || connectedDeviceModel == "N94" || connectedDeviceModel == "J1"  {
                                        if uploadToDevice2(bytes, ibss_size) == 0 {print("Uploaded iBSS\n"); sleep(3); printDeviceInfo() } else {print("Error while uploading iBSS", logLevel:.ERROR); return }
                                    } else {
                                        if uploadToDevice(bytes, UInt(ibss_size)) == 0 {
                                            print("Uploaded iBSS")
                                            if connectedDeviceModel == "J71" || connectedDeviceModel == "N53" || connectedDeviceModel == "J85" || connectedDeviceModel == "J85m" || connectedDeviceModel == "D22" || connectedDeviceModel == "D21" || connectedDeviceModel == "D20" || connectedDeviceModel == "D101" || connectedDeviceModel == "D111" || connectedDeviceModel == "J71A" || connectedDeviceModel == "J98A" || connectedDeviceModel == "N112" || self.connectedDeviceModel == "J127" {
                                                if uploadToDevice(bytes, UInt(ibss_size)) == 0 {
                                                    print("Uploaded iBSS\n")
                                                } else {
                                                    print("Error while uploading iBSS", logLevel:.ERROR)
                                                    deviceDetectionHandler = true
                                                    return
                                                }
                                            }

                                        } else {
                                            print("Error while uploading iBSS")
                                            return
                                        }
                                    }
                                    
                                    })
                            }
            
            // Sending iBEC
            DispatchQueue.main.async {
                self.ProgressB.doubleValue = 60
                self.progSetString(stat: 5)
            }
            if !runTask {DispatchQueue.main.async {
                self.ConnectedString.stringValue = NSLocalizedString("Canceled", comment: "")}; deviceDetectionHandler = true; return }

let ibec_size = iBEC_data.count
            if ibec_size < 5 {
                print("iBEC skipped")
            } else {
                
                iBEC_data.withUnsafeMutableBytes({ (bytes: UnsafeMutablePointer<UInt8>) -> Void in
                    if uploadToDevice(bytes, UInt(ibec_size)) == 0 {
                        print("Uploaded iBEC\n")
                    } else {
                        print("Error while uploading iBEC", logLevel:.ERROR)
                        deviceDetectionHandler = true
                        return
                    }

                    })
            }
            // Sending diags
            DispatchQueue.main.async {
                self.ProgressB.doubleValue = 70
                self.progSetString(stat: 6)
            }
            if !runTask {DispatchQueue.main.async {
                self.ConnectedString.stringValue = NSLocalizedString("Canceled", comment: "")}; deviceDetectionHandler = true; return }

            if connectedDeviceModel == "J71" || connectedDeviceModel == "J85" || connectedDeviceModel == "J85m" || connectedDeviceModel == "N53" {
                sleep(3)
            }
            let diag_size = Diags_data.count
            if diag_size < 5 {
                print("Diags skipped")
            } else {
                Diags_data.withUnsafeMutableBytes({ (bytes: UnsafeMutablePointer<UInt8>) -> Void in
                                 //Use `bytes` inside this closure
                    if uploadToDevice(bytes, UInt(diag_size)) == 0 {
                        print("Uploaded diags\n")
                    } else {
                        print("Error while uploading diags", logLevel:.ERROR)
                        deviceDetectionHandler = true
                        return
                    }
                    })
            }
            DispatchQueue.main.async {
                self.ProgressB.doubleValue = 90
                self.progSetString(stat: 7)
            }
            if !runTask {DispatchQueue.main.async {
                self.ConnectedString.stringValue = NSLocalizedString("Canceled", comment: "")}; deviceDetectionHandler = true; return }
            DispatchQueue.main.async { [self] in
                if USBSERIAL.state == .on {
                    DispatchQueue.global(qos: .background).async {
                        startDiags()
                    }
                } else {
                    DispatchQueue.global(qos: .background).async {
                        startDiags_()
                    }
                }
            }


            DispatchQueue.main.async {
                self.progSetString(stat: 8)
                self.ProgressB.doubleValue = 100
            }
            deviceDetectionHandler = true

   
        
        } catch {
            print(error, logLevel:.ERROR)
        }
    }
    func deviceDetection() {
        
        if temp_block == true {return}
        temp_block = true
        getDeviceModel()
        let chip_id = chipID
        let board_id = boardID
        let mode = Dmode
        for devices in supportedDevicesJson {
            if chip_id == devices.cpid && board_id == devices.bdid {
                DispatchQueue.main.async { [self] in
                    self.ConnectedString.stringValue = "\(devices.productName) in \(String(cString: Dmode)) Mode"
                    connectedDeviceModel = devices.internalName
                    if String(cString: Dmode) == "DFU" {
                        GoBTN.isEnabled = true
                    } else {
                        GoBTN.isEnabled = false
                    }
                }
            }
        }
        if chip_id == 0 && board_id == 0 {
            DispatchQueue.main.async { [self] in
                self.ConnectedString.stringValue = NSLocalizedString("No device detected...", comment: "")
                connectedDeviceModel = ""
                GoBTN.isEnabled = false
            }
        }
        temp_block = false
}
    
    
    func eclipsa7000() -> Int32 {
        let task = Process()
        task.launchPath = Bundle.main.url(forResource: "eclipsa7000", withExtension: "", subdirectory: "exploits")?.path
        task.arguments = ["eclipsa7000"]
        task.launch()
        var timer = 8
        while timer > 0 {
            if !task.isRunning {
                return task.terminationStatus
            }
            timer -= 1
            sleep(1)
            print("\(timer) seconds left until timeout")
        }
        if timer <= 0 {
            task.terminate()
            return Int32(1)
        } else {
            return Int32(1)
        }
    }
    func eclipsa7001() -> Int32 {
        let task = Process()
        task.launchPath = Bundle.main.url(forResource: "eclipsa7001", withExtension: "", subdirectory: "exploits")?.path
        task.arguments = ["eclipsa7001"]
        task.launch()
        var timer = 8
        while timer > 0 {
            if !task.isRunning {
                return task.terminationStatus
            }
            timer -= 1
            sleep(1)
            print("\(timer) seconds left until timeout")
        }
        if timer <= 0 {
            task.terminate()
            return Int32(1)
        } else {
            return Int32(1)
        }
    }
    func eclipsa8000() -> Int32 {
        let task = Process()
        task.launchPath = Bundle.main.url(forResource: "eclipsa8000", withExtension: "", subdirectory: "exploits")?.path
        task.arguments = ["eclipsa8000"]
        task.launch()
       var timer = 8
        while timer > 0 {
            if !task.isRunning {
                return task.terminationStatus
            }
            timer -= 1
            sleep(1)
            print("\(timer) seconds left until timeout")
        }
        if timer <= 0 {
            task.terminate()
            return Int32(1)
        } else {
            return Int32(1)
        }
    }
    func eclipsa8003() -> Int32 {
        let task = Process()
        task.launchPath = Bundle.main.url(forResource: "eclipsa8003", withExtension: "", subdirectory: "exploits")?.path
        task.arguments = ["eclipsa8003"]
        task.launch()
        var timer = 8
        while timer > 0 {
            if !task.isRunning {
                return task.terminationStatus
            }
            timer -= 1
            sleep(1)
            print("\(timer) seconds left until timeout")
        }
        if timer <= 0 {
            task.terminate()
            return Int32(1)
        } else {
            return Int32(1)
        }
    }
    func fuguPWN8010() -> Int32 {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.launchPath = Bundle.main.url(forResource: "Fugu", withExtension: "", subdirectory: "exploits/Fugu_8010")?.path
        task.arguments = ["pwn"]
        task.launch()
        var timer = 8
        while timer > 0 {
            if !task.isRunning {
                return task.terminationStatus
            }
            timer -= 1
            sleep(1)
            print("\(timer) seconds left until timeout")
        }
        if timer <= 0 {
            task.terminate()
            return Int32(1)
        } else {
            return Int32(1)
        }
    }
    func ipwndfu8010_rmsignchecks() -> Int32 {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = [Bundle.main.url(forResource: "exploit", withExtension: "sh", subdirectory: "exploits/ipwndfu8010")!.path]
        task.launch()
        var timer = 8
        while timer > 0 {
            if !task.isRunning {
                return task.terminationStatus
            }
            timer -= 1
            sleep(1)
            print("\(timer) seconds left until timeout")
        }
        if timer <= 0 {
            task.terminate()
            return Int32(1)
        } else {
            return Int32(1)
        }
    }
    
    func ipwndfu8015() -> Int32 {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = [Bundle.main.url(forResource: "exploit", withExtension: "sh", subdirectory: "exploits/ipwndfu8015")!.path]
        task.launch()
        var timer = 8
        while timer > 0 {
            if !task.isRunning {
                return task.terminationStatus
            }
            timer -= 1
            sleep(1)
            print("\(timer) seconds left until timeout")
        }
        if timer <= 0 {
            task.terminate()
            return Int32(1)
        } else {
            return Int32(1)
        }
    }
    func ipwndfu_a4() -> Int32 {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = [Bundle.main.url(forResource: "exploit4", withExtension: "sh", subdirectory: "exploits/ipwndfu8015")!.path]
        task.launch()
        var timer = 8
        while timer > 0 {
            if !task.isRunning {
                return task.terminationStatus
            }
            timer -= 1
            sleep(1)
            print("\(timer) seconds left until timeout")
        }
        if timer <= 0 {
            task.terminate()
            return Int32(1)
        } else {
            return Int32(1)
        }
    }
    func ipwndfu_a5(path: String) -> Int32 {
        let task = Process()
        task.launchPath = Bundle.main.url(forResource: "ipwndfu", withExtension: "", subdirectory: "exploits/ipwndfu-a5")!.path
        task.arguments = ["-l",path]
        task.launch()
        task.waitUntilExit()
        return task.terminationStatus
    }

    func ipwndfu_a6() -> Int32 {
        let task = Process()
        task.launchPath = Bundle.main.url(forResource: "pwnedDFU", withExtension: "", subdirectory: "exploits")!.path
        task.arguments = ["-p"]
        task.launch()
        var timer = 20
        while timer > 0 {
            if !task.isRunning {
                return task.terminationStatus
            }
            timer -= 1
            sleep(1)
            print("\(timer) seconds left until timeout")
        }
        if timer <= 0 {
            task.terminate()
            return Int32(1)
        } else {
            return Int32(1)
        }
    }
    func ipwndfu_a7() -> Int32 {
        let task = Process()
        task.launchPath = Bundle.main.url(forResource: "pwnedDFU", withExtension: "", subdirectory: "exploits")!.path
        task.arguments = ["-p","-f"]
        task.launch()
        var timer = 20
        while timer > 0 {
            if !task.isRunning {
                return task.terminationStatus
            }
            timer -= 1
            sleep(1)
            print("\(timer) seconds left until timeout")
        }
        if timer <= 0 {
            task.terminate()
            return Int32(1)
        } else {
            return Int32(1)
        }
    }
    
    @IBOutlet weak var GoBTN: NSButton!
    @IBOutlet weak var ConnectedString: NSTextField!
}




struct supportedDevicesStruct: Codable {
    let productName:String
    let internalName:String
    let cpid:Int32
    let bdid:Int32
}


extension String {
    
    var hexadecimal: Data? {
        var data = Data(capacity: count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }
        
        guard data.count > 0 else { return nil }
        
        return data
    }
    
}

extension PurpleViewController {
    
    func Go_now() {
        
        deviceDetectionHandler = false
        runTask = true
        
        // Check device here
            
            DispatchQueue.global(qos: .background).async { [self] in
                    
                    DispatchQueue.main.async {
                        self.ConnectedString.stringValue = NSLocalizedString("Exploiting...", comment: "")
                        self.ProgressB.doubleValue = 20
                        self.progSetString(stat: 1)
                    }
                    DispatchQueue.main.async {
                        self.GoBTN.isEnabled = false
                    }
//                    /// A4
//                    if self.connectedDeviceModel == "N90" || self.connectedDeviceModel == "N90B" {
//                        if self.ipwndfu_a4() == 0 {
//                            print("Successfully exploited")
//                            self.getBootchain()
//                        }else {
//                            DispatchQueue.main.async {
//                                self.ProgressB.doubleValue = 0
//                                self.ConnectedString.stringValue = NSLocalizedString("Error while exploiting\nReboot and try again...", comment: "")
//                            }
//                            sleep(3)
//                            self.deviceDetectionHandler = true
//
//                        }
//                    }
//
//                    /// A5 devices
//                    if self.connectedDeviceModel == "K93A" || self.connectedDeviceModel == "K93" || self.connectedDeviceModel == "P105" || self.connectedDeviceModel == "J1" || self.connectedDeviceModel == "N94" {
//
//                        DispatchQueue.main.async {
//                            let alert = NSAlert()
//                            alert.messageText = NSLocalizedString("Information", comment: "")
//                            alert.informativeText = NSLocalizedString("Please make sure your A5 is already in pwnedDFU. Otherwise diags can't be booted... ", comment: "")
//                            alert.addButton(withTitle: NSLocalizedString("Continue", comment: ""))
//                            alert.addButton(withTitle: NSLocalizedString("Cancel", comment: ""))
//                            let modalResult = alert.runModal()
//                            switch modalResult {
//                            case .alertFirstButtonReturn:
//                                DispatchQueue.global(qos: .background).async {
//                                    self.getBootchain()
//                                }
//                            default:
//                                self.deviceDetectionHandler = true
//                                DispatchQueue.main.async { [self] in
//                                    self.ProgressB.doubleValue = 0
//                                }
//                                return
//                            }
//                        }
//
//                    }
                    
//                    /// A6
//                    if self.connectedDeviceModel == "P101" || self.connectedDeviceModel == "N41" || self.connectedDeviceModel == "N48" {
//                        if self.ipwndfu_a6() == 0 {
//                            print("Successfully exploited")
//                            self.getBootchain()
//                        }else {
//                            DispatchQueue.main.async {
//                                self.ProgressB.doubleValue = 0
//                                self.ConnectedString.stringValue = NSLocalizedString("Error while exploiting\nReboot and try again...", comment: "")
//                            }
//                            sleep(3)
//                            self.deviceDetectionHandler = true
//
//                        }
//                    }
                
                print(connectedDeviceModel)
                    
                    if  self.connectedDeviceModel == "J96" || self.connectedDeviceModel == "N102" || self.connectedDeviceModel == "N56" || self.connectedDeviceModel == "N61" || self.connectedDeviceModel == "J81" || self.connectedDeviceModel == "J71S" || self.connectedDeviceModel == "N71" || self.connectedDeviceModel == "N66" || self.connectedDeviceModel == "N69u" || self.connectedDeviceModel == "J71T" || self.connectedDeviceModel == "N71m" || self.connectedDeviceModel == "N66m" || self.connectedDeviceModel == "N69" || self.connectedDeviceModel == "J71B" || self.connectedDeviceModel == "J120" || self.connectedDeviceModel == "J207" ||
                        self.connectedDeviceModel == "J171" || self.connectedDeviceModel == "D111" || self.connectedDeviceModel == "D101" || self.connectedDeviceModel == "D20" || self.connectedDeviceModel == "D21" || self.connectedDeviceModel == "D22" || self.connectedDeviceModel == "J98A" || self.connectedDeviceModel == "J127" || self.connectedDeviceModel == "N112" {
                     if pwn() == 0 {
                     print("Successfully exploited")
                     self.getBootchain()
                     } else {
                        DispatchQueue.main.async {
                            self.ProgressB.doubleValue = 0
                            self.ConnectedString.stringValue = NSLocalizedString("Error while exploiting\nReboot and try again...", comment: "")
                        }
                        sleep(3)
                         self.deviceDetectionHandler = true
                     }
                        // A7 Devices use ipwnder32
                    } else if self.connectedDeviceModel == "N53" || self.connectedDeviceModel == "J85" || self.connectedDeviceModel == "J85m" || self.connectedDeviceModel == "J71" {
                        if pwnA6A7() == 0 {
                        print("Successfully exploited")
                        self.getBootchain()
                        } else {
                           DispatchQueue.main.async {
                               self.ProgressB.doubleValue = 0
                               self.ConnectedString.stringValue = NSLocalizedString("Error while exploiting\nReboot and try again...", comment: "")
                           }
                           sleep(3)
                            self.deviceDetectionHandler = true
                        }
                        
                        // A10 devices use Fugu
                    }
                                
                }

       
        
    }
    
    
    
}



func convert_to_mutable_pointer(value: String) -> UnsafeMutablePointer<Int8> {
    let input = (value as NSString).utf8String
    guard  let computed_buffer =  UnsafeMutablePointer<Int8>(mutating: input) else {
        return UnsafeMutablePointer<Int8>(mutating: "")
    }
    return computed_buffer
}

struct checkLic: Codable {
    let valid:Bool
    let response:String
    let hash:String
}


