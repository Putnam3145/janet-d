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

module janet.c;

import core.stdc.stdarg;
import core.stdc.stddef;
import core.stdc.stdio;

extern (C):

/***** START SECTION CONFIG *****/

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

/* Enable or disable the peg module */

/* Enable or disable the typedarray module */

/* Enable or disable large int types (for now 64 bit, maybe 128 / 256 bit integer types) */

/* How to export symbols */

/* Tell complier some functions don't return */

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

enum JANET_STACK_MAX = 16384;

/* Use nanboxed values - uses 8 bytes per value instead of 12 or 16.
 * To turn of nanboxing, for debugging purposes or for certain
 * architectures (Nanboxing only tested on x86 and x64), comment out
 * the JANET_NANBOX define.*/

/* We will only enable nanboxing by default on 64 bit systems
 * on x86. This is mainly because the approach is tied to the
 * implicit 47 bit address space. */

/* Runtime config constants */
enum JANET_NANBOX_BIT = 0;

enum JANET_SINGLE_THREADED_BIT = 0;

enum JANET_CURRENT_CONFIG_BITS = JANET_SINGLE_THREADED_BIT | JANET_NANBOX_BIT;

/* Represents the settings used to compile Janet, as well as the version */
struct JanetBuildConfig
{
    uint major;
    uint minor;
    uint patch;
    uint bits;
}

/* Get config of current compilation unit. */

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

/* Use type punning for GC objects */

/* All of the primary Janet GCed types */

/* Prefixed Janet types */

/* Other structs */
alias JanetCFunction = Janet function (int, Janet*);

@nogc: // CFunctions can't be guaranteed to be @nogc, so this goes after the definition

/* Basic types for all Janet Values */
enum JanetType
{
    JANET_NUMBER = 0,
    JANET_NIL = 1,
    JANET_BOOLEAN = 2,
    JANET_FIBER = 3,
    JANET_STRING = 4,
    JANET_SYMBOL = 5,
    JANET_KEYWORD = 6,
    JANET_ARRAY = 7,
    JANET_TUPLE = 8,
    JANET_TABLE = 9,
    JANET_STRUCT = 10,
    JANET_BUFFER = 11,
    JANET_FUNCTION = 12,
    JANET_CFUNCTION = 13,
    JANET_ABSTRACT = 14,
    JANET_POINTER = 15
}

enum JANET_COUNT_TYPES = JanetType.JANET_POINTER + 1;

/* Type flags */
enum JANET_TFLAG_NIL = 1 << JanetType.JANET_NIL;
enum JANET_TFLAG_BOOLEAN = 1 << JanetType.JANET_BOOLEAN;
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
enum JANET_TFLAG_POINTER = 1 << JanetType.JANET_POINTER;

enum JANET_TFLAG_BYTES = JANET_TFLAG_STRING | JANET_TFLAG_SYMBOL | JANET_TFLAG_BUFFER | JANET_TFLAG_KEYWORD;
enum JANET_TFLAG_INDEXED = JANET_TFLAG_ARRAY | JANET_TFLAG_TUPLE;
enum JANET_TFLAG_DICTIONARY = JANET_TFLAG_TABLE | JANET_TFLAG_STRUCT;
enum JANET_TFLAG_LENGTHABLE = JANET_TFLAG_BYTES | JANET_TFLAG_INDEXED | JANET_TFLAG_DICTIONARY;
enum JANET_TFLAG_CALLABLE = JANET_TFLAG_FUNCTION | JANET_TFLAG_CFUNCTION | JANET_TFLAG_LENGTHABLE | JANET_TFLAG_ABSTRACT;

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

/***** START SECTION NON-C API *****/

/* Some janet types use offset tricks to make operations easier in C. For
 * external bindings, we should prefer using the Head structs directly, and
 * use the host language to add sugar around the manipulation of the Janet types. */

