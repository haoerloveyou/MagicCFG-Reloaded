/*
 * boot.c
 * copyright (C) 2020/05/25 dora2ios
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

static int send_data(irecv_client_t client, unsigned char* data, size_t size){
    return irecv_usb_control_transfer(client, 0x21, 1, 0, 0, data, size, 100);
}

static int irecv_get_device(irecv_client_t client) {
    if(client) {
        irecv_close(client);
        client = NULL;
    }
    irecv_open_with_ecid(&client, 0);
    if(!client) {
        return -1;
    }
    int mode = 0;
    
    irecv_get_mode(client, &mode);
    if(mode != IRECV_K_DFU_MODE) {
        irecv_close(client);
        client = NULL;
        return -1;
    }
    return 0;
}

int boot_client_n(irecv_client_t client, char* ibss, size_t ibss_sz) {
    int ret;
    printf("Uploading image\n");
    ret = irecv_send_buffer(client, (unsigned char*)ibss, ibss_sz, 0);
    if(ret != 0) {
        printf("ERROR: Failed to upload image.\n");
        return -1;
    }
    
    ret = irecv_finish_transfer(client);
    if(ret != 0) {
        printf("ERROR: Failed to execute image.\n");
        return -1;
    }
    return 0;
}

// boot for 32-bit checkm8 devices
