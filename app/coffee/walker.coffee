fs = require 'fs'

# Given a file, we need to be able to transparently uncompress and 
# analyse the XML within it to cull out the abstract.

walker = (dir, callback) ->
  queue = [dir]

  _walker = () ->
    if queue.length > 0
      first = queue.shift()
      fs.stat first, (err, stats) ->
        if stats && stats.isDirectory()
          fs.readdir first, (err, files) ->
            if files
              for file in files
                queue.push(first + "/" + file)
            callback first, _walker
        else
          callback first, _walker
    else
      callback undefined, _walker
  _walker()

module.exports.walk = walker
