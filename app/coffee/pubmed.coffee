libxml  = require('libxmljs')
expat   = require('node-expat')
fs      = require('fs')
zlib    = require('zlib')
util    = require('util')
mongodb = require('mongodb')

memwatch = require('memwatch')

walker  = require("./walker")

base    = "/Users/swatt/pubmed_xml"

MongoClient = mongodb.MongoClient

# memwatch.on 'stats', (stats) ->
#   console.log "GC stats", stats

parseFile = (file, done) ->
  console.log "Parsing", file

  MongoClient.connect "mongodb://localhost:27017/pubmed", (err, db) ->
    db.collection 'pubmed', (err, pubmed) ->

      stringData = []
      articleData = {}
      tagStack = []
      seenArticles = 0
      startAttributes = {}
      meshTerm = {}
      databank = {}

      updateElement = (data) ->
        pubmed.update {_id: data._id}, data, {w: 1, upsert: true}, (err, result) ->
          if err
            console.log "Error", err
          else 
            console.log "Written", data._id, result

      getValue = () ->
        stringData.join("").trim()

      handleStartElement = (name, attrs) ->
        stringData = []
        tagStack.push name
        startAttributes = attrs

        if name == 'MedlineCitation'
          articleData = {}
          tagStack = []
          seenArticles = 0

      handleEndElement = (name, attrs) ->

        tagStack.pop()

        if name == 'MedlineCitation' && articleData.abstract?
          updateElement(articleData)
        else if name == 'PMID'
          articleData._id = getValue()
        else if name == 'Year' && tagStack[tagStack.length - 1] == 'PubDate' && ! articleData.year?
          articleData.year = getValue()
        else if name == 'Article'
          seenArticles++
        else if name == 'PublicationType'
          articleData.publicationTypes = [] if ! articleData.publicationTypes?
          articleData.publicationTypes.push getValue()
        else if name == 'ArticleTitle' && seenArticles == 0
          articleData.title = getValue()
        else if name == 'AbstractText' && tagStack[tagStack.length - 1] == 'Abstract'
          articleData.abstract = [] if ! articleData.abstract?
          entry = {text: getValue()}
          entry.label = startAttributes["Label"] if startAttributes["Label"]?
          entry.category = startAttributes["NlmCategory"] if startAttributes["NlmCategory"]?
          articleData.abstract.push entry
        else if name == 'DescriptorName'
          meshTerm = {term: getValue(), qualifiers: []}
        else if name == 'QualifierName'
          meshTerm.qualifiers.push getValue()
        else if name  == 'MeshHeading'
          articleData.meshTerms = [] if ! articleData.meshTerms?
          articleData.meshTerms.push meshTerm
        else if name == 'DataBankName'
          databank = {name: getValue(), accessions: []}
        else if name == 'AccessionNumber'
          databank.accessions.push getValue()
        else if name == 'DataBank'
          articleData.databanks = [] if ! articleData.databanks?
          articleData.databanks.push databank

      handleText = (string) ->
        stringData.push string

      parser = new expat.Parser("UTF-8")
      parser.addListener 'startElement', handleStartElement
      parser.addListener 'endElement', handleEndElement
      parser.addListener 'text', handleText

      raw = fs.createReadStream(file)
      gunzip = zlib.createGunzip({chunkSize: 1*1024*1024})
      uncompressed = raw.pipe(gunzip)

      uncompressed.on 'data', (chunk) ->
        parser.write chunk.toString()

      uncompressed.on 'end', () ->
        db.close()
        done()

handleFile = (file, done) ->
  if /\.xml\.gz$/.test(file)
    parseFile file, done
  else
    done()

walker.walk "#{base}/medlease", handleFile
