(import source/tests/helper :prefix "" :exit true)
(assert (cfunction? foo) "foo exists")
(assert (cfunction? bar) "bar exists")
(assert (= (foo 0) 1) "(foo 0) = 1")
(assert (= (foo 1) 2) "(foo 1) = 2")
(assert (= (bar 0) 2) "(bar 0) = 2")
(assert (= (bar 1) 3) "(bar 1) = 3")
