module janet;

public import janet.d;

public import janet.c : Janet,JanetFunction,JanetTable,JanetKV;

JanetTable* coreEnv; /// The core environment 

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

/**
    Define an immutable value in Janet, as Janet's "def".
    Immutable means something slightly different in Janet than in D,
    so this doesn't take in a const or immutable value.
    Name and documentation should be string literals, or otherwise
    made to be zero-terminated outside of this.
*/
@nogc void janetDef(T)(JanetTable* env,string name,T val,string documentation = "")
{
    import janet.c : janet_def;
    janet_def(env,cast(const(char*))name,janetWrap(val),cast(const(char*))documentation);
}

/**
    As janetDef, but value is mutable, as Janet's "var".
*/
@nogc void janetVar(T)(JanetTable* env,string name,T val,string documentation = "")
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

package struct JanetAbstractClassHelper(T)
{
    T obj;
}