module janet.vm;

import janet.c;

import janet;

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

/// Load a file and run it in the Janet VM.
@nogc int doFile(string path,JanetTable* env = coreEnv)
{
    import std.io.file : File;
    import core.memory : pureMalloc, pureFree;
    int len = 0;
    ubyte* buffer = cast(ubyte*)pureMalloc(ubyte.sizeof * 0x10_0000);
    scope(exit) pureFree(buffer);
    synchronized
    {
        auto f = File(path);
        len = cast(int)f.read(buffer[0..0x10_0000]);
    }
    return janet_dobytes(env,cast(ubyte*)buffer,len,"",null);
}
/// ditto
@nogc int doFile(string path, Janet* out_, JanetTable* env = coreEnv)
{
    import std.io.file : File;
    import core.memory : pureMalloc, pureFree;
    int len = 0;
    ubyte* buffer = cast(ubyte*)pureMalloc(ubyte.sizeof * 0x10_0000);
    scope(exit) pureFree(buffer);
    synchronized
    {
        auto f = File(path);
        len = cast(int)f.read(buffer[0..0x10_0000]);
    }
    return janet_dobytes(env,cast(ubyte*)buffer,len,"",out_);
}

unittest
{
    import std.parallelism;
    import std.stdio;
    TaskPool ourPool = new TaskPool();
    writeln("Testing parallelism...");
    import std.file : readText;
    string memoizedString = readText("./source/tests/dtests/parallel.janet");
    foreach(int i;0..100_000)
    {
        if(i%10_000==0)
        {
            memoizedString = readText("./source/tests/dtests/parallel.janet");
        }
        ourPool.put(task!doString(memoizedString));
    }
    ourPool.finish();
    writeln("Parallelism test finished.");
}