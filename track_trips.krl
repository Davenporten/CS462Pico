ruleset track_trips {
	meta {
		name "Track trips"
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
		select when echo message
		pre {
			mileage = event:attr("mileage").klog("input passed to mileage: ")
		}
		send_directive("trip") with
			trip_length = mileage
	}




}
