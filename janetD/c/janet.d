/*
* Copyright (c) 2019 Calvin Rose
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to
* deal in the Software without restriction, including without limitation the
* rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
* sell copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
* IN THE SOFTWARE.
*/

//Converted with dstep

module janet.c;

import core.stdc.math;

extern (C):

/***** START SECTION CONFIG *****/

enum JANET_VERSION = "0.4.0";

enum JANET_BUILD = "local";

/*
 * Detect OS and endianess.
 * From webkit source. There is likely some extreneous
 * detection for unsupported platforms
 */

/* Check Unix */

/* Darwin */

/* GNU/Hurd */

/* Solaris */

/* Enable certain posix features */

enum JANET_WINDOWS = 1;

/* Check 64-bit vs 32-bit */ /* Windows 64 bit */
/* Itanium in LP64 mode */
/* DEC Alpha */
/* BE */
/* S390 64-bit (BE) */

/* ARM 64-bit */
enum JANET_64 = 1;

/* Check big endian */
/* MIPS 32-bit */
/* CPU(PPC) - PowerPC 32-bit */

/* PowerPC 64-bit */
/* Sparc 32bit */
/* Sparc 64-bit */
/* S390 64-bit */
/* S390 32-bit */
/* ARM big endian */
/* ARM RealView compiler */

enum JANET_LITTLE_ENDIAN = 1;

/* Check emscripten */

/* Define how global janet state is declared */

/* Enable or disable dynamic module loading. Enabled by default. */

/* Enable or disable the assembler. Enabled by default. */

/* How to export symbols */

/* Handle runtime errors */

/* What to do when out of memory */

/* Prevent some recursive functions from recursing too deeply
 * ands crashing (the parser). Instead, error out. */
enum JANET_RECURSION_GUARD = 1024;

/* Maximum depth to follow table prototypes before giving up and returning nil. */
enum JANET_MAX_PROTO_DEPTH = 200;

/* Maximum depth to follow table prototypes before giving up and returning nil. */
enum JANET_MAX_MACRO_EXPAND = 200;

/* Define max stack size for stacks before raising a stack overflow error.
 * If this is not defined, fiber stacks can grow without limit (until memory
 * runs out) */
enum JANET_STACK_MAX = 8192;

/* Use nanboxed values - uses 8 bytes per value instead of 12 or 16.
 * To turn of nanboxing, for debugging purposes or for certain
 * architectures (Nanboxing only tested on x86 and x64), comment out
 * the JANET_NANBOX define.*/

/* Alignment for pointers */

enum JANET_WALIGN = 8;

/***** END SECTION CONFIG *****/

/***** START SECTION TYPES *****/

/* Names of all of the types */
extern __gshared const(char*)[16] janet_type_names;
extern __gshared const(char*)[14] janet_signal_names;
extern __gshared const(char*)[16] janet_status_names;

/* Fiber signals */
enum JanetSignal
{
    JANET_SIGNAL_OK = 0,
    JANET_SIGNAL_ERROR = 1,
    JANET_SIGNAL_DEBUG = 2,
    JANET_SIGNAL_YIELD = 3,
    JANET_SIGNAL_USER0 = 4,
    JANET_SIGNAL_USER1 = 5,
    JANET_SIGNAL_USER2 = 6,
    JANET_SIGNAL_USER3 = 7,
    JANET_SIGNAL_USER4 = 8,
    JANET_SIGNAL_USER5 = 9,
    JANET_SIGNAL_USER6 = 10,
    JANET_SIGNAL_USER7 = 11,
    JANET_SIGNAL_USER8 = 12,
    JANET_SIGNAL_USER9 = 13
}

/* Fiber statuses - mostly corresponds to signals. */
enum JanetFiberStatus
{
    JANET_STATUS_DEAD = 0,
    JANET_STATUS_ERROR = 1,
    JANET_STATUS_DEBUG = 2,
    JANET_STATUS_PENDING = 3,
    JANET_STATUS_USER0 = 4,
    JANET_STATUS_USER1 = 5,
    JANET_STATUS_USER2 = 6,
    JANET_STATUS_USER3 = 7,
    JANET_STATUS_USER4 = 8,
    JANET_STATUS_USER5 = 9,
    JANET_STATUS_USER6 = 10,
    JANET_STATUS_USER7 = 11,
    JANET_STATUS_USER8 = 12,
    JANET_STATUS_USER9 = 13,
    JANET_STATUS_NEW = 14,
    JANET_STATUS_ALIVE = 15
}

/* All of the janet types */

/* Other structs */
alias JanetCFunction = Janet function (int argc, Janet* argv);

/* Basic types for all Janet Values */
enum JanetType
{
    JANET_NUMBER = 0,
    JANET_NIL = 1,
    JANET_FALSE = 2,
    JANET_TRUE = 3,
    JANET_FIBER = 4,
    JANET_STRING = 5,
    JANET_SYMBOL = 6,
    JANET_KEYWORD = 7,
    JANET_ARRAY = 8,
    JANET_TUPLE = 9,
    JANET_TABLE = 10,
    JANET_STRUCT = 11,
    JANET_BUFFER = 12,
    JANET_FUNCTION = 13,
    JANET_CFUNCTION = 14,
    JANET_ABSTRACT = 15
}

enum JANET_COUNT_TYPES = JanetType.JANET_ABSTRACT + 1;

