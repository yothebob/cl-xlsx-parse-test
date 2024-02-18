(defsystem "health-parser"
  :version "0.0.1"
  :author "Brandon Brodrick"
  :license "MIT"
  :depends-on ()
  :components ((:module "src"
                :components
                ((:file "main"))))
  :description ""
  :in-order-to ((test-op (test-op "health-parser/tests"))))

(defsystem "health-parser/tests"
  :author "Brandon Brodrick"
  :license "MIT"
  :depends-on ("health-parser"
               "rove"
	       "cl-xlsx"
	       "cl-base64"
	       "yason")
  :components ((:module "tests"
                :components
                ((:file "main"))))
  :description "Test system for health-parser"
  :perform (test-op (op c) (symbol-call :rove :run c)))
