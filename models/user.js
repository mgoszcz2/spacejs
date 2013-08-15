/*External libs*/
var mongo = require('mongojs');
var ObjectId = mongo.ObjectId;
var bc = require('bcrypt');

/*Local libs*/
var utils = require('../libs/utils');
var config = require('../config');

/*Connect to mongo and prepare exports*/
var db = mongo('mongodb://127.0.0.1:'+config.mongoPort+'/master', ['users']);
var user = {}
module.exports = user;

/*Check if user with following username exists*/
user.checkName = function(name, callback){
	db.users.findOne({'username': name}, function(err, user){
		utils.tryLog(err, "models/user.checkName");
		callback(user ? true : false);
	});
}

/*Check if user with following email exists*/
user.checkEmail = function(email, callback){
	db.users.findOne({'email': email}, function(err, user){
		utils.tryLog(err, "models/user.checkEmail");
		callback(user ? true : false);
	});
}

/*Check whether user exists with an id*/
user.getId = function(id, callback){
    db.users.findOne({'_id': ObjectId(id)}, function(err, user){
		utils.tryLog(err, "models/user.getId");
        callback(user);
    });
}

/*Get username by their id and password,
rewritten for passport.js localStrategy callback format*/
user.login = function(id, password, callback){
	db.users.findOne({
        '$or': [
            {'email': id},
            {'username': id}
        ]
    }, function(err, user){
        utils.tryLog(err, "models/users.login");
        if(!user)
            callback(null, false);
        else if(bc.compareSync(password, user.password) == true)//Auth success
            callback(null, user);
        else
            callback(null, false);
    });
}

user.register = function(username, email, password, callback){
    db.users.save({'username': username, 'email': email, 'password': hashPassword(password)}, function(err, user){
        utils.tryLog(err, "models/user.register");
        callback();
    });
}

function hashPassword(password){
    return bc.hashSync(password, config.bcryptCost);
}
