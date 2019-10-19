module janet.func;

import janet.c;

import janet;

/**
    Emulates the effects of janet_pcall using a thread-local fiber
    and D-like varargs.
*/
@nogc Janet callJanet(T...)(JanetFunction* fun,T args)
{
    Janet[T.length] wrappedArgs = [];
    static foreach(i,v;args)
    {
        wrappedArgs[i]=janetWrap(v);
    }
    Janet j;
    enum argc = T.length;
    const(Janet*) argv = cast(const(Janet*))(wrappedArgs);
    if(defaultFiber.isNull)
    {
        defaultFiber = janet_fiber(fun,128,argc,argv);
    }
    JanetFiber* fiber = janet_fiber_reset(defaultFiber.get,fun,argc,argv);
    const int result = janet_continue(fiber,janet_wrap_nil(),&j);
    debug assert(result==0,"Function errored! "~j.as!string);
    return j;
}
private Janet janetReturn(alias func,Args...)(Args args)
{
    import std.traits : ReturnType;
    static if(is(ReturnType!func == void))
    {
        func(args);
        return janet_wrap_nil();
    }
    else
    {
        return janetWrap!(ReturnType!func)(func(args));
    }
}

/**
    Wraps around a function, allowing it to be called in Janet.
*/
template makeJanetCFunc(alias func)
{
    import std.traits : Parameters,isNestedFunction,arity;
    import std.typecons : Tuple;
    import std.meta;
    extern(C) static Janet ourJanetFunc (int argc, Janet* argv) //not @nogc because function passed in might not be @nogc
    {
        static foreach(overload;__traits(getOverloads,__traits(parent,func),__traits(identifier,func)))
        {
            Tuple!(Parameters!overload) args;
            static if(arity!overload == 0)
            {
                if(argc == 0)
                {
                    return janetReturn!(overload)();
                }
            }
            else
            {
                if(argc == arity!overload)
                {
                    bool argsCorrect = true;
                    static foreach(i;0..args.length)
                    {
                        argsCorrect = argsCorrect && argv[i].janetCompatible!(Parameters!overload[i]);
                        if(argsCorrect)
                        {
                            args[i] = (&argv[i]).as!(Parameters!overload[i]);
                        }
                    }
                    if(argsCorrect)
                    {
                        return janetReturn!(overload)(args.expand);
                    }
                }
            }
        }
        return janet_wrap_nil();
    }
    JanetCFunction makeJanetCFunc()
    {
        return &ourJanetFunc;
    }
}

import std.traits : isPointer,PointerTarget;

/**
    The same, but requires a type and an instance of that type as an argument.
    This is due to many class methods requiring context pointers.
    This is mostly only useful for class/struct registering.
*/
template makeJanetCFunc(alias func,T)
    if(is(T == class) || isPointer!T && is(PointerTarget!T == struct))
{
    import std.traits : Parameters,ReturnType,isNestedFunction,arity;
    import std.typecons : Tuple;
    T obj;
    JanetCFunction makeJanetCFunc(T argObj)
    {
        obj = argObj;
        return &ourJanetFunc;
    }
    extern(C) static Janet ourJanetFunc (int argc, Janet* argv)
    {
        foreach(overload;__traits(getOverloads,__traits(parent,func),__traits(identifier,func)))
        {
            Tuple!(Parameters!overload) args;
            static if(arity!overload == 0)
            {
                if(argc == 0)
                {
                    static if(is(ReturnType!overload == void))
                    {
                        mixin("obj."~__traits(identifier,overload)~"();");
                        return janet_wrap_nil();
                    }
                    else
                    {
                        return janetWrap!(ReturnType!overload)(mixin("obj."~__traits(identifier,overload)~"()"));
                    }
                    
                }
            }
            else
            {
                if(argc == arity!overload)
                {
                    bool argsCorrect = true;
                    static foreach(i;0..args.length)
                    {
                        argsCorrect = argsCorrect && argv[i].janetCompatible!(Parameters!overload[i]);
                        if(argsCorrect)
                        {
                            args[i] = (&argv[i]).as!(Parameters!overload[i]);
                        }
                    }
                    if(argsCorrect)
                    {
                        static if(is(ReturnType!overload == void))
                        {
                            mixin("obj."~__traits(identifier,overload)~"(args.expand)");
                            return janet_wrap_nil();
                        }
                        else
                        {
                            return janetWrap!(ReturnType!overload)(mixin("obj."~__traits(identifier,overload)~"(args.expand)"));
                        }
                    }
                }
            }
        }
        return janet_wrap_nil();
    }
}

/**
    Makes a function globally available with Janet.
*/
@nogc void registerFunctionWithJanet(alias func,string documentation = "")()
{
    JanetReg[2] reg;
    reg[0].name = cast(const(char)*)__traits(identifier,func);
    reg[0].cfun = makeJanetCFunc!func;
    reg[0].documentation = cast(const(char)*)(documentation);
    janet_cfuns(coreEnv,"",&reg[0]);
}

version(unittest)
{
    int foo(int x)
    {
        return x+1;
    }
    int bar(int y)
    {
        return y+2;
    }
}

unittest
{
    import std.stdio : writeln;
    writeln("Performing CFunction register test.");
    registerFunctionWithJanet!(foo,"Returns the input plus one.");
    registerFunctionWithJanet!(bar,"Returns the input plus two.");
    writeln("Functions registered.");
    assert(doFile("./source/tests/dtests/function.janet") == 0,"Function failed!");
}