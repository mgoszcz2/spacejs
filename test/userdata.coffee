should = require 'should'
_ = require 'lodash'
arena = require '../src/realtime/arena'
config = require '../src/config'

testStartPos =
  x: 50
  y: 50
testRoomSize =
  x: 100
  y: 100
testAvatarSize =
  x: 20
  y: 20



describe 'Userdata', ->
  describe '#constructor', ->
    it 'should return an object', ->
      res = new arena.Userdata _.cloneDeep(testStartPos), testAvatarSize

      res.should.be.an.Object

    it 'should start at a given start postion', ->
      res = new arena.Userdata _.cloneDeep(testStartPos), testAvatarSize
      res = res.jsonify()

      res.pos.x.should.equal 50
      res.pos.y.should.equal 50


  describe '#update', ->
    it 'should update data', ->
      event = new arena.Event
        turn: {value: 45}
        move: {value: 1000}

      res = new arena.Userdata _.cloneDeep(testStartPos), testAvatarSize
      res.update event, testRoomSize
      res = res.jsonify()

      res.pos.x.should.be.approximately 757, 0.2
      res.pos.y.should.be.approximately 757, 0.2
      res.angle.should.equal 45
      res.hitWall.should.be.true

    it 'should handle missing data', ->
      event = new arena.Event {}

      res = new arena.Userdata _.cloneDeep(testStartPos), testAvatarSize
      res.update event, testRoomSize
      res = res.jsonify()

      res.pos.x.should.equal testStartPos.x
      res.pos.y.should.equal testStartPos.y
      res.angle.should.equal 0
      res.hitWall.should.be.false

    it 'should add turns together', ->
      event = new arena.Event
        turn: {value: 45}
        move: {value: 1000}

      res = new arena.Userdata _.cloneDeep(testStartPos), testAvatarSize
      res.update event, testRoomSize
      res.update event, testRoomSize
      res = res.jsonify()

      res.angle.should.equal 90

    it 'should handle angle overflow', ->
      event = new arena.Event
        turn: {value: 180}
        move: {value: 1000}

      res = new arena.Userdata _.cloneDeep(testStartPos), testAvatarSize
      res.update event, testRoomSize for i in [0..2]
      res = res.jsonify()

      res.angle.should.equal 180


  describe '#isDone, #setDone, #unsetDone', ->
    it 'should be not done by default', ->
      res = new arena.Userdata _.cloneDeep(testStartPos), testAvatarSize
      res.isDone().should.equal no

    it 'should be able to be set & unset', ->
      res = new arena.Userdata _.cloneDeep(testStartPos), testAvatarSize
      res.setDone()
      res.isDone().should.equal yes
      res.unsetDone()
      res.isDone().should.equal no


  describe '#getPosition', ->
    it 'should return current position', ->
      res = new arena.Userdata _.cloneDeep(testStartPos), testAvatarSize
      res.getPosition().x.should.equal testStartPos.x
      res.getPosition().y.should.equal testStartPos.y


  describe '#isDead, #handleHit', ->
    it 'should return no by default', ->
      res = new arena.Userdata _.cloneDeep(testStartPos), testAvatarSize
      res.isDead().should.be.false

    it 'should be yes if live is depleated', ->
      res = new arena.Userdata _.cloneDeep(testStartPos), testAvatarSize
      res.handleHit 'bullet' for i in [0...config.defaultLive / config.hitValues.bullet]
      res.isDead().should.be.true
