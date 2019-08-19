import janet.c;

unittest
{
    import std.file;
    import std.stdio;
    janet_init;
    pragma(msg,__traits(getLinkage,janet_core_env));
    Janet testJanet;
    const ubyte[] file = cast(const(ubyte[]))read("./source/tests/hello.janet");
    const(ubyte)* realFile = cast(const(ubyte)*)file;
    int realFileLength = cast(int)(file.length);
    auto empty = janet_table(1);
    auto env = janet_core_env(empty);
    auto n = janet_dobytes(env,realFile,realFileLength,cast(const(char)*)"./source/tests/hello.janet",&testJanet);
}