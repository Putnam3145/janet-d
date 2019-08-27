module janet.vm;

import janet.c;

static JanetTable* coreEnv; /// The core environment 

private __gshared JanetTable* __gCoreEnv; // this is only ever used in here, so __gshared ought to be kosher

import janet.d;

static shared bool startJanetOnThreadStart = true; /// If this is false, new threads won't automatically start a janet thread

static this()
{
    if(startJanetOnThreadStart)
    {
        janet_init();
        synchronized
        {
            coreEnv = janet_core_env(__gCoreEnv);
        }
    }
}

shared static this()
{
    janet_init();
    __gCoreEnv = janet_core_env(null);
}

static ~this()
{
    
    janet_deinit();
}

int doFile(string path,JanetTable* env = coreEnv)
{
    import std.file : read;
    ubyte[] f;
    synchronized
    {
        f = cast(ubyte[])read(path);
    }
    return janet_dobytes(env,&f[0],cast(int)(f.length),(&path[0]),null);
}

@nogc int doString(string str,JanetTable* env = coreEnv)
{
    import std.string : representation;
    return janet_dobytes(env,&str.representation[0],cast(int)str.length,"",null);
}

///
unittest
{
    doString(`(print "doString unittest succeeded!")`);
}

int doFile(string path, Janet* out_, JanetTable* env = coreEnv)
{
    import std.file : read;
    ubyte[] f;
    synchronized
    {
        f = cast(ubyte[])read(path);
    }
    return janet_dobytes(env,&f[0],cast(int)(f.length),(&path[0]),out_);
}

@nogc int doString(string str,Janet* out_,JanetTable* env = coreEnv)
{
    import std.string : representation;
    return janet_dobytes(env,&str.representation[0],cast(int)str.length,"",out_);
}

/*
    No compiling now because:
    1. Compiling was only grabbing the last function call in any file I compiled.
    2. It led to an inability to deinit janet on thread close because pointers returned to might
    come from thread local storage, which was unsafe and led to segfaults.
*/