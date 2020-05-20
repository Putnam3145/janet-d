/*
* Copyright (c) 2020 Calvin Rose
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
import core.stdc.stdint;
import core.stdc.stdio;

extern (C):

/* Variable length arrays are ok */

/***** START SECTION CONFIG *****/

enum JANET_BUILD = "local";

/*
 * Detect OS and endianess.
 * From webkit source. There is likely some extreneous
 * detection for unsupported platforms
 */

/* Check for any flavor of BSD (except apple) */

/* Check for Mac */

/* Check for Linux */

/* Check Unix */

/* Darwin */

/* GNU/Hurd */

/* Solaris */

enum JANET_WINDOWS = 1;

/* Check 64-bit vs 32-bit */ /* Windows 64 bit */
/* Itanium in LP64 mode */
/* DEC Alpha */
/* BE */
/* S390 64-bit (BE) */

/* ARM 64-bit */
enum JANET_64 = 1;

/* Check big endian */
/* If we know the target is LE, always use that - e.g. ppc64 little endian
 * defines the __LITTLE_ENDIAN__ macro in the ABI spec, so we can rely
 * on that and if that's not defined, fall back to big endian assumption
 */
enum JANET_LITTLE_ENDIAN = 1;
/* MIPS 32-bit */
/* CPU(PPC) - PowerPC 32-bit */

/* PowerPC 64-bit */
/* Sparc 32bit */
/* Sparc 64-bit */
/* S390 64-bit */
/* S390 32-bit */
/* ARM big endian */
/* ARM RealView compiler */

/* Check emscripten */

/* Check sun */

/* Add some windows flags */

/* Define how global janet state is declared */

/* Enable or disable dynamic module loading. Enabled by default. */

/* Enable or disable the assembler. Enabled by default. */

/* Enable or disable the peg module */

/* Enable or disable the typedarray module */

/* Enable or disable networking */

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

/* Define default max stack size for stacks before raising a stack overflow error.
 * This can also be set on a per fiber basis. */

enum JANET_STACK_MAX = 0x7fffffff;

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

// Must be defined before including stdlib.h

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

enum JANET_SIGNAL_EVENT = JanetSignal.JANET_SIGNAL_USER9;

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

/* Recursive type (Janet) */

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

    _Anonymous_0 as_c;
    JanetType type;
}

/* C functions */
alias JanetCFunction = Janet function (int argc, Janet* argv);

@nogc:

/* String and other aliased pointer types */
alias JanetString = const(ubyte)*;
alias JanetSymbol = const(ubyte)*;
alias JanetKeyword = const(ubyte)*;
alias JanetTuple = const(Janet)*;
alias JanetStruct = const(JanetKV)*;
alias JanetAbstract = void*;

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

@safe Janet janet_wrap_nil ();
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

/* Wrap the simple types */

/* Unwrap the simple types */

/* Wrap the pointer types */

/* Unwrap the pointer types */

/* Wrap the pointer types */

pure @safe extern (D) auto janet_u64(T)(auto ref T x)
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
    return x.type != JanetType.JANET_NIL && (x.type != JanetType.JANET_BOOLEAN || (x.as.u64 & 0x1));
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

pure @safe extern (D) auto janet_unwrap_boolean(T)(auto ref T x)
{
    return x.as.u64 & 0x1;
}

pure @safe extern (D) auto janet_unwrap_number(T)(auto ref T x)
{
    return x.as.number;
}

/* End of tagged union implementation */

pure int janet_checkint (Janet x);
pure int janet_checkint64 (Janet x);
pure int janet_checksize (Janet x);
JanetAbstract janet_checkabstract (Janet x, const(JanetAbstractType)* at);

pure @safe extern (D) auto janet_checkintrange(T)(auto ref T x)
{
    return x >= INT32_MIN && x <= INT32_MAX && x == cast(int) x;
}

pure @safe extern (D) auto janet_checkint64range(T)(auto ref T x)
{
    return x >= INT64_MIN && x <= INT64_MAX && x == cast(long) x;
}

