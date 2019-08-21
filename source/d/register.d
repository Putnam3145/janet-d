module janet.register;

import janet.c;

import janet.wrap;

private template isInternal(string field) // grabbed up from LuaD
{
	enum isInternal = field.length >= 2 && field[0..2] == "__";
}

import std.traits : hasStaticMember,isFunction;

template defaultGetter(T)
{
    alias GetterFunc = Janet function (void* data, Janet key);
    extern(C) Janet getterFunc(void* data, Janet key)
    {
        if(key.type != JanetType.JANET_KEYWORD && key.type != JanetType.JANET_STRING)
        {
            return janet_wrap_nil();
        }
        import std.string : fromStringz;
        string keyStr = fromJanetString(key);
        T realData = cast(T)data;
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
                    return wrap(mixin("realData."~field));
                }
            }
                default:
                    return janet_wrap_nil();
            }
    }
    auto defaultGetter = &getterFunc;
}

template defaultPut(T)
{
    extern(C) void defaultPutFunc(void* data, Janet key, Janet value)
    {
        if(key.type != JanetType.JANET_KEYWORD && key.type != JanetType.JANET_STRING)
        {
            return;
        }
        string keyStr = key.fromJanetString;
        T realData = cast(T)data;
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

const(JanetAbstractType)* registerType(T,string pack="")()
    if(is(T == class))
{
    JanetAbstractType* newType = new JanetAbstractType;
    static if(pack!="")
    {
        newType.name = cast(const(char)*)(pack~"/"~T.stringof);
    }
    else
    {
        newType.name = cast(const(char)*)(T.stringof);
    }
    pragma(msg,T.stringof~" registered!");
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
        int a;
        string b;
        Bar bar;
    }
    import std.stdio : writeln;
    import std.file;
    import std.parallelism : task;
    auto fileTask = task!read("./source/tests/dtests/register.janet");
    fileTask.executeInNewThread();
    janet_init();
    scope(exit) janet_deinit();
    auto abstractClass = registerType!(TestClass,"tests");
    auto abstractInstance = janet_abstract(abstractClass,__traits( classInstanceSize,TestClass));
    TestClass baz = cast(TestClass) abstractInstance;
    baz.a = 5;
    baz.b = "foobar";
    baz.bar.foo = 10;
    assert(baz.a == 5);
    assert(baz.b == "foobar");
    assert(baz.bar.foo == 10);
    auto env = janet_core_env(null);
    import std.string : toStringz;
    janet_def(env,toStringz("abstractTest"),wrap(abstractInstance),toStringz("abstractTest"));
    Janet* j;
    writeln("Abstract test:");
    Janet testJanet;
    const ubyte[] file = cast(const(ubyte[]))(fileTask.spinForce);
    const(ubyte)* realFile = cast(const(ubyte)*)file;
    int realFileLength = cast(int)(file.length);
    assert(janet_dobytes(env,realFile,realFileLength,
        cast(const(char)*)("./source/tests/dtests/register.janet"),&testJanet)==0,"Abstract test errored!");
}