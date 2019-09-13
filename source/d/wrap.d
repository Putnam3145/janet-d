module janet.wrap;

import janet.c;

import janet.d : JanetDAbstractHead, JanetStrType;

private template isInternal(string field) // grabbed up from LuaD
{
	enum isInternal = field.length >= 2 && field[0..2] == "__";
}

import std.traits : isSomeString,isArray,isAssociativeArray,isPointer;
/// Converts a Janet string to a D string.
@nogc string fromJanetString(Janet janet)
{
    import std.string : fromStringz;
    const auto unwrapped = janet_unwrap_string(janet);
    const(char)* charArray = cast(const(char)*)(unwrapped);
    return cast(string)fromStringz(charArray);
}
/// ditto
@nogc string fromJanetString(Janet* janet)
{
    import std.string : fromStringz;
    const auto unwrapped = janet_unwrap_string(*janet);
    const(char)* charArray = cast(const(char)*)(unwrapped);
    return cast(string)fromStringz(charArray);
}
/// Returns true if the Janet argument's type is compatible with the template type. Used for type checking at runtime.
pure @safe @nogc bool janetCompatible(T)(Janet janet)
{
    static if(is(T == bool))
    {
        return janet.type == JanetType.JANET_BOOLEAN;
    }
    else static if(is(T : double) || is(T : int))
    {
        return janet.type == JanetType.JANET_NUMBER;
    }
    else static if(is(T == JanetFiber*))
    {
        return janet.type == JanetType.JANET_FIBER;
    }
    else static if(is(T == JanetFunction*))
    {
        return janet.type == JanetType.JANET_FUNCTION;
    }
    else static if(isSomeString!T)
    {
        return janet.type == JanetType.JANET_STRING || janet.type == JanetType.JANET_SYMBOL || janet.type == JanetType.JANET_KEYWORD || janet.type == JanetType.JANET_BUFFER;
    }
    else static if(isArray!T)
    {
        return janet.type == JanetType.JANET_ARRAY || janet.type == JanetType.JANET_TUPLE;
    }
    else static if(isAssociativeArray!T || is(T == struct))
    {
        return janet.type == JanetType.JANET_TABLE || janet.type == JanetType.JANET_STRUCT;
    }
    else static if(is(T==JanetCFunction))
    {
        return janet.type == JanetType.JANET_CFUNCTION;
    }
    else static if(is(T==class))
    {
        return janet.type == JanetType.JANET_ABSTRACT;
    }
    else static if(isPointer!T)
    {
        return janet.type == JanetType.JANET_POINTER;
    }
    else
    {
        return false;
    }
}

pure @safe @nogc bool janetCompatible(T)(T x,Janet janet)
{
    return janetCompatible!(T)(janet);
}

@nogc T as(T)(Janet janet)
    if(canBeSafelyConverted!T || isSomeString!T || is(T == struct) || isPointer!T)
{
    return (&janet).as!T;
}

T as(T)(Janet janet)
    if(is(T == class))
{
    return (&janet).as!T;
}

private bool canBeSafelyConverted(T)()
{
    return !(isSomeString!T || is(T == class) || is(T == struct) || isPointer!T);
}

/** Converts from a Janet object to an object of the given type
    A safe version of the function will be used for all types that can be safely converted.*/
@safe @nogc T as(T)(Janet* janet)
    if(canBeSafelyConverted!T)
{
    static if(is(T == bool))
    {
        return cast(bool)janet_getboolean(janet,0);
    }
    else static if(is(T : int))
    {
        return janet_getinteger(janet,0);
    }
    else static if(is(T : double))
    {
        return janet_getnumber(janet,0);
    }
    else static if(is(T == JanetFiber*))
    {
        return janet_getfiber(janet,0);
    }
    else static if(is(T == JanetFunction*))
    {
        return janet_getfunction(janet,0);
    }
    else static if(is(T == JanetArray*))
    {
        return janet_getarray(janet,0);
    }
    else static if(is(T == JanetTable*))
    {
        return janet_gettable(janet,0);
    }
    else static if(is(T == JanetBuffer*))
    {
        return janet_getbuffer(janet,0);
    }
    else static if(is(T==JanetCFunction))
    {
        return janet_getcfunction(janet,0);
    }
}
/// ditto
@nogc T as(T,JanetStrType strType = JanetStrType.STRING)(Janet* janet)
    if(isPointer!T || isSomeString!T || is(T == struct))
{
    static if(isPointer!T)
    {
        return cast(T)(janet_getpointer(janet,0));
    }
    else static if(isSomeString!T)
    {
        final switch(strType)
        {
            import std.traits : EnumMembers;
            static foreach(t;EnumMembers!JanetStrType)
            {
                case t:
                    if(!janet_checktype(janet,mixin("JanetType.JANET_"~__traits(identifier,EnumMembers!JanetStrType[t]))))
                    {
                        janet_panic_type(*janet,0,mixin("JANET_TFLAG_"~__traits(identifier,EnumMembers!JanetStrType[t])));
                    }
                    return cast(T)(fromJanetString(janet));
            }
        }
    }
    else static if(is(T == struct))
    {
        JanetTable* tbl = janet_gettable(janet,0);
        T newStruct;
        for(int i=0;i<tbl.count;i++)
        {
            JanetKV kv = tbl.data[i];
            static foreach(field; __traits(allMembers,T))
            {
                if(as!(typeof("T."~field))(kv.key) == field)
                {
                    mixin("newStruct."~field) = as!(typeof(mixin("T."~field)))(kv.value);
                }
            }
        }
        return newStruct;
    }
}
/// ditto
T as(T,JanetStrType strType = JanetStrType.STRING)(Janet* janet)
    if(is(T==class))
{
    // this assumes that wrap has previously been used to make the abstract.
    // abstract objects initialized in janet must be gotten in a different way.
    // i'll probably figure it out eventually, really.
    // and i know that this is a terrible thing to read in comments.
    import janet.register : registerType;
    return cast(T)(*(cast(void**)(janet_getabstract(janet,0,registerType!T))));
}

