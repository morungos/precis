# Various CoffeeScript implementations of text processing for piloting the analysis

# First, a base classifier interface, sort of. 

class Classifier

  reset: () ->
    alert "Need to override method: reset"

  train: (documents, labels) ->
    alert "Need to override method: train"

  test: (documents, labels) ->
    alert "Need to override method: test"

module.exports.Classifier = Classifier

# A simple Bayesian classifier, as much for testing frameworks as anything else, as it's not 
# likely to be the most effective. 

apparatus = require('apparatus')

class BayesianClassifier extends Classifier

  classifier = undefined

  reset: () ->
    classifier = new apparatus.BayesClassifier();

  train: (documents, labels) ->
    for doc, i in documents
      classifier.addExample doc, labels[i]
    classifier.train()

  test: (documents, labels) ->
    classifier.classify(doc) == labels[i] for doc, i in documents

module.exports.BayesianClassifier = BayesianClassifier
