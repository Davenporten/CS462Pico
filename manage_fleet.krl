ruleset manage_fleet {
	meta {

		name "Manage Fleet"
		description <<
Ruleset for managing a fleet
>>
		author "Ray Clinton"
		logging on
		shares __testing, nameFromID
	}

	
	global {
		__testing = {
			"queries": [
				{ "domain": "car", "type": "new_vehicle", "attrs": [ "vin" ]}
			],
			"events": [
			]

		}

		nameFromID = function(vin) {
			"Pico " + vin
		}
	}
	
	rule create_vehicle {
		select when car new_vehicle
		pre {
			vin = event:attr("vin")
			exists = ent:vins >< vin
			eci = meta:eci
		}
		if exists then
			send_directive("vehicle_created")
				with vin = vin
		fired {
		} else {
			ent:vins := ent:vins.defaultsTo([]).union([vin]);
			raise pico event "new_child_request"
      			attributes { "dname": nameFromID(vin) }
		}
	}


}
