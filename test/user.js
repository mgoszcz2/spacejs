var should = require('should');
var user = require('../models/user');
var userid = "123456123456123456123456";

describe('User model', function(){
  before(function(done){
    user.register('[test]', '[email]', '[password]');
    done();
  });

  describe('#register()', function(){
    it('should exist', function(){
      user.register('[test2]', '[email2]', '[password2]');
      user.checkEmail('[email2]', function(res){ res.should.be.true });
    });
  });
  describe('#login()', function(){
    it('should work when using email', function(){
      user.login('[email]', '[password]', function(error, res){ res.should.be.ok });
    });

    it('should work when using name', function(){
      user.login('[test]', '[password]', function(error, res){ res.should.be.ok });
    });
  });

  describe('#getId()', function(){
    it('should return something', function(){
      user.getId(userid, function(res){ res.should.be.ok });
    });
  });

  describe('#checkEmail()', function(){
    it('should be true if email taken', function(){
      user.checkEmail('[email]', function(res){ res.should.be.true });
    });
    it('should be false if email not taken', function(){
      user.checkEmail('[email3]', function(res){ res.should.be.false });
    });
  });

  describe('#checkName()', function(){
    it('should be true if username taken', function(){
      user.checkName('[test]', function(res){ res.should.be.true });
    });
    it('should be false if username not taken', function(){
      user.checkName('[test3]', function(res){ res.should.be.false });
    });
  });
});
