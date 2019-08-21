module janet.wrap;

import janet.c;

private template isInternal(string field) // grabbed up from LuaD
{
	enum isInternal = field.length >= 2 && field[0..2] == "__";
}

import std.traits : isSomeString,isArray,isAssociativeArray,isPointer;

string fromJanetString(Janet janet)
{
    import std.string : fromStringz;
    const auto unwrapped = janet_unwrap_string(janet);
    debug import std.stdio;
    const(char)* charArray = cast(const(char)*)(unwrapped);
    debug writeln(*charArray);
    return cast(string)fromStringz(charArray);
}

bool janetCompatible(T)(Janet janet)
{
    static if(is(T : double) || is(T : int))
    {
        return janet.type == JanetType.JANET_NUMBER;
    }
    else static if(is(T == bool))
    {
        return janet.type == JanetType.JANET_BOOLEAN;
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

T getFromJanet(T)(Janet janet)
{
    static if(is(T : int))
    {
        return janet_unwrap_integer(janet);
    }
    else static if(is(T : double))
    {
        return janet_unwrap_number(janet);
    }
    else static if(is(T == bool))
    {
        return cast(bool)janet_unwrap_boolean(janet);
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
        return cast(T*)(janet_unwrap_abstract(janet)); // NOTE : we're assuming you're checking properly here.
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


Janet wrap(T)(T x)
{
    static if(is(T==void*))
    {
        return janet_wrap_abstract(x);
    }
    else static if(isSomeString!T)
    {
        import std.string : toStringz;
        return janet_wrap_string(janet_string(cast(ubyte*)x,cast(int)x.length));
    }
    else static if(isPointer!T)
    {
        return janet_wrap_pointer(x);
    }
    else static if(is(T : double))
    {
        return janet_wrap_number_safe(x);
    }
    else static if(is(T : bool))
    {
        return janet_wrap_boolean(x);
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
                    janet_table_put(tbl,wrap(field),mixin("wrap(x."~field~")"));
                }
            }
        }
        return janet_wrap_table(tbl);
    }
    static assert("Not a compatible type for janet wrap!");
}
Janet wrap(K,V)(V[K] arr)
{
    JanetTable* tbl = janet_table(arr.length);
    foreach(K key,V value; arr)
    {
        janet_table_put(arr,wrap(key),wrap(value));
    }
    return janet_wrap_table(arr);
}

unittest
{
    // This test is failing right now, apparently at the wrapping step.
    janet_init();
    scope(exit) janet_deinit();
    const string foo = "foo";
    auto env = janet_core_env(null);
    Janet* j;
    auto janetFoo = wrap(foo);
    import std.string : toStringz;
    janet_def(env,toStringz("foo"),janetFoo,"A simple string, which should say 'foo'.");
    janet_dostring(env,`(print "Foo is: " foo)`,"",j);
    const auto janetedString = getFromJanet!string(wrap(foo));
    assert(janetedString == foo,janetedString~" is not "~foo);
}