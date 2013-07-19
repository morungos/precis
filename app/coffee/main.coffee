csv = require('csv')
natural = require('natural')


buildFeatureMatrix = (texts) ->

  stemmer = natural.PorterStemmer

  nextTermIndex = 0
  termIndexes = {}

  buildFeatureVector = (text) ->

  texts.map (text) ->
    buildFeatureVector(text)

buildDocumentsAndLabels = () ->

  headers = false

  texts = []
  labels = []
  index = 0

  reader = new csv()
  reader
    .from('data/sources.csv')
    .transform (row) ->
      if ! headers
        headers = true
      else
        texts.push row[2]
        labels.push if row[7] == '1' then '+' else '-'
        index++
    .on 'end', () ->
      # Now do some natural language shit
      buildFeatureMatrix texts

buildDocumentsAndLabels()