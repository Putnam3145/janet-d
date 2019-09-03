module janet.all;

public import janet.d;

public import janet.c : JanetFunction,JanetTable,JanetKV;

import janet.c;

/**
    Define an immutable value in Janet.
    Immutable means something slightly different in Janet than in D,
    so this doesn't take in a const or immutable value.
*/
void janetDef(JanetTable* env,string name,Janet val,string documentation = "")
{
    import std.string : toStringz;
    import janet.c : janet_def;
    janet_def(env,toStringz(name),val,toStringz(documentation));
}
/**
    Define a mutable value in Janet.
*/
void janetVar(JanetTable* env,string name,Janet val,string documentation = "")
{
    import std.string : toStringz;
    import janet.c : janet_var;
    janet_var(env,toStringz(name),val,toStringz(documentation));
}

Janet get(JanetTable* tbl,string key)
{
    return janet_table_get(tbl,janetWrap(key));
}

Janet get(JanetTable* tbl,Janet key)
{
    return janet_table_get(tbl,key);
}

Janet get(JanetKV* tbl,string key)
{
    return janet_struct_get(tbl,janetWrap(key));
}

Janet get(JanetKV* tbl,Janet key)
{
    return janet_struct_get(tbl,key);
}

unittest
{
    import std.file;
    import std.stdio;
    import std.parallelism;
    // run the examples in parallel
    foreach(DirEntry entry;dirEntries("./source/tests/","suite*.janet",SpanMode.shallow))
    {
        const auto errorString = entry.name~" errored!";
        JanetObject j;
        assert(doFile(entry.name,&(j.janet))==0,errorString~j.as!string);
    }
}