/* Type flags */
enum JANET_TFLAG_NIL = 1 << JanetType.JANET_NIL;
enum JANET_TFLAG_FALSE = 1 << JanetType.JANET_FALSE;
enum JANET_TFLAG_TRUE = 1 << JanetType.JANET_TRUE;
enum JANET_TFLAG_FIBER = 1 << JanetType.JANET_FIBER;
enum JANET_TFLAG_NUMBER = 1 << JanetType.JANET_NUMBER;
enum JANET_TFLAG_STRING = 1 << JanetType.JANET_STRING;
enum JANET_TFLAG_SYMBOL = 1 << JanetType.JANET_SYMBOL;
enum JANET_TFLAG_KEYWORD = 1 << JanetType.JANET_KEYWORD;
enum JANET_TFLAG_ARRAY = 1 << JanetType.JANET_ARRAY;
enum JANET_TFLAG_TUPLE = 1 << JanetType.JANET_TUPLE;
enum JANET_TFLAG_TABLE = 1 << JanetType.JANET_TABLE;
enum JANET_TFLAG_STRUCT = 1 << JanetType.JANET_STRUCT;
enum JANET_TFLAG_BUFFER = 1 << JanetType.JANET_BUFFER;
enum JANET_TFLAG_FUNCTION = 1 << JanetType.JANET_FUNCTION;
enum JANET_TFLAG_CFUNCTION = 1 << JanetType.JANET_CFUNCTION;
enum JANET_TFLAG_ABSTRACT = 1 << JanetType.JANET_ABSTRACT;

/* Some abstractions */
enum JANET_TFLAG_BOOLEAN = JANET_TFLAG_TRUE | JANET_TFLAG_FALSE;
enum JANET_TFLAG_BYTES = JANET_TFLAG_STRING | JANET_TFLAG_SYMBOL | JANET_TFLAG_BUFFER | JANET_TFLAG_KEYWORD;
enum JANET_TFLAG_INDEXED = JANET_TFLAG_ARRAY | JANET_TFLAG_TUPLE;
enum JANET_TFLAG_DICTIONARY = JANET_TFLAG_TABLE | JANET_TFLAG_STRUCT;
enum JANET_TFLAG_LENGTHABLE = JANET_TFLAG_BYTES | JANET_TFLAG_INDEXED | JANET_TFLAG_DICTIONARY;
enum JANET_TFLAG_CALLABLE = JANET_TFLAG_FUNCTION | JANET_TFLAG_CFUNCTION;

/* We provide three possible implementations of Janets. The preferred
 * nanboxing approach, for 32 or 64 bits, and the standard C version. Code in the rest of the
 * application must interact through exposed interface. */

/* Required interface for Janet */
/* wrap and unwrap for all types */
/* Get type quickly */
/* Check against type quickly */
/* Small footprint */
/* 32 bit integer support */

/* janet_type(x)
 * janet_checktype(x, t)
 * janet_wrap_##TYPE(x)
 * janet_unwrap_##TYPE(x)
 * janet_truthy(x)
 * janet_memclear(p, n) - clear memory for hash tables to nils
 * janet_u64(x) - get 64 bits of payload for hashing
 */

/* 64 Nanboxed Janet value */
union Janet
{
    ulong u64;
    long i64;
    double number;
    void* pointer;
}

extern (D) auto janet_u64(T)(auto ref T x)
{
    return x.u64;
}

enum JANET_NANBOX_TAGBITS = 0xFFFF800000000000;
enum JANET_NANBOX_PAYLOADBITS = 0x00007FFFFFFFFFFF;

extern (D) auto janet_nanbox_lowtag(T)(auto ref T type)
{
    return cast(ulong) type | 0x1FFF0;
}

extern (D) auto janet_nanbox_tag(T)(auto ref T type)
{
    return janet_nanbox_lowtag(type) << 47;
}

extern (D) auto janet_type(T)(auto ref T x)
{
    return isnan(x.number) ? ((x.u64 >> 47) & 0xF) : JanetType.JANET_NUMBER;
}

extern (D) auto janet_nanbox_checkauxtype(T0, T1)(auto ref T0 x, auto ref T1 type)
{
    return (x.u64 & JANET_NANBOX_TAGBITS) == janet_nanbox_tag(type);
}

extern (D) auto janet_nanbox_isnumber(T)(auto ref T x)
{
    return !isnan(x.number) || janet_nanbox_checkauxtype(x, JanetType.JANET_NUMBER);
}

extern (D) auto janet_checktype(T0, T1)(auto ref T0 x, auto ref T1 t)
{
    return (t == JanetType.JANET_NUMBER) ? janet_nanbox_isnumber(x) : janet_nanbox_checkauxtype(x, t);
}

void* janet_nanbox_to_pointer (Janet x);
Janet janet_nanbox_from_pointer (void* p, ulong tagmask);
Janet janet_nanbox_from_cpointer (const(void)* p, ulong tagmask);
Janet janet_nanbox_from_double (double d);
Janet janet_nanbox_from_bits (ulong bits);

extern (D) auto janet_truthy(T)(auto ref T x)
{
    return !(janet_checktype(x, JanetType.JANET_NIL) || janet_checktype(x, JanetType.JANET_FALSE));
}

extern (D) auto janet_nanbox_wrap_(T0, T1)(auto ref T0 p, auto ref T1 t)
{
    return janet_nanbox_from_pointer(p, janet_nanbox_tag(t));
}

extern (D) auto janet_nanbox_wrap_c(T0, T1)(auto ref T0 p, auto ref T1 t)
{
    return janet_nanbox_from_cpointer(p, janet_nanbox_tag(t));
}

