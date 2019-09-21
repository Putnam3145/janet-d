module janet.vm;

import janet.c;

JanetTable* coreEnv; /// The core environment 

import std.typecons : Nullable;

package Nullable!(JanetFiber*,null) defaultFiber;

import janet;

static this()
{
    janet_init();
    coreEnv = janet_core_env(null);
}

static ~this()
{
    janet_deinit();
}

/// Run a string in the Janet VM.
@nogc int doString(string str,JanetTable* env = coreEnv)
{
    import std.string : representation;
    return janet_dobytes(env,&str.representation[0],cast(int)str.length,"",null);
}
/// ditto 
@nogc int doString(string str,Janet* out_,JanetTable* env = coreEnv)
{
    import std.string : representation;
    return janet_dobytes(env,&str.representation[0],cast(int)str.length,"",out_);
}
///
unittest
{
    doString(`(print "doString unittest succeeded!")`);
}
/// Load a file and run it in the Janet VM. Not @nogc!
int doFile(string path,JanetTable* env = coreEnv)
{
    import std.file : readText;
    string str;
    synchronized
    {
        str = readText(path);
    }
    return doString(str,env);
}
/// ditto
int doFile(string path, Janet* out_, JanetTable* env = coreEnv)
{
    import std.file : readText;
    string str;
    synchronized
    {
        str = readText(path);
    }
    return doString(str,out_,env);
}

unittest
{
    import std.parallelism;
    import std.stdio;
    TaskPool ourPool = new TaskPool();
    writeln("Testing parallelism (and hot-swapping, if you're fast)...");
    import std.file : readText;
    string memoizedString = readText("./source/tests/dtests/parallel.janet");
    foreach(int i;0..1_000_000)
    {
        if(i%100_000==0)
        {
            memoizedString = readText("./source/tests/dtests/parallel.janet");
        }
        ourPool.put(task!doString(memoizedString));
    }
    ourPool.finish(true);
    writeln("Parallelism test finished.");
}