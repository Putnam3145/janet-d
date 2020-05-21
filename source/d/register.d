module janet.register;

import janet.c;

import janet;

import std.algorithm.searching : startsWith;
private enum isInternal(string field) = field.startsWith("__");

import std.traits : hasStaticMember,isFunction,FunctionAttribute,functionAttributes,arity,Parameters;

private template isPropertySetter(alias sym)
    if(isFunction!sym)
{
    enum isPropertySetter = (functionAttributes!sym & FunctionAttribute.property) && arity!sym == 1;
}

import std.meta : anySatisfy;

enum isSettableProperty(alias sym) = !(isFunction!sym) ||
anySatisfy!(isPropertySetter,__traits(getOverloads,__traits(parent,sym),__traits(identifier,sym)));

private template GetParameterToPropertyFunc(alias sym)
    if(isFunction!sym && isSettableProperty!sym)
{
    static foreach(overload;__traits(getOverloads,__traits(parent,sym),__traits(identifier,sym)))
    {
        import std.traits : arity,Parameters;
        static if(arity!overload == 1)
        {
            alias GetParameterToPropertyFunc = Parameters!overload[0];
        }
    }
}
/**
    This gives us the ability to take a D-initialized object and pass it to Janet without
    moving any data around in particular. The void* should be a pointer given
    by janet_unwrap_abstract on a Janet which was earlier made by janet_wrap_abstract
    on an object of type T. It should be used in any static functions that will be
    expected for registerType on the void* that's sent in.
*/
T getDataFromHelper(T)(void* data)
{
    // though to be honest this might actually be a fantastic misunderstanding/abuse of what abstract types are
    auto helper = *cast(JanetAbstractClassHelper!T*) data;
    return helper.obj;
}

private template defaultGetter(T)
{
    extern(C) int getterFunc(void* data, Janet key,Janet* _out) //Cannot be @nogc because it might call non-@nogc functions.
    {
        import std.string : fromStringz;
        immutable string keyStr = (&key).as!(string,JanetStrType.KEYWORD);
        debug import std.stdio : writeln;
        T realData = getDataFromHelper!(T)(data);
        switch(keyStr)
        {
            static foreach(field; __traits(allMembers,T))
            {
                static if(!isInternal!field &&
                        field != "this" &&
                        field != "Monitor")
                {
                    static if(!isFunction!(mixin("T."~field)) || isSettableProperty!(mixin("T."~field)))
                    {
                        case field:
                            *_out = janetWrap(mixin("realData."~field));
                            return 1;
                    }
                    else
                    {
                        case field:
                            *_out = janetWrap(makeJanetCFunc!(mixin("T."~field))(realData));
                            return 1;
                    }
                }
            }
                default:
                    return 0;
            }
    }
    auto defaultGetter = &getterFunc;
}

