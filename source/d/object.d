module janet.object;

import janet.c;

import janet.d;

/** A generic wrapper for a janet pointer. Can be assigned to and initialized like a standard struct. .
    For easier assurances, one can also use the various wrappers around stricter types available (TODO).*/
struct JanetObject
{
    Janet janet; /// The actual janet object this refers to. Aliased to, so all functions that operate on Janet operate on JanetObject.
    alias janet this;
    this(T)(T x) /// Initializer, which can use any type wrap() works with.
    {
        janet = janetWrap(x);
    }
    void opAssign(T)(T x) /// Assignment operator. Can be used with any janet compatible type.
    {
        janet = janetWrap(x);
    }
    T as(T)() /// Gets the janet object as this type. Does proper checking for most types, but some (strings) need to be checked!
    {
        return getFromJanet!T(janet);
    }
    pure @safe @nogc bool compatible(T)() /// Returns true if the janet object can be coerced into the given value.
    {
        return janetCompatible!T(janet);
    }
}

///
unittest
{
    initJanet();
    scope(exit) deinitJanet();
    import std.stdio : writeln;
    writeln("Performing JanetObject test.");
    JanetObject testObj = JanetObject(3);
    assert(testObj.as!int == 3);
    testObj = "foo";
    assert(testObj.as!string == "foo");
    testObj = true;
    assert(testObj.compatible!bool,"Object is not converted to bool correctly!");
    assert(testObj.as!bool,"Object converted to bool is not truthy!");
    class OtherTestClass
    {
        int b = 3;
    }
    auto a = new OtherTestClass;
    testObj = a;
    auto c = testObj.as!OtherTestClass;
    assert(c == a);
}