var should = require('should');
var room = require('../models/room');

describe('Room model', function(){
  before(function(done){
    room.addRoom('[name]', '[limit]');
    done();
  });

  describe('#listRooms()', function(){
    it('should be an array', function(){
      room.listRooms(function(res){ res.should.be.an.instanceOf(Array); });
    });
    it('should contain a room', function(){
      room.listRooms(function(res){
        res[res.length-1].should.include({'name': '[name]', 'limit': '[limit]'});
      });
    });
  });

  describe('#addRoom()', function(){
    it('should add a room', function(){
      room.addRoom('[name2]', '[limit2]');
      room.listRooms(function(res){
        res[res.length-1].should.include({'name': '[name2]', 'limit': '[limit2]'});
      });
    });
  });
});
