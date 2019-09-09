module janet.all;

public import janet.d;

public import janet.c : Janet,JanetFunction,JanetTable,JanetKV;

import janet.c;

/**
    Define an immutable value in Janet, as Janet's "def".
    Immutable means something slightly different in Janet than in D,
    so this doesn't take in a const or immutable value.
    This function is @nogc if the value is not a class object.
*/
@nogc void janetDef(T)(JanetTable* env,string name,T val,string documentation = "")
    if(!(is(T == class)))
in
{
    import std.string : toStringz;
    assert(name == toStringz(name),"Name of a def must be a null-terminated string.");
    assert(documentation == toStringz(documentation),"Documentation must be a null-terminated string.");
}
do
{
    import janet.c : janet_def;
    janet_def(env,name,janetWrap(val),documentation);
}

/// ditto
void janetDef(T)(JanetTable* env,string name,T val,string documentation = "")
    if(is(T == class))
in
{
    import std.string : toStringz;
    assert(name == toStringz(name),"Name of a def must be a null-terminated string.");
    assert(documentation == toStringz(documentation),"Documentation must be a null-terminated string.");
}
do
{
    import janet.c : janet_def;
    janet_def(env,name,janetWrap(val),documentation);
}

/**
    As janetDef, but value is mutable, as Janet's "var".
*/
@nogc void janetVar(T)(JanetTable* env,string name,T val,string documentation = "")
    if(!(is(T == class)))
in
{
    import std.string : toStringz;
    assert(name == toStringz(name),"Name of a var must be a null-terminated string.");
    assert(documentation == toStringz(documentation),"Documentation must be a null-terminated string.");
}
do
{
    import janet.c : janet_var;
    janet_var(env,name,janetWrap(val),documentation);
}

/// ditto
void janetVar(T)(JanetTable* env,string name,T val,string documentation = "")
    if(is(T == class))
in
{
    import std.string : toStringz;
    assert(name == toStringz(name),"Name of a var must be a null-terminated string.");
    assert(documentation == toStringz(documentation),"Documentation must be a null-terminated string.");
}
do
{
    import janet.c : janet_var;
    janet_var(env,name,janetWrap(val),documentation);
}

/**
    Gets a Janet value from a JanetTable. Can take any Janet-compatible type as a key.
    Uses a @nogc version for anything that can be converted without the GC (i.e. non-classes).
*/
@nogc Janet get(T)(JanetTable* tbl,T key)
    if(!(is(T == class)))
{
    return janet_table_get(tbl,janetWrap(key));
}
/// ditto
Janet get(T)(JanetTable* tbl,T key)
    if((is(T == class)))
{
    return janet_table_get(tbl,janetWrap(key));
}
/// As above, but for a struct (JanetKV*).
@nogc Janet get(T)(JanetKV* tbl,T key)
    if(!(is(T == class)))
{
    return janet_struct_get(tbl,janetWrap(key));
}
/// ditto
Janet get(T)(JanetKV* tbl,T key)
    if(is(T == class))
{
    return janet_struct_get(tbl,janetWrap(key));
}

unittest
{
    import std.file;
    foreach(DirEntry entry;dirEntries("./source/tests/","suite*.janet",SpanMode.shallow))
    {
        const auto errorString = entry.name~" errored!";
        Janet j;
        assert(doFile(entry.name,&j)==0,errorString~(&j).as!(string));
    }
}