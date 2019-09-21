import janet;

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