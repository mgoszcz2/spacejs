var colors = require('colors');
var utils = {}
module.exports = utils;

/*Try to log if error evals to true*/
utils.tryLog = function(err, msg){
	if(err)
		console.log(('['+process.pid+'] ('+err+') '+msg).red.bold);
}

utils.argArray = function(arg){
	return [].slice.call(arg);
}
