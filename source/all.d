module janet.all;

public import janet.d;

unittest
{
    import std.file;
    import std.stdio;
    // run the examples in parallel
    foreach(DirEntry entry;dirEntries("./source/tests/","*.janet",SpanMode.shallow))
    {
        Janet testJanet;
        const ubyte[] file = cast(const(ubyte[]))read(entry.name);
        const(ubyte)* realFile = cast(const(ubyte)*)file;
        int realFileLength = cast(int)(file.length);
        auto errorString = entry.name~" errored!";
        import janet.c : janet_dobytes;
        assert(janet_dobytes(coreEnv,realFile,realFileLength,cast(const(char)*)(entry.name),&testJanet)==0,errorString);
    }
}