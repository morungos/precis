should = require("should")

BayesianClassifier = require("../app/js/classification").BayesianClassifier
classifier = new BayesianClassifier()

describe 'BayesianClassifier', () ->

  documents = [
    [1,1,1,0,0,0],
    [1,0,1,0,0,0],
    [1,1,1,0,0,0], 
    [0,0,0,1,1,1],
    [0,0,0,1,0,1],
    [0,0,0,1,1,0]
  ]

  labels = ['+', '+', '+', '-', '-', '-'] 

  testDocuments = [
    [1,1,1,0,0,0],
    [1,0,1,0,1,0],
    [0,0,1,1,1,1],
    [0,0,1,1,1,1],
  ]

  testLabels = ['+', '+', '+', '-']

  it 'should exist', (done) ->
    should.exist classifier
    done()

  it 'should reset', (done) ->
    classifier.reset()
    done()

  it 'should train', (done) ->
    classifier.reset()
    classifier.train(documents, labels)
    done()

  it 'should classify', (done) ->
    classifier.reset()
    classifier.train(documents, labels)
    results = classifier.test(testDocuments, testLabels)
    results.should.eql([true, true, false, true])
    done()

