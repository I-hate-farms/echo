
public class FreeShapeShadowEffect : Clutter.OffscreenEffect
{
	const int SHADOW_OFFSET = 12;

	Cogl.Texture? shadow = null;
	bool invalid = true;

	float cached_width = -1;
	float cached_height = -1;

	public override bool pre_paint ()
	{
		if (shadow != null) {
			print ("PAinting shadow\n");
			Cogl.set_source_texture (shadow);
			// TODO use scaling_factor ?
			var offset_x = actor.width / 2 - shadow.get_width () / 2;
			var offset_y = actor.height / 2 - shadow.get_height ()/ 2;
			// test.abc.def
			Cogl.rectangle (offset_x * 2, offset_y * 2,
					shadow.get_width (), shadow.get_height ());
		}

		return base.pre_paint ();
	}

	public override void paint (Clutter.EffectPaintFlags flags)
	{
		print ("flags: %s\n", flags == Clutter.EffectPaintFlags.ACTOR_DIRTY ? "actor dirty" : "not dirty");
		base.paint (flags);
	}

	public override void set_actor (Clutter.Actor? actor)
	{
		if (actor != null)
			actor.allocation_changed.disconnect (allocation_changed);

		base.set_actor (actor);

		if (actor != null)
			actor.allocation_changed.connect (allocation_changed);
	}

	void allocation_changed (Clutter.ActorBox box, Clutter.AllocationFlags flags)
	{
		print ("ALLO CHCNAGED\n");
		invalid = true;
		queue_repaint ();
	}

	public override void post_paint ()
	{
		Clutter.ActorBox box;
		base.post_paint ();

		if (!actor.get_paint_box (out box))
			return;

		if (!invalid && box.get_width () == cached_width && box.get_height () == cached_height)
			return;

		if (redo_id != 0)
			Source.remove (redo_id);

		redo_id = Idle.add (redo_shadow);
	}

	uint redo_id;

	bool redo_shadow ()
	{
		Clutter.ActorBox box;

		redo_id = 0;

		if (!actor.get_paint_box (out box))
			return false;

		cached_width = box.get_width ();
		cached_height = box.get_height ();
		print ("REDOING\n");

		unowned Cogl.Texture texture = (Cogl.Texture) get_texture ();
		if (texture == null)
			return false;

		var width = (int) Math.ceilf (texture.get_width ());
		var height = (int) Math.ceilf (texture.get_height ());
		var pixels = new uint8[width * height * 4];
		int length;
		if ((length = texture.get_data (Cogl.PixelFormat.BGRA_8888_PRE, 0, pixels)) == 0)
			return false;

		invalid = false;

		for (var i = 0; i < length; i += 4) {
			if (pixels[i + 0] < 10)
				continue;

			pixels[i + 0] = 255;
			pixels[i + 1] = 0;
			pixels[i + 2] = 0;
			pixels[i + 3] = 0;
		}

		var surface = new Cairo.ImageSurface.for_data (pixels, Cairo.Format.ARGB32,
				width, height, Cairo.Format.ARGB32.stride_for_width (width));
		((Cairo.ImageSurface)surface).write_to_png ("blah.png");

		var buffer_width = width + SHADOW_OFFSET * 2;
		var buffer_height = height + SHADOW_OFFSET * 2;
		var buffer = new Granite.Drawing.BufferSurface (buffer_width, buffer_height);

		buffer.context.set_source_surface (surface, SHADOW_OFFSET, SHADOW_OFFSET);
		buffer.context.paint ();
		buffer.exponential_blur (SHADOW_OFFSET / 3);

		shadow = new Cogl.Texture.from_data (buffer_width, buffer_height,
				Cogl.TextureFlags.NONE,
				Cogl.PixelFormat.ARGB_8888,
				Cogl.PixelFormat.ARGB_8888,
				Cairo.Format.ARGB32.stride_for_width (buffer_width),
				((Cairo.ImageSurface) buffer.surface).get_data ());

		// now that we grabbed a texture, we need to repaint
		actor.queue_redraw ();
		return false;
	}
}

void set_content_from_icon (Clutter.Actor actor, string icon, int size,
		Clutter.Color? color = null)
{
	Gdk.Pixbuf? pixbuf = null;
	var icon_theme = Gtk.IconTheme.get_default ();
	var flags = Gtk.IconLookupFlags.FORCE_SIZE;

	try {
		if (color != null) {
			var info = icon_theme.lookup_icon (icon, size, flags);
			Gdk.RGBA rgba = {
				color.red / 255.0,
				color.green / 255.0,
				color.blue / 255,
				color.alpha / 255.0
			};
			pixbuf = info.load_symbolic (rgba);
		} else
			pixbuf = icon_theme.load_icon (icon, size, flags);
	} catch (Error e) {
		warning (e.message);
	}

	if (pixbuf != null)
		set_content_from_pixbuf (actor, pixbuf);
}

void set_content_from_file (Clutter.Actor actor, string file)
{
	var pixbuf = new Gdk.Pixbuf.from_file (file);
	set_content_from_pixbuf (actor, pixbuf);
}

void set_content_from_pixbuf (Clutter.Actor actor, Gdk.Pixbuf pixbuf)
{
	var content = new Clutter.Image ();
	var width = pixbuf.get_width ();
	var height = pixbuf.get_height ();

	content.set_data (pixbuf.get_pixels (),
			pixbuf.has_alpha ? Cogl.PixelFormat.RGBA_8888 : Cogl.PixelFormat.RGB_888,
			width,
			height,
			pixbuf.get_rowstride ());

	actor.set_size (width, height);
	actor.content = content;
}

