libxml  = require('libxmljs')
fs      = require('fs')
zlib    = require('zlib')
util    = require('util')
mongodb = require('mongodb')

walker  = require("./walker")

base    = "/Users/swatt/pubmed_xml"

MongoClient = mongodb.MongoClient

MongoClient.connect "mongodb://localhost:27017/pubmed", (err, db) ->

  db.collection 'pubmed', (err, pubmed) ->

    buildRecord = (article) ->
      data = {}
      data._id = article.get("PMID").text().trim()

      debugger if data._id == '19867289'

      articleBody = article.find("Article[1]")[0]
      data.title = articleBody.get("ArticleTitle").text().trim()

      abstracts = articleBody.find("Abstract/AbstractText")
      data.abstract = abstracts.map (abstractElement) ->
        entry = {}
        entry.text = abstractElement.text().trim()
        entry.label = abstractElement.attr("Label") if abstractElement.attr("Label")
        entry.category = abstractElement.attr("NlmCategory") if abstractElement.attr("NlmCategory")
        entry

      publicationTypes = articleBody.find("PublicationTypeList/PublicationType")
      data.publicationTypes = publicationTypes.map (type) -> type.text().trim()

      data.meshTerms = article.find("MeshHeadingList/MeshHeading").map (heading) ->
        entry = {term: heading.get("DescriptorName").text().trim()}
        entry.qualifiers = (value.text().trim() for value in heading.find("QualifierName"))
        entry

      data.year = articleBody.get("descendant::PubDate/Year").text().trim()
      data

    writeRecords = (records, callback) ->
      if records.length == 0
        callback()
      else 
        record = records.shift()
        pubmed.update {_id: record._id}, record, {w: 1, upsert: true}, (err, result) ->
          if err
            console.log "error", err
          else
            console.log "Wrote record", record._id, result
            writeRecords records, callback

    extractFile = (xmlDoc, done) ->
      
      articles = (buildRecord(article) for article in xmlDoc.find("//MedlineCitation[count(Article/Abstract) > 0]"))
      writeRecords articles, () ->
        done()

    parseFile = (file, done) ->

      console.log "Parsing", file

      result = []

      raw = fs.createReadStream(file)
      gunzip = zlib.createGunzip({chunkSize: 1*1024*1024})
      uncompressed = raw.pipe(gunzip)

      uncompressed.on 'data', (chunk) ->
        result.push chunk.toString()

      uncompressed.on 'end', () ->
        xml = result.join("")
        xmlDoc = libxml.parseXmlString(xml)
        extractFile xmlDoc, done

    handleFile = (file, done) ->
      if /\.xml\.gz$/.test(file)
        parseFile file, done
      else
        done()

    walker.walk "#{base}/baseline", handleFile