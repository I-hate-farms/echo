
test-suite: ../echo/Project.vala ../echo/CodeTree.vala ../echo/Utils.vala TestSuite.vala TestUtils.vala SymbolListingTestCase.vala
	# Build the tests
	valac -X -w --pkg libvala-0.28 --pkg gio-2.0 --pkg gee-0.8 -o test-suite \
			../echo/Utils.vala \
			../echo/Project.vala \
			../echo/CodeTree.vala \
			../echo/Locator.vala  \
			\
			TestCase.vala \
			TestSuite.vala \
			TestUtils.vala \
			\
			SymbolListingTestCase.vala 
			
	# Launch the tests		
	./test-suite