public class MediaControls : Clutter.Actor
{
	Clutter.Actor play_button;
	Clutter.Actor prev_button;
	Clutter.Actor next_button;

	construct
	{
		play_button = new Sonata.PlayButton ();
		prev_button = new Clutter.Actor ();
		next_button = new Clutter.Actor ();

		Clutter.Color white = { 255, 255, 255, 255 };

		set_content_from_icon (prev_button, "media-skip-backward-symbolic", 64, white);
		set_content_from_icon (next_button, "media-skip-forward-symbolic", 64, white);

		layout_manager = new Clutter.BoxLayout ();

		add_child (prev_button);
		add_child (play_button);
		add_child (next_button);
	}
}

public class Background : Clutter.Actor
{
	Clutter.Actor avatar;
	Clutter.Text name_label;

	Clutter.Actor cover_art;
	Clutter.Text song_title;
	Clutter.Text song_description;
	MediaControls media_controls;

	construct
	{
		set_pivot_point (0.5f, 0.5f);
		set_content_from_file (this, "/usr/share/backgrounds/Ryan Schroeder.jpg");

		avatar = new Clutter.Actor ();
		set_content_from_file (avatar, "/var/lib/AccountsService/icons/tom");

		cover_art = new Clutter.Actor ();
		set_content_from_file (cover_art, "/usr/share/noise/icons/albumart.svg");

		name_label = new Clutter.Text.with_text (null, "Tom Beckmann");
		name_label.color = { 255, 255, 255, 255 };

		song_title = new Clutter.Text.with_text (null, "Don't Get Me Wrong");
		song_title.color = { 255, 255, 255, 255 };
		song_title.add_effect (new FreeShapeShadowEffect ());
		song_description = new Clutter.Text.with_text ("8", "by Odjbox & Lucinda Bell from Unknown Album");
		song_description.color = { 255, 255, 255, 255 };

		media_controls = new MediaControls ();
		// media_controls.add_effect (new FreeShapeShadowEffect ());

		add_child (avatar);
		add_child (name_label);
		add_child (cover_art);
		add_child (song_title);
		add_child (song_description);
		add_child (media_controls);
	}

	public override void allocate (Clutter.ActorBox box, Clutter.AllocationFlags flags)
	{
		base.allocate (box, flags);

		const float COVER_ART_SIZE = 128;
		const float SPACING = 12;
		const float PADDING = 48;

		var child_box = Clutter.ActorBox ();
		child_box.set_size (64, 64);

		var bottom_line_y = box.get_height () - child_box.get_height () - 48;
		var bottom_line_x = PADDING;

		child_box.set_origin (bottom_line_x, bottom_line_y);
		avatar.allocate (child_box, flags);

		bottom_line_x += child_box.get_width ();

		child_box.set_origin (bottom_line_x + SPACING, bottom_line_y + child_box.get_height () / 2 - name_label.height / 2);
		child_box.set_size (name_label.width, name_label.height);
		name_label.allocate (child_box, flags);

		var music_total_width = COVER_ART_SIZE + SPACING + Math.fmaxf (song_title.width, song_description.width);
		var music_text_height = song_title.height + song_description.height + SPACING;
		var music_x = box.get_width () / 2 - music_total_width / 2;
		var music_y = box.get_height () / 2 - COVER_ART_SIZE / 2;

		child_box.set_size (COVER_ART_SIZE, COVER_ART_SIZE);
		child_box.set_origin (music_x, music_y);
		cover_art.allocate (child_box, flags);

		music_x += COVER_ART_SIZE + SPACING;
		music_y += COVER_ART_SIZE / 2 - music_text_height / 2;

		child_box.set_origin (music_x, music_y);
		child_box.set_size (song_title.width, song_title.height);
		song_title.allocate (child_box, flags);

		child_box.set_origin (music_x, music_y + song_title.height + SPACING);
		child_box.set_size (song_description.width, song_description.height);
		song_description.allocate (child_box, flags);

		child_box.set_size (media_controls.width, media_controls.height);
		child_box.set_origin (box.get_width () - child_box.get_width () - PADDING,
				box.get_height () - child_box.get_height () - 22);
		media_controls.allocate (child_box, flags);
	}
}

void main (string[] args)
{
	GtkClutter.init (ref args);

	var w = new Gtk.Window ();
	var c = new GtkClutter.Embed ();
	var s = c.get_stage ();

	var system_background = new Clutter.Actor ();
	system_background.content_repeat = Clutter.ContentRepeat.BOTH;
	set_content_from_file (system_background, "/usr/share/gala/texture.png");
	system_background.add_constraint (new Clutter.BindConstraint (s, Clutter.BindCoordinate.SIZE, 0));

	var background = new Background ();
	background.add_constraint (new Clutter.BindConstraint (s, Clutter.BindCoordinate.SIZE, 0));

	background.set_scale (0.8, 0.8);
	background.opacity = 0;

	s.add_child (system_background);
	s.add_child (background);

	w.add (c);
	w.destroy.connect (Gtk.main_quit);
	w.show_all ();
	w.fullscreen ();

	background.save_easing_state ();
	background.set_easing_mode (Clutter.AnimationMode.EASE_OUT_QUAD);
	background.set_easing_duration (800);
	background.set_easing_delay (200);
	background.opacity = 255;
	background.set_scale (1, 1);
	background.restore_easing_state ();

	Gtk.main ();
}
