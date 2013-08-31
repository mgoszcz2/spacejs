# Robocode

## How to run

* Customize /config.js
* Start a mongodb server at port specified in /config.js file
* Run `npm start`

## Testing

    npm test

Warning: I was too lazy and didn't add test cleanup - testing will
modify your database.

## Bugs
* `ship.hitWall()` call sometimes couses an error
* `pos` data vanishes on server side
* `ship.turnBy()` stops at 360

## TODO

* Implement `gun` API object
* Fix bugs
* Add nicer grpahics
* Github integration
* Room creation & chat
* Add more tests