pure @safe extern (D) auto janet_unwrap_integer(T)(auto ref T x)
{
    return cast(int) janet_unwrap_number(x);
}

pure @safe extern (D) auto janet_wrap_integer(T)(auto ref T x)
{
    return janet_wrap_number(cast(int) x);
}

pure @safe extern (D) auto janet_checktypes(T0, T1)(auto ref T0 x, auto ref T1 tps)
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

/* Number of Janets a frame takes up in the stack
 * Should be constant across architectures */
enum JANET_FRAME_SIZE = 4;

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
    int sm_line;
    int sm_column;
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
enum JANET_FUNCDEF_FLAG_HASCLOBITSET = 0x2000000;
enum JANET_FUNCDEF_FLAG_TAG = 0xFFFF;

/* Source mapping structure for a bytecode instruction */
struct JanetSourceMapping
{
    int line;
    int column;
}

/* A function definition. Contains information needed to instantiate closures. */
struct JanetFuncDef
{
    JanetGCObject gc;
    int* environments; /* Which environments to capture from parent. */
    Janet* constants;
    JanetFuncDef** defs;
    uint* bytecode;
    uint* closure_bitset; /* Bit set indicating which slots can be referenced by closures. */

    /* Various debug information */
    JanetSourceMapping* sourcemap;
    JanetString source;
    JanetString name;

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
    size_t line;
    size_t column;
    size_t pending;
    int lookback;
    int flag;
}

/* A context for marshaling and unmarshaling abstract types */
struct JanetMarshalContext
{
    void* m_state;
    void* u_state;
    int flags;
    const(ubyte)* data;
    const(JanetAbstractType)* at;
}

/* Defines an abstract type */
struct JanetAbstractType
{
    const(char)* name;
    int function (void* data, size_t len) gc;
    int function (void* data, size_t len) gcmark;
    int function (void* data, Janet key, Janet* out_) get;
    void function (void* data, Janet key, Janet value) put;
    void function (void* p, JanetMarshalContext* ctx) marshal;
    void* function (JanetMarshalContext* ctx) unmarshal;
    void function (void* p, JanetBuffer* buffer) tostring;
    int function (void* lhs, void* rhs) compare;
    int function (void* p, size_t len) hash;
    Janet function (void* p, Janet key) next;
    Janet function (void* p, int argc, Janet* argv) call;
}

/* Some macros to let us add extra types to JanetAbstract types without
 * needing to changing native modules that declare them as static const
 * structures. If more fields are added, these macros are modified to include
 * default values (usually NULL). This silences missing field warnings. */

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

struct JanetRNG
{
    uint a;
    uint b;
    uint c;
    uint d;
    uint counter;
}

struct JanetFile
{
    FILE* file;
    int flags;
}

/* Thread types */
struct JanetMailbox;

