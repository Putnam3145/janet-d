import janet.c;

unittest
{
    import std.file;
    import std.stdio;
    import std.parallelism;
    // run the examples in parallel
    janet_init();
    scope(exit) janet_deinit();
    auto env = janet_core_env(null);
    foreach(DirEntry entry;dirEntries("./source/tests/","*.janet",SpanMode.shallow))
    {
        Janet testJanet;
        const ubyte[] file = cast(const(ubyte[]))read(entry.name);
        const(ubyte)* realFile = cast(const(ubyte)*)file;
        int realFileLength = cast(int)(file.length);
        auto errorString = entry.name~" errored!";
        assert(janet_dobytes(env,realFile,realFileLength,cast(const(char)*)(entry.name),&testJanet)==0,errorString);
    }
}