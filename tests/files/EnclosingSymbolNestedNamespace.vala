// Taken from anjuta plugin.vala
// Note missing peas namespace 


public class Scratch.Plugins.ValaCompletion.Plugin : Peas.ExtensionBase,  Peas.Activatable {

    class Provider : Object, Gtk.SourceCompletionProvider {
        public Gtk.TextBuffer buffer { get; construct; }
        public ValaProvider provider { get; construct; }
        public File file { get; construct; }

        Gtk.TextIter start_pos;

        public Provider (File file, Gtk.TextBuffer buffer, ValaProvider provider) {
            Object (buffer: buffer, file: file, provider: provider);
        }

        public void populate (Gtk.SourceCompletionContext context) {
            var list = new List<Gtk.SourceCompletionItem> ();

            var mark = buffer.get_insert ();
            Gtk.TextIter end;
            buffer.get_iter_at_mark (out end, mark);

            Gtk.TextIter start;
            // move to start of line
            buffer.get_iter_at_line_offset (out start, end.get_line (), 0);

            int start_column, line = end.get_line ();
            var text = buffer.get_text (start, end, false);
            var hits = provider.populate (file, text, line, end.get_line_offset (), out start_column);

            buffer.get_iter_at_line_offset (out start_pos, line, start_column);

            foreach (var hit in hits) {
                var item = new Gtk.SourceCompletionItem (hit.label, hit.label, null, null);
                print ("%s is %s\n", hit.label, hit.type.to_string ());
                if (hit.type == ValaProvider.ResultType.FUNCTION)
                    item.set_data<bool> ("is-function", true);
                list.prepend (item);
            }

            list.reverse ();
            context.add_proposals (this, list, true);
        }

        public void update_info (Gtk.SourceCompletionProposal proposal, Gtk.SourceCompletionInfo info) {
            /* No additional info provided on proposals */
            return;
        }

        public bool activate_proposal (Gtk.SourceCompletionProposal proposal, Gtk.TextIter iter) {
            var settings = Scratch.Plugins.ValaCompletion.Settings.get_default ();
            var insert = proposal.get_text ();
            if (proposal.get_data<bool> ("is-function")) {
                if (settings.bracket_after_func) {
                    if (settings.space_after_func)
                        insert += " ";
                    insert += "(";
                }
            }

            buffer.@delete (ref start_pos, ref iter);
            buffer.insert (ref start_pos, insert, insert.length);
            return true;
        }

        public string get_name () {
            return "My completion!!!";
        }

        public int get_priority () {
            return 3;
        }

        public bool match (Gtk.SourceCompletionContext context) {
            return true;
        }

        public Gtk.SourceCompletionActivation get_activation () {
            return Gtk.SourceCompletionActivation.INTERACTIVE |
                   Gtk.SourceCompletionActivation.USER_REQUESTED;
        }

        public unowned Gtk.Widget? get_info_widget (Gtk.SourceCompletionProposal proposal) {
            /* As no additional info is provided no widget is needed */
            return null;
        }

        public int get_interactive_delay () {
            return 0;
        }

        Gdk.Pixbuf? icon = null;
        public unowned Gdk.Pixbuf? get_icon () {
            if (icon == null)
                icon = Gtk.IconTheme.get_default ().load_icon ("document-export", 16, 0);
            return icon;
        }

        public bool get_start_iter (Gtk.SourceCompletionContext context, Gtk.SourceCompletionProposal proposal, Gtk.TextIter iter) {
            var mark = buffer.get_insert ();
            Gtk.TextIter cursor_iter;
            buffer.get_iter_at_mark (out cursor_iter, mark);

            iter = cursor_iter;
            iter.backward_word_start ();
            return true;
        }
    }

    MainWindow main_window;

    public Object object { owned get; construct; }
    Scratch.Services.Interface plugins;

    private List<Gtk.SourceView> text_view_list = new List<Gtk.SourceView> ();
    public Gtk.SourceView? current_view {get; private set;}
    public Scratch.Services.Document current_document {get; private set;}

    private const string NAME = N_("Vala Completion");
    private const string DESCRIPTION = N_("Show a completion dialog with vala completion"); // TODO

    private bool completion_visible = false;

    Manager manager;

    Gtk.ListStore error_list;

    public void activate () {
        plugins = (Scratch.Services.Interface) object;
        manager = new Manager ();
        plugins.hook_window.connect ((w) => {
            this.main_window = w;
        });

        error_list = new Gtk.ListStore (5, typeof (Gdk.Pixbuf), typeof (string), typeof (string), typeof (Vala.SourceLocation), typeof (string));

        plugins.hook_notebook_bottom.connect ((notebook) => {
            var scroll = new Gtk.ScrolledWindow (null, null);
            var view = new Gtk.TreeView.with_model (error_list);

            view.insert_column_with_attributes (-1, null, new Gtk.CellRendererPixbuf (), "pixbuf", 0);
            view.insert_column_with_attributes (-1, _("Message"), new Gtk.CellRendererText (), "text", 1);
            view.insert_column_with_attributes (-1, _("Location"), new Gtk.CellRendererText (), "text", 2);

            view.get_column (1).expand = true;

            scroll.add (view);
            scroll.show_all ();

            notebook.append_page (scroll, new Gtk.Label (_("Errors")));
        });

        var err_pixbuf = Gtk.IconTheme.get_default ().load_icon ("dialog-error", 16, 0);
        var warn_pixbuf = Gtk.IconTheme.get_default ().load_icon ("dialog-warning", 16, 0);
        var note_pixbuf = Gtk.IconTheme.get_default ().load_icon ("dialog-information", 16, 0);
        var depr_pixbuf = Gtk.IconTheme.get_default ().load_icon ("dialog-question", 16, 0);

        manager.error_list_set.connect ((list) => {
            error_list.clear ();
            Gtk.TreeIter iter;
            Gdk.Pixbuf pixbuf;
            foreach (var error in list) {
                error_list.append (out iter);
                switch (error.type) {
                    case Report.ErrorType.ERROR:
                        pixbuf = err_pixbuf;
                        break;
                    case Report.ErrorType.WARNING:
                        pixbuf = warn_pixbuf;
                        break;
                    case Report.ErrorType.DEPRECATED:
                        pixbuf = depr_pixbuf;
                        break;
                    default:
                        pixbuf = note_pixbuf;
                        break;
                }
                error_list.@set (iter,
                    0, pixbuf,
                    1, error.message,
                    2, "%s:%i".printf (error.source.file.filename, error.source.begin.line),
                    3, error.source.begin,
                    4, error.source.file.filename);
            }
        });

        plugins.hook_document.connect ((document) => {
            if (document.file == null)
                return;

            if (!manager.add_file (document.file.get_path ()))
                return;

            document.source_view.buffer.insert_text.connect ((loc, new_text, len) => {
                if (len > 1)
                    return;

                print ("NEW CHARACTER: %s\n", new_text);
            });

            document.source_view.completion.add_provider (new Provider (document.file, document.source_view.buffer, manager.provider));

            document.doc_saved.connect (() => manager.on_file_saved (document.file, document.get_text ()));
        });
    }

    public void deactivate () {
        text_view_list.@foreach (cleanup);
    }

    public void update_state () {
    }

    void cleanup (Gtk.SourceView document) {
    }
}

[ModuleInit]
public void peas_register_types (GLib.TypeModule module) {
    var objmodule = module as Peas.ObjectModule;
    objmodule.register_extension_type (typeof (Peas.Activatable),
                                       typeof (Scratch.Plugins.ValaCompletion.Plugin));
}
