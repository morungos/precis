util    = require('util')
mongodb = require('mongodb')

MongoClient = mongodb.MongoClient

MongoClient.connect "mongodb://localhost:27017/pubmed", (err, db) ->

  db.collection 'pubmed', (err, pubmed) ->

    matched = []

    positiveTermRegexp = /\b(?:clinical|trial|patient\w+|enrol\w+|targeted|therap\w+|toxic\w+|survival|CI|HR|respon\w+|administer\w+)\b/gi
    negativeTermRegexp = /\b(?:specimen\w+|animal|mouse|mice|cell\w+|membrane|cytoplasm\w+|xenograft\w+|culture\w+|model\w+|assay)\b/gi

    contextTermRegexp = /(\w+\W+){5,5}(?:KRAS|EGFR)(\W+\w+){5,5}/g

    # Genetic aspects get different weighting.
    # |mutation

    # Reliable-ish way of coding up genes, mutations, needed. We should really add these as indexes and scores, then we can
    # pull out any 

    findTrials = () ->

      pubmed.find({clinicalTerms: true}).each (err, doc) ->

        if doc

          positive = 0
          negative = 0
          found = false

          pmid = doc._id
          title = doc.title
          abstract = doc.abstract

          abstractText = abstract.map((entry) -> entry.text).join("\n")
          titleAndAbstractText = title + "\n" + abstractText

          result = 0

          positive++ while positiveTermRegexp.exec(titleAndAbstractText)
          negative++ while negativeTermRegexp.exec(titleAndAbstractText)

          while result = contextTermRegexp.exec(titleAndAbstractText)
            if ! found
              console.log "----------------"
              console.log pmid, positive, negative, positive - negative, title
              found = true
            console.log result[0]


        else

          db.close()

    findTrials()