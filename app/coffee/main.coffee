csv = require('csv')
natural = require('natural')

class Dataset 

  constructor: (@texts, @labels) ->
    @stemmer = natural.PorterStemmer
    @tokenizer = new natural.WordTokenizer()

  buildFeatureMatrix: () ->

    nextTermIndex = 0
    termIndexes = {}

    plusTerms = []
    minusTerms = []

    for text, k in @texts
      for token in @tokenizer.tokenize(text)
        index = if termIndexes[token]? then termIndexes[token] else termIndexes[token] = nextTermIndex++
        vector = if @labels[k] == '+' then plusTerms else minusTerms
        vector[index] = (vector[index] || 0) + 1

    # Build a flipped table so we can get from index back to term
    termTerms = []
    for own term, k of termIndexes
      termTerms[k] = term

    # From this, compute a chi square statistic for estimating an effective
    # set of features. Even reporting this is a good sign. 
    plusTermsTotal = plusTerms.reduce (t, s) -> t + s
    minusTermsTotal = minusTerms.reduce (t, s) -> t + s
    plusTermsCount = plusTerms.length
    minusTermsCount = plusTermsCount
    console.log plusTermsTotal, minusTermsTotal

    sqr = (x) -> x * x

    sign = (x) -> if x > 0 then 1 else if x < 0 then -1 else 0

    # Now we have both expected and observed values available to us, and can build
    # a chi square vector along the k.
    chiTerms = new Array(plusTermsCount)
    for k in [0..plusTermsCount - 1]
      plus = plusTerms[k] || 0
      minus = minusTerms[k] || 0
      total = plus + minus
      plusExpected = (total * plusTermsTotal) / (plusTermsTotal + minusTermsTotal)
      minusExpected = (total * minusTermsTotal) / (plusTermsTotal + minusTermsTotal)
      if plusExpected + minusExpected >= 10 
        chi = (sqr(plus - plusExpected) / plusExpected) + (sqr(minus - minusExpected) / minusExpected)
        chiTerms[k] = [chi, termTerms[k], plus, minus, sign(plus - plusExpected)]
      else 
        chiTerms[k] = [0, termTerms[k], plus, minus, 0]

    chiTerms.sort (a, b) -> b[0] - a[0]

    console.log "term,score,valence"
    for chi in chiTerms
      if chi[0] > 0
        console.log chi.join(",")

  run: () ->
    @buildFeatureMatrix()


buildDataset = (callback) ->

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
        if row[6] == '1'
          texts.push row[2]
          level = row[4].substring(0, row[4].length - 1)
          console.log level
          labels.push if level == "I" || level == "II" then '+' else '-'
          index++
    .on 'end', () ->
      # Now do some natural language shit
      dataset = new Dataset(texts, labels)
      callback(null, dataset)

buildDataset (err, dataset) ->
  dataset.run()