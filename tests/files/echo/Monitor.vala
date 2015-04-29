namespace Echo {

    public class Monitor : Object {

        int64 startNs = 0;
        int64 stopNs = 0;

        public void start () {
            startNs = GLib.get_real_time ();
        }

        public void stop () {
            stopNs = GLib.get_real_time ();
        }

        public string to_string( )
        {
            int64 stopMs = stopNs / 1000;
            int64 startMs = startNs / 1000;

            long durationMs = (long)(stopMs - startMs);
            string duration = "";
            long sec = durationMs/1000;
            long ms = durationMs %1000;
            if( sec >0 )
                duration = duration + sec.to_string () +"s ";
            //long ms = durationMs - 1000*sec;
            duration = duration + ms.to_string () +"ms";
            if( sec > 0 )
                duration = duration + " (total: %sms) ".printf( durationMs.to_string () );
            return duration;
        }
    }
}