/* Wrap the simple types */
extern (D) auto janet_wrap_nil()
{
    return janet_nanbox_from_payload(JanetType.JANET_NIL, 1);
}

extern (D) auto janet_wrap_true()
{
    return janet_nanbox_from_payload(JanetType.JANET_TRUE, 1);
}

extern (D) auto janet_wrap_false()
{
    return janet_nanbox_from_payload(JanetType.JANET_FALSE, 1);
}

alias janet_wrap_number = janet_nanbox_from_double;

/* Unwrap the simple types */
extern (D) auto janet_unwrap_boolean(T)(auto ref T x)
{
    return janet_checktype(x, JanetType.JANET_TRUE);
}

extern (D) auto janet_unwrap_number(T)(auto ref T x)
{
    return x.number;
}

/* Wrap the pointer types */
extern (D) auto janet_wrap_struct(T)(auto ref T s)
{
    return janet_nanbox_wrap_c(s, JanetType.JANET_STRUCT);
}

extern (D) auto janet_wrap_tuple(T)(auto ref T s)
{
    return janet_nanbox_wrap_c(s, JanetType.JANET_TUPLE);
}

extern (D) auto janet_wrap_fiber(T)(auto ref T s)
{
    return janet_nanbox_wrap_(s, JanetType.JANET_FIBER);
}

extern (D) auto janet_wrap_array(T)(auto ref T s)
{
    return janet_nanbox_wrap_(s, JanetType.JANET_ARRAY);
}

extern (D) auto janet_wrap_table(T)(auto ref T s)
{
    return janet_nanbox_wrap_(s, JanetType.JANET_TABLE);
}

extern (D) auto janet_wrap_buffer(T)(auto ref T s)
{
    return janet_nanbox_wrap_(s, JanetType.JANET_BUFFER);
}

extern (D) auto janet_wrap_string(T)(auto ref T s)
{
    return janet_nanbox_wrap_c(s, JanetType.JANET_STRING);
}

extern (D) auto janet_wrap_symbol(T)(auto ref T s)
{
    return janet_nanbox_wrap_c(s, JanetType.JANET_SYMBOL);
}

extern (D) auto janet_wrap_keyword(T)(auto ref T s)
{
    return janet_nanbox_wrap_c(s, JanetType.JANET_KEYWORD);
}

extern (D) auto janet_wrap_abstract(T)(auto ref T s)
{
    return janet_nanbox_wrap_(s, JanetType.JANET_ABSTRACT);
}

extern (D) auto janet_wrap_function(T)(auto ref T s)
{
    return janet_nanbox_wrap_(s, JanetType.JANET_FUNCTION);
}

extern (D) auto janet_wrap_cfunction(T)(auto ref T s)
{
    return janet_nanbox_wrap_(s, JanetType.JANET_CFUNCTION);
}

/* Unwrap the pointer types */
extern (D) auto janet_unwrap_struct(T)(auto ref T x)
{
    return cast(const(JanetKV)*) janet_nanbox_to_pointer(x);
}

extern (D) auto janet_unwrap_tuple(T)(auto ref T x)
{
    return cast(const(Janet)*) janet_nanbox_to_pointer(x);
}

extern (D) auto janet_unwrap_fiber(T)(auto ref T x)
{
    return cast(JanetFiber*) janet_nanbox_to_pointer(x);
}

extern (D) auto janet_unwrap_array(T)(auto ref T x)
{
    return cast(JanetArray*) janet_nanbox_to_pointer(x);
}

extern (D) auto janet_unwrap_table(T)(auto ref T x)
{
    return cast(JanetTable*) janet_nanbox_to_pointer(x);
}

extern (D) auto janet_unwrap_buffer(T)(auto ref T x)
{
    return cast(JanetBuffer*) janet_nanbox_to_pointer(x);
}

extern (D) auto janet_unwrap_string(T)(auto ref T x)
{
    return cast(const(ubyte)*) janet_nanbox_to_pointer(x);
}

extern (D) auto janet_unwrap_symbol(T)(auto ref T x)
{
    return cast(const(ubyte)*) janet_nanbox_to_pointer(x);
}

extern (D) auto janet_unwrap_keyword(T)(auto ref T x)
{
    return cast(const(ubyte)*) janet_nanbox_to_pointer(x);
}

extern (D) auto janet_unwrap_abstract(T)(auto ref T x)
{
    return janet_nanbox_to_pointer(x);
}

extern (D) auto janet_unwrap_pointer(T)(auto ref T x)
{
    return janet_nanbox_to_pointer(x);
}

extern (D) auto janet_unwrap_function(T)(auto ref T x)
{
    return cast(JanetFunction*) janet_nanbox_to_pointer(x);
}

extern (D) auto janet_unwrap_cfunction(T)(auto ref T x)
{
    return cast(JanetCFunction) janet_nanbox_to_pointer(x);
}

/* 32 bit nanboxed janet */

/* Wrap the pointer types */

/* A general janet value type for more standard C */

/* End of tagged union implementation */

int janet_checkint (Janet x);
int janet_checkint64 (Janet x);

extern (D) auto janet_checkintrange(T)(auto ref T x)
{
    return x == cast(int) x;
}

extern (D) auto janet_checkint64range(T)(auto ref T x)
{
    return x == cast(long) x;
}

extern (D) auto janet_unwrap_integer(T)(auto ref T x)
{
    return cast(int) janet_unwrap_number(x);
}

