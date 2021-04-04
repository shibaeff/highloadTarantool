.PHONY: test
test:
	python3 bootstrap.py
	tarantool send_requests.lua ini_config.json
	echo Applying commit
	curl localhost:8081/commit
	echo Checking the commit
	tarantool send_requests.lua config.json
	echo Checking that 9082 is null
	nc -zv localhost 9082 || true
	echo Finished testing
	bash ./kill.sh