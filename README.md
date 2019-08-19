Bindings to the [Janet programming language](https://janet-lang.org/) for the [D programming language](https://dlang.org/).

Highly barebones at the moment--API is identical to the C api for now.

One would have to run dstep on linux to get a proper janet.d, and the pre-compiled object files are have JANET_NO_DYNAMIC_MODULES and JANET_NO_NANBOX defined.