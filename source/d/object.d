module janet.object;

import janet.c;

struct JanetObject
{
    private:
        Janet* J;
    public:
        this(T)(T x)
        {
            J = wrap(x);
        }

}