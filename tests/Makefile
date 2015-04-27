
test-suite: ../echo/Project.vala ../echo/CodeTree.vala ../echo/Completion.vala ../echo/Utils.vala ../echo/Locator.vala TestSuite.vala TestUtils.vala TestCase.vala SymbolListingTestCase.vala EnclosingSymbolTestCase.vala
	# Build the tests
	valac -X -lm -X -w --pkg libvala-0.28 --pkg gio-2.0 --pkg gee-0.8 --target-glib=2.32 -o test-suite \
			../echo/Utils.vala \
			../echo/Project.vala \
			../echo/CodeTree.vala \
			../echo/Locator.vala  \
			../echo/Completion.vala  \
			\
			TestCase.vala \
			TestSuite.vala \
			TestUtils.vala \
			\
			SymbolListingTestCase.vala \
			EnclosingSymbolTestCase.vala 

test: test-suite 
		./test-suite
