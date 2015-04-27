
echo-test: echo/Project.vala echo/CodeTree.vala echo/Utils.vala src/testing.vala
	valac -X -w --pkg libvala-0.28 --pkg gio-2.0 -o echo-test \
		echo/Utils.vala \
		echo/Project.vala \
		echo/CodeTree.vala \
		echo/Locator.vala \
		echo/Completion.vala \		
		src/testing.vala 

