## Introduction
Code manipulation library for vala: getting barked at will be a pleasure

Echo uses [libvala-0.28](https://dl.dropboxusercontent.com/u/17850028/libvala/valadoc/index.htm)

## Features 
  - returns a complete `code tree` from vala's `AST`
  - handles packages
  - provide completion 
  - full set of [unit tests](tests)

## How to build 
```
./hen build
```
## Sample 
```
	var loop = new MainLoop ();

	var project = new Project ("testing");
	project.add_external_package ("glib-2.0");
	project.add_external_package ("gobject-2.0");
	project.add_external_package ("clutter-gtk-1.0");
	project.add_external_package ("granite");

	// project.add_file ("./test.vala");
	project.add_file ("./tests/files/main_namespace.vala");

	project.update.begin (() => {
		print ("UPDATE FINISHED\n");
		try {
			project.complete ("./tests/files/main_namespace.vala", 20, 10);
		} catch (Error e) {
			warning (e.message);
		}
		loop.quit ();
	});
	loop.run ();
```

## How to install 
```
./hen install
```

## How to run the test suite
The unit tests are defined in the folder `tests`

```
./hen run test
```

Expected output : 
```
/SymbolListingTestCase/list_symbols_in_simple_main: OK
<more tests>                                      : OK 

```
