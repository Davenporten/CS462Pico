ruleset manage_fleet {
	meta {

		name "Manage Fleet"
		description <<
Ruleset for managing a fleet
>>
		author "Ray Clinton"
		logging on
		use module Subscriptions
		shares __testing, nameFromID, vehicles
	}

	
	global {
		__testing = {
			"queries": [
                                { "name": "nameFromID", "args": [ "vin" ] },
                                { "name": "__testing" },
								{ "name": "vehicles" }
			],
			"events": [
                                { "domain": "car", "type": "new_vehicle", "attrs": [ "vin" ] }
			] 

		}

		nameFromID = function(vin) {
			"Pico " + vin
		}

		vehicles = function() {
			ent:subs
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
			ent:subs := Subscriptions:getSubscriptions()
			raise pico event "new_child_request"
      			attributes { "dname": nameFromID(vin) }
		}
	}

	rule pico_child_initialized {
		select when pico child_initialized
		pre {
			the_section = event:attr("new_child")
			the_vin = event:attr("rs_attrs"){"vin"}
		}
		if vin.klog("found section_id")
		then
			event:send({ 
				"eci": the_vin.eci, "eid": "install-ruleset",
				"domain": "pico", "type": "new_ruleset",
				"attrs": { "rid": "track_trips", "section_id": vin } 
			})
			event:send({ 
				"eci": the_vin.eci, "eid": "install-ruleset",
				"domain": "pico", "type": "new_ruleset",
				"attrs": { "rid": "Subscriptions", "section_id": vin } 
			})
			event:send({ 
				"eci": the_vin.eci, "eid": "install-ruleset",
				"domain": "wrangler", "type": "subscription",
				"attrs": { 
					"name_space" : "fleet" , 
					"my_role" : "manage" , 
					"subscriber_role": "Driving",
					"channel_type":"Subscriptions",
					"attrs":"none", 
					"subscriber_eci":the_vin.eci } 
			})
		fired {
			ent:vins := ent:vins.defaultsTo({});
			ent:vins{[vin]} := the_vin

		}
	}

}

