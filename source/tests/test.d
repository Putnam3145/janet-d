import janet;

unittest
{
    import std.file : dirEntries, DirEntry, SpanMode;
    auto anyErrored = false;
    foreach(DirEntry entry;dirEntries("./source/tests/","suite*.janet",SpanMode.shallow))
    {
        Janet j;
        if(doFile(entry.name,&j))
        {
            anyErrored = true;
        }
    }
    assert(!anyErrored);
}