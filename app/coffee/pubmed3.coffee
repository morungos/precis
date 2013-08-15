fs          = require 'fs'
zlib        = require 'zlib'
util        = require 'util'
xml         = require 'xml-object-stream'
mongodb     = require 'mongodb'
csv         = require 'ya-csv'

MongoClient = mongodb.MongoClient

getGenes = (callback) ->
  geneNames = {}

  addGeneName = (name) ->
    geneNames[name] = name if name.length > 1

  MongoClient.connect "mongodb://localhost:27017/heliotrope", (err, db) ->
    db.collection 'genes', (err, genes) ->
      genes.find({}, {"name": 1, "sections.description.data": 1}).each (err, doc) ->
        if err
          db.close()
          callback err, null
        else if doc
          addGeneName doc.name
          for synonym in doc.sections.description.data.synonyms
            addGeneName synonym
        else
          db.close()
          callback null, Object.keys(geneNames).sort()

getGeneRegex = (callback) ->
  getGenes (err, geneNames) ->
    regex = if ! err then new RegExp("\\b(" + geneNames.join("|") + ")\\b", "g") else null
    callback err, regex

getElementText = (element) ->
  values = []
  if element.hasOwnProperty '$children'
    values = (getElementText(value) for value in element["$children"])
  if element.hasOwnProperty '$text'
    values.push element["$text"]
  values.join(" ")

getGeneRegex (err, geneRegexp) ->

  counter = 0
  contextLength = 50
  writer = csv.createCsvStreamWriter(process.stdout)

  handleArticle = (article) ->
    if ++counter % 10000 == 0 
      console.error counter

    articleData = article["Article"]
    articleTitle =  getElementText(articleData["ArticleTitle"])

    articleAbstractText = getElementText(articleData["Abstract"])
    articleTitleAndAbstractText = articleTitle + "\n" + articleAbstractText

    while result = geneRegexp.exec(articleTitleAndAbstractText)
      position = result.index
      match = result[1]
      length = match.length
      prefix = articleTitleAndAbstractText.substring(position - contextLength, position).replace("\n", " ")
      suffix = articleTitleAndAbstractText.substring(position + length, position + length + contextLength).replace("\n", " ")
      writer.writeRecord([prefix,match,suffix])

  readStream = fs.createReadStream('trials.xml')

  parser = xml.parse readStream

  parser.each 'MedlineCitation', handleArticle

  parser.on 'end', () ->
    done()