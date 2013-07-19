# A fairly simple cross-validation system. Basically it takes a classifier and
# a bunch of labels and runs the training/test framework across it a bunch of 
# times generating statistics, which it then reports. 

shuffle = (array) ->
  counter = array.length

  while counter > 0
    index = (Math.random() * counter--) | 0

    temp = array[counter]
    array[counter] = array[index]
    array[index] = temp

  array


class Validation

  constructor: (@classifier, @options) ->

  # Runs one complete cycle of cross validation
  test: (documents, labels) ->

    count = documents.length
    indexes = [0..count-1]
    shuffledIndexes = shuffle(indexes)

    results = []

    for round in [0..@options.k - 1]

      partitionedDocuments = [[], []]
      partitionedLabels = [[], []]

      # The partitioned sets have 0 = training set, 1 = test set
      for i, k in shuffledIndexes
        partition = if ((k + round) % @options.k) == 0 then 1 else 0
        partitionedDocuments[partition].push(documents[i % count])
        partitionedLabels[partition].push(labels[i % count])

      # Put the training partition into a reset classifier
      @classifier.reset()
      @classifier.train(partitionedDocuments[0], partitionedLabels[0])

      # Now we can test, and build a set of true/false results
      resultBooleans = @classifier.test(partitionedDocuments[1], partitionedLabels[1])

      # And report the results. These should be broken down by label, so we
      # have results for each.
      resultLabels = {}
      for label, i in partitionedLabels[1]
        resultLabels[label] ?= [0, 0]
        resultLabels[label][if resultBooleans[i] then 0 else 1]++;

      for own key, value of resultLabels
        results.push [round, key, value[0], value[1]]

    results

module.exports.Validation = Validation
