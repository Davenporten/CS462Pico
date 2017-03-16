ruleset tracker {
	meta {
		name "Tracker"
		description <<
For the first lab with picos
>>
		author "Ray Clinton"
		logging on
		shares __testing
	}

	global {
		__testing = {
			"queries": [
				{ "name": "__testing" }
			],
			"events": [
				{ "domain": "explicit", "type": "trip_processed", "attrs": [ "mileage" ]}
			]

		}


	}

	rule setup {
		select when set up
		pre {
			ent:long_trip := event:attr("long_trip").klog("input passed to long_trip: ")
		}

	}

	rule process_trip {
		select when explicit trip_processed
		pre {
			ent:mileage := event:attr("mileage").klog("input passed to mileage: ")
		}
		send_directive("trip") with
			trip_length = mileage
	}

	rule raised {
		select when explicit raise
		send_directive("raise") with
			msg = "Mileage was more"
			msg
	
	}

	rule find_long_trips {
		select when explicit trip_processed
		send_directive("check") with
			mil = ent:mileage
			long  = ent:long_trip
			 

	}


}
