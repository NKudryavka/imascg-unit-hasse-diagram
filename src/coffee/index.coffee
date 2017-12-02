### 的場梨沙ちゃんをよろしくお願いします ###
matobaRisaClick = document.createElement 'a'
matobaRisaClick.href = '#'
matobaRisaClick.addEventListener 'click', (e) ->
  e.preventDefault()
  risa = d3.selectAll('.node').filter((d) -> d.name == '的場梨沙')
  risa.on('click')(risa.datum())

document.addEventListener 'DOMContentLoaded', (loadEvent) ->
  d3.json 'data/data.json', (err, allData) ->
    return console.log err if err
    
    fontSize = 9
    canvasWidth = 1800
    levelHeight = 120
    classes = 
      selected: 'selected'
      inclusion: 'inclusion'
      associated: 'associated'

    centerX = canvasWidth / 2
    wrapWidth = canvasWidth - 200
    rowSpace = 2 * fontSize + 4
    measureWidth = document.getElementById 'measureWidth'
    getTextWidth = (text) ->
      measureWidth.textContent = text
      measureWidth.style.fontSize = "#{fontSize}px"
      measureWidth.getBBox().width

    for belongs, nodes of allData
      continue unless belongs == 'CinderellaGirls'
      defxs = [{}, {}, {}, {}, {}, {}, {}]
      levelAllWidths = [0,0,0,0,0,0,0]
      nodes = nodes.map (n) ->
        n.level = if n.members.length > 5 then 6 else n.members.length
        n.level = 0 if n.level == 1 and n.members[0] == n.name
        n.width = getTextWidth(n.name) + 10
        n
      .sort (a, b) -> a.level - b.level
      nodes.forEach (n) -> levelAllWidths[n.level] = n.width + (levelAllWidths[n.level] || 0)
      levelAllWidths.forEach (w, l) -> defxs[l].line = Math.ceil(w/wrapWidth)

      yPositions = defxs.map((v) -> v.line).reverse().reduce((b, v) ->
        if b.length > 0
          bb = b[b.length-1]
          b.push 
            top: bb.bottom + levelHeight
            bottom: bb.bottom + levelHeight + (v-1)*rowSpace
          b
        else
          [{top:rowSpace, bottom:v*rowSpace}]
      , []).map((v) -> v.top).reverse()

      nodes = nodes.map (n) ->
        temp = (defxs[n.level][l] || 0 for l in [0...defxs[n.level].line])
        n.sublevel = temp.indexOf Math.min temp...
        n.fx = (defxs[n.level][n.sublevel] || 0) + n.width/2 + 5
        n.fy = (yPositions[n.level] || rowSpace) + n.sublevel * rowSpace
        defxs[n.level][n.sublevel] = (defxs[n.level][n.sublevel] || 0) + n.width + 5
        n
      .map (n) ->
        n.fx += centerX - defxs[n.level][n.sublevel]/2
        n
      edges = nodes.map (n) -> n.includes.map (i) -> {source: n.name, target: i}
      edges = [].concat edges...

      linkForce = d3.forceLink(edges).id((d) -> d.name)

      updateNetwork = (e) ->
        d3.select("svg.main").selectAll "line"
        .attr "x1", (d) -> d.source.x
        .attr "y1", (d) -> d.source.y
        .attr "x2", (d) -> d.target.x
        .attr "y2", (d) -> d.target.y

        d3.select("svg.main").selectAll "g.node"
        .attr "transform", (d) -> "translate(#{d.x},#{d.y})"

      force = d3.forceSimulation nodes
      .force "link", linkForce
      .on "tick", updateNetwork

      edgeEnter = d3.select("svg.main").selectAll("g.edge")
      .data(edges).enter().append "g"
      .attr "class", "edge"

      edgeEnter.append "line"

      nodeEnter = d3.select("svg.main").selectAll("g.node")
      .data nodes, (d) -> d.name
      .enter().append "g"
      .attr "class", "node"

      returnDefault = ->
        for k, v of classes
          edgeEnter.classed v, false
          nodeEnter.classed v, false

      makeFrontEdge = ->
        d3.select(@).node().parentNode.insertBefore d3.select(@).node(), d3.select('.node').node()
      
      getAncestors = (node) ->
        res = [[], []]
        loop
          up = edgeEnter.filter (d) -> d.target in node.data()
          node = nodeEnter.filter (d) -> not up.filter((p) -> p.source == d).empty()
          res = [res[0].concat(up.data()), res[1].concat(node.data())]
          break if up.empty()
        [edgeEnter.filter((d) -> d in res[0]), nodeEnter.filter((d) -> d in res[1])]

      getChildren = (node) ->
        res = [[], []]
        loop
          down = edgeEnter.filter (d) -> d.source in node.data()
          node = nodeEnter.filter (d) -> not down.filter((p) -> p.target == d).empty()
          res = [res[0].concat(down.data()), res[1].concat(node.data())]
          break if down.empty()
        [edgeEnter.filter((d) -> d in res[0]), nodeEnter.filter((d) -> d in res[1])]

      nodeEnter.on 'click', (cd) ->
        returnDefault()
        # clicked node
        node = nodeEnter.filter (d) -> d == cd
        node.classed classes.selected, true

        # inclusion
        [upPaths, ancestors] = getAncestors node
        [downPaths, children] = getChildren node

        # associated
        getChildren ancestors
        .map((g) -> g.classed classes.associated, true)[0].each makeFrontEdge
        getAncestors children
        .map((g) -> g.classed classes.associated, true)[0].each makeFrontEdge

        [upPaths, downPaths].map (s) -> s.each makeFrontEdge
        [upPaths, ancestors, downPaths, children].map (s) ->
          s.classed classes.associated, false
          s.classed classes.inclusion, true

      nodeEnter.append "rect"
      .attr "x", (d) -> -d.width/2
      .attr "y", -fontSize
      .attr "width", (d) -> d.width
      .attr "height", fontSize*2
      .attr "rx", 2
      .attr "ry", 2

      ### 的場梨沙ちゃんをよろしくお願いします ###
      nodeEnter.append "text"
      .classed 'svg-text-outer', true
      .attr "y", 3
      .style "stroke-width", (d) -> if d.name == '的場梨沙' then '0px' else "1px"
      .style "font-size", "#{fontSize}px"
      .text (d) -> d.name

      nodeEnter.append "text"
      .classed 'svg-text-inner', true
      .attr "y", 3
      .style "font-size", "#{fontSize}px"
      .text (d) -> d.name

      returnDefault()

      ### 的場梨沙ちゃんをよろしくお願いします ###
      matobaRisa = document.getElementById 'matoba-risa'
      matobaRisaClick.innerText = matobaRisa.innerText
      matobaRisa.innerText = ''
      matobaRisa.appendChild matobaRisaClick