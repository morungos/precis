xml         = require 'xml-object-stream'
fs          = require('fs')
zlib        = require('zlib')
util        = require('util')

walker      = require("./walker")

base        = "/Users/swatt/pubmed_xml"


# memwatch.on 'stats', (stats) ->
#   console.log "GC stats", stats

entities = {
  '"': '&quot;',
  '&': '&amp;',
  '\'': '&apos;',
  '<': '&lt;',
  '>': '&gt;'
};

escape = (value) ->
  value.replace /"|&|'|<|>/g, (entity) -> entities[entity]

emitStart = (name, attrs) ->
  process.stdout.write '<' + name
  for own attr, value of attrs
    process.stdout.write ' ' + attr + '="' + escape(attrs[attr]) + '"'
  process.stdout.write '>'

emitEnd = (name) ->
  process.stdout.write '</' + name + '>'

emitNewline = () ->
  process.stdout.write '\n'

emitIndent = (count) ->
  process.stdout.write new Array(count + 1).join("  ");

emitText = (text) ->
  process.stdout.write escape(text)

emitElement = (element, indent) ->
  emitNewline()
  emitIndent indent
  emitStart element["$name"], element.$
  if element.hasOwnProperty('$children')
    for child in element['$children']
      emitElement child, indent + 1
    emitNewline()
    emitIndent indent
  else
    emitText element["$text"] if element.hasOwnProperty('$text')
  emitEnd element["$name"]  

getElementText = (element) ->
  values = []
  if element.hasOwnProperty '$children'
    values = (getElementText(value) for value in element["$children"])
  if element.hasOwnProperty '$text'
    values.push element["$text"]
  values.join(" ")

parseFile = (file, done) ->
  console.error "Parsing", file

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
        # emitOneElement article, 'MedlineCitation'
        # process.stdout.write "\n"
      emitElement article, 1

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
  else 
    emitNewline
    emitEnd 'MedlineCitationList'
    process.stdout.write "\n"

emitStart 'MedlineCitationList', {}

walker.walk "#{base}", handleFile

