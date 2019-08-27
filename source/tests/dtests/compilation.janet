(print "This is a test of the compilation system. This should compile without any issues.")
(comment import ./source/tests/helper :prefix "" :exit true)
(print "Import doesn't work in threads. This needs fixed in the future.")