util    = require('util')
mongodb = require('mongodb')

MongoClient = mongodb.MongoClient

MongoClient.connect "mongodb://localhost:27017/pubmed", (err, db) ->

  db.collection 'pubmed', (err, pubmed) ->

    matched = []

    clinicalRegexp = /\bclinical\b/i
    trialRegexp = /\btrial\b/i
    clinicalTrialRegexp = /^clinical trial/i

    findTrials = () ->

      pubmed.find({clinicalTerms: {$exists: false}}).each (err, doc) ->

        if doc

          pmid = doc._id
          title = doc.title
          abstract = doc.abstract

          abstractText = abstract.map((entry) -> entry.text).join("\n")
          titleAndAbstractText = title + "\n" + abstractText

          trialTerms = clinicalRegexp.test(titleAndAbstractText) && trialRegexp.test(titleAndAbstractText)

          trial = trialTerms ||
                  doc.publicationTypes.some((type) -> type == 'Clinical Trial') ||
                  if doc.meshTerms? then doc.meshTerms.some((term) -> clinicalTrialRegexp.test(term.term)) else false

          if trial
            pubmed.update {_id: pmid}, {$set: {clinicalTerms: trial}}, {w: 1, upsert: false}, (err, result) ->
              if err
                console.log "Err", result
              else 
                console.log "Tagged", pmid, trial, result

        else

          db.close()

    # updateTrials = (identifiers) ->

    #   if identifiers.length == 0
    #     finish()
    #   else
    #     id = identifiers.pop()
    #     db.pubmed.update {_id: id}, {$set: {clinicalTerms: true}}, {w: 1, upsert: false}, (err, result) ->
    #       if err
    #         console.log "Err", result
    #       else 
    #         console.log "Updated", id, result
    #         updateTrials(identifiers)

    findTrials()