struct JanetThread
{
    JanetMailbox* mailbox;
    JanetTable* encode;
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
    JOP_MODULO = 12,
    JOP_REMAINDER = 13,
    JOP_BAND = 14,
    JOP_BOR = 15,
    JOP_BXOR = 16,
    JOP_BNOT = 17,
    JOP_SHIFT_LEFT = 18,
    JOP_SHIFT_LEFT_IMMEDIATE = 19,
    JOP_SHIFT_RIGHT = 20,
    JOP_SHIFT_RIGHT_IMMEDIATE = 21,
    JOP_SHIFT_RIGHT_UNSIGNED = 22,
    JOP_SHIFT_RIGHT_UNSIGNED_IMMEDIATE = 23,
    JOP_MOVE_FAR = 24,
    JOP_MOVE_NEAR = 25,
    JOP_JUMP = 26,
    JOP_JUMP_IF = 27,
    JOP_JUMP_IF_NOT = 28,
    JOP_JUMP_IF_NIL = 29,
    JOP_JUMP_IF_NOT_NIL = 30,
    JOP_GREATER_THAN = 31,
    JOP_GREATER_THAN_IMMEDIATE = 32,
    JOP_LESS_THAN = 33,
    JOP_LESS_THAN_IMMEDIATE = 34,
    JOP_EQUALS = 35,
    JOP_EQUALS_IMMEDIATE = 36,
    JOP_COMPARE = 37,
    JOP_LOAD_NIL = 38,
    JOP_LOAD_TRUE = 39,
    JOP_LOAD_FALSE = 40,
    JOP_LOAD_INTEGER = 41,
    JOP_LOAD_CONSTANT = 42,
    JOP_LOAD_UPVALUE = 43,
    JOP_LOAD_SELF = 44,
    JOP_SET_UPVALUE = 45,
    JOP_CLOSURE = 46,
    JOP_PUSH = 47,
    JOP_PUSH_2 = 48,
    JOP_PUSH_3 = 49,
    JOP_PUSH_ARRAY = 50,
    JOP_CALL = 51,
    JOP_TAILCALL = 52,
    JOP_RESUME = 53,
    JOP_SIGNAL = 54,
    JOP_PROPAGATE = 55,
    JOP_IN = 56,
    JOP_GET = 57,
    JOP_PUT = 58,
    JOP_GET_INDEX = 59,
    JOP_PUT_INDEX = 60,
    JOP_LENGTH = 61,
    JOP_MAKE_ARRAY = 62,
    JOP_MAKE_BUFFER = 63,
    JOP_MAKE_STRING = 64,
    JOP_MAKE_STRUCT = 65,
    JOP_MAKE_TABLE = 66,
    JOP_MAKE_TUPLE = 67,
    JOP_MAKE_BRACKET_TUPLE = 68,
    JOP_GREATER_THAN_EQUAL = 69,
    JOP_LESS_THAN_EQUAL = 70,
    JOP_NEXT = 71,
    JOP_INSTRUCTION_COUNT = 72
}

/* Info about all instructions */
extern __gshared JanetInstructionType[JanetOpCode.JOP_INSTRUCTION_COUNT] janet_instructions;

/***** END SECTION OPCODES *****/

/***** START SECTION MAIN *****/

/* Event Loop */
void janet_loop ();

/* Parsing */
extern __gshared const JanetAbstractType janet_parser_type;
pure void janet_parser_init (JanetParser* parser);
pure void janet_parser_deinit (JanetParser* parser);
pure void janet_parser_consume (JanetParser* parser, ubyte c);
pure JanetParserStatus janet_parser_status (JanetParser* parser);
pure Janet janet_parser_produce (JanetParser* parser);
pure const(char)* janet_parser_error (JanetParser* parser);
pure void janet_parser_flush (JanetParser* parser);
pure void janet_parser_eof (JanetParser* parser);
pure int janet_parser_has_more (JanetParser* parser);

/* Assembly */
enum JanetAssembleStatus
{
    JANET_ASSEMBLE_OK = 0,
    JANET_ASSEMBLE_ERROR = 1
}

struct JanetAssembleResult
{
    JanetFuncDef* funcdef;
    JanetString error;
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
    JanetString error;
    JanetFiber* macrofiber;
    JanetSourceMapping error_mapping;
    JanetCompileStatus status;
}

JanetCompileResult janet_compile (Janet source, JanetTable* env, JanetString where);

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
    JanetString source,
    int line,
    int column);

/* RNG */
extern __gshared const JanetAbstractType janet_rng_type;
JanetRNG* janet_default_rng ();
pure void janet_rng_seed (JanetRNG* rng, uint seed);
pure void janet_rng_longseed (JanetRNG* rng, const(ubyte)* bytes, int len);
pure uint janet_rng_u32 (JanetRNG* rng);

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
void janet_buffer_push_string (JanetBuffer* buffer, JanetString string);
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

pure extern (D) auto janet_tuple_from_head(T)(auto ref T gcobject)
{
    return cast(const(Janet)*) cast(char*) gcobject + offsetof(JanetTupleHead, data);
}

pure extern (D) auto janet_tuple_length(T)(auto ref T t)
{
    return janet_tuple_head(t).length;
}

pure extern (D) auto janet_tuple_hash(T)(auto ref T t)
{
    return janet_tuple_head(t).hash;
}

pure extern (D) auto janet_tuple_sm_line(T)(auto ref T t)
{
    return janet_tuple_head(t).sm_line;
}

