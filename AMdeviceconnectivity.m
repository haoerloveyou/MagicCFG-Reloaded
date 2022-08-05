//
//  AMdeviceconnectivity.m
//  XFlash
//
//  Created by Jan Fabel on 12.02.22.
//

#include "AMdeviceconnectivity.h"
#import <Foundation/Foundation.h>
#import "AMRestore.h"
#import <CoreFoundation/CoreFoundation.h>
#import <Security/Security.h>
#include <string.h>
#include "callSwiftCallBacks.h"


AMRestorableDeviceRef device;


/// Grab  identifiers from device
/// @param deviceL  Apple Mobile Restorable Device Reference
void getDeviceIdentifiers(AMRestorableDeviceRef deviceL) {
    char* ecidtemp = NULL;
    uint64_t dev = AMRestorableDeviceGetECID(deviceL);
    
    // Return nil when no ECID can be found...
    if (dev == NULL) { invoke_detector("","","",""); return;}
    printf("ECID: %" PRIu64 "\n", dev);
    char xx [128];
    snprintf(xx, sizeof(xx), "%" PRIu64 "", dev);
    ecidtemp = xx;
    
    char* modetemp = NULL;
    char xy [128];
    int dev2 = AMRestorableDeviceGetState(deviceL);
    
    // Return nil when no device state can be found...
    if (dev2 == NULL) {
        invoke_detector("","","","");
        return;}
    printf("Mode: %d\n", dev2);
    snprintf(xy, sizeof(xy), "%d", AMRestorableDeviceGetState(deviceL));
    modetemp = xy;
    
    char* chipIDtemp = NULL;
    char xz [128];
    uint32_t cp = AMRestorableDeviceGetChipID(deviceL);
    
    // Return nil when no CPID can be found...
    if (cp == NULL) {
        invoke_detector("","","","");
        return;}
    printf("CPID: %d\n", AMRestorableDeviceGetChipID(deviceL));
    snprintf(xz, sizeof(xz), "%d", AMRestorableDeviceGetChipID(deviceL));
    chipIDtemp = xz;
    
    char* boardIDtemp = NULL;
    char xa [128];
    uint32_t bd = AMRestorableDeviceGetBoardID(deviceL);
    
    // Return BDID as zero if no BDID can be found...
    if (bd == NULL) {
        invoke_detector(ecidtemp, modetemp, chipIDtemp, "0");
        return;}
    printf("BDID: %d\n", AMRestorableDeviceGetBoardID(deviceL));
    snprintf(xa, sizeof(xa), "%d", AMRestorableDeviceGetBoardID(deviceL));
    boardIDtemp = xa;
    
    // Ping detector with fetched device identifiers
    invoke_detector(ecidtemp, modetemp, chipIDtemp, boardIDtemp);
    
    
    
}



