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

private class MemoizedFile //i feel like i should make a separate package for this
{
    import core.sync.mutex;
    shared Mutex mtx;
    shared private string _internalContents;
    private string _fileName;
    string contents(bool refresh=false)
    {
        import std.file : readText;
        mtx.lock_nothrow();
        scope(exit) mtx.unlock_nothrow();
        if(refresh)
        {
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
        mtx = new shared Mutex(this);
        _internalContents = readText(_fileName = file);
    }
}

private MemoizedFile[string] memoizedFiles;

private string readFile(string path)
{
    if(path in memoizedFiles)
    {
        return memoizedFiles[path].contents;
    }
    else
    {
        return (memoizedFiles[path] = new MemoizedFile(path)).contents;
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
    memoizedFiles.remove(path);
    return doFile(path,env);
}
/// ditto
int hotswapFile(string path, Janet* out_, JanetTable* env = coreEnv)
{
    memoizedFiles.remove(path);
    return doFile(path,out_,env);
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

    Also causing segfaults right now: parallel foreach, running doFile. I do not know why.
*/

unittest
{
    import std.parallelism;
    import std.stdio;
    writeln("Testing parallelism (and hot-swapping, if you're fast)...");
    foreach(int i;0..10000)
    {
        if(!(i%100))
        {
            taskPool.put(task!hotswapFile("./source/tests/dtests/parallel.janet"));
        }
        else
        {
            taskPool.put(task!doFile("./source/tests/dtests/parallel.janet"));
        }
    }
    writeln("Pool put together.");
    taskPool.finish(true);
    writeln("Pool finished.");
}