pure extern (D) auto janet_tuple_sm_column(T)(auto ref T t)
{
    return janet_tuple_head(t).sm_column;
}

pure extern (D) auto janet_tuple_flag(T)(auto ref T t)
{
    return janet_tuple_head(t).gc.flags;
}

Janet* janet_tuple_begin (int length);
JanetTuple janet_tuple_end (Janet* tuple);
JanetTuple janet_tuple_n (const(Janet)* values, int n);

/* String/Symbol functions */
extern (D) auto janet_string_head(T)(auto ref T s)
{
    return cast(JanetStringHead*) cast(char*) s - offsetof(JanetStringHead, data);
}

extern (D) auto janet_string_length(T)(auto ref T s)
{
    return janet_string_head(s).length;
}

extern (D) auto janet_string_hash(T)(auto ref T s)
{
    return janet_string_head(s).hash;
}

ubyte* janet_string_begin (int length);
JanetString janet_string_end (ubyte* str);
JanetString janet_string (const(ubyte)* buf, int len);
JanetString janet_cstring (const(char)* cstring);
int janet_string_compare (JanetString lhs, JanetString rhs);
int janet_string_equal (JanetString lhs, JanetString rhs);
int janet_string_equalconst (JanetString lhs, const(ubyte)* rhs, int rlen, int rhash);
JanetString janet_description (Janet x);
JanetString janet_to_string (Janet x);
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

JanetString janet_formatc (const(char)* format, ...);
JanetBuffer* janet_formatb (JanetBuffer* bufp, const(char)* format, ...);
void janet_formatbv (JanetBuffer* bufp, const(char)* format, va_list args);

/* Symbol functions */
JanetSymbol janet_symbol (const(ubyte)* str, int len);
JanetSymbol janet_csymbol (const(char)* str);
JanetSymbol janet_symbol_gen ();

extern (D) auto janet_symbolv(T0, T1)(auto ref T0 str, auto ref T1 len)
{
    return janet_wrap_symbol(janet_symbol(str, len));
}

extern (D) auto janet_csymbolv(T)(auto ref T cstr)
{
    return janet_wrap_symbol(janet_csymbol(cstr));
}

/* Keyword functions */
JanetKeyword janet_keyword (const(ubyte)* str, int len);
JanetKeyword janet_ckeyword (const(char)* str);

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