pure JanetStructHead* janet_struct_head (const(JanetKV)* st);
pure JanetAbstractHead* janet_abstract_head (const(void)* abstract_);
pure JanetStringHead* janet_string_head (const(ubyte)* s);
pure JanetTupleHead* janet_tuple_head (const(Janet)* tuple);

/* Some language bindings won't have access to the macro versions. */

pure JanetType janet_type (Janet x);
pure int janet_checktype (Janet x, JanetType type);
pure int janet_checktypes (Janet x, int typeflags);
pure int janet_truthy (Janet x);

pure const(JanetKV)* janet_unwrap_struct (Janet x);
pure const(Janet)* janet_unwrap_tuple (Janet x);
pure JanetFiber* janet_unwrap_fiber (Janet x);
pure JanetArray* janet_unwrap_array (Janet x);
pure JanetTable* janet_unwrap_table (Janet x);
pure JanetBuffer* janet_unwrap_buffer (Janet x);
pure const(ubyte)* janet_unwrap_string (Janet x);
pure const(ubyte)* janet_unwrap_symbol (Janet x);
pure const(ubyte)* janet_unwrap_keyword (Janet x);
pure void* janet_unwrap_abstract (Janet x);
pure void* janet_unwrap_pointer (Janet x);
pure JanetFunction* janet_unwrap_function (Janet x);
pure JanetCFunction janet_unwrap_cfunction (Janet x);
pure int janet_unwrap_boolean (Janet x);
pure double janet_unwrap_number (Janet x);
pure int janet_unwrap_integer (Janet x);

Janet janet_wrap_nil ();
Janet janet_wrap_number (double x);
Janet janet_wrap_true ();
Janet janet_wrap_false ();
Janet janet_wrap_boolean (int x);
Janet janet_wrap_string (const(ubyte)* x);
Janet janet_wrap_symbol (const(ubyte)* x);
Janet janet_wrap_keyword (const(ubyte)* x);
Janet janet_wrap_array (JanetArray* x);
Janet janet_wrap_tuple (const(Janet)* x);
Janet janet_wrap_struct (const(JanetKV)* x);
Janet janet_wrap_fiber (JanetFiber* x);
Janet janet_wrap_buffer (JanetBuffer* x);
Janet janet_wrap_function (JanetFunction* x);
Janet janet_wrap_cfunction (JanetCFunction x);
Janet janet_wrap_table (JanetTable* x);
Janet janet_wrap_abstract (void* x);
Janet janet_wrap_pointer (void* x);
Janet janet_wrap_integer (int x);

/***** END SECTION NON-C API *****/

/* 64 Nanboxed Janet value */

/* Wrap the simple types */

/* Unwrap the simple types */

/* Wrap the pointer types */

/* Unwrap the pointer types */

/* 32 bit nanboxed janet */

/* Wrap the pointer types */

/* A general janet value type for more standard C */
struct Janet
{
    union _Anonymous_0
    {
        ulong u64;
        double number;
        int integer;
        void* pointer;
        const(void)* cpointer;
    }

    _Anonymous_0 as;
    JanetType type;
}

pure extern (D) auto janet_u64(T)(auto ref T x)
{
    return x.as.u64;
}

pure @safe extern (D) auto janet_type(T)(auto ref T x)
{
    return x.type;
}

pure @safe extern (D) auto janet_checktype(T0, T1)(auto ref T0 x, auto ref T1 t)
{
    return x.type == t;
}

pure @safe extern (D) auto janet_truthy(T)(auto ref T x)
{
    return x.type != JanetType.JANET_NIL && (x.type != JanetType.JANET_BOOLEAN || (x.as.integer & 0x1));
}

pure extern (D) auto janet_unwrap_struct(T)(auto ref T x)
{
    return cast(const(JanetKV)*) x.as.pointer;
}

pure extern (D) auto janet_unwrap_tuple(T)(auto ref T x)
{
    return cast(const(Janet)*) x.as.pointer;
}

