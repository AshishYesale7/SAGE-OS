
#ifndef AI_HAT_H
#define AI_HAT_H

int ai_hat_init();
int ai_hat_run_model(const char *model_name, void *input, void *output);
void ai_hat_shutdown();

#endif // AI_HAT_H
