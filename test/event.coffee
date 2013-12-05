should = require 'should'
arena = require '../src/realtime/arena'




describe 'Event', ->
  describe '#constructor', ->
    it 'should return an object', ->
      res = new arena.Event {}

      res.should.be.an.Object




  describe '#hasTurn', ->
    it 'should return false if data wrong', ->
      res1 = new arena.Event {}
      res2 = new arena.Event {turn: {}}
      res1.hasTurn().should.be.false
      res2.hasTurn().should.be.false

    it 'should return true', ->
      res = new arena.Event {turn: {value: 0}}
      res.hasTurn().should.be.true


  describe '#hasMove', ->
    it 'should return false if data wrong', ->
      res1 = new arena.Event {}
      res2 = new arena.Event {move: {}}
      res1.hasMove().should.be.false
      res2.hasMove().should.be.false

    it 'should return true', ->
      res = new arena.Event {move: {value: 0}}
      res.hasMove().should.be.true

  describe '#getTurn', ->
    it 'should return the turn', ->
      res = new arena.Event {turn: {value: 42}}
      res.getTurn().should.equal 42

    it 'should return null otherwise', ->
      res1 = new arena.Event {}
      res2 = new arena.Event {turn: {}}
      should.equal res1.getTurn(), null
      should.equal res1.getTurn(), null

  describe '#getMove', ->
    it 'should return the turn', ->
      res = new arena.Event {move: {value: 42}}
      res.getMove().should.equal 42

    it 'should return null otherwise', ->
      res1 = new arena.Event {}
      res2 = new arena.Event {move: {}}
      should.equal res1.getMove(), null
      should.equal res1.getTurn(), null
