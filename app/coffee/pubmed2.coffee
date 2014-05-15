XmlStream   = require('./lib/xml-stream')
fs          = require('fs')
zlib        = require('zlib')
util        = require('util')

walker      = require("./walker")

base        = "/Users/swatt/pubmed_xml/medlease"


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

emitText = (text) ->
  process.stdout.write escape(text)

emitElement = (element, name) ->
  if Array.isArray(element)
    length = element.length
    for value, i in element
      emitOneElement value, name
  else
    emitOneElement element, name

emitOneElement = (element, name) ->
  if typeof element == 'object'
    emitStart name, element.$
    if element.hasOwnProperty('$children')
      emitChildren element.$children
    else
      hasText = false
      for own child of element
        if child != '$' && child != '$name'
          if child == '$text'
            hasText = true 
          else 
            emitElement element[child], child
      emitText element["$text"] if hasText
    emitEnd name
  else
    emitStart name, element.$
    emitText element
    emitEnd name

getElementText = (element) ->
  if Array.isArray(element)
    (getElementText(value) for value in element).join(" ")
  else if typeof element == 'object'
    values = []
    if element.hasOwnProperty('$children')
      values = (getElementText(value) for value in element[$children])
    else 
      values = (getElementText(element[child]) for own child of element when child != '$' && child != '$name')
      values.push element["$text"] if element.hasOwnProperty('$text')
    values.join(" ")
  else 
    element

parseFile = (file, done) ->
  console.error "Parsing", file

  # Now let's handle the article itself. This is where we can filter and do any
  # interesting stuff. 

  clinicalRegexp = /\bclinical\b/i
  trialRegexp = /\btrial\b/i
  clinicalTrialRegexp = /^clinical trial/i

  handleArticle = (article) ->
    articleData = article["Article"]
    articleTitle = articleData["ArticleTitle"]
    hasAbstract = Object.keys(articleData).some (type) -> type == 'Abstract'

    if hasAbstract
      articleAbstractText = getElementText(articleData["Abstract"])
      articleTitleAndAbstractText = articleTitle + "\n" + articleAbstractText

      publicationTypes = articleData["PublicationTypeList"]["PublicationType"]
      meshTerms = if article["MeshHeadingList"]? then article["MeshHeadingList"]["MeshHeading"] else []

      trialTerms = clinicalRegexp.test(articleTitleAndAbstractText) && trialRegexp.test(articleTitleAndAbstractText)
      trialPublicationType = publicationTypes.some((type) -> type == 'Clinical Trial')
      trialMeshTerm = meshTerms.some (mesh) -> 
        clinicalTrialRegexp.test(mesh["DescriptorName"]["$text"])

      if trialTerms || trialPublicationType || trialMeshTerm
        emitOneElement article, 'MedlineCitation'
        process.stdout.write "\n"

  raw = fs.createReadStream(file)
  gunzip = zlib.createGunzip({chunkSize: 1*1024*1024})
  uncompressed = raw.pipe(gunzip)

  xml = new XmlStream(uncompressed)

  xml.collect 'PublicationType'
  xml.collect 'Author'
  xml.collect 'MeshHeading'
  xml.on 'updateElement: MedlineCitation', handleArticle

  uncompressed.on 'end', () ->
    done()

handleFile = (file, done) ->
  if file?
    if /\.xml\.gz$/.test(file)
      parseFile file, done
    else
      done()
  else 
    # emitEnd 'MedlineCitationList'
    process.stdout.write "\n"

emitStart 'MedlineCitationList', {}
process.stdout.write "\n"

walker.walk "#{base}", handleFile

