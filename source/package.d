module janet;

public import janet.d;

public import janet.c : Janet,JanetFunction,JanetTable,JanetKV;

JanetTable* coreEnv; /// The core environment 

import std.typecons : Nullable;

package Nullable!(JanetFiber*,null) defaultFiber;

version(JanetD_NoAutoInit) // Sometimes we might not want to start up a janet instance on every thread's creation
{
    /**
        Initialize Janet. This is done automatically if not compiled with the JanetD_NoAutoInit
        version, at the initialization of every thread. Compiling with the JanetD_NoAutoInit,
        these functions must be used instead, which do all the same stuff that is normally done
        automatically.
    */
    void initJanet()
    {
        janet_init();
        coreEnv = janet_core_env(null);
    }
    alias deinitJanet = janet_deinit; /// ditto
}
else
{
    static this()
    {
        janet_init();
        coreEnv = janet_core_env(null);
    }
    static ~this()
    {
        janet_deinit();
    }
}

import janet.c;

/// An enum of the different kinds of things you can turn a string into.
enum JanetStrType
{
    STRING,
    SYMBOL,
    KEYWORD
}

package struct JanetDAbstractHead(T)
    if(is(T == class))
{
    JanetGCObject gc;
    const(JanetAbstractType)* type;
    size_t size;
    union AbstractUnion
    {
        long[] fakeData;
        T realData;
    }
    AbstractUnion data;
    import janet.register : registerType;
    void initialize(T dataArg)
    {
        type = registerType!T;
        size = __traits(classInstanceSize,T);
        data.realData = dataArg;
    }
    this(T dataArg)
    {
        initialize(dataArg);
    }
    void* ptr()
    {
        return cast(void*)&data;
    }
}

/**
    Define an immutable value in Janet, as Janet's "def".
    Immutable means something slightly different in Janet than in D,
    so this doesn't take in a const or immutable value.
*/
@nogc void janetDef(T,S1,S2)(JanetTable* env,string name,T val,string documentation = "")
{
    import janet.c : janet_def;
    janet_def(env,cast(const(char*))name,janetWrap(val),cast(const(char*))documentation);
}

/**
    As janetDef, but value is mutable, as Janet's "var".
*/
@nogc void janetVar(T,S1,S2)(JanetTable* env,string name,T val,string documentation = "")
{
    import janet.c : janet_var;
    janet_var(env,cast(const(char*))name,janetWrap(val),cast(const(char*))documentation);
}

/**
    Gets a Janet value from a JanetTable. Can take any Janet-compatible type as a key.
*/
@nogc Janet get(T)(JanetTable* tbl,T key)
{
    return janet_table_get(tbl,janetWrap(key));
}
/// As above, but for a struct (JanetKV*).
@nogc Janet get(T)(JanetKV* tbl,T key)
{
    return janet_struct_get(tbl,janetWrap(key));
}