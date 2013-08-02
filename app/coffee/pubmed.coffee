libxml = require('libxmljs')
fs    = require('fs')
zlib  = require('zlib')

walker = require("./walker")

base = "/Users/swatt/pubmed_xml"

addFileToDatabase = (article) ->
  

extractFile = (xmlDoc, done) ->
  
  for article in xmlDoc.find("//MedlineCitation[count(Abstract) > 0]")
    console.log "Analyzing PMID", article.get("PMID").text()

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