module janet.object;

import janet.c;

import janet.wrap;

/** A generic wrapper for a janet pointer. Can be assigned to and initialized like a standard struct. 
    As there is no way to get D type info for an object at runtime the getFromJanet template is required to get a value from this.
    One can check which type the object contains with janetCompatible.
    For easier assurances, one can also use the various wrappers around stricter types available (TODO).*/
struct JanetObject
{
    Janet janet; /// The actual janet object this refers to. Aliased to, so all functions that operate on Janet operate on JanetObject.
    alias janet this;
    this(T)(T x) /// Initializer, which can use any function wrap() works with.
    {
        janet = wrap(x);
    }
    void opAssign(T)(T x) /// Assignment operator. Can be used with any janet compatible type.
    {
        janet = wrap(x);
    }
}

///
unittest
{
    janet_init();
    scope(exit) janet_deinit();
    JanetObject testObj = JanetObject(3);
    assert(testObj.getFromJanet!int == 3);
    testObj = "foo";
    assert(testObj.getFromJanet!string == "foo");
}