extern (D) auto janet_struct_from_head(T)(auto ref T t)
{
    return cast(const(JanetKV)*) cast(char*) gcobject + offsetof(JanetStructHead, data);
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
Janet janet_table_get_ex (JanetTable* t, Janet key, JanetTable** which);
Janet janet_table_rawget (JanetTable* t, Janet key);
Janet janet_table_remove (JanetTable* t, Janet key);
void janet_table_put (JanetTable* t, Janet key, Janet value);
JanetStruct janet_table_to_struct (JanetTable* t);
void janet_table_merge_table (JanetTable* table, JanetTable* other);
void janet_table_merge_struct (JanetTable* table, JanetStruct other);
JanetKV* janet_table_find (JanetTable* t, Janet key);
JanetTable* janet_table_clone (JanetTable* table);

/* Fiber */
JanetFiber* janet_fiber (JanetFunction* callee, int capacity, int argc, const(Janet)* argv);
JanetFiber* janet_fiber_reset (JanetFiber* fiber, JanetFunction* callee, int argc, const(Janet)* argv);
JanetFiberStatus janet_fiber_status (JanetFiber* fiber);
JanetFiber* janet_current_fiber ();
JanetFiber* janet_root_fiber ();

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

pure extern (D) auto janet_abstract_from_head(T)(auto ref T gcobject)
{
    return cast(JanetAbstract) cast(char*) gcobject + offsetof(JanetAbstractHead, data);
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
JanetAbstract janet_abstract_end (void* abstractTemplate);
JanetAbstract janet_abstract (const(JanetAbstractType)* type, size_t size); /* begin and end in one call */

/* Native */
alias JanetModule = void function (JanetTable*);
alias JanetModconf = JanetBuildConfig function ();
JanetModule janet_native (const(char)* name, JanetString* error);

/* Marshaling */
enum JANET_MARSHAL_UNSAFE = 0x20000;

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
void janet_gcpressure (size_t s);

/* Functions */
JanetFuncDef* janet_funcdef_alloc ();
JanetFunction* janet_thunk (JanetFuncDef* def);
int janet_verify (JanetFuncDef* def);

/* Pretty printing */
enum JANET_PRETTY_COLOR = 1;
enum JANET_PRETTY_ONELINE = 2;
enum JANET_PRETTY_NOTRUNC = 4;
JanetBuffer* janet_pretty (JanetBuffer* buffer, int depth, int flags, Janet x);

/* Misc */

enum JANET_HASH_KEY_SIZE = 16;
void janet_init_hash_key (ref ubyte[JANET_HASH_KEY_SIZE] key);

pure int janet_equals (Janet x, Janet y);
pure int janet_hash (Janet x);
pure int janet_compare (Janet x, Janet y);
pure int janet_cstrcmp (JanetString str, const(char)* other);
pure Janet janet_in (Janet ds, Janet key);
pure Janet janet_get (Janet ds, Janet key);
pure Janet janet_next (Janet ds, Janet key);
pure Janet janet_getindex (Janet ds, int index);
pure int janet_length (Janet x);
pure Janet janet_lengthv (Janet x);
void janet_put (Janet ds, Janet key, Janet value);
void janet_putindex (Janet ds, int index, Janet value);

pure extern (D) auto janet_flag_at(T0, T1)(auto ref T0 F, auto ref T1 I)
{
    return F & ((1) << I);
}

Janet janet_wrap_number_safe (double x) @trusted;
pure int janet_keyeq (Janet x, const(char)* cstring);
pure int janet_streq (Janet x, const(char)* cstring);
pure int janet_symeq (Janet x, const(char)* cstring);

/* VM functions */
int janet_init ();
void janet_deinit ();
JanetSignal janet_continue (JanetFiber* fiber, Janet in_, Janet* out_);
JanetSignal janet_pcall (JanetFunction* fun, int argn, const(Janet)* argv, Janet* out_, JanetFiber** f);
JanetSignal janet_step (JanetFiber* fiber, Janet in_, Janet* out_);
Janet janet_call (JanetFunction* fun, int argc, const(Janet)* argv);
Janet janet_mcall (const(char)* name, int argc, Janet* argv);
void janet_stacktrace (JanetFiber* fiber, Janet err);

/* Scratch Memory API */
alias JanetScratchFinalizer = void function (void*);

void* janet_smalloc (size_t size);
void* janet_srealloc (void* mem, size_t size);
void* janet_scalloc (size_t nmemb, size_t size);
void janet_sfinalizer (void* mem, JanetScratchFinalizer finalizer);
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
JanetBindingType janet_resolve (JanetTable* env, JanetSymbol sym, Janet* out_);
void janet_register (const(char)* name, JanetCFunction cfun);

/* Get values from the core environment. */
Janet janet_resolve_core (const(char)* name);

/* New C API */

/* Allow setting entry name for static libraries */

void janet_signalv (JanetSignal signal, Janet message);
void janet_panicv (Janet message);
void janet_panic (const(char)* message);
void janet_panics (JanetString message);
void janet_panicf (const(char)* format, ...);
void janet_dynprintf (const(char)* name, FILE* dflt_file, const(char)* format, ...);
void janet_panic_type (Janet x, int n, int expected);
void janet_panic_abstract (Janet x, int n, const(JanetAbstractType)* at);
void janet_arity (int arity, int min, int max);
void janet_fixarity (int arity, int fix);

pure @trusted Janet janet_getmethod (const(ubyte)* method, const(JanetMethod)* methods);

pure @trusted double janet_getnumber (const(Janet)* argv, int n);
pure @trusted JanetArray* janet_getarray (const(Janet)* argv, int n);
pure @trusted JanetTuple janet_gettuple (const(Janet)* argv, int n);
pure @trusted JanetTable* janet_gettable (const(Janet)* argv, int n);
pure @trusted JanetStruct janet_getstruct (const(Janet)* argv, int n);
pure @trusted JanetString janet_getstring (const(Janet)* argv, int n);
pure const(char)* janet_getcstring (const(Janet)* argv, int n); // can't be @trusted -- pointer arithmetic in the C func
pure @trusted JanetSymbol janet_getsymbol (const(Janet)* argv, int n);
pure @trusted JanetKeyword janet_getkeyword (const(Janet)* argv, int n);
pure @trusted JanetBuffer* janet_getbuffer (const(Janet)* argv, int n);
pure @trusted JanetFiber* janet_getfiber (const(Janet)* argv, int n);
pure @trusted JanetFunction* janet_getfunction (const(Janet)* argv, int n);
pure @trusted JanetCFunction janet_getcfunction (const(Janet)* argv, int n);
pure @trusted int janet_getboolean (const(Janet)* argv, int n);
pure @trusted void* janet_getpointer (const(Janet)* argv, int n);

pure @trusted int janet_getnat (const(Janet)* argv, int n);
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
pure @trusted ulong janet_getflags (const(Janet)* argv, int n, const(char)* flags);

/* Optionals */
double janet_optnumber (const(Janet)* argv, int argc, int n, double dflt);
JanetTuple janet_opttuple (const(Janet)* argv, int argc, int n, JanetTuple dflt);
JanetStruct janet_optstruct (const(Janet)* argv, int argc, int n, JanetStruct dflt);
JanetString janet_optstring (const(Janet)* argv, int argc, int n, JanetString dflt);
const(char)* janet_optcstring (const(Janet)* argv, int argc, int n, const(char)* dflt);
JanetSymbol janet_optsymbol (const(Janet)* argv, int argc, int n, JanetString dflt);
JanetKeyword janet_optkeyword (const(Janet)* argv, int argc, int n, JanetString dflt);
JanetFiber* janet_optfiber (const(Janet)* argv, int argc, int n, JanetFiber* dflt);
JanetFunction* janet_optfunction (const(Janet)* argv, int argc, int n, JanetFunction* dflt);
JanetCFunction janet_optcfunction (const(Janet)* argv, int argc, int n, JanetCFunction dflt);
int janet_optboolean (const(Janet)* argv, int argc, int n, int dflt);
void* janet_optpointer (const(Janet)* argv, int argc, int n, void* dflt);
int janet_optnat (const(Janet)* argv, int argc, int n, int dflt);
int janet_optinteger (const(Janet)* argv, int argc, int n, int dflt);
long janet_optinteger64 (const(Janet)* argv, int argc, int n, long dflt);
size_t janet_optsize (const(Janet)* argv, int argc, int n, size_t dflt);
JanetAbstract janet_optabstract (const(Janet)* argv, int argc, int n, const(JanetAbstractType)* at, JanetAbstract dflt);

/* Mutable optional types specify a size default, and construct a new value if none is provided */
JanetBuffer* janet_optbuffer (const(Janet)* argv, int argc, int n, int dflt_len);
JanetTable* janet_opttable (const(Janet)* argv, int argc, int n, int dflt_len);
JanetArray* janet_optarray (const(Janet)* argv, int argc, int n, int dflt_len);

Janet janet_dyn (const(char)* name);
void janet_setdyn (const(char)* name, Janet value);

extern __gshared const JanetAbstractType janet_file_type;

enum JANET_FILE_WRITE = 1;
enum JANET_FILE_READ = 2;
enum JANET_FILE_APPEND = 4;
enum JANET_FILE_UPDATE = 8;
enum JANET_FILE_NOT_CLOSEABLE = 16;
enum JANET_FILE_CLOSED = 32;
enum JANET_FILE_BINARY = 64;
enum JANET_FILE_SERIALIZABLE = 128;
enum JANET_FILE_PIPED = 256;

Janet janet_makefile (FILE* f, int flags);
FILE* janet_getfile (const(Janet)* argv, int n, int* flags);
FILE* janet_dynfile (const(char)* name, FILE* def);
JanetAbstract janet_checkfile (Janet j);
FILE* janet_unwrapfile (Janet j, int* flags);

/* Marshal API */
void janet_marshal_size (JanetMarshalContext* ctx, size_t value);
void janet_marshal_int (JanetMarshalContext* ctx, int value);
void janet_marshal_int64 (JanetMarshalContext* ctx, long value);
void janet_marshal_byte (JanetMarshalContext* ctx, ubyte value);
void janet_marshal_bytes (JanetMarshalContext* ctx, const(ubyte)* bytes, size_t len);
void janet_marshal_janet (JanetMarshalContext* ctx, Janet x);
void janet_marshal_abstract (JanetMarshalContext* ctx, JanetAbstract abstract_);

void janet_unmarshal_ensure (JanetMarshalContext* ctx, size_t size);
size_t janet_unmarshal_size (JanetMarshalContext* ctx);
int janet_unmarshal_int (JanetMarshalContext* ctx);
long janet_unmarshal_int64 (JanetMarshalContext* ctx);
ubyte janet_unmarshal_byte (JanetMarshalContext* ctx);
void janet_unmarshal_bytes (JanetMarshalContext* ctx, ubyte* dest, size_t len);
Janet janet_unmarshal_janet (JanetMarshalContext* ctx);
JanetAbstract janet_unmarshal_abstract (JanetMarshalContext* ctx, size_t size);

void janet_register_abstract_type (const(JanetAbstractType)* at);
const(JanetAbstractType)* janet_get_abstract_type (Janet key);

extern __gshared const JanetAbstractType janet_peg_type;

/* opcodes for peg vm */
enum JanetPegOpcode
{
    RULE_LITERAL = 0, /* [len, bytes...] */
    RULE_NCHAR = 1, /* [n] */
    RULE_NOTNCHAR = 2, /* [n] */
    RULE_RANGE = 3, /* [lo | hi << 16 (1 word)] */
    RULE_SET = 4, /* [bitmap (8 words)] */
    RULE_LOOK = 5, /* [offset, rule] */
    RULE_CHOICE = 6, /* [len, rules...] */
    RULE_SEQUENCE = 7, /* [len, rules...] */
    RULE_IF = 8, /* [rule_a, rule_b (b if a)] */
    RULE_IFNOT = 9, /* [rule_a, rule_b (b if not a)] */
    RULE_NOT = 10, /* [rule] */
    RULE_BETWEEN = 11, /* [lo, hi, rule] */
    RULE_GETTAG = 12, /* [searchtag, tag] */
    RULE_CAPTURE = 13, /* [rule, tag] */
    RULE_POSITION = 14, /* [tag] */
    RULE_ARGUMENT = 15, /* [argument-index, tag] */
    RULE_CONSTANT = 16, /* [constant, tag] */
    RULE_ACCUMULATE = 17, /* [rule, tag] */
    RULE_GROUP = 18, /* [rule, tag] */
    RULE_REPLACE = 19, /* [rule, constant, tag] */
    RULE_MATCHTIME = 20, /* [rule, constant, tag] */
    RULE_ERROR = 21, /* [rule] */
    RULE_DROP = 22, /* [rule] */
    RULE_BACKMATCH = 23, /* [tag] */
    RULE_LENPREFIX = 24 /* [rule_a, rule_b (repeat rule_b rule_a times)] */
}

struct JanetPeg
{
    uint* bytecode;
    Janet* constants;
    size_t bytecode_len;
    uint num_constants;
}

extern __gshared const JanetAbstractType janet_ta_view_type;
extern __gshared const JanetAbstractType janet_ta_buffer_type;

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

extern __gshared const JanetAbstractType janet_s64_type;
extern __gshared const JanetAbstractType janet_u64_type;

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

extern __gshared const JanetAbstractType janet_thread_type;

int janet_thread_receive (Janet* msg_out, double timeout);
int janet_thread_send (JanetThread* thread, Janet msg, double timeout);

/***** END SECTION MAIN *****/

/* Re-enable popped variable length array warnings */

/* JANET_H_defined */