pure extern (D) auto janet_unwrap_fiber(T)(auto ref T x)
{
    return cast(JanetFiber*) x.as.pointer;
}

pure extern (D) auto janet_unwrap_array(T)(auto ref T x)
{
    return cast(JanetArray*) x.as.pointer;
}

pure extern (D) auto janet_unwrap_table(T)(auto ref T x)
{
    return cast(JanetTable*) x.as.pointer;
}

pure extern (D) auto janet_unwrap_buffer(T)(auto ref T x)
{
    return cast(JanetBuffer*) x.as.pointer;
}

pure extern (D) auto janet_unwrap_string(T)(auto ref T x)
{
    return cast(const(ubyte)*) x.as.pointer;
}

pure extern (D) auto janet_unwrap_symbol(T)(auto ref T x)
{
    return cast(const(ubyte)*) x.as.pointer;
}

pure extern (D) auto janet_unwrap_keyword(T)(auto ref T x)
{
    return cast(const(ubyte)*) x.as.pointer;
}

pure extern (D) auto janet_unwrap_abstract(T)(auto ref T x)
{
    return x.as.pointer;
}

pure extern (D) auto janet_unwrap_pointer(T)(auto ref T x)
{
    return x.as.pointer;
}

pure extern (D) auto janet_unwrap_function(T)(auto ref T x)
{
    return cast(JanetFunction*) x.as.pointer;
}

pure extern (D) auto janet_unwrap_cfunction(T)(auto ref T x)
{
    return cast(JanetCFunction) x.as.pointer;
}

pure extern (D) auto janet_unwrap_boolean(T)(auto ref T x)
{
    return x.as.u64 & 0x1;
}

pure extern (D) auto janet_unwrap_number(T)(auto ref T x)
{
    return x.as.number;
}

/* End of tagged union implementation */

pure int janet_checkint (Janet x);
pure int janet_checkint64 (Janet x);
pure int janet_checksize (Janet x);

pure extern (D) auto janet_checkintrange(T)(auto ref T x)
{
    return x == cast(int) x;
}

pure extern (D) auto janet_checkint64range(T)(auto ref T x)
{
    return x == cast(long) x;
}

pure extern (D) auto janet_unwrap_integer(T)(auto ref T x)
{
    return cast(int) janet_unwrap_number(x);
}

pure extern (D) auto janet_wrap_integer(T)(auto ref T x)
{
    return janet_wrap_number(cast(int) x);
}

pure extern (D) auto janet_checktypes(T0, T1)(auto ref T0 x, auto ref T1 tps)
{
    return (1 << janet_type(x)) & tps;
}

/* GC Object type pun. The lower 16 bits of flags are reserved for the garbage collector,
 * but the upper 16 can be used per type for custom flags. The current collector is a linked
 * list of blocks, which is naive but works. */
struct JanetGCObject
{
    int flags;
    JanetGCObject* next;
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
    JanetGCObject gc; /* GC Object stuff */
    int flags; /* More flags */
    int frame; /* Index of the stack frame */
    int stackstart; /* Beginning of next args */
    int stacktop; /* Top of stack. Where values are pushed and popped from. */
    int capacity;
    int maxstack; /* Arbitrary defined limit for stack overflow */
    JanetTable* env; /* Dynamic bindings table (usually current environment). */
    Janet* data;
    JanetFiber* child; /* Keep linked list of fibers for restarting pending fibers */
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
    JanetGCObject gc;
    int count;
    int capacity;
    Janet* data;
}

/* A byte buffer type. Used as a mutable string or string builder. */
struct JanetBuffer
{
    JanetGCObject gc;
    int count;
    int capacity;
    ubyte* data;
}

/* A mutable associative data type. Backed by a hashtable. */
struct JanetTable
{
    JanetGCObject gc;
    int count;
    int capacity;
    int deleted;
    JanetKV* data;
    JanetTable* proto;
}

/* A key value pair in a struct or table */
struct JanetKV
{
    Janet key;
    Janet value;
}

