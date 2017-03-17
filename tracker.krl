ruleset tracker {
	meta {
		name "Tracker"
		description <<
For the first lab with picos
>>
		author "Ray Clinton"
		logging on
		shares post, __testing, miles, result
	}

	global {
		__testing = {
			"queries": [
				{ "name": "__testing" },
                                { "name": "post"},
                                { "name": "miles"},
                                { "name": "result"}
			],
			"events": [
				{ "domain": "explicit", "type": "trip_processed", "attrs": [ "mileage" ]},
                                { "domain": "explicit", "type": "find_long_trips"},
                                { "domain": "set", "type": "up", "attrs": [ "long_trip" ]}
			]

		}

                post = function() {
                     ent:long_trip
                }

                miles = function() {
                     ent:mileage
                }

                result = function() {
                     ent:result
                }

	}

	rule setup {
		select when set up
		fired {
			ent:long_trip := event:attr("long_trip").klog("input passed to long_trip: ")
		}

	}

	rule process_trip {
		select when explicit trip_processed
                send_directive("trip") with
			trip_length = mileage
		fired {
			ent:mileage := event:attr("mileage").klog("input passed to mileage: ")
		}
	}

	rule raised {
		select when explicit raise
		send_directive("raise") with
		        msg = "Mileage was more"
                always {
			ent:long_trip := event:attr("mileage").klog("from other event: ")
                }	
	
	}

	rule find_long_trips {
		select when explicit find_long_trips
                always {
                     results = (ent:mileage.as("Number") > ent:long_trip.as("Number")) => ent:mileage | ent:long_trip;
                     ent:result := results;
		     raise explicit event "raise"
                         with mileage = results
                         
                }
	}


}