extern (D) auto janet_wrap_integer(T)(auto ref T x)
{
    return janet_wrap_number(cast(int) x);
}

extern (D) auto janet_checktypes(T0, T1)(auto ref T0 x, auto ref T1 tps)
{
    return (1 << janet_type(x)) & tps;
}

/* Fiber signal masks. */
enum JANET_FIBER_MASK_ERROR = 2;
enum JANET_FIBER_MASK_DEBUG = 4;
enum JANET_FIBER_MASK_YIELD = 8;

enum JANET_FIBER_MASK_USER0 = 16 << 0;
enum JANET_FIBER_MASK_USER1 = 16 << 1;
enum JANET_FIBER_MASK_USER2 = 16 << 2;
enum JANET_FIBER_MASK_USER3 = 16 << 3;
enum JANET_FIBER_MASK_USER4 = 16 << 4;
enum JANET_FIBER_MASK_USER5 = 16 << 5;
enum JANET_FIBER_MASK_USER6 = 16 << 6;
enum JANET_FIBER_MASK_USER7 = 16 << 7;
enum JANET_FIBER_MASK_USER8 = 16 << 8;
enum JANET_FIBER_MASK_USER9 = 16 << 9;

extern (D) auto JANET_FIBER_MASK_USERN(T)(auto ref T N)
{
    return 16 << N;
}

enum JANET_FIBER_MASK_USER = 0x3FF0;

enum JANET_FIBER_STATUS_MASK = 0xFF0000;
enum JANET_FIBER_STATUS_OFFSET = 16;

/* A lightweight green thread in janet. Does not correspond to
 * operating system threads. */
struct JanetFiber
{
    Janet* data;
    JanetFiber* child; /* Keep linked list of fibers for restarting pending fibers */
    int frame; /* Index of the stack frame */
    int stackstart; /* Beginning of next args */
    int stacktop; /* Top of stack. Where values are pushed and popped from. */
    int capacity;
    int maxstack; /* Arbitrary defined limit for stack overflow */
    int flags; /* Various flags */
}

/* Mark if a stack frame is a tail call for debugging */
enum JANET_STACKFRAME_TAILCALL = 1;

/* Mark if a stack frame is an entrance frame */
enum JANET_STACKFRAME_ENTRANCE = 2;

/* A stack frame on the fiber. Is stored along with the stack values. */
struct JanetStackFrame
{
    JanetFunction* func;
    uint* pc;
    JanetFuncEnv* env;
    int prevframe;
    int flags;
}

/* Number of Janets a frame takes up in the stack */
enum JANET_FRAME_SIZE = (JanetStackFrame.sizeof + Janet.sizeof - 1) / Janet.sizeof;

/* A dynamic array type. */
struct JanetArray
{
    Janet* data;
    int count;
    int capacity;
}

/* A byte buffer type. Used as a mutable string or string builder. */
struct JanetBuffer
{
    ubyte* data;
    int count;
    int capacity;
}

/* A mutable associative data type. Backed by a hashtable. */
struct JanetTable
{
    JanetKV* data;
    JanetTable* proto;
    int count;
    int capacity;
    int deleted;
}

/* A key value pair in a struct or table */
struct JanetKV
{
    Janet key;
    Janet value;
}

/* Some function definition flags */
enum JANET_FUNCDEF_FLAG_VARARG = 0x10000;
enum JANET_FUNCDEF_FLAG_NEEDSENV = 0x20000;
enum JANET_FUNCDEF_FLAG_FIXARITY = 0x40000;
enum JANET_FUNCDEF_FLAG_HASNAME = 0x80000;
enum JANET_FUNCDEF_FLAG_HASSOURCE = 0x100000;
enum JANET_FUNCDEF_FLAG_HASDEFS = 0x200000;
enum JANET_FUNCDEF_FLAG_HASENVS = 0x400000;
enum JANET_FUNCDEF_FLAG_HASSOURCEMAP = 0x800000;
enum JANET_FUNCDEF_FLAG_TAG = 0xFFFF;

/* Source mapping structure for a bytecode instruction */
struct JanetSourceMapping
{
    int start;
    int end;
}

/* A function definition. Contains information needed to instantiate closures. */
struct JanetFuncDef
{
    int* environments; /* Which environments to capture from parent. */
    Janet* constants;
    JanetFuncDef** defs;
    uint* bytecode;

    /* Various debug information */
    JanetSourceMapping* sourcemap;
    const(ubyte)* source;
    const(ubyte)* name;

    int flags;
    int slotcount; /* The amount of stack space required for the function */
    int arity; /* Not including varargs */
    int constants_length;
    int bytecode_length;
    int environments_length;
    int defs_length;
}

/* A function environment */
struct JanetFuncEnv
{
    union _Anonymous_0
    {
        JanetFiber* fiber;
        Janet* values;
    }

    _Anonymous_0 as;
    int length; /* Size of environment */
    int offset; /* Stack offset when values still on stack. If offset is <= 0, then
    environment is no longer on the stack. */
}

/* A function */
struct JanetFunction
{
    JanetFuncDef* def;
    JanetFuncEnv*[] envs;
}

struct JanetParseState;

enum JanetParserStatus
{
    JANET_PARSE_ROOT = 0,
    JANET_PARSE_ERROR = 1,
    JANET_PARSE_PENDING = 2
}