unittest
{
    int r = 0;
    int* pr = &r;
    Janet j;
    j = janetWrap(pr);
    pr = (j).as!(int*);
}

@safe @nogc Janet janetWrap()
{
    return janet_wrap_nil();
}

/**
    Wraps a D value to a Janet value.
    Works for a bunch of built-in types as well as structs; for classes, see register.d.
*/
@nogc Janet janetWrap(T,JanetStrType strType = JanetStrType.STRING)(T x)
{
    /*For the record, if I try to do operator overloading with this, I get this wonderful error:
        source\d\function.d(40,43): Error: none of the overloads of janetWrap are callable using argument types (int), candidates are:
        source\d\wrap.d(193,19):        janet.wrap.janetWrap(int x)
    so if you're wondering why this is an else-static-if template even though it has one return type, that's why.
    */
    static if(is(T==Janet))
    {
        return x;
    }
    else static if(is(T == bool))
    {
        return janet_wrap_boolean(x);
    }
    else static if(is(T==void*))
    {
        return janet_wrap_abstract(x);
    }
    else static if(is(T == JanetCFunction))
    {
        return janet_wrap_cfunction(x);
    }
    else static if(isSomeString!T)
    {
        import std.string : representation;
        final switch(strType)
        {
            case JanetStrType.STRING:
                return janet_wrap_string(janet_string(cast(ubyte*)x,cast(int)x.length));
            case JanetStrType.SYMBOL:
                return janet_wrap_symbol(janet_string(cast(ubyte*)x,cast(int)x.length));
            case JanetStrType.KEYWORD:
                return janet_wrap_keyword(janet_string(cast(ubyte*)x,cast(int)x.length));
        }
    }
    else static if(is(T==const(char)*))
    {
        final switch(strType)
        {
            case JanetStrType.STRING:
                return janet_wrap_string(janet_cstring(x));
            case JanetStrType.SYMBOL:
                return janet_wrap_symbol(janet_cstring(x));
            case JanetStrType.KEYWORD:
                return janet_wrap_keyword(janet_cstring(x));
        }
    }
    else static if(isPointer!T)
    {
        return janet_wrap_pointer(x);
    }
    else static if(is(T : double))
    {
        return janet_wrap_number_safe(x);
    }
    else static if(is(T : int))
    {
        return janet_wrap_integer(x);
    }
    else static if(isArray!T)
    {
        JanetArray* arr = janet_array(cast(int)x.length);
        foreach(item; x)
        {
            janet_array_push(arr,janetWrap(item));
        }
        return janet_wrap_array(arr);
    }
    else static if(is(T == struct))
    {
        JanetTable* tbl = janet_table(x.tupleof.length);
        import std.traits : isFunction;
        static foreach(field; __traits(allMembers,T))
        {
            static if(!isInternal!field &&
                    field != "this" &&
                    field != "opAssign") // also from LuaD
            {
                static if(isFunction!(mixin("x."~field)))
                {
                    import janet.func : makeJanetCFunc;
                    janet_table_put(tbl,janetWrap(makeJanetCFunc!(mixin("T."~field))(x)));
                }
                else
                {
                    janet_table_put(tbl,janetWrap(field),mixin("janetWrap(x."~field~")"));
                }
            }
        }
        return janet_wrap_table(tbl);
    }
    static assert("Not a compatible type for janet wrap!");
}

unittest
{
    int[] arr = [1,2,3,4,5];
    janetWrap(arr);
}

/// ditto
Janet janetWrap(T)(T x)
    if(is(T == class))
{
    // see the JanetDAbstractHead class and register.d for other info.
    return janet_wrap_abstract(new JanetDAbstractHead!(T)(x).ptr);
}
/// ditto
@nogc Janet janetWrap(alias func)()
{
    import janet.func : makeJanetCFunc;
    return janetWrap(makeJanetCFunc!func);
}

version(unittest)
{
    int baz(int a)
    {
        return a+1;
    }
}

unittest
{
    janetWrap!baz;
}

/// ditto
@nogc Janet janetWrap(K,V)(V[K] arr)
{
    JanetTable* tbl = janet_table(arr.length);
    foreach(K key,V value; arr)
    {
        janet_table_put(arr,janetWrap(key),wrjanetWrapap(value));
    }
    return janet_wrap_table(arr);
}
unittest
{
    import std.stdio : writeln;
    import janet.vm : coreEnv;
    writeln("Starting wrap test.");
    const string foo = "foo";
    Janet* j;
    auto janetFoo = janetWrap(foo);
    import std.string : toStringz;
    janet_def(coreEnv,toStringz("foo"),janetFoo,"A simple string, which should say 'foo'.");
    const auto janetedString = as!string(janetFoo);
    assert(janetedString == foo,janetedString~" is not "~foo~". This is likely caused by compiling with wrong settings (turn nanboxing off!)");
}