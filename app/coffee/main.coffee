fs = require 'fs'
 
walk = (dir, f_visit) ->
  _walk = (dir) ->
    fns = fs.readdirSync dir
    for fn in fns
      fn = dir + '/' + fn
      f_visit fn
      if fs.statSync(fn).isDirectory()
        _walk fn
  _walk(dir)


dir = '/Volumes/PubMed'
action = console.log
walk dir, action