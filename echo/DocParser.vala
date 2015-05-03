namespace Echo {
	public class DocParser {

		/*static construct {
			// FIXME loading comments
			var instance = DocParser.instance ();
		}*/

		private static DocParser _instance = null;

		public static DocParser instance () {
			// FIXME hacky and slow
			if( _instance == null) {
				_instance = new DocParser ();
				// HACK
				var file_path = "/home/craSSSn/Documents/Projects/i-hate-farms/ide/echo/comments/" ;
				if( File.new_for_path (file_path).query_exists ())
				{
					var file_names = new string[] {"GLib-2.0.gir", "Gee-0.8.gir", "Gio-2.0.gir",
						"Gtk-3.0.gir", "Gdk-3.0.gir" };

					foreach (var file_name in file_names) {
						_instance.load_from_file (file_path + file_name + ".comments");
					}
				}
			}
			return _instance;
		}

		public class DocEntry {
			public string name = "";
			public string parent = "";
			public string comment = "";

			public DocEntry (string parent, string name, string comment) {
				this.parent = parent;
				this.name = name;
				this.comment = comment;
			}
			public string to_string () {
				return "%s.%s: %s".printf (parent, name, comment.substring (0, int.min (comment.length, 30)));
			}
		}

		private Gee.TreeMap<string, DocEntry> entries = new Gee.TreeMap<string, DocEntry>();

		// HACK Remove the first part of the namespace because
		// we need to cross reference gir files with vapi files
		// to get everything right.
		private Gee.TreeMap<string, DocEntry> hacked_entries = new Gee.TreeMap<string, DocEntry>();

		public int parse (string gir_file_path) {
			//entries.clear ();
			var node = fetch_xml_node (gir_file_path);
			if( node != null )
	        	parse_nodes (node, "", "");
			return entries.size;
		}

		public void save_to_file (string desc_file_path) {
	        var file = File.new_for_path (desc_file_path);

	        // delete if file already exists
	        if (file.query_exists ()) {
	            file.delete ();
	        }
	        try {
				var output = new DataOutputStream (file.create (FileCreateFlags.REPLACE_DESTINATION));
				foreach (var entry in entries.values) {
					if( entry.comment != "" && entry.comment != null) {
						write (output, "#NAME: %s".printf (entry.name));
						write (output, "#PARENT: %s".printf (entry.parent));
						write (output, "#COMMENT: %s".printf (entry.comment));
					}
				}
		    } catch (Error e) {
		        error ("%s", e.message);
		    }
		}

		private void write (DataOutputStream output, string str) {
			output.put_string (str+"\n");
		}

		public int load_from_file (string desc_file_path) {
		    // A reference to our file
		    var file = File.new_for_path (desc_file_path);
		    //entries.clear ();

		    if (!file.query_exists ()) {
		        stderr.printf ("File '%s' doesn't exist.\n", file.get_path ());
		    }

		    try {
		        // Open file for reading and wrap returned FileInputStream into a
		        // DataInputStream, so we can read line by line
		        var dis = new DataInputStream (file.read ());
		        string line;
		        var name = "";
		        var parent = "";
		        var comment = new StringBuilder ();
		        // Read lines until end of file (null) is reached
		        while ((line = dis.read_line (null)) != null) {
		            if( line.has_prefix ("#NAME: ")) {
		            	// Save the previous values
		            	var entry = new DocEntry (parent, name, comment.str);
		            	// HACK because we can't get the package right
		            	var index = parent.index_of (".");
		            	if ( index > -1) {
		            		var hacked_parent = parent.substring (index+1);
		            		// print ("%s\n", hacked_parent);
		            		hacked_entries.@set(hacked_parent+"."+name, entry);
		            	}

		            	entries.@set(parent+"."+name, entry);
		            	parent = "";
		            	comment = new StringBuilder ();

		            	name = line.substring ("#NAME: ".length);
		            } else if ( line.has_prefix ("#PARENT: ")) {
		            	parent = line.substring ("#PARENT: ".length);
		            } else if ( line.has_prefix ("#COMMENT: ")) {
		            	comment.append (line.substring ("#COMMENT: ".length));
		            }
		            else {
		            	comment.append ( "\n");
		            	comment.append ( line);
		            }
		        }
		    } catch (Error e) {
		        error ("%s", e.message);
		    }
		    return entries.size;
		}

		public string find_comment (string? fully_qualified_path) {
			if( !(fully_qualified_path != "" && fully_qualified_path != null))
				return "";

			var path = fully_qualified_path;
			// HACK because we can't get the package right
        	var index = path.index_of (".");
        	if ( index > -1) {
        		path = path.substring (index+1);
        		// print ("%s\n", hacked_parent);
        		// hacked_entries.@set(hacked_parent+"."+name, entry);
        	}

			var result = hacked_entries.@get (path);
			// var result = entries.@get (path);
			if (result == null ) {
				if (hacked_entries.size != 0)
					Utils.report_debug ("DocParser", "No comment for '%s'".printf (path));
				return "";
			}
			return result.comment;
		}

		public void clear () {
			entries.clear ();
		}
	    private Xml.Doc* doc = null;

	    private Xml.Node* fetch_xml_node (string url)
	    {
	        doc = Xml.Parser.parse_file(url);

	        if (doc == null) {
	            return null;
	        }

	        Xml.Node* root = doc->get_root_element ();
	        if (root == null) {
	            delete doc;
	            return null;
	        }
	        return root;
	    }

	    private DocEntry current;
	    private string parent_node_name;
	    //private string name_space = "";
		private void parse_nodes (Xml.Node* node, string parent, string name_space) {
	            for (Xml.Node* iter = node->children; iter != null; iter = iter->next) {
	                if (iter->type != Xml.ElementType.ELEMENT_NODE) {
	                    continue;
	                }

	                string node_name = iter->name;
	                string node_content = iter->get_content ();
	                if(node_name == "doc") {
	                    var ns = name_space.substring (1);
	                    // print ("NS: %s\n", ns);
	                    var index = ns.last_index_of (".");
	                    var entry_name = "";
	                    if( index > -1) {
	                    	entry_name = ns.substring (index+1);
	                    	ns = ns.substring (0, index);
	                    }
	                    var entry = new DocEntry (ns,
	                    	entry_name,
	                    	node_content);
	                    //print (entry.to_string () + "\n");
	                    entries.@set (ns + "." + entry_name, entry);
	                }
	                var name = iter->get_prop ("name");
	                if(name != null && name != "") {
	                    parent_node_name = name;
	                }
	                //name_space += "." + node_name;
	                // Followed by its children nodes
	                parse_nodes (iter, parent + node_name, name_space + "." + parent_node_name);
	            }
	        }

	}
}