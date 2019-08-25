module janet.wrap;

import janet.c;

import janet.d : JanetDAbstractHead;

private template isInternal(string field) // grabbed up from LuaD
{
	enum isInternal = field.length >= 2 && field[0..2] == "__";
}

import std.traits : isSomeString,isArray,isAssociativeArray,isPointer;
/// Converts a Janet string to a D string.
string fromJanetString(Janet janet)
{
    import std.string : fromStringz;
    const auto unwrapped = janet_unwrap_string(janet);
    const(char)* charArray = cast(const(char)*)(unwrapped);
    return cast(string)fromStringz(charArray);
}
/// Returns true if the Janet argument's type is compatible with the template type. Used for type checking at runtime.
bool janetCompatible(T)(Janet janet)
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

bool janetCompatible(T)(T x,Janet janet)
{
    return janetCompatible!(T)(janet);
}

/** Converts from a Janet object to an object of the given type.
    Does absolutely no checking on its own! You must check or ensure that it will never coerce to an invalid type yourself.*/
@system T getFromJanet(T)(Janet janet)
{
    static if(is(T == bool))
    {
        return cast(bool)janet_unwrap_boolean(janet);
    }
    else static if(is(T : int))
    {
        return janet_unwrap_integer(janet);
    }
    else static if(is(T : double))
    {
        return janet_unwrap_number(janet);
    }
    else static if(is(T == JanetFiber*))
    {
        return janet_unwrap_fiber(janet);
    }
    else static if(is(T == JanetFunction*))
    {
        return janet_unwrap_function(janet);
    }
    else static if(isSomeString!T)
    {
        return cast(T)(fromJanetString(janet));
    }
    else static if(is(T == JanetArray*))
    {
        return janet_unwrap_array(janet);
    }
    else static if(is(T == JanetTable*))
    {
        return janet_unwrap_table(janet);
    }
    else static if(is(T == JanetBuffer*))
    {
        return janet_unwrap_buffer(janet);
    }
    else static if(is(T == class))
    {
        return cast(T)(janet_unwrap_abstract(janet));
    }
    else static if(is(T == struct))
    {
        JanetTable* tbl = janet_unwrap_table(janet);
        T newStruct;
        for(int i=0;i<tbl.count;i++)
        {
            JanetKV kv = tbl.data[i];
            static foreach(field; __traits(allMembers,T))
            {
                if(getFromJanet!(typeof("T."~field))(kv.key) == field)
                {
                    mixin("newStruct."~field) = getFromJanet!(typeof(mixin("T."~field)))(kv.value);
                }
            }
        }
        return newStruct;
    }
    else static if(is(T==JanetCFunction))
    {
        return janet_unwrap_cfunction(janet);
    }
    else static if(isPointer!T)
    {
        return cast(T)(janet_unwrap_pointer(janet));
    }
}

/**
    Wraps a D value to a Janet value.
    Works for a bunch of built-in types as well as structs; for classes, see register.d.
*/
Janet janetWrap(T,string strType = "string")(T x)
{
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
        import std.string : toStringz;
        final switch(strType)
        {
            case "string":
                return janet_wrap_string(janet_string(cast(ubyte*)x,cast(int)x.length));
            case "symbol":
                return janet_wrap_symbol(janet_string(cast(ubyte*)x,cast(int)x.length));
            case "keyword":
                return janet_wrap_keyword(janet_string(cast(ubyte*)x,cast(int)x.length));
        }
    }
    else static if(is(T==const(char)*))
    {
        final switch(strType)
        {
            case "string":
                return janet_wrap_string(janet_cstring(x));
            case "symbol":
                return janet_wrap_symbol(janet_cstring(x));
            case "keyword":
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
        JanetArray* arr = janet_array(x.length);
        foreach(item; x)
        {
            janet_array_push(arr,wrap(item));
        }
        return janet_wrap_array(arr);
    }
    else static if(is(T == struct))
    {
        JanetTable* tbl = janet_table(x.tupleof.length);
        static foreach(field; __traits(allMembers,T))
        {
            static if(!isInternal!field &&
                    field != "this" &&
                    field != "opAssign") // also from LuaD
            {
                enum isMemberFunction = mixin("is(typeof(&x." ~ field ~ ") == delegate)"); //LuaD
                static if(!isMemberFunction)
                {
                    janet_table_put(tbl,janetWrap(field),mixin("janetWrap(x."~field~")"));
                }
            }
        }
        return janet_wrap_table(tbl);
    }
    else static if(is(T == class))
    {
        // see the JanetDAbstractHead class and register.d for other info.
        return janet_wrap_abstract(new JanetDAbstractHead!(T)(x).ptr);
    }
    static assert("Not a compatible type for janet wrap!");
}

Janet janetWrap(alias func)()
{
    import janet.func : makeJanetCFunc;
    return wrap(makeJanetCFunc!func);
}

/// ditto
Janet janetWrap(K,V)(V[K] arr)
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
    import janet.vm : initJanet, coreEnv;
    initJanet();
    scope(exit) janet_deinit();
    const string foo = "foo";
    Janet* j;
    auto janetFoo = janetWrap(foo);
    import std.string : toStringz;
    janet_def(coreEnv,toStringz("foo"),janetFoo,"A simple string, which should say 'foo'.");
    const auto janetedString = getFromJanet!string(janetWrap(foo));
    assert(janetedString == foo,janetedString~" is not "~foo~". This is likely caused by compiling with wrong settings (turn nanboxing off!)");
}