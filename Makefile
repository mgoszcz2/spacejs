COFFEE=./node_modules/coffee-script/bin/coffee
COFFEE_COMPILE=./node_modules/coffee-script/bin/coffee -m -c
MOCHA=./node_modules/mocha/bin/mocha

.PHONY: default clean start test coverage

default:
	$(COFFEE_COMPILE) ./src/*.coffee
	$(COFFEE_COMPILE) ./src/models/*.coffee
	$(COFFEE_COMPILE) ./src/libs/*.coffee
	$(COFFEE_COMPILE) ./src/realtime/*.coffee
	$(COFFEE_COMPILE) ./src/routes/*.coffee

clean:
	rm -fv ./src/*.map          ./src/*.js
	rm -fv ./src/models/*.map   ./src/models/*.js
	rm -fv ./src/libs/*.map     ./src/libs/*.js
	rm -fv ./src/realtime/*.map ./src/realtime/*.js
	rm -fv ./src/routes/*.map   ./src/routes/*.js
	rm -fv ./test/*.map         ./test/*.js

start:
	$(COFFEE) src/app.coffee

test:
	$(MOCHA) -R progress

coverage:
	$(MOCHA) -r blanket -R html-cov > coverage.html
