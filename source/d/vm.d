module janet.vm;

import janet.c;

static JanetTable* coreEnv;

import janet.d;

int initJanet()
{
    scope(success) coreEnv = janet_core_env(null);
    return janet_init();
}