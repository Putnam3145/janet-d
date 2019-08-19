import janet.c;

unittest
{
    import std.file;
    import std.stdio;
    import std.parallelism;
    // run the examples in parallel
    foreach(DirEntry entry;parallel(dirEntries("./source/tests/","*.janet",SpanMode.depth),1))
    {
        janet_init();
        Janet testJanet;
        const ubyte[] file = cast(const(ubyte[]))read(entry.name);
        writeln("Testing file ",entry.name);
        const(ubyte)* realFile = cast(const(ubyte)*)file;
        int realFileLength = cast(int)(file.length);
        auto empty = janet_table(1);
        auto env = janet_core_env(empty);
        auto errorString = entry.name~" errored!";
        assert(janet_dobytes(env,realFile,realFileLength,cast(const(char)*)(entry.name),&testJanet)==0,errorString);
        writeln("Success!");
    }
}