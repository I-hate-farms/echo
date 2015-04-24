
echo-test: Project.vala CodeTree.vala Utils.vala
	valac --pkg libvala-0.28 --pkg gio-2.0 Utils.vala Project.vala CodeTree.vala -o echo-test

