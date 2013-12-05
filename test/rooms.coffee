_ = require 'lodash'
should = require 'should'
arena = require '../src/realtime/arena'

testRoomSize =
  x: 100
  y: 100

testStartPos = [
  {
    x: 25
    y: 50
  }, {
    x: 75
    y: 50
  }
]
testDbData = [
  {
    name: "Room 1"
    limit: 2
  }, {
    name: "Room 2"
    limit: 1
  }
]




describe 'Rooms', ->
  describe '#constructor', ->
    it 'should return an object', ->
      res = new arena.Rooms testRoomSize, testStartPos
      res.should.be.an.Object


  describe '#get, #updateData', ->
    it 'should add and retrive a room', ->
      res = new arena.Rooms testRoomSize, testStartPos
      res.updateData testDbData, no

      res.get(testDbData[0].name).should.be.an.instanceof arena.Room
      res.get(testDbData[1].name).should.be.an.instanceof arena.Room

    it 'shoould not over-write exsisting rooms', ->
      res = new arena.Rooms testRoomSize, testStartPos
      res.updateData testDbData, no
      oldRoom = res.get testDbData[0].name

      res.updateData testDbData, no
      newRoom = res.get testDbData[0].name

      oldRoom.should.equal newRoom


  describe '#has', ->
    it 'should return false by default', ->
      res = new arena.Rooms testRoomSize, testStartPos
      res.has(testDbData[0].name).should.be.false

    it 'should be true otherwise', ->
      res = new arena.Rooms testRoomSize, testStartPos
      res.updateData testDbData, no
      res.has(testDbData[0].name).should.be.true
