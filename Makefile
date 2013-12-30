COFFEEC=./node_modules/coffee-script/bin/coffee -m -c #Compile
OCOFFEEC=../../../node_modules/coffee-script/bin/coffee -m -c #Other one for client side
MOCHA=./node_modules/mocha/bin/mocha
STYLUS=./node_modules/stylus/bin/stylus --include-css > /dev/null

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
	$(STYLUS) ./src/public/css/*.styl

clean:
	rm -fv ./src/public/js/arena.{js,map}
	rm -fv ./src/*.{js,map}
	rm -fv ./src/models/*.{js,map}
	rm -fv ./src/libs/*.{js,map}
	rm -fv ./src/realtime/*.{js,map}
	rm -fv ./src/routes/*.{js,map}
	rm -fv ./src/public/css/*.css

start:
	@node src/app.js

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
