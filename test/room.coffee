should = require 'should'
arena = require '../src/realtime/arena'
_ = require 'lodash'

testLimit = 2
testStartPos = [{
  x: 75
  y: 50
}, {
  x: 25
  y: 50
}]
testRoomSize =
  x: 100
  y: 100
testUsernames = [
  "Jack",
  "Jil"
]
testAvatarSize =
  x: 20
  y: 20



describe 'Room', ->
  describe '#constructor', ->
    it 'should return an object', ->
      res = new arena.Room testLimit, testRoomSize, testStartPos
      res.should.be.an.Object


  describe '#getLimit', ->
    it 'should return the limit', ->
      res = new arena.Room testLimit, testRoomSize, testStartPos
      res.getLimit().should.equal 2


  describe '#getCount', ->
    it 'should be 0 at the start', ->
      res = new arena.Room testLimit, testRoomSize, testStartPos
      res.getCount().should.be.equal 0

    it 'should equal to number of players added', ->
      res = new arena.Room testLimit, testRoomSize, testStartPos
      res.addUser testUsernames[0], testAvatarSize
      res.addUser testUsernames[1], testAvatarSize
      res.getCount().should.equal 2


  describe '#getRoomSize', ->
    it 'should get correct room size', ->
      res = new arena.Room testLimit, testRoomSize, testStartPos
      res.getRoomSize().should.equal testRoomSize


  describe '#addUser', ->
    it 'should give each user a separate StartPos copy', ->
      event = new arena.Event {move: {value: 1}}

      res = new arena.Room testLimit, testRoomSize, testStartPos
      res.addUser testUsernames[0], testAvatarSize
      res.addUser testUsernames[1], testAvatarSize

      user1 = res.getUser testUsernames[0]
      user2 = res.getUser testUsernames[1]

      user1.update event, testRoomSize

      user1pos = user1.jsonify().pos
      user2pos = user2.jsonify().pos

      user1pos.x.should.not.equal user2pos.x
      user1pos.y.should.not.equal user2pos.y

  describe '#leaveUser', ->
    it 'should remove a user from a room', ->
      res = new arena.Room testLimit, testRoomSize, testStartPos
      res.addUser testUsernames[0], testAvatarSize
      res.leaveUser testUsernames[0]
      should.equal res.getUser(testUsernames[0]), undefined


  describe '#getUser', ->
    it 'should retrive a user instance', ->
      res = new arena.Room testLimit, testRoomSize, testStartPos
      res.addUser testUsernames[0], testAvatarSize
      res.getUser(testUsernames[0]).should.be.an.instanceof arena.Userdata


  describe '#allDone', ->
    it 'should be false by default', ->
      res = new arena.Room testLimit, testRoomSize, testStartPos
      res.allDone().should.be.false

    it 'should be true once all is done', ->
      res = new arena.Room testLimit, testRoomSize, testStartPos

      res.addUser testUsernames[0], testAvatarSize
      res.addUser testUsernames[1], testAvatarSize

      res.getUser(testUsernames[0]).setDone()
      res.getUser(testUsernames[1]).setDone()

      res.allDone().should.be.true


  describe '#resetDone', ->
    it 'should reset done state', ->
      res = new arena.Room testLimit, testRoomSize, testStartPos

      res.addUser testUsernames[0], testAvatarSize
      res.addUser testUsernames[1], testAvatarSize

      res.getUser(testUsernames[0]).setDone()
      res.getUser(testUsernames[1]).setDone()

      res.resetDone()

      res.allDone().should.be.false


  describe '#isFull', ->
    it 'should be false by default', ->
      res = new arena.Room testLimit, testRoomSize, testStartPos
      res.isFull().should.be.false

    it 'should be full after @limit amount of users join', ->
      res = new arena.Room testLimit, testRoomSize, testStartPos
      res.addUser testUsernames[0], testAvatarSize
      res.addUser testUsernames[1], testAvatarSize

      res.isFull().should.be.true

  describe '#getAllUserData', ->
    it 'should return data', ->
      res = new arena.Room testLimit, testRoomSize, testStartPos
      res.should.be.an.Object

    it 'should contains parsable data', ->
      res = new arena.Room testLimit, testRoomSize, testStartPos
      res.addUser testUsernames[0], testAvatarSize
      res = res.getAllUserData()[testUsernames[0]]

      res.angle.should.an.Number
      res.hitWall.should.be.an.Boolean
      res.pos.should.be.an.Object
      res.pos.y.should.be.an.Number
      res.pos.x.should.be.an.Number
