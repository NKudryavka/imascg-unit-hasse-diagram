rp = require 'request-promise'
fs = require 'fs'
process = require 'process'

url = 'https://sparql.crssnky.xyz/spql/imas/query'
queries = ['units', 'belonging']
funcs = 
  units: (res) ->
    r = {}
    res.forEach (v) -> 
      r[v.unit.value] = [] unless r[v.unit.value]?
      r[v.unit.value].push v.member.value
    r
  belonging: (res) ->
    r = {}
    res.forEach (v) ->
      r[v.idol.value] = [] unless r[v.idol.value]?
      r[v.idol.value].push v.belonging.value
      r[v.idol.value].push 'MillionStars' if v.belonging.value == '765AS'
    r

unless fs.existsSync 'site'
  fs.mkdirSync 'site'

saveDir = 'site/data'
unless fs.existsSync saveDir
  fs.mkdirSync saveDir

intersection = (a, b) -> a.filter (v) -> v in b

Promise.all (rp({uri: url, qs: {query: fs.readFileSync("sparqls/#{q}.sparql"), format: 'json'}}) for q in queries)
.then (results) ->
  data = {}
  for result, query in results
    query = queries[query]
    result = funcs[query] JSON.parse(result).results.bindings 
    data[query] = result

  belongings = {}
  addBelongings = (belongs, unit, members) ->
    belongings[belongs] = {} unless belongings[belongs]?
    belongings[belongs][unit] = members

  for name, belongs of data.belonging
    belongs.forEach (bel) -> addBelongings bel, name, [name]

  for unit, members of data.units
    belongs = members
    .map (n) -> data.belonging[n]
    .reduce intersection
    if belongs.length == 1
      addBelongings belongs[0], unit, members
    else if belongs.length == 2 and '765AS' in belongs and 'MillionStars' in belongs
      addBelongings '765AS', unit, members
  belongings
.then (data) ->
  result = {}

  for belongs, units of data
    isUnit = (unit) -> units[unit].length != 1 or units[unit][0] != unit
    includes = {}
    names = Object.keys(units)
    unitNames = names.filter isUnit
    names.forEach (unit) ->
      includes[unit] = []
      if isUnit unit
        names.filter((n) -> n != unit).forEach (vs) ->
          if units[unit].length > units[vs].length or !isUnit(vs)
            inter = intersection units[unit], units[vs]
            includes[unit].push vs if units[vs].length == inter.length
    graph = []
    names.forEach (unit) ->
      graph.push
        name: unit
        members: units[unit]
        includes: includes[unit].filter (desc) ->
          includes[unit].filter((n) -> isUnit(n) and n != desc)
          .reduce ((b, sib) -> b and !(desc in includes[sib])), true
    result[belongs] = graph
  fs.writeFile "#{saveDir}/data.json", JSON.stringify result
.catch (err) ->
  console.log err
  process.exit(1)
