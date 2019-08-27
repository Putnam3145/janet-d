module janet.vm;

import janet.c;

static JanetTable* coreEnv; /// The core environment 

private __gshared JanetTable* __gCoreEnv;

import janet.d;

__gshared bool startJanetOnThreadStart = true; /// If this is false, new threads won't automatically start a janet thread

static this()
{
    if(startJanetOnThreadStart)
    {
        debug import std.stdio : writeln;
        scope(success)
        {
            coreEnv = janet_core_env(__gCoreEnv);
        }
        debug writeln("Global thread starting.");
        janet_init();
    }
}

shared static this()
{
    debug import std.stdio : writeln;
    debug writeln("Global thread starting.");
    janet_init();
    __gCoreEnv = janet_core_env(null);
}

static ~this()
{
    //janet_deinit();
}

int doFile(in char[] path,JanetTable* env = coreEnv)
{
    import std.file : read;
    const ubyte[] f = cast(const(ubyte[]))read(path);
    const(ubyte)* fPointer = &f[0];
    int fLength = cast(int)(f.length);
    return janet_dobytes(env,fPointer,fLength,(&path[0]),null);
}

int doString(const(char)* str,JanetTable* env = coreEnv)
{
    return janet_dostring(env,str,"",null);
}

///
unittest
{
    doString(`(print "doString unittest succeeded!")`);
}

int doFile(in char[] path, out Janet* out_, JanetTable* env = coreEnv)
{
    import std.file : read;
    const ubyte[] f = cast(const(ubyte[]))read(path);
    const(ubyte)* fPointer = &f[0];
    int fLength = cast(int)(f.length);
    return janet_dobytes(env,fPointer,fLength,(&path[0]),out_);
}

int doString(const(char)* str,out Janet* out_,JanetTable* env = coreEnv)
{
    return janet_dostring(env,str,"",out_);
}

@nogc JanetFunction compileString(string str,JanetTable* env = coreEnv,in char[] path = null)
{
    JanetParser p = JanetParser();
    JanetParser* parser = &p;
    janet_parser_init(parser);
    scope(exit) janet_parser_deinit(parser);
    JanetCompileResult cres;
    debug import std.stdio : writeln;
    const(ubyte)* realPath;
    if(path)
    {
        realPath = cast(const(ubyte)*)path;
    }
    else
    {
        realPath = cast(const(ubyte)*)("<unknown>");
    }
    foreach(ubyte c;str)
    {
        parser.janet_parser_consume(c);
    }
    parser.janet_parser_eof();
    while(parser.janet_parser_has_more)
    {
        auto prod = parser.janet_parser_produce;
        cres = janet_compile(prod,env,realPath);
        if(cres.status == JanetCompileStatus.JANET_COMPILE_ERROR)
        {
            import std.string : fromStringz;
            assert(0,fromStringz(cast(const(char)*)cres.error));
        }
    }
    auto func = janet_thunk(cres.funcdef);
    return *func;
}

JanetFunction compileFile(in char[] path,JanetTable* env = coreEnv)
{
    import std.file : readText;
    return compileString(readText(path),env,path);
}
///
unittest
{
    import std.parallelism : task;
    auto funcTask = task!compileFile("./source/tests/dtests/compilation.janet");
    funcTask.executeInNewThread(); // Doing it in a new thread to check if these things work in new threads.
    Janet j;

    callJanet(&(funcTask.spinForce()));
}