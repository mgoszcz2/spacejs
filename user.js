var mongo = require('mongojs');
var utils = require('../libs/utils');
var db = mongo('master', ['users']);
var user = {}

user.exists = function(name, callback){
	db.users.findOne({'username': 'name'}, function(err, user){
		utils.tryLog(err, "models/users.exists");
		callback(user ? true : false);
	});
}
