module janet.d;

public import janet.vm;

public import janet.object;

public import janet.wrap;

public import janet.func;

public import janet.register;

import janet.c;

package struct JanetDAbstractHead(T)
    if(is(T == class))
{
    JanetGCObject gc;
    const(JanetAbstractType)* type;
    size_t size;
    union AbstractUnion
    {
        long[] fakeData;
        T realData;
    }
    AbstractUnion data;
    import janet.register : registerType;
    this(T dataArg)
    {
        type = registerType!T;
        size = __traits(classInstanceSize,T);
        data.realData = dataArg;
    }
    void* ptr()
    {
        return cast(void*)&data;
    }
}