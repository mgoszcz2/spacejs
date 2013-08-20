describe("Realtime module", function(){
  it("should return function", function(){
    require('../realtime/main').should.be.an.instanceOf(Function);
  });
});
