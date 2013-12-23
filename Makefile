COFFEEC=./node_modules/coffee-script/bin/coffee -m -c #Compile
OCOFFEEC=../../../node_modules/coffee-script/bin/coffee -m -c #Other one for client side
MOCHA=./node_modules/mocha/bin/mocha

.PHONY: default clean start test coverage show_test debug debug_brk

default:
	$(COFFEEC) ./src/*.coffee
	$(COFFEEC) ./src/models/*.coffee
	$(COFFEEC) ./src/libs/*.coffee
	$(COFFEEC) ./src/realtime/*.coffee
	$(COFFEEC) ./src/routes/*.coffee

	# I will make this more general later
	# Special case for Client side sripts to correct source maps paths

	cd ./src/public/js/ && $(OCOFFEEC) arena.coffee

clean:
	rm -fv ./src/*.map          ./src/*.js
	rm -fv ./src/models/*.map   ./src/models/*.js
	rm -fv ./src/libs/*.map     ./src/libs/*.js
	rm -fv ./src/realtime/*.map ./src/realtime/*.js
	rm -fv ./src/routes/*.map   ./src/routes/*.js
	rm -fv ./src/public/js/arena.{js,map}

start:
	node src/app.js

debug:
	node --debug src/app.js

debug_brk:
	node --debug-brk src/app.js

test:
	$(MOCHA) -R progress

show_test:
	$(MOCHA) -R spec

coverage:
	(MOCHA) -r blanket -R html-cov > coverage.html