/* A janet parser */
struct JanetParser
{
    Janet* args;
    const(char)* error;
    JanetParseState* states;
    ubyte* buf;
    size_t argcount;
    size_t argcap;
    size_t statecount;
    size_t statecap;
    size_t bufcount;
    size_t bufcap;
    size_t offset;
    size_t pending;
    int lookback;
}

/* Defines an abstract type */
struct JanetAbstractType
{
    const(char)* name;
    int function (void* data, size_t len) gc;
    int function (void* data, size_t len) gcmark;
    Janet function (void* data, Janet key) get;
    void function (void* data, Janet key, Janet value) put;
}

/* Contains information about abstract types */
struct JanetAbstractHeader
{
    const(JanetAbstractType)* type;
    size_t size;
}

struct JanetReg
{
    const(char)* name;
    JanetCFunction cfun;
    const(char)* documentation;
}

struct JanetMethod
{
    const(char)* name;
    JanetCFunction cfun;
}

struct JanetView
{
    const(Janet)* items;
    int len;
}

struct JanetByteView
{
    const(ubyte)* bytes;
    int len;
}

struct JanetDictView
{
    const(JanetKV)* kvs;
    int len;
    int cap;
}

struct JanetRange
{
    int start;
    int end;
}

/***** END SECTION TYPES *****/

/***** START SECTION OPCODES *****/

/* Bytecode op argument types */
enum JanetOpArgType
{
    JANET_OAT_SLOT = 0,
    JANET_OAT_ENVIRONMENT = 1,
    JANET_OAT_CONSTANT = 2,
    JANET_OAT_INTEGER = 3,
    JANET_OAT_TYPE = 4,
    JANET_OAT_SIMPLETYPE = 5,
    JANET_OAT_LABEL = 6,
    JANET_OAT_FUNCDEF = 7
}

/* Various types of instructions */
enum JanetInstructionType
{
    JINT_0 = 0, /* No args */
    JINT_S = 1, /* Slot(3) */
    JINT_L = 2, /* Label(3) */
    JINT_SS = 3, /* Slot(1), Slot(2) */
    JINT_SL = 4, /* Slot(1), Label(2) */
    JINT_ST = 5, /* Slot(1), Slot(2) */
    JINT_SI = 6, /* Slot(1), Immediate(2) */
    JINT_SD = 7, /* Slot(1), Closure(2) */
    JINT_SU = 8, /* Slot(1), Unsigned Immediate(2) */
    JINT_SSS = 9, /* Slot(1), Slot(1), Slot(1) */
    JINT_SSI = 10, /* Slot(1), Slot(1), Immediate(1) */
    JINT_SSU = 11, /* Slot(1), Slot(1), Unsigned Immediate(1) */
    JINT_SES = 12, /* Slot(1), Environment(1), Far Slot(1) */
    JINT_SC = 13 /* Slot(1), Constant(2) */
}

/* All opcodes for the bytecode interpreter. */
enum JanetOpCode
{
    JOP_NOOP = 0,
    JOP_ERROR = 1,
    JOP_TYPECHECK = 2,
    JOP_RETURN = 3,
    JOP_RETURN_NIL = 4,
    JOP_ADD_IMMEDIATE = 5,
    JOP_ADD = 6,
    JOP_SUBTRACT = 7,
    JOP_MULTIPLY_IMMEDIATE = 8,
    JOP_MULTIPLY = 9,
    JOP_DIVIDE_IMMEDIATE = 10,
    JOP_DIVIDE = 11,
    JOP_BAND = 12,
    JOP_BOR = 13,
    JOP_BXOR = 14,
    JOP_BNOT = 15,
    JOP_SHIFT_LEFT = 16,
    JOP_SHIFT_LEFT_IMMEDIATE = 17,
    JOP_SHIFT_RIGHT = 18,
    JOP_SHIFT_RIGHT_IMMEDIATE = 19,
    JOP_SHIFT_RIGHT_UNSIGNED = 20,
    JOP_SHIFT_RIGHT_UNSIGNED_IMMEDIATE = 21,
    JOP_MOVE_FAR = 22,
    JOP_MOVE_NEAR = 23,
    JOP_JUMP = 24,
    JOP_JUMP_IF = 25,
    JOP_JUMP_IF_NOT = 26,
    JOP_GREATER_THAN = 27,
    JOP_GREATER_THAN_IMMEDIATE = 28,
    JOP_LESS_THAN = 29,
    JOP_LESS_THAN_IMMEDIATE = 30,
    JOP_EQUALS = 31,
    JOP_EQUALS_IMMEDIATE = 32,
    JOP_COMPARE = 33,
    JOP_LOAD_NIL = 34,
    JOP_LOAD_TRUE = 35,
    JOP_LOAD_FALSE = 36,
    JOP_LOAD_INTEGER = 37,
    JOP_LOAD_CONSTANT = 38,
    JOP_LOAD_UPVALUE = 39,
    JOP_LOAD_SELF = 40,
    JOP_SET_UPVALUE = 41,
    JOP_CLOSURE = 42,
    JOP_PUSH = 43,
    JOP_PUSH_2 = 44,
    JOP_PUSH_3 = 45,
    JOP_PUSH_ARRAY = 46,
    JOP_CALL = 47,
    JOP_TAILCALL = 48,
    JOP_RESUME = 49,
    JOP_SIGNAL = 50,
    JOP_GET = 51,
    JOP_PUT = 52,
    JOP_GET_INDEX = 53,
    JOP_PUT_INDEX = 54,
    JOP_LENGTH = 55,
    JOP_MAKE_ARRAY = 56,
    JOP_MAKE_BUFFER = 57,
    JOP_MAKE_STRING = 58,
    JOP_MAKE_STRUCT = 59,
    JOP_MAKE_TABLE = 60,
    JOP_MAKE_TUPLE = 61,
    JOP_NUMERIC_LESS_THAN = 62,
    JOP_NUMERIC_LESS_THAN_EQUAL = 63,
    JOP_NUMERIC_GREATER_THAN = 64,
    JOP_NUMERIC_GREATER_THAN_EQUAL = 65,
    JOP_NUMERIC_EQUAL = 66,
    JOP_INSTRUCTION_COUNT = 67
}

