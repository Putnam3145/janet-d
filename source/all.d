module janet.all;

public import janet.d;

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