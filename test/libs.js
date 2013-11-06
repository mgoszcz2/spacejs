var should = require('should');
var utils = require('../libs/utils');

describe("Utils", function(){
  describe("#tryLog", function(){
    it("should return true when 'err' is false", function(){
      utils.tryLog(false, "").should.be.true; 
    });
    it("should return true when 'err' is 0", function(){
      utils.tryLog(0, "").should.be.true; 
    });
    it("should return true when 'err' is undefined", function(){
      utils.tryLog(undefined, "").should.be.true; 
    });
    it("should return true when 'err' is null", function(){
      utils.tryLog(null, "").should.be.true; 
    });
    it("should return true when 'err' is empty string", function(){
      utils.tryLog("", "").should.be.true; 
    });
  });

  describe("#argArray()", function(){
    it("should return an array", function(){
      (function(){
        utils.argArray(arguments).should.be.an.instanceOf(Array);
        utils.argArray(arguments).should.include(1);
      })(1);
    });
  });

  describe("#iss()", function(){
    it("should return true if string", function(){
      utils.iss("").should.be.true;
      utils.iss(new String()).should.be.true;
    });
    it("should return false if not string", function(){
      utils.iss(undefined).should.be.false;
      utils.iss(null).should.be.false;
      utils.iss(0).should.be.false;
      utils.iss(1).should.be.false;
      utils.iss({}).should.be.false;
      utils.iss([]).should.be.false;
    });
  });
});