/* Info about all instructions */
extern __gshared JanetInstructionType[JanetOpCode.JOP_INSTRUCTION_COUNT] janet_instructions;

/***** END SECTION OPCODES *****/

/***** START SECTION MAIN *****/

/* Parsing */
void janet_parser_init (JanetParser* parser);
void janet_parser_deinit (JanetParser* parser);
int janet_parser_consume (JanetParser* parser, ubyte c);
JanetParserStatus janet_parser_status (JanetParser* parser);
Janet janet_parser_produce (JanetParser* parser);
const(char)* janet_parser_error (JanetParser* parser);
void janet_parser_flush (JanetParser* parser);
JanetParser* janet_check_parser (Janet x);

extern (D) auto janet_parser_has_more(T)(auto ref T P)
{
    return P.pending;
}

/* Assembly */
enum JanetAssembleStatus
{
    JANET_ASSEMBLE_OK = 0,
    JANET_ASSEMBLE_ERROR = 1
}

struct JanetAssembleResult
{
    JanetFuncDef* funcdef;
    const(ubyte)* error;
    JanetAssembleStatus status;
}

JanetAssembleResult janet_asm (Janet source, int flags);
Janet janet_disasm (JanetFuncDef* def);
Janet janet_asm_decode_instruction (uint instr);

/* Compilation */
enum JanetCompileStatus
{
    JANET_COMPILE_OK = 0,
    JANET_COMPILE_ERROR = 1
}

struct JanetCompileResult
{
    JanetFuncDef* funcdef;
    const(ubyte)* error;
    JanetFiber* macrofiber;
    JanetSourceMapping error_mapping;
    JanetCompileStatus status;
}

JanetCompileResult janet_compile (Janet source, JanetTable* env, const(ubyte)* where);

/* Get the default environment for janet */
JanetTable* janet_core_env ();

int janet_dobytes (JanetTable* env, const(ubyte)* bytes, int len, const(char)* sourcePath, Janet* out_);
int janet_dostring (JanetTable* env, const(char)* str, const(char)* sourcePath, Janet* out_);

/* Number scanning */
int janet_scan_number (const(ubyte)* str, int len, double* out_);

/* Debugging */
void janet_debug_break (JanetFuncDef* def, int pc);
void janet_debug_unbreak (JanetFuncDef* def, int pc);
void janet_debug_find (
    JanetFuncDef** def_out,
    int* pc_out,
    const(ubyte)* source,
    int offset);

/* Array functions */
JanetArray* janet_array (int capacity);
JanetArray* janet_array_n (const(Janet)* elements, int n);
JanetArray* janet_array_init (JanetArray* array, int capacity);
void janet_array_deinit (JanetArray* array);
void janet_array_ensure (JanetArray* array, int capacity, int growth);
void janet_array_setcount (JanetArray* array, int count);
void janet_array_push (JanetArray* array, Janet x);
Janet janet_array_pop (JanetArray* array);
Janet janet_array_peek (JanetArray* array);

/* Buffer functions */
JanetBuffer* janet_buffer (int capacity);
JanetBuffer* janet_buffer_init (JanetBuffer* buffer, int capacity);
void janet_buffer_deinit (JanetBuffer* buffer);
void janet_buffer_ensure (JanetBuffer* buffer, int capacity, int growth);
void janet_buffer_setcount (JanetBuffer* buffer, int count);
void janet_buffer_extra (JanetBuffer* buffer, int n);
void janet_buffer_push_bytes (JanetBuffer* buffer, const(ubyte)* string, int len);
void janet_buffer_push_string (JanetBuffer* buffer, const(ubyte)* string);
void janet_buffer_push_cstring (JanetBuffer* buffer, const(char)* cstring);
void janet_buffer_push_u8 (JanetBuffer* buffer, ubyte x);
void janet_buffer_push_u16 (JanetBuffer* buffer, ushort x);
void janet_buffer_push_u32 (JanetBuffer* buffer, uint x);
void janet_buffer_push_u64 (JanetBuffer* buffer, ulong x);

/* Tuple */

enum JANET_TUPLE_FLAG_BRACKETCTOR = 1;

extern (D) auto janet_tuple_raw(T)(auto ref T t)
{
    return cast(int*) t - 5;
}

extern (D) auto janet_tuple_length(T)(auto ref T t)
{
    return janet_tuple_raw(t)[0];
}

extern (D) auto janet_tuple_hash(T)(auto ref T t)
{
    return (janet_tuple_raw(t)[1]);
}

extern (D) auto janet_tuple_sm_start(T)(auto ref T t)
{
    return (janet_tuple_raw(t)[2]);
}

extern (D) auto janet_tuple_sm_end(T)(auto ref T t)
{
    return (janet_tuple_raw(t)[3]);
}

extern (D) auto janet_tuple_flag(T)(auto ref T t)
{
    return (janet_tuple_raw(t)[4]);
}

