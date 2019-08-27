module janet.func;

import janet.c;

import janet.d;

/**
    A wrapper around call_janet using D-like varargs.
*/
@nogc Janet callJanet(T...)(JanetFunction* fun,T args)
{
    debug import std.stdio : writeln;
    pragma(msg,T.length);
    Janet[T.length] wrappedArgs = [];
    static foreach(i,v;args)
    {
        wrappedArgs[i]=janetWrap(v);
    }
    Janet j;
    int result = janet_pcall(fun,T.length,cast(const(Janet*))(wrappedArgs),&j,null);
    debug writeln(result," ",j);
    debug assert(result==0,"Function errored! "~j.getFromJanet!string);
    return j;
}
/**
    Wraps around a function, allowing it to be called in Janet.
*/
template makeJanetCFunc(alias func)
{
    import std.traits : Parameters,ReturnType,isNestedFunction;
    import std.typecons : Tuple;
    extern(C) static Janet ourJanetFunc (int argc, Janet* argv)
    {
        Tuple!(Parameters!func) args;
        alias funcParams = Parameters!func;
        static foreach(i;0..args.length)
        {
            args[i] = getFromJanet!(funcParams[i])(argv[i]);
        }
        return janetWrap!(ReturnType!func)(func(args.expand));
    }
    JanetCFunction makeJanetCFunc()
    {
        return &ourJanetFunc;
    }
}
/**
    The same, but requires a delegate or function pointer be put in as an argument.
    This is due to many class methods requiring context pointers.
    This is mostly only useful for class registering.
*/
template makeJanetCFunc(alias func,T,Args...)
{
    import std.traits : Parameters,ReturnType,isNestedFunction;
    import std.typecons : Tuple;
    static T delegate(Args) dg;
    static T function(Args) fp;
    JanetCFunction makeJanetCFunc(T delegate(Args) argDg)
    {
        dg = argDg;
        return &ourJanetFunc;
    }
    JanetCFunction makeJanetCFunc(T function(Args) argFp) // templates are so wonderful.
    {
        fp = argFp;
        return &ourJanetFunc;
    }
    extern(C) static Janet ourJanetFunc (int argc, Janet* argv)
    {
        Tuple!(Parameters!func) args;
        alias funcParams = Parameters!func;
        static foreach(i;0..args.length)
        {
            args[i] = getFromJanet!(funcParams[i])(argv[i]);
        }
        if(dg)
        {
            return janetWrap!(ReturnType!func)(dg(args.expand));
        }
        else
        {
            return janetWrap!(ReturnType!func)(fp(args.expand));
        }
    }
}

/**
    Makes a function globally available with Janet.
*/
void registerFunctionWithJanet(alias func,string documentation = "")()
{
    import std.string : toStringz;
    JanetReg[2] reg;
    reg[0].name = cast(const(char)*)toStringz(__traits(identifier,func));
    reg[0].cfun = makeJanetCFunc!func;
    reg[0].documentation = cast(const(char)*)toStringz(documentation);
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
    registerFunctionWithJanet!foo();
    registerFunctionWithJanet!bar();
    writeln("Functions registered.");
    assert(doFile("./source/tests/dtests/function.janet") == 0,"Function failed!");
}