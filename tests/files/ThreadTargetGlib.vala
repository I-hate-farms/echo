
public class ThreadTargetGlib {

		public void update_sync ()
		{
		}

		public async void update ()
		{
			new Thread<void*> (null, () => {
				update_sync ();

				Idle.add (() => {
					update.callback ();
					return false;
				});
				return null;
			});

			yield;
		}

}

public static int main (string[] args) {

}