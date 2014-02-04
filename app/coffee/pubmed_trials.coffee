xml         = require 'xml-object-stream'
fs          = require('fs')
zlib        = require('zlib')
util        = require('util')
sys         = require('sys')
mongodb     = require('mongodb')
log4js      = require('log4js')
cluster     = require('cluster')

walker      = require("./walker")

base        = "/Users/swatt/pubmed_xml"

MongoClient = mongodb.MongoClient
logger      = log4js.getLogger()

# memwatch.on 'stats', (stats) ->
#   console.log "GC stats", stats

entities = {
  '"': '&quot;',
  '&': '&amp;',
  '\'': '&apos;',
  '<': '&lt;',
  '>': '&gt;'
};

getElementText = (element) ->
  values = []
  if element.hasOwnProperty '$children'
    values = (getElementText(value) for value in element["$children"])
  if element.hasOwnProperty '$text'
    values.push element["$text"]
  values.join(" ")

elementListEntries =
  "/Article/AuthorList/Author": 1
  "/Article/Abstract/AbstractText": 1
  "/Article/PublicationTypeList/PublicationType": 1
  "/Article/DataBankList/DataBank": 1
  "/Article/DataBankList/DataBank/AccessionNumberList/AccessionNumber": 1
  "/Article/Language": 1
  "/Article/ELocationID": 1
  "/ChemicalList/Chemical": 1
  "/MeshHeadingList/MeshHeading": 1
  "/MeshHeadingList/MeshHeading/QualifierName": 1
  "/CitationSubset": 1
  "/Article/GrantList/Grant": 1
  "/OtherID": 1
  "/CommentsCorrectionsList/CommentsCorrections": 1
  "/KeywordList/Keyword": 1
  "/GeneralNote": 1
  "/InvestigatorList/Investigator": 1
  "/SupplMeshList/SupplMeshName": 1
  "/PersonalNameSubjectList/PersonalNameSubject": 1
  "/GeneSymbolList/GeneSymbol": 1

objectListEntries =
  "/Article/Abstract/AbstractText": 1

dateListEntries = 
  "/DateCreated": 1
  "/DateCompleted": 1
  "/DateRevised": 1
  "/Article/ArticleDate": 1

convertElementToJson = (element, path) ->
  result = {}

  if element["$children"]?
    for own k, v of element["$"]
      result[k] = v
    for child in element["$children"]
      field = child["$name"]
      newPath = path + "/" + field
      if field
        if elementListEntries[newPath]
          if ! result[field]?
            result[field] = []
          result[field].push convertElementToJson(child, newPath)
        else
          if result[field]?
            throw new Error("Duplicate entry in: #{newPath}, #{element}")
          result[field] = convertElementToJson(child, newPath)
      if dateListEntries[newPath]
        result[field]['date'] = new Date(Date.UTC(parseInt(result[field]['Year']), parseInt(result[field]['Month']) - 1, parseInt(result[field]['Day'])))
    result
  else if element["$text"]?
    if Object.keys(element["$"]).length != 0 or objectListEntries[path]
      for own k, v of element["$"]
        result[k] = v
      result["value"] = element["$text"]
      result
    else
      element["$text"]
  else
    for own k, v of element["$"]
      result[k] = v
    result

MongoClient.connect "mongodb://localhost:27017/pubmed", (err, db) ->
  db.collection 'pubmed', (err, pubmed) ->

    pubmed.ensureIndex {"id": 1}, (err) ->

    parseFile = (file, done) ->
      logger.error("Parsing: " + file)

      # Now let's handle the article itself. This is where we can filter and do any
      # interesting stuff. 

      clinicalRegexp = /\bclinical\b/i
      trialRegexp = /\btrial\b/i
      clinicalTrialRegexp = /^clinical trial/i

      isArticle = (article) ->
        articleData = article["Article"]
        if articleData.hasOwnProperty 'Abstract'
          articleTitle = getElementText(articleData["ArticleTitle"])
          articleAbstractText = getElementText(articleData["Abstract"])
          articleTitleAndAbstractText = articleTitle + "\n" + articleAbstractText

          publicationTypes = if articleData["PublicationTypeList"]? then articleData["PublicationTypeList"]["$children"] else []
          meshTerms = if article["MeshHeadingList"]? then article["MeshHeadingList"]["$children"] else []

          trialPublicationType = publicationTypes.some((type) -> getElementText(type) == 'Clinical Trial')
          trialMeshTerm = meshTerms.some (mesh) -> clinicalTrialRegexp.test(getElementText(mesh["DescriptorName"]))

          trialTerms = clinicalRegexp.test(articleTitleAndAbstractText) && trialRegexp.test(articleTitleAndAbstractText)

          trialTerms || trialPublicationType || trialMeshTerm
        else
          false

      handleArticle = (article) ->
        if isArticle(article)
          try
            record = convertElementToJson(article, "")
            record["id"] = record["PMID"]["value"]
            pubmed.update {id: record["id"]}, record, {w: 1, upsert: true}, (err, result) ->
              if err
                logger.error("Error: " + err)
              else 
                logger.info("Updated PMID: " + record["id"])
          catch error
            logger.error("Error: " + error)

          # emitOneElement article, 'MedlineCitation'
          # console.log sys.inspect(article, false, 10)


          # console.log sys.inspect(convertElementToJson(article, ""), false, 10)
          # emitElement article, 1

      raw = fs.createReadStream(file)
      gunzip = zlib.createGunzip({chunkSize: 1*1024*1024})
      uncompressed = raw.pipe(gunzip)

      parser = xml.parse uncompressed

      parser.each 'MedlineCitation', handleArticle

      parser.on 'end', () ->
        done()

    handleFile = (file, done) ->
      if file?
        if /\.xml\.gz$/.test(file)
          parseFile file, done
        else
          done()

    walker.walk "#{base}", handleFile

