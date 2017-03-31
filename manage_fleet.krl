ruleset manage_fleet {
	meta {

		name "Manage Fleet"
		description <<
Ruleset for managing a fleet
>>
		author "Ray Clinton"
		logging on
		use module Subscriptions
//        use module v1_wrangler alias wrangler
		shares __testing, nameFromID, vehicles, my_vins
	}

	
	global {
		__testing = {
			"queries": [
                                { "name": "nameFromID", "args": [ "vin" ] },
                                { "name": "__testing" },
				{ "name": "vehicles" },
                                { "name": "my_vins" }
			],
			"events": [
                                { "domain": "car", "type": "new_vehicle", "attrs": [ "vin" ] },
                                { "domain": "car", "type": "unneeded_vehicle", "attrs": [ "name", "vin" ] },
                                { "domain": "car", "type": "reset" }
			] 

		}

		nameFromID = function(vin) {
			"Pico " + vin
		}

		vehicles = function() {
                      Subscriptions:getSubscriptions().klog("Subscriptions: ")
		}

                reset = {}

                my_vins = function() {
                      ent:vins
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
			//ent:subs := Subscriptions:getSubscriptions().klog("Subscriptions: ");
			raise pico event "new_child_request"
      			attributes { "dname": nameFromID(vin), "vin": vin }
		}
	}

	rule pico_child_initialized {
		select when pico child_initialized
		pre {
			the_child = event:attr("new_child").klog("new_child")
			the_vin = event:attrs().klog("rs_attrs")
		}
		if the_vin.klog("found section_id")
		then
			event:send({ 
				"eci": the_child.eci, "eid": "install-ruleset",
				"domain": "pico", "type": "new_ruleset",
				"attrs": { "rid": "track_trips" } 
			})

		fired {
			ent:vins := ent:vins.defaultsTo({});
			ent:vins{[vin]} := the_vin.rs_attrs.vin.klog("the vin");
                        raise car event "second"
                            attributes{"dname": nameFromID(the_vin.rs_attrs.vin), "eci": the_child.eci,"vin": the_vin.rs_attrs.vin}
		}
	}

        rule second_set {
                select when car second
		pre {
			//the_section = event:attr("new_child").klog("new_child")
			the_vin = event:attr("vin").klog("attrs")
                        the_eci = event:attr("eci").klog("eci")
		}
		event:send({ 
			"eci": the_eci, "eid": "install-second",
			"domain": "pico", "type": "new_ruleset",
			"attrs": { "rid": "trip_store", "section_id": the_vin } 
		})
                always {
                        raise car event "sub_in"
                            attributes{"dname": nameFromID(vin), "eci": the_eci, "vin": the_vin}
                }
        }

        rule sub_rule {
                select when car sub_in
		pre {
			//the_section = event:attr("new_child").klog("new_child")
			the_vin = event:attr("vin").klog("attrs")
                        the_eci = event:attr("eci").klog("eci")
		}
		event:send({ 
			"eci": the_eci, "eid": "install-second",
			"domain": "pico", "type": "new_ruleset",
			"attrs": { "rid": "Subscriptions", "section_id": the_vin } 
		})
                always {
                        raise car event "sub"
                            attributes{"dname": nameFromID(vin), "eci": the_eci, "vin": the_vin}
                }

        }

        rule sub {
                select when car sub
		pre {
			//the_section = event:attr("new_child").klog("new_child")
			the_vin = event:attr("vin").klog("attrs_sub")
                        the_eci = event:attr("eci").klog("eci")
		}
		event:send({ 
			"eci": the_eci, "eid": "install-sub",
			"domain": "wrangler", "type": "subscription",
			"attrs": { 
                                "name": nameFromID(the_vin),
				"name_space" : "fleet" , 
				"my_role" : "manage" , 
				"subscriber_role": "Driving",
				"channel_type":"Subscriptions",
				"attrs":"none", 
				"subscriber_eci":meta:eci }
                })
        }

        rule reset_vins {
               select when car reset
               always {
                     ent:vins := reset
               }
  
        }

        rule delete_vehicle {
              select when car unneeded_vehicle
              pre {
                   name = event:attr("name").klog("name")
                   vin = event:attr("vin").klog("vin")
                   //test = ent:vins
                   //test = test.filter(function(x) {x neq vin}).klog("test")
              }
//              if(not name.isnull()) then 
//                   wrangler:deleteChild(name)
              
              always {
                   //ent:vins := ent:vins.filter(function(x){x neq vin});
                   raise wrangler event "subscription_cancellation"
                          with subscription_name = name
                   raise wrangler event "child_deletion"
                          attributes{ "id": name, "eci": meta:eci }
              }
        }

}


