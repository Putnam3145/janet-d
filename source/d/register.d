module janet.register;

import janet.c;

import janet.d;

private template isInternal(string field) // grabbed up from LuaD
{
	enum isInternal = field.length >= 2 && field[0..2] == "__";
}

import std.traits : hasStaticMember,isFunction;

private template defaultGetter(T)
{
    alias GetterFunc = Janet function (void* data, Janet key);
    extern(C) Janet getterFunc(void* data, Janet key)
    {
        if(key.type != JanetType.JANET_KEYWORD && key.type != JanetType.JANET_STRING)
        {
            return janet_wrap_nil();
        }
        import std.string : fromStringz;
        string keyStr = key.getFromJanet!string;
        /*
            While it's fresh in my mind:
            the void* passed in is a pointer to a JanetDAbstractHead!T's data member,
            which is a union of a long[] and an object of class T.
            As objects of classes are pass-by-reference, this object is actually a pointer, and can be accessed as such with a void*.
            Since we know that the data at the union is a memory address, we can convert it to a void**, then treat the data there
            as an object of class T.
        */
        T realData = cast(T)*(cast(void**)data); //TODO: figure out a way to do this that isn't so onerous
        switch(keyStr)
        {
            static foreach(field; __traits(allMembers,T))
            {
                static if(!isInternal!field &&
                        field != "this" &&
                        field != "Monitor")
                {
                    static if(isFunction!(mixin("T."~field)))
                    {
                        case field:
                            return janetWrap(makeJanetCFunc!(mixin("realData."~field))(&mixin("realData."~field)));
                    }
                    else
                    {
                        case field:
                            return janetWrap(mixin("realData."~field));
                    }
                }
            }
                default:
                    return janet_wrap_nil();
            }
    }
    auto defaultGetter = &getterFunc;
}

private template defaultPut(T)
{
    extern(C) void defaultPutFunc(void* data, Janet key, Janet value)
    {
        if(key.type != JanetType.JANET_KEYWORD && key.type != JanetType.JANET_STRING)
        {
            return;
        }
        string keyStr = key.getFromJanet!string;
        T realData = cast(T)*(cast(void**)data);
        switch(keyStr)
        {
            static foreach(field; __traits(allMembers,T))
            {
                static if(!isInternal!field &&
                        field != "this" &&
                        field != "Monitor" &&
                        !isFunction!(mixin("T."~field)))
                {
                case field:
                    if(janetCompatible!(typeof(mixin("T."~field)))(value))
                    {
                        mixin("realData."~field) = getFromJanet!(typeof(mixin("T."~field)))(value);
                    }
                    return;
                }
            }
            default:
                return;
        }
    }
    auto defaultPut = &defaultPutFunc;
}
/** Allows one to register a JanetAbstractType with Janet.

    The returned object can be used as an argument for the janet_abstract function, which will return a void*.

    This void* can be safely(?) cast to T (TODO: prove safety, make function to ensure it if so).

    One can add static string to the class by the name of "janetPackage", which will be prepended to its class name in Janet before a '/'.

    For example: register class "Bar" with janetPackage "Foo" will result in "Foo/Bar".

    This process may be made easier in a later version.

    A registered class looks for the following functions:

    - Janet __janetGet(void* data,Janet key)
    
    - void __janetPut(void* data,Janet key,Janet value)
    
    - void __janetMarshal (void* p, JanetMarshalContext* ctx)
    
    - void __janetUnmarshal (void* p, JanetMarshalContext* ctx)
    
    - void __janetTostring (void* p, JanetBuffer* buffer)
    
    - int __janetGC (void* data, size_t len)
    
    - int __janetGCMark (void* data, size_t len)
    
    All of these are optional; get and put will have defaults applied (see the source code for info) if none is defined.

*/
const(JanetAbstractType)* registerType(T)()
    if(is(T == class))
{
    JanetAbstractType* newType = new JanetAbstractType;
    import std.string : toStringz;
    static if(hasStaticMember!(T,"janetPackage"))
    {
        newType.name = cast(const(char)*)toStringz(T.janetPackage~"/"~T.stringof);
    }
    else
    {
        newType.name = cast(const(char)*)toStringz(T.stringof);
    }
    {
        const auto existingType = janet_get_abstract_type(janet_csymbolv(newType.name));
        if(existingType)
        {
            return existingType;
        }
    }
    static if(hasStaticMember!(T,"__janetGet"))
    {
        newType.get = &T.__janetGet;
    }
    else
    {
        newType.get = defaultGetter!T;
    }
    static if(hasStaticMember!(T,"__janetPut"))
    {
        newType.get = &T.__janetPut;
    }
    else
    {
        newType.put = defaultPut!T;
    }
    static if(hasStaticMember!(T,"__janetMarshal"))
    {
        newType.marshal = &T.__janetMarshal;
    }
    static if(hasStaticMember!(T,"__janetUnmarshal"))
    {
        newType.unmarshal = &T.__janetUnmarshal;
    }
    static if(hasStaticMember!(T,"__janetGC"))
    {
        newType.gc = &T.__janetGC;
    }
    static if(hasStaticMember!(T,"__janetGCMark"))
    {
        newType.gcmark = &T.__janetGCMark;
    }
    static if(hasStaticMember!(T,"__janetToString"))
    {
        newType.tostring = &T.__janetToString;
    }
    janet_register_abstract_type(newType);
    return newType;
}

unittest
{
    struct Bar
    {
        int foo;
    }
    class TestClass
    {
        static string janetPackage="tests";
        int a;
        string b;
        Bar bar;
        int testFunc(int b)
        {
            return b + 2;
        }
    }
    import std.file;
    import std.parallelism : task;
    auto fileTask = task!read("./source/tests/dtests/register.janet");
    fileTask.executeInNewThread();
    initJanet();
    scope(exit) janet_deinit();
    import std.stdio : writeln;
    writeln("Performing class register test.");
    TestClass baz = new TestClass();
    baz.a = 5;
    baz.b = "foobar";
    baz.bar.foo = 10;
    auto abstractInstance = janetWrap(baz);
    assert(baz.a == 5);
    assert(baz.b == "foobar");
    assert(baz.bar.foo == 10);
    import std.string : toStringz;
    janet_def(coreEnv,toStringz("abstractTest"),abstractInstance,toStringz("abstractTest"));
    Janet* j;
    Janet testJanet;
    const ubyte[] file = cast(const(ubyte[]))(fileTask.spinForce);
    const(ubyte)* realFile = cast(const(ubyte)*)file;
    int realFileLength = cast(int)(file.length);
    assert(janet_dobytes(coreEnv,realFile,realFileLength,
        cast(const(char)*)("./source/tests/dtests/register.janet"),&testJanet)==0,"Abstract test errored!");
    writeln("Success.");
    writeln("Performing class wrapping access violation test.");
    foreach(int i;0..10000)
    {
        TestClass boo = new TestClass();
        auto abst = janetWrap(boo);
    }
    writeln("Success.");
}