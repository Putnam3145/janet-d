module janet;

public import janet.d;

public import janet.c : Janet,JanetFunction,JanetTable,JanetKV;

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

import std.string : toStringz;

template isStringOrCString(T)
{
    import std.traits : isSomeString,isSomeChar,isPointer,PointerTarget;
    enum isStringOrCString = isSomeString!T || (isPointer!T && isSomeChar!(PointerTarget!T));
}

/**
    Define an immutable value in Janet, as Janet's "def".
    Immutable means something slightly different in Janet than in D,
    so this doesn't take in a const or immutable value.
    This function is @nogc if the value is not a class object.
*/
@nogc void janetDef(T,S1,S2)(JanetTable* env,S1 name,T val,S2 documentation = "")
    if(!(is(T == class)) && isStringOrCString!S1 && isStringOrCString!S2)
{
    import janet.c : janet_def;
    janet_def(env,cast(const(char*))name,janetWrap(val),cast(const(char*))documentation);
}

/// ditto
void janetDef(T,S1,S2)(JanetTable* env,S1 name,T val,S2 documentation = "")
    if(is(T == class) && isStringOrCString!S1 && isStringOrCString!S2)
{
    import janet.c : janet_def;
    janet_def(env,cast(const(char*))name,janetWrap(val),cast(const(char*))documentation);
}

/**
    As janetDef, but value is mutable, as Janet's "var".
*/
@nogc void janetVar(T,S1,S2)(JanetTable* env,string name,T val,string documentation = "")
    if((!(is(T == class))) && isStringOrCString!S1 && isStringOrCString!S2)
{
    import janet.c : janet_var;
    janet_var(env,cast(const(char*))name,janetWrap(val),cast(const(char*))documentation);
}

/// ditto
void janetVar(T,S1,S2)(JanetTable* env,string name,T val,string documentation = "")
    if(is(T == class) && isStringOrCString!S1 && isStringOrCString!S2)
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