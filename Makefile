
echo-test: echo/Project.vala echo/CodeTree.vala echo/Completion.vala echo/Utils.vala echo/Locator.vala
	valac -X -lm -g -X -w --pkg libvala-0.28 --pkg gio-2.0 --pkg gee-0.8 --target-glib=2.32 -o test-suite \
			echo/Utils.vala \
			echo/Project.vala \
			echo/CodeTree.vala \
			echo/Locator.vala  \
			echo/Completion.vala \
			src/testing.vala

