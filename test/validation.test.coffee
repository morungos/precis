should = require("should")

Validation = require("../app/js/validation").Validation

class MockClassifier

  constructor: (@results) ->

  reset: () ->

  train: (documents, labels) ->

  test: (documents, labels) ->
    fn = @results
    fn(label) for label in labels

testDocuments = [
  [1,1,1,0,0,0],
  [1,0,1,0,0,0],
  [1,1,1,0,0,0], 
  [0,0,0,1,1,1],
  [0,0,0,1,0,1],
  [0,0,0,1,1,0]
]
testLabels = ['+', '+', '+', '-', '-', '-'] 

describe 'Validation', () ->

  it 'should validate a small set of always false classifications', (done) ->
    alwaysFalse = () -> false
    classifier = new MockClassifier(alwaysFalse)
    validator = new Validation(classifier, {k: 10})

    results = validator.test(testDocuments, testLabels)
    results.length.should.equal(6)
    (record[2] for record in results).should.eql([0, 0, 0, 0, 0, 0])
    (record[3] for record in results).should.eql([1, 1, 1, 1, 1, 1])
    done()

  it 'should validate a small set of always true classifications', (done) ->
    alwaysTrue = () -> true
    classifier = new MockClassifier(alwaysTrue)
    validator = new Validation(classifier, {k: 10})

    results = validator.test(testDocuments, testLabels)
    results.length.should.equal(6)
    (record[2] for record in results).should.eql([1, 1, 1, 1, 1, 1])
    (record[3] for record in results).should.eql([0, 0, 0, 0, 0, 0])
    done()