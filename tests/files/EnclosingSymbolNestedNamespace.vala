// Taken and simplified from anjuta plugin.vala
// Note missing peas namespace 


public class A.B.ValaCompletion : Object {

    public string get_name () {
        return "My completion!!!";
    }

    class Provider : Object {
        public string buffer { get; construct; }
        public int provider { get; construct; }
        public bool file { get; construct; }

        string start_pos;

        public Provider () {
            
        }

        public void populate () {
            
        }

        public void update_info () {
            /* No additional info provided on proposals */
            return;
        }

        public bool activate_proposal () {
            return false;
        }

        public string get_name () {
            return "My completion!!!";
        }

        public int get_priority () {
            return 3;
        }

        public bool match () {
            return true;
        }

        
       
        public int get_interactive_delay () {
            return 0;
        }

        public bool get_start_iter () {
        		return false;
        }
    }


   
}

[ModuleInit]
public void peas_register_types () {
    
}
