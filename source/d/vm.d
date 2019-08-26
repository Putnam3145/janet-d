module janet.vm;

import janet.c;

static JanetTable* coreEnv;

static bool initialized;

import janet.d;

int initJanet()
{
    scope(success)
    {
        coreEnv = janet_core_env(null);
        initialized = true;
    }
    if(initialized)
    {
        return 0;
    }
    return janet_init();
}

void deinitJanet()
{
    scope(success) initialized = false;
    if(initialized)
    {
        janet_deinit();
    }
}