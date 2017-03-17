ruleset trip_store {

	meta {
    	name "Trip Store"
    	description <<
Last ruleset for pico lab
>>
	    author "Ray Clinton"
    	logging on
    	shares __testing, trips, long_trips, short_trips
	}

  	global {


                trips = function() {
                        ent:trips
                }

                long_trips = function() {
                        ent:long_trips
                }

		__testing = {
			"queries": [
                             { "name": "__testing"},
                             { "name": "trips"},
                             { "name": "long_trips"},
                             { "name": "short_trips"}
			], 

			"events": [
                             { "domain": "explicit", "type": "trip_processed", "attrs": [ "miles" ]},
                             { "domain": "explicit", "type": "found_long_trip", "attrs": [ "miles" ]},
                             { "domain": "car", "type": "reset"}
			]

		}

                set_times = { "_0": { "name": { "mils": "" } } }

                short_trips = function() {
                        shorts = (ent:trips.keys()).difference((ent:long_trips.keys())).klog("short keys: ");
                        shrts = ent:trips.filter(function(k,v) {
                             shorts.any(function(x) {
                                   k.klog("k: ");
                                   (x.klog("k: ") == v.klog("v: "))
                             })
                        });
                        shrts
                        
                }


                find = function(arr) {

                }



  	}

	rule collect_trips {
		select when explicit trip_processed
		pre {
			miles = event:attr("miles").klog("Miles: ")
		}
                always {
                        ent:trips := ent:trips.defaultsTo(set_times,"initialization was needed");
                        ent:trips{[time:now(),"name","mils"]} := miles
                }
	}


	rule collect_long_trips {
		select when explicit found_long_trip
		pre {
			miles = event:attr("miles").klog("Miles: ")
		}
                always {
                        time = time:now();
                        ent:long_trips := ent:long_trips.defaultsTo(set_times,"initialization was needed");
                        ent:long_trips{[time,"name","mils"]} := miles;
                        ent:trips{[time, "name", "mils"]} := miles
                }
	}

	rule clear_trips {
		select when car reset
                always {
                        ent:trips := set_times;
                        ent:long_trips := set_times
                }
	}


}

