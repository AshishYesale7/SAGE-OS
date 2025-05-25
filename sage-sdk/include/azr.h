
#ifndef AZR_H
#define AZR_H

#include <stdint.h>

int azr_init(const char *model_path);
int azr_translate_syscall(int syscall_num, void *args);
void azr_destroy();

#endif // AZR_H