Janet* janet_tuple_begin (int length);
const(Janet)* janet_tuple_end (Janet* tuple);
const(Janet)* janet_tuple_n (const(Janet)* values, int n);
int janet_tuple_equal (const(Janet)* lhs, const(Janet)* rhs);
int janet_tuple_compare (const(Janet)* lhs, const(Janet)* rhs);

/* String/Symbol functions */
extern (D) auto janet_string_raw(T)(auto ref T s)
{
    return cast(int*) s - 2;
}

extern (D) auto janet_string_length(T)(auto ref T s)
{
    return janet_string_raw(s)[0];
}

extern (D) auto janet_string_hash(T)(auto ref T s)
{
    return (janet_string_raw(s)[1]);
}

ubyte* janet_string_begin (int length);
const(ubyte)* janet_string_end (ubyte* str);
const(ubyte)* janet_string (const(ubyte)* buf, int len);
const(ubyte)* janet_cstring (const(char)* cstring);
int janet_string_compare (const(ubyte)* lhs, const(ubyte)* rhs);
int janet_string_equal (const(ubyte)* lhs, const(ubyte)* rhs);
int janet_string_equalconst (const(ubyte)* lhs, const(ubyte)* rhs, int rlen, int rhash);
const(ubyte)* janet_description (Janet x);
const(ubyte)* janet_to_string (Janet x);
void janet_to_string_b (JanetBuffer* buffer, Janet x);
void janet_description_b (JanetBuffer* buffer, Janet x);

extern (D) auto janet_cstringv(T)(auto ref T cstr)
{
    return janet_wrap_string(janet_cstring(cstr));
}

extern (D) auto janet_stringv(T0, T1)(auto ref T0 str, auto ref T1 len)
{
    return janet_wrap_string(janet_string(str, len));
}

const(ubyte)* janet_formatc (const(char)* format, ...);

/* Symbol functions */
const(ubyte)* janet_symbol (const(ubyte)* str, int len);
const(ubyte)* janet_csymbol (const(char)* str);
const(ubyte)* janet_symbol_gen ();

extern (D) auto janet_symbolv(T0, T1)(auto ref T0 str, auto ref T1 len)
{
    return janet_wrap_symbol(janet_symbol(str, len));
}

extern (D) auto janet_csymbolv(T)(auto ref T cstr)
{
    return janet_wrap_symbol(janet_csymbol(cstr));
}

/* Keyword functions */
alias janet_keyword = janet_symbol;
alias janet_ckeyword = janet_csymbol;

extern (D) auto janet_keywordv(T0, T1)(auto ref T0 str, auto ref T1 len)
{
    return janet_wrap_keyword(janet_keyword());
}

extern (D) auto janet_ckeywordv(T)(auto ref T cstr)
{
    return janet_wrap_keyword(janet_ckeyword());
}

/* Structs */
extern (D) auto janet_struct_raw(T)(auto ref T t)
{
    return cast(int*) t - 4;
}

extern (D) auto janet_struct_length(T)(auto ref T t)
{
    return janet_struct_raw(t)[0];
}

extern (D) auto janet_struct_capacity(T)(auto ref T t)
{
    return janet_struct_raw(t)[1];
}

extern (D) auto janet_struct_hash(T)(auto ref T t)
{
    return janet_struct_raw(t)[2];
}

/* Do something with the 4th header slot - flags? */
JanetKV* janet_struct_begin (int count);
void janet_struct_put (JanetKV* st, Janet key, Janet value);
const(JanetKV)* janet_struct_end (JanetKV* st);
Janet janet_struct_get (const(JanetKV)* st, Janet key);
JanetTable* janet_struct_to_table (const(JanetKV)* st);
int janet_struct_equal (const(JanetKV)* lhs, const(JanetKV)* rhs);
int janet_struct_compare (const(JanetKV)* lhs, const(JanetKV)* rhs);
const(JanetKV)* janet_struct_find (const(JanetKV)* st, Janet key);

/* Table functions */
JanetTable* janet_table (int capacity);
JanetTable* janet_table_init (JanetTable* table, int capacity);
void janet_table_deinit (JanetTable* table);
Janet janet_table_get (JanetTable* t, Janet key);
Janet janet_table_rawget (JanetTable* t, Janet key);
Janet janet_table_remove (JanetTable* t, Janet key);
void janet_table_put (JanetTable* t, Janet key, Janet value);
const(JanetKV)* janet_table_to_struct (JanetTable* t);
void janet_table_merge_table (JanetTable* table, JanetTable* other);
void janet_table_merge_struct (JanetTable* table, const(JanetKV)* other);
JanetKV* janet_table_find (JanetTable* t, Janet key);

/* Fiber */
JanetFiber* janet_fiber (JanetFunction* callee, int capacity, int argc, const(Janet)* argv);
JanetFiber* janet_fiber_reset (JanetFiber* fiber, JanetFunction* callee, int argc, const(Janet)* argv);

extern (D) auto janet_fiber_status(T)(auto ref T f)
{
    return (f.flags & JANET_FIBER_STATUS_MASK) >> JANET_FIBER_STATUS_OFFSET;
}

/* Treat similar types through uniform interfaces for iteration */
int janet_indexed_view (Janet seq, const(Janet*)* data, int* len);
int janet_bytes_view (Janet str, const(ubyte*)* data, int* len);
int janet_dictionary_view (Janet tab, const(JanetKV*)* data, int* len, int* cap);
Janet janet_dictionary_get (const(JanetKV)* data, int cap, Janet key);
const(JanetKV)* janet_dictionary_next (const(JanetKV)* kvs, int cap, const(JanetKV)* kv);

