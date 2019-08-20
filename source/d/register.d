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
                    debug
                    {
                        import std.stdio : writeln;
                        writeln(field);
                        writeln("the value is: ");
                        writeln(mixin("realData."~field));

                    }
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
    janet_init();
    auto abstractClass = registerType!(TestClass,"Bepis");
    auto abstractInstance = janet_abstract(abstractClass,__traits( classInstanceSize,TestClass));
    TestClass baz = cast(TestClass) abstractInstance;
    baz.a = 5;
    baz.b = "foobar";
    baz.bar.foo = 10;
    auto env = janet_core_env(null);
    pragma(msg,__traits( classInstanceSize,TestClass));
    janet_def(env,"bepis",wrap(abstractInstance),"bepis");
    Janet* j;
    assert(janet_dostring(env,"(print (get bepis :a)) (print (get bepis :b)) (print (get bepis :bar)) (print bepis)","",j),"Abstract class errored!");
}