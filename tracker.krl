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
				{ "domain": "echo", "type": "message", "attrs": [ "mileage" ]}
			]

		}


	}

	rule process_trip {
		select when car new_trip
		pre {
			mileage = event:attr("mileage").klog("input passed to mileage: ")
		}
		send_directive("trip") with
			trip_length = mileage
	}




}
