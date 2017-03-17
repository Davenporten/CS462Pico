ruleset trip_store {

	meta {
    	name "Trip Store"
    	description <<
Last ruleset for pico lab
>>
	    author "Ray Clinton"
    	logging on
    	shares __testing
	}

  	global {

		__testing = {
			"quieries": [

			], 

			"events": [

			]

		}
  	}

	rule collect_trips {
		select when explicit trip_processed
		pre {
			miles = event:attr("miles").klog("Miles: ")
			time = timestamp
		}
	}

	rule collect_long_trips {
		select when explicit found_long_trip

	}

	rule clear_trips {
		select when car reset

	}


}