/* Prefix for a tuple */
struct JanetTupleHead
{
    JanetGCObject gc;
    int length;
    int hash;
    int sm_start;
    int sm_end;
    const(Janet)[] data;
}

/* Prefix for a struct */
struct JanetStructHead
{
    JanetGCObject gc;
    int length;
    int hash;
    int capacity;
    const(JanetKV)[] data;
}

/* Prefix for a string */
struct JanetStringHead
{
    JanetGCObject gc;
    int length;
    int hash;
    const(ubyte)[] data;
}

/* Prefix for an abstract value */
struct JanetAbstractHead
{
    JanetGCObject gc;
    const(JanetAbstractType)* type;
    size_t size;
    long[] data; /* Use long long to ensure most general alignment */
}

/* Some function definition flags */
enum JANET_FUNCDEF_FLAG_VARARG = 0x10000;
enum JANET_FUNCDEF_FLAG_NEEDSENV = 0x20000;
enum JANET_FUNCDEF_FLAG_HASNAME = 0x80000;
enum JANET_FUNCDEF_FLAG_HASSOURCE = 0x100000;
enum JANET_FUNCDEF_FLAG_HASDEFS = 0x200000;
enum JANET_FUNCDEF_FLAG_HASENVS = 0x400000;
enum JANET_FUNCDEF_FLAG_HASSOURCEMAP = 0x800000;
enum JANET_FUNCDEF_FLAG_STRUCTARG = 0x1000000;
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
    JanetGCObject gc;
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
    int min_arity; /* Including varargs */
    int max_arity; /* Including varargs */
    int constants_length;
    int bytecode_length;
    int environments_length;
    int defs_length;
}

/* A function environment */
struct JanetFuncEnv
{
    JanetGCObject gc;

    union _Anonymous_1
    {
        JanetFiber* fiber;
        Janet* values;
    }

    _Anonymous_1 as;
    int length; /* Size of environment */
    int offset; /* Stack offset when values still on stack. If offset is <= 0, then
    environment is no longer on the stack. */
}

enum JANET_FUNCFLAG_TRACE = 1 << 16;

/* A function */
struct JanetFunction
{
    JanetGCObject gc;
    JanetFuncDef* def;
    JanetFuncEnv*[] envs;
}

struct JanetParseState;

enum JanetParserStatus
{
    JANET_PARSE_ROOT = 0,
    JANET_PARSE_ERROR = 1,
    JANET_PARSE_PENDING = 2,
    JANET_PARSE_DEAD = 3
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
    int flag;
}

struct JanetMarshalContext
{
    void* m_state; /* void* to not expose MarshalState ?*/
    void* u_state;
    int flags;
    const(ubyte)* data;
}

/* Defines an abstract type */
struct JanetAbstractType
{
    const(char)* name;
    int function (void* data, size_t len) gc;
    int function (void* data, size_t len) gcmark;
    Janet function (void* data, Janet key) get;
    void function (void* data, Janet key, Janet value) put;
    void function (void* p, JanetMarshalContext* ctx) marshal;
    void function (void* p, JanetMarshalContext* ctx) unmarshal;
    void function (void* p, JanetBuffer* buffer) tostring;
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
    JOP_PROPAGATE = 51,
    JOP_GET = 52,
    JOP_PUT = 53,
    JOP_GET_INDEX = 54,
    JOP_PUT_INDEX = 55,
    JOP_LENGTH = 56,
    JOP_MAKE_ARRAY = 57,
    JOP_MAKE_BUFFER = 58,
    JOP_MAKE_STRING = 59,
    JOP_MAKE_STRUCT = 60,
    JOP_MAKE_TABLE = 61,
    JOP_MAKE_TUPLE = 62,
    JOP_MAKE_BRACKET_TUPLE = 63,
    JOP_NUMERIC_LESS_THAN = 64,
    JOP_NUMERIC_LESS_THAN_EQUAL = 65,
    JOP_NUMERIC_GREATER_THAN = 66,
    JOP_NUMERIC_GREATER_THAN_EQUAL = 67,
    JOP_NUMERIC_EQUAL = 68,
    JOP_INSTRUCTION_COUNT = 69
}