private template defaultPut(T)
{
    extern(C) void defaultPutFunc(void* data, Janet key, Janet value)
    {
        string keyStr = (&key).as!(string,JanetStrType.KEYWORD);
        T realData = getDataFromHelper!(T)(data);
        switch(keyStr)
        {
            static foreach(field; __traits(allMembers,T))
            {
                static if(!isInternal!field &&
                        field != "this" &&
                        field != "Monitor" &&
                        isSettableProperty!(mixin("T."~field)))
                {
                /*
                */
                case field:
                    static if(isFunction!(mixin("T."~field)))
                    {
                        mixin("realData."~field~" = value.as!(GetParameterToPropertyFunc!(T."~field~"));");
                    }
                    else
                    {
                        if(janetCompatible!(typeof(mixin("T."~field)))(value))
                        {
                            mixin("realData."~field) = value.as!(typeof(mixin("T."~field)));
                        }
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

private template janetHash(T)
{
    extern(C) int janetHashFunc(void* p, size_t len) 
    {
        T realData = getDataFromHelper!(T)(p);
        return cast(int)((realData.toHash%uint.max)-int.max);
    }
    auto janetHash = &janetHashFunc;
}

private template janetCall(T)
{
    extern(C) Janet janetCallFunc (void* p, int argc, Janet* argv)
    {
        import std.traits : arity;
        T realData = getDataFromHelper!(T)(p);
        return makeJanetCFunc!(realData.opCall,T)(realData)(argc,argv);
    }
    auto janetCall = &janetCallFunc;
}

private template janetCompare(T)
{
    extern(C) int janetCompareFunc(void* lhs, void* rhs)
    {
        auto lHelper = *cast(JanetAbstractClassHelper!T*) lhs;
        auto rHelper = *cast(JanetAbstractClassHelper!T*) rhs;
        return lHelper.obj.opCmp(rHelper.obj);
    }
    auto janetCompare = &janetCompareFunc;
}

/** Allows one to register a JanetAbstractType with Janet.

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

    - Janet __janetNext (void* data, Janet key)

    - int __janetHash (void* p, size_t len)
    
    All of these are optional; get, put and hash will have defaults applied (see the source code for info) if either is not defined. Compare and call are automatically generated for types with opCmp and opCall respectively.

*/
@nogc const(JanetAbstractType)* registerType(T)()
    if(is(T == class))
{
    import core.memory : pureMalloc;
    static if(hasStaticMember!(T,"__janetPackage"))
    {
        enum typeName = T.__janetPackage~"/"~T.stringof;
    }
    else
    {
        enum typeName = T.stringof;
    }
    const auto existingType = janet_get_abstract_type(janet_csymbolv(cast(const(char*))typeName));
    if(existingType)
    {
        return existingType;
    }
    JanetAbstractType newType;
    newType.name = cast(const(char*))typeName;
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
    static if(hasStaticMember!(T,"__janetNext"))
    {
        newType.next = &T.__janetNext;
    }
    static if(hasStaticMember!(T,"__janetHash"))
    {
        newType.hash = &T.__janetHash;
    }
    else
    {
        newType.hash = janetHash!T;
    }
    import std.traits : isCallable, isOrderingComparable;
    static if(isCallable!T)
    {
        newType.call = janetCall!T;
    }
    static if(isOrderingComparable!T)
    {
        newType.compare = janetCompare!T;
    }
    auto typePointer = cast(JanetAbstractType*)pureMalloc(JanetAbstractType.sizeof);
    *typePointer = newType;
    //I am *pretty* sure the below line keeps the allocated memory from leaking.
    //it's 64 bytes per registered type though so it's probably irrelevant
    janet_register_abstract_type(typePointer);
    return typePointer;
}

unittest
{
    import std.stdio : writeln;
    class SmallClass
    {
        int justAnInt = 4;
    }
    writeln("Performing class wrapping memory tests.");
    import std.range : iota;
    foreach(int i;iota(0,10_000))
    {
        SmallClass boo = new SmallClass();
        janetWrap(boo);
    }
    writeln("Success.");
}

unittest
{
    struct Bar
    {
        int foo;
        void voidFunc()
        {
            return;
        }
    }
    class TestClass
    {
        static immutable string __janetPackage="tests";
        int a;
        string b;
        Bar bar;
        int testFunc(int b)
        {
            return b + 2;
        }
        private int _private;
        @property int getSetInt()
        {
            return _private; 
        }
        @property int getSetInt(int n) 
        {
            return _private = n;
        }
    }
    import std.file;
    import std.parallelism : task;
    import std.stdio : writeln;
    writeln("Performing class register test.");
    TestClass baz = new TestClass();
    baz.a = 5;
    baz.b = "foobar";
    baz.bar.foo = 10;
    baz.getSetInt = 12;
    assert(baz.a == 5);
    assert(baz.b == "foobar");
    assert(baz.bar.foo == 10);
    import std.string : toStringz;
    janetDef(coreEnv,"abstractTest",baz,"abstractTest");
    Janet testJanet;
    writeln("Checking abstractTest exists...");
    assert(!doString(`(assert (abstract? abstractTest) "abstractTest exists")`));
    writeln("File to be done...");
    assert(doFile("./source/tests/dtests/register.janet",&testJanet)==0,"Abstract test errored! "~testJanet.as!string);
    writeln("Success.");
}   