ruleset pico_one {
	meta {
		name "Pico One"
		description <<
For the first lab with picos
>>
		author "Ray Clinton"
		logging on
		shares test, __testing
	}

	global {
		test = function() {
			msg = "This is a test";
			msg
		}

		__testing = {
			"queries": [
				{ "name": "test" },
				{ "name": "__testing" }
			],
			"events": [
				{ "domain": "echo", "type": "hello" },
                                { "domain": "echo", "type": "message", "attrs": [ "input" ] }
			]
		}
	}

	rule hello {
		select when echo hello
		send_directive("say") with
			something = "Hello World"

	}

	rule message {
		select when echo message
		pre {
			input = event:attr("input").klog("input passed in: ")
		}
		send_directive("say") with
			something = input

	}

}