/* Info about all instructions */
extern __gshared JanetInstructionType[JanetOpCode.JOP_INSTRUCTION_COUNT] janet_instructions;

/***** END SECTION OPCODES *****/

/***** START SECTION MAIN *****/

/* Parsing */
void janet_parser_init (JanetParser* parser);
void janet_parser_deinit (JanetParser* parser);
void janet_parser_consume (JanetParser* parser, ubyte c);
JanetParserStatus janet_parser_status (JanetParser* parser);
Janet janet_parser_produce (JanetParser* parser);
const(char)* janet_parser_error (JanetParser* parser);
void janet_parser_flush (JanetParser* parser);
void janet_parser_eof (JanetParser* parser);
int janet_parser_has_more (JanetParser* parser);

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
JanetTable* janet_core_env (JanetTable* replacements);

int janet_dobytes (JanetTable* env, const(ubyte)* bytes, int len, const(char)* sourcePath, Janet* out_);
int janet_dostring (JanetTable* env, const(char)* str, const(char)* sourcePath, Janet* out_);

/* Number scanning */
int janet_scan_number (const(ubyte)* str, int len, double* out_);
int janet_scan_int64 (const(ubyte)* str, int len, long* out_);
int janet_scan_uint64 (const(ubyte)* str, int len, ulong* out_);

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

enum JANET_TUPLE_FLAG_BRACKETCTOR = 0x10000;

pure extern (D) auto janet_tuple_head(T)(auto ref T t)
{
    return cast(JanetTupleHead*) cast(char*) t - offsetof(JanetTupleHead, data);
}

pure extern (D) auto janet_tuple_length(T)(auto ref T t)
{
    return janet_tuple_head(t).length;
}

pure extern (D) auto janet_tuple_hash(T)(auto ref T t)
{
    return janet_tuple_head(t).hash;
}

pure extern (D) auto janet_tuple_sm_start(T)(auto ref T t)
{
    return janet_tuple_head(t).sm_start;
}

pure extern (D) auto janet_tuple_sm_end(T)(auto ref T t)
{
    return janet_tuple_head(t).sm_end;
}

pure extern (D) auto janet_tuple_flag(T)(auto ref T t)
{
    return janet_tuple_head(t).gc.flags;
}

Janet* janet_tuple_begin (int length);
const(Janet)* janet_tuple_end (Janet* tuple);
const(Janet)* janet_tuple_n (const(Janet)* values, int n);
pure int janet_tuple_equal (const(Janet)* lhs, const(Janet)* rhs);
pure int janet_tuple_compare (const(Janet)* lhs, const(Janet)* rhs);

/* String/Symbol functions */
pure extern (D) auto janet_string_head(T)(auto ref T s)
{
    return cast(JanetStringHead*) cast(char*) s - offsetof(JanetStringHead, data);
}

pure extern (D) auto janet_string_length(T)(auto ref T s)
{
    return janet_string_head(s).length;
}

pure extern (D) auto janet_string_hash(T)(auto ref T s)
{
    return janet_string_head(s).hash;
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
void janet_formatb (JanetBuffer* bufp, const(char)* format, va_list args);

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
extern (D) auto janet_struct_head(T)(auto ref T t)
{
    return cast(JanetStructHead*) cast(char*) t - offsetof(JanetStructHead, data);
}

extern (D) auto janet_struct_length(T)(auto ref T t)
{
    return janet_struct_head(t).length;
}

extern (D) auto janet_struct_capacity(T)(auto ref T t)
{
    return janet_struct_head(t).capacity;
}

extern (D) auto janet_struct_hash(T)(auto ref T t)
{
    return janet_struct_head(t).hash;
}

JanetKV* janet_struct_begin (int count);
void janet_struct_put (JanetKV* st, Janet key, Janet value);
const(JanetKV)* janet_struct_end (JanetKV* st);
pure Janet janet_struct_get (const(JanetKV)* st, Janet key);
JanetTable* janet_struct_to_table (const(JanetKV)* st);
pure int janet_struct_equal (const(JanetKV)* lhs, const(JanetKV)* rhs);
pure int janet_struct_compare (const(JanetKV)* lhs, const(JanetKV)* rhs);
const(JanetKV)* janet_struct_find (const(JanetKV)* st, Janet key);

/* Table functions */
JanetTable* janet_table (int capacity);
JanetTable* janet_table_init (JanetTable* table, int capacity);
void janet_table_deinit (JanetTable* table);
pure Janet janet_table_get (JanetTable* t, Janet key);
Janet janet_table_rawget (JanetTable* t, Janet key);
Janet janet_table_remove (JanetTable* t, Janet key);
void janet_table_put (JanetTable* t, Janet key, Janet value);
const(JanetKV)* janet_table_to_struct (JanetTable* t);
void janet_table_merge_table (JanetTable* table, JanetTable* other);
void janet_table_merge_struct (JanetTable* table, const(JanetKV)* other);
JanetKV* janet_table_find (JanetTable* t, Janet key);
JanetTable* janet_table_clone (JanetTable* table);

/* Fiber */
JanetFiber* janet_fiber (JanetFunction* callee, int capacity, int argc, const(Janet)* argv);
JanetFiber* janet_fiber_reset (JanetFiber* fiber, JanetFunction* callee, int argc, const(Janet)* argv);
JanetFiberStatus janet_fiber_status (JanetFiber* fiber);
JanetFiber* janet_current_fiber ();

/* Treat similar types through uniform interfaces for iteration */
int janet_indexed_view (Janet seq, const(Janet*)* data, int* len);
int janet_bytes_view (Janet str, const(ubyte*)* data, int* len);
int janet_dictionary_view (Janet tab, const(JanetKV*)* data, int* len, int* cap);
Janet janet_dictionary_get (const(JanetKV)* data, int cap, Janet key);
const(JanetKV)* janet_dictionary_next (const(JanetKV)* kvs, int cap, const(JanetKV)* kv);

/* Abstract */
pure extern (D) auto janet_abstract_head(T)(auto ref T u)
{
    return cast(JanetAbstractHead*) cast(char*) u - offsetof(JanetAbstractHead, data);
}

pure extern (D) auto janet_abstract_type(T)(auto ref T u)
{
    return janet_abstract_head(u).type;
}

pure extern (D) auto janet_abstract_size(T)(auto ref T u)
{
    return janet_abstract_head(u).size;
}

void* janet_abstract_begin (const(JanetAbstractType)* type, size_t size);
void* janet_abstract_end (void*);
void* janet_abstract (const(JanetAbstractType)* type, size_t size); /* begin and end in one call */

/* Native */
alias JanetModule = void function (JanetTable*);
alias JanetModconf = JanetBuildConfig function ();
JanetModule janet_native (const(char)* name, const(ubyte*)* error);

/* Marshaling */
void janet_marshal (JanetBuffer* buf, Janet x, JanetTable* rreg, int flags);
Janet janet_unmarshal (
    const(ubyte)* bytes,
    size_t len,
    int flags,
    JanetTable* reg,
    const(ubyte*)* next);
JanetTable* janet_env_lookup (JanetTable* env);
void janet_env_lookup_into (JanetTable* renv, JanetTable* env, const(char)* prefix, int recurse);

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

/* Pretty printing */
enum JANET_PRETTY_COLOR = 1;
JanetBuffer* janet_pretty (JanetBuffer* buffer, int depth, int flags, Janet x);

/* Misc */
int janet_equals (Janet x, Janet y);
int janet_hash (Janet x);
int janet_compare (Janet x, Janet y);
int janet_cstrcmp (const(ubyte)* str, const(char)* other);
Janet janet_get (Janet ds, Janet key);
Janet janet_getindex (Janet ds, int index);
int janet_length (Janet x);
void janet_put (Janet ds, Janet key, Janet value);
void janet_putindex (Janet ds, int index, Janet value);
ulong janet_getflags (const(Janet)* argv, int n, const(char)* flags);

extern (D) auto janet_flag_at(T0, T1)(auto ref T0 F, auto ref T1 I)
{
    return F & ((1) << I);
}

Janet janet_wrap_number_safe (double x) @trusted;

/* VM functions */
int janet_init ();
void janet_deinit ();
JanetSignal janet_continue (JanetFiber* fiber, Janet in_, Janet* out_);
JanetSignal janet_pcall (JanetFunction* fun, int argn, const(Janet)* argv, Janet* out_, JanetFiber** f);
Janet janet_call (JanetFunction* fun, int argc, const(Janet)* argv);
void janet_stacktrace (JanetFiber* fiber, Janet err);

/* Scratch Memory API */
void* janet_smalloc (size_t size);
void* janet_srealloc (void* mem, size_t size);
void janet_sfree (void* mem);

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

/* Allow setting entry name for static libraries */

alias JANET_ENTRY_NAME = janet_init;

void janet_panicv (Janet message);
void janet_panic (const(char)* message);
void janet_panics (const(ubyte)* message);
void janet_panicf (const(char)* format, ...);
void janet_printf (const(char)* format, ...);
void janet_panic_type (Janet x, int n, int expected);
void janet_panic_abstract (Janet x, int n, const(JanetAbstractType)* at);
void janet_arity (int arity, int min, int max);
void janet_fixarity (int arity, int fix);

pure @trusted Janet janet_getmethod (const(ubyte)* method, const(JanetMethod)* methods);
pure @trusted double janet_getnumber (const(Janet)* argv, int n);
pure @trusted JanetArray* janet_getarray (const(Janet)* argv, int n);
pure @trusted const(Janet)* janet_gettuple (const(Janet)* argv, int n);
pure @trusted JanetTable* janet_gettable (const(Janet)* argv, int n);
pure @trusted const(JanetKV)* janet_getstruct (const(Janet)* argv, int n);
pure @trusted const(ubyte)* janet_getstring (const(Janet)* argv, int n);
pure const(char)* janet_getcstring (const(Janet)* argv, int n); // can't be @trusted -- pointer arithmetic in the C func
pure @trusted const(ubyte)* janet_getsymbol (const(Janet)* argv, int n);
pure @trusted const(ubyte)* janet_getkeyword (const(Janet)* argv, int n);
pure @trusted JanetBuffer* janet_getbuffer (const(Janet)* argv, int n);
pure @trusted JanetFiber* janet_getfiber (const(Janet)* argv, int n);
pure @trusted JanetFunction* janet_getfunction (const(Janet)* argv, int n);
pure @trusted JanetCFunction janet_getcfunction (const(Janet)* argv, int n);
pure @trusted int janet_getboolean (const(Janet)* argv, int n);
pure @trusted void* janet_getpointer (const(Janet)* argv, int n);

pure @trusted int janet_getinteger (const(Janet)* argv, int n);
pure @trusted long janet_getinteger64 (const(Janet)* argv, int n);
pure @trusted size_t janet_getsize (const(Janet)* argv, int n);
pure @trusted JanetView janet_getindexed (const(Janet)* argv, int n);
pure @trusted JanetByteView janet_getbytes (const(Janet)* argv, int n);
pure @trusted JanetDictView janet_getdictionary (const(Janet)* argv, int n);
pure @trusted void* janet_getabstract (const(Janet)* argv, int n, const(JanetAbstractType)* at);
pure @trusted JanetRange janet_getslice (int argc, const(Janet)* argv);
pure @trusted int janet_gethalfrange (const(Janet)* argv, int n, int length, const(char)* which);
pure @trusted int janet_getargindex (const(Janet)* argv, int n, int length, const(char)* which);

Janet janet_dyn (const(char)* name);
void janet_setdyn (const(char)* name, Janet value);

FILE* janet_getfile (const(Janet)* argv, int n, int* flags);
FILE* janet_dynfile (const(char)* name, FILE* def);

/* Marshal API */
void janet_marshal_size (JanetMarshalContext* ctx, size_t value);
void janet_marshal_int (JanetMarshalContext* ctx, int value);
void janet_marshal_int64 (JanetMarshalContext* ctx, long value);
void janet_marshal_byte (JanetMarshalContext* ctx, ubyte value);
void janet_marshal_bytes (JanetMarshalContext* ctx, const(ubyte)* bytes, size_t len);
void janet_marshal_janet (JanetMarshalContext* ctx, Janet x);

size_t janet_unmarshal_size (JanetMarshalContext* ctx);
int janet_unmarshal_int (JanetMarshalContext* ctx);
long janet_unmarshal_int64 (JanetMarshalContext* ctx);
ubyte janet_unmarshal_byte (JanetMarshalContext* ctx);
void janet_unmarshal_bytes (JanetMarshalContext* ctx, ubyte* dest, size_t len);
Janet janet_unmarshal_janet (JanetMarshalContext* ctx);

void janet_register_abstract_type (const(JanetAbstractType)* at);
const(JanetAbstractType)* janet_get_abstract_type (Janet key);

enum JanetTArrayType
{
    JANET_TARRAY_TYPE_U8 = 0,
    JANET_TARRAY_TYPE_S8 = 1,
    JANET_TARRAY_TYPE_U16 = 2,
    JANET_TARRAY_TYPE_S16 = 3,
    JANET_TARRAY_TYPE_U32 = 4,
    JANET_TARRAY_TYPE_S32 = 5,
    JANET_TARRAY_TYPE_U64 = 6,
    JANET_TARRAY_TYPE_S64 = 7,
    JANET_TARRAY_TYPE_F32 = 8,
    JANET_TARRAY_TYPE_F64 = 9
}

struct JanetTArrayBuffer
{
    ubyte* data;
    size_t size;
    int flags;
}

struct JanetTArrayView
{
    union _Anonymous_2
    {
        void* pointer;
        ubyte* u8;
        byte* s8;
        ushort* u16;
        short* s16;
        uint* u32;
        int* s32;
        ulong* u64;
        long* s64;
        float* f32;
        double* f64;
    }

    _Anonymous_2 as;
    JanetTArrayBuffer* buffer;
    size_t size;
    size_t stride;
    JanetTArrayType type;
}

JanetTArrayBuffer* janet_tarray_buffer (size_t size);
JanetTArrayView* janet_tarray_view (JanetTArrayType type, size_t size, size_t stride, size_t offset, JanetTArrayBuffer* buffer);
int janet_is_tarray_view (Janet x, JanetTArrayType type);
JanetTArrayBuffer* janet_gettarray_buffer (const(Janet)* argv, int n);
JanetTArrayView* janet_gettarray_view (const(Janet)* argv, int n, JanetTArrayType type);
JanetTArrayView* janet_gettarray_any (const(Janet)* argv, int n);

enum JanetIntType
{
    JANET_INT_NONE = 0,
    JANET_INT_S64 = 1,
    JANET_INT_U64 = 2
}

JanetIntType janet_is_int (Janet x);
Janet janet_wrap_s64 (long x);
Janet janet_wrap_u64 (ulong x);
long janet_unwrap_s64 (Janet x);
ulong janet_unwrap_u64 (Janet x);
int janet_scan_int64 (const(ubyte)* str, int len, long* out_);
int janet_scan_uint64 (const(ubyte)* str, int len, ulong* out_);

/***** END SECTION MAIN *****/

/* JANET_H_defined */
