module janet.vm;

import janet.c;

static JanetTable* coreEnv; /// The core environment 

import janet.d;

static this()
{
    janet_init();
    coreEnv = janet_core_env(null);
}

static ~this()
{
    janet_deinit();
}

shared private class MemoizedFile //i feel like i should make a separate package for this
{
    import core.sync.mutex;
    private Mutex mtx;
    private string _internalContents;
    private string _fileName;
    string contents(bool refresh=false)()
    {
        import std.file : readText;
        static if(refresh)
        {
            mtx.lock_nothrow();
            scope(exit) mtx.unlock_nothrow();
            return _internalContents = readText(_fileName);
        }
        else
        {
            return _internalContents;
        }
    }
    this(string file)
    {
        import std.file : readText;
        mtx = new shared Mutex(cast()this);
        _internalContents = readText(_fileName = file);
    }
}

private static shared(MemoizedFile)[string] memoizedFiles;

private string readFile(bool refresh=false)(string path)
{
    if(path in memoizedFiles)
    {
        return memoizedFiles[path].contents!refresh;
    }
    else
    {
        return (memoizedFiles[path] = new shared MemoizedFile(path)).contents;
    }
}

//in lieu of using std.functional's memoization, i'm going to do a simpler one here.

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
/// Load a file and run it in the Janet VM.
int doFile(string path,JanetTable* env = coreEnv)
{
    return doString(readFile(path),env);
}
/// ditto
int doFile(string path, Janet* out_, JanetTable* env = coreEnv)
{
    return doString(readFile(path),out_,env);
}
/// janet-d memoizes file accesses for faster loading. This resets the memoization. Otherwise identical to doFile.
int hotswapFile(string path,JanetTable* env = coreEnv)
{
    return doString(readFile!true(path),env);
}
/// ditto
int hotswapFile(string path, Janet* out_, JanetTable* env = coreEnv)
{
    return doString(readFile!true(path),out_,env);
}

///
unittest
{
    doString(`(print "doString unittest succeeded!")`);
}

/*
    No compiling now because:
    1. Compiling was only grabbing the last function call in any file I compiled.
    2. It led to an inability to deinit janet on thread close because pointers returned to might
    come from thread local storage, which was unsafe and led to segfaults.

    It is not recommended to use the global taskPool for janet-d. Use a specialized task pool and make sure it finishes.
*/

unittest
{
    import std.parallelism;
    import std.stdio;
    TaskPool ourPool = new TaskPool();
    writeln("Testing parallelism (and hot-swapping, if you're fast)...");
    foreach(int i;0..1000000)
    {
        if(!(i%100))
        {
            ourPool.put(task!hotswapFile("./source/tests/dtests/parallel.janet"));
        }
        else
        {
            ourPool.put(task!doFile("./source/tests/dtests/parallel.janet"));
        }
    }
    ourPool.finish(true);
    writeln("Parallelism test finished.");
}