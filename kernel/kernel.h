#ifndef KERNEL_TASK_H_
#define KERNEL_TASK_H

#include "MemoryMap.h"

#define NOT_ENOUGH_TASK_NUM     0xFFFFFFFF
#define USR_TASK_STACK_SIZE     0x100000
#define MAX_TASK_NUM            (TASK_STACK_SIZE / USR_TASK_STACK_SIZE)

#endif /* KERNEL_TASK_H_ */