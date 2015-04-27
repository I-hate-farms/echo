
## Bugs 
  - create a new project, add existing files, view classpads 
  - create a new file TODO.md -> bad name. View the 
  
  ```
  ** (MonoDevelop:4237): CRITICAL **: echo_code_tree_get_code_tree: assertion 'src != NULL' failed
ERROR [2015-04-27 16:45:19Z]: GLib-Critical: Source ID 3513 was not found when attempting to remove it
```

  ```
  ERROR:/home/cran/Documents/Projects/i-hate-farms/ide/echo/echo/Project.vala:187:echo_project_get_all_symbols_for_file: assertion failed: (src != null)
Stacktrace:

  at <unknown> <0xffffffff>
  at (wrapper managed-to-native) MonoDevelop.ValaBinding.Parser.Echo.Project.echo_project_get_enclosing_symbol_at_position (intptr,string,int,int) <IL 0x00026, 0xffffffff>
  at MonoDevelop.ValaBinding.Parser.Echo.Project.GetEnclosingSymbolAtPosition (string,int,int) [0x0000a] in /home/cran/Documents/Projects/i-hate-farms/ide/ValaBinding/Parser/Echo/Project.cs:68
  at MonoDevelop.ValaBinding.Parser.ProjectInformation.GetEnclosingSymbolAtPosition (string,int,int) [0x0000a] in /home/cran/Documents/Projects/i-hate-farms/ide/ValaBinding/Parser/ProjectInformation.cs:162
  at MonoDevelop.ValaBinding.ValaTextEditorExtension.UpdatePath (object,Mono.TextEditor.DocumentLocationEventArgs) [0x0003f] in /home/cran/Documents/Projects/i-hate-farms/ide/ValaBinding/Parser/ValaTextEditorExtension.cs:396
  at (wrapper delegate-invoke) System.EventHandler`1.invoke_void_object_TEventArgs (object,TEventArgs) <IL 0x00027, 0x000d1>
  at (wrapper delegate-invoke) System.EventHandler`1.invoke_void_object_TEventArgs (object,TEventArgs) <IL 0x00027, 0x000d1>
  at (wrapper delegate-invoke) System.EventHandler`1.invoke_void_object_TEventArgs (object,TEventArgs) <IL 0x00027, 0x000d1>
  at (wrapper delegate-invoke) System.EventHandler`1.invoke_void_object_TEventArgs (object,TEventArgs) <IL 0x00027, 0x000d1>
  at (wrapper delegate-invoke) System.EventHandler`1.invoke_void_object_TEventArgs (object,TEventArgs) <IL 0x00059, 0xffffffff>
  at Mono.TextEditor.Caret.OnPositionChanged (Mono.TextEditor.DocumentLocationEventArgs) <IL 0x0002a, 0x000df>
  at Mono.TextEditor.Caret.set_Location (Mono.TextEditor.DocumentLocation) <IL 0x00083, 0x00309>
  at Mono.TextEditor.TextViewMargin.MousePressed (Mono.TextEditor.MarginMouseEventArgs) <IL 0x0050e, 0x02227>
  at Mono.TextEditor.TextArea.OnButtonPressEvent (Gdk.EventButton) <IL 0x000ed, 0x004d5>
  at Gtk.Widget.buttonpressevent_cb (intptr,intptr) <IL 0x00014, 0x000d7>
  at (wrapper native-to-managed) Gtk.Widget.buttonpressevent_cb (intptr,intptr) <IL 0x00024, 0xffffffff>
  at <unknown> <0xffffffff>
  at (wrapper managed-to-native) Gtk.Application.gtk_main () <IL 0x0000e, 0xffffffff>
  at Gtk.Application.Run () <IL 0x00000, 0x0002f>
  at MonoDevelop.Ide.IdeApp.Run () <IL 0x00001, 0x00037>
  at MonoDevelop.Ide.IdeStartup.Run (MonoDevelop.Ide.MonoDevelopOptions) <IL 0x007d3, 0x0304f>
  at MonoDevelop.Ide.IdeStartup.Main (string[],MonoDevelop.Ide.Extensions.IdeCustomizer) <IL 0x00093, 0x0039b>
  at MonoDevelop.Startup.MonoDevelopMain.Main (string[]) <IL 0x00003, 0x0004b>
  at (wrapper runtime-invoke) <Module>.runtime_invoke_int_object (object,intptr,intptr,intptr) <IL 0x0005c, 0xffffffff>

Native stacktrace:

	/usr/bin/mono() [0x4accac]
	/lib/x86_64-linux-gnu/libpthread.so.0(+0x10340) [0x7fb73e930340]
	/lib/x86_64-linux-gnu/libc.so.6(gsignal+0x39) [0x7fb73e591cc9]
	/lib/x86_64-linux-gnu/libc.so.6(abort+0x148) [0x7fb73e5950d8]
	/lib/x86_64-linux-gnu/libglib-2.0.so.0(g_assertion_message+0x155) [0x7fb73a874fb5]
	/lib/x86_64-linux-gnu/libglib-2.0.so.0(g_assertion_message_expr+0x4a) [0x7fb73a87504a]
	/usr/lib/x86_64-linux-gnu/libecho.so(echo_project_get_all_symbols_for_file+0x100) [0x7fb6f3246379]
	/usr/lib/x86_64-linux-gnu/libecho.so(echo_project_get_enclosing_symbol_at_position+0x100) [0x7fb6f324609e]
	[0x40bfade0]
	```
