

#include <stdint.h>
#include <pthread.h>
#include <stdio.h>
#include <unistd.h>


#include "callSwiftCallBacks.h"


void* detector_(char*, char*, char*, char*);

void* invoke_detector(char* x, char* y,char* z, char* a) {
  return detector_(x,y,z,a);
}