/* Abstract */
extern (D) auto janet_abstract_header(T)(auto ref T u)
{
    return cast(JanetAbstractHeader*) u - 1;
}

extern (D) auto janet_abstract_type(T)(auto ref T u)
{
    return janet_abstract_header(u).type;
}

extern (D) auto janet_abstract_size(T)(auto ref T u)
{
    return janet_abstract_header(u).size;
}

void* janet_abstract (const(JanetAbstractType)* type, size_t size);

/* Native */
alias JanetModule = void function (JanetTable*);
JanetModule janet_native (const(char)* name, const(ubyte*)* error);

/* Marshaling */
int janet_marshal (
    JanetBuffer* buf,
    Janet x,
    Janet* errval,
    JanetTable* rreg,
    int flags);
int janet_unmarshal (
    const(ubyte)* bytes,
    size_t len,
    int flags,
    Janet* out_,
    JanetTable* reg,
    const(ubyte*)* next);
JanetTable* janet_env_lookup (JanetTable* env);

/* GC */
void janet_mark (Janet x);
void janet_sweep ();
void janet_collect ();
void janet_clear_memory ();
void janet_gcroot (Janet root);
int janet_gcunroot (Janet root);
int janet_gcunrootall (Janet root);
int janet_gclock ();
void janet_gcunlock (int handle);

/* Functions */
JanetFuncDef* janet_funcdef_alloc ();
JanetFunction* janet_thunk (JanetFuncDef* def);
int janet_verify (JanetFuncDef* def);

/* Misc */
int janet_equals (Janet x, Janet y);
int janet_hash (Janet x);
int janet_compare (Janet x, Janet y);
int janet_cstrcmp (const(ubyte)* str, const(char)* other);
JanetBuffer* janet_pretty (JanetBuffer* buffer, int depth, Janet x);
Janet janet_get (Janet ds, Janet key);
Janet janet_getindex (Janet ds, int index);
int janet_length (Janet x);
void janet_put (Janet ds, Janet key, Janet value);
void janet_putindex (Janet ds, int index, Janet value);

/* VM functions */
int janet_init ();
void janet_deinit ();
JanetSignal janet_continue (JanetFiber* fiber, Janet in_, Janet* out_);
JanetSignal janet_pcall (JanetFunction* fun, int argn, const(Janet)* argv, Janet* out_, JanetFiber** f);
Janet janet_call (JanetFunction* fun, int argc, const(Janet)* argv);
void janet_stacktrace (JanetFiber* fiber, Janet err);

/* C Library helpers */
enum JanetBindingType
{
    JANET_BINDING_NONE = 0,
    JANET_BINDING_DEF = 1,
    JANET_BINDING_VAR = 2,
    JANET_BINDING_MACRO = 3
}

void janet_def (JanetTable* env, const(char)* name, Janet val, const(char)* documentation);
void janet_var (JanetTable* env, const(char)* name, Janet val, const(char)* documentation);
void janet_cfuns (JanetTable* env, const(char)* regprefix, const(JanetReg)* cfuns);
JanetBindingType janet_resolve (JanetTable* env, const(ubyte)* sym, Janet* out_);
void janet_register (const(char)* name, JanetCFunction cfun);

/* New C API */

void janet_panicv (Janet message);
void janet_panic (const(char)* message);
void janet_panics (const(ubyte)* message);
void janet_panic_type (Janet x, int n, int expected);
void janet_panic_abstract (Janet x, int n, const(JanetAbstractType)* at);
void janet_arity (int arity, int min, int max);
void janet_fixarity (int arity, int fix);

Janet janet_getmethod (const(ubyte)* method, const(JanetMethod)* methods);
double janet_getnumber (const(Janet)* argv, int n);
JanetArray* janet_getarray (const(Janet)* argv, int n);
const(Janet)* janet_gettuple (const(Janet)* argv, int n);
JanetTable* janet_gettable (const(Janet)* argv, int n);
const(JanetKV)* janet_getstruct (const(Janet)* argv, int n);
const(ubyte)* janet_getstring (const(Janet)* argv, int n);
const(ubyte)* janet_getsymbol (const(Janet)* argv, int n);
const(ubyte)* janet_getkeyword (const(Janet)* argv, int n);
JanetBuffer* janet_getbuffer (const(Janet)* argv, int n);
JanetFiber* janet_getfiber (const(Janet)* argv, int n);
JanetFunction* janet_getfunction (const(Janet)* argv, int n);
JanetCFunction janet_getcfunction (const(Janet)* argv, int n);
int janet_getboolean (const(Janet)* argv, int n);

int janet_getinteger (const(Janet)* argv, int n);
long janet_getinteger64 (const(Janet)* argv, int n);
JanetView janet_getindexed (const(Janet)* argv, int n);
JanetByteView janet_getbytes (const(Janet)* argv, int n);
JanetDictView janet_getdictionary (const(Janet)* argv, int n);
void* janet_getabstract (const(Janet)* argv, int n, const(JanetAbstractType)* at);
JanetRange janet_getslice (int argc, const(Janet)* argv);
int janet_gethalfrange (const(Janet)* argv, int n, int length, const(char)* which);
int janet_getargindex (const(Janet)* argv, int n, int length, const(char)* which);

/***** END SECTION MAIN *****/

/* JANET_H_defined */
