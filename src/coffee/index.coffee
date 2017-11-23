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
    centerX = 900
    levelHeight = 120
    selectedColor = 'red'
    associatedColor = '#07f'

    rowSpace = 2 * fontSize + 4
    measureWidth = document.getElementById 'measureWidth'
    getTextWidth = (text) ->
      measureWidth.textContent = text
      measureWidth.style.fontSize = "#{fontSize}px"
      measureWidth.getBBox().width

    for belongs, nodes of allData
      continue unless belongs == 'CinderellaGirls'
      defxs = [{line: 6}, {line: 1}, {line: 5}, {line: 6}, {line: 2}, {line: 2}, {line: 1}]
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
      units = {}
      nodes = nodes.map (n) ->
        units[n.name] = n
        n.level = if n.members.length > 5 then 6 else n.members.length
        n.level = 0 if n.level == 1 and n.members[0] == n.name
        n.width = getTextWidth(n.name) + 10
        n.fy = yPositions[n.level] || rowSpace
        n
      .sort (a, b) -> a.level - b.level
      .map (n, i) ->
        i %= defxs[n.level].line
        n.fx = (defxs[n.level][i] || 0) + n.width/2 + 5
        n.fy += i * rowSpace
        defxs[n.level][i] = (defxs[n.level][i] || 0) + n.width + 5
        n
      .map (n, i) ->
        n.fx += centerX - defxs[n.level][i%defxs[n.level].line]/2
        n
      edges = nodes.map (n) -> n.includes.map (i) -> {source: n.name, target: i}
      edges = [].concat edges...

      networkCenter = d3.forceCenter().x(700)
      manyBody = d3.forceManyBody().strength(-50)
      linkForce = d3.forceLink(edges).id((d) -> d.name)
      .distance((l) -> (l.source.members.length - l.target.members.length)*180)
      .strength(0.2).iterations(5)
      collideForce = d3.forceCollide().radius((d) -> 10).strength(1)

      forceX = d3.forceX(1300).strength(0.01)

      updateNetwork = (e) ->
        d3.select("svg.main").selectAll "line"
        .attr "x1", (d) -> d.source.x
        .attr "y1", (d) -> d.source.y
        .attr "x2", (d) -> d.target.x
        .attr "y2", (d) -> d.target.y

        d3.select("svg.main").selectAll "g.node"
        .attr "transform", (d) -> "translate(#{d.x},#{d.y})"

      force = d3.forceSimulation nodes
      #.force "charge", manyBody
      .force "link", linkForce
      #.force "center", networkCenter
      #.force "x", forceX
      #.force "y", forceY
      #.force "collide", collideForce
      .on "tick", updateNetwork

      edgeEnter = d3.select("svg.main").selectAll("g.edge")
      .data(edges).enter().append "g"
      .attr "class", "edge"

      edgeEnter.append "line"
      .style "stroke-width", '1px'
      .style "stroke", "black"
      .style "pointer-events", "none"

      nodeEnter = d3.select("svg.main").selectAll("g.node")
      .data nodes, (d) -> d.name
      .enter().append "g"
      .attr "class", "node"

      returnDefault = ->
        edgeEnter.selectAll 'line'
        .style 'stroke', 'black'
        .style 'stroke-width', '1px'
        nodeEnter.selectAll 'rect'
        .style 'stroke', 'black'
        nodeEnter.selectAll 'text'
        .style 'fill', 'black'

      makeFrontEdge = ->
        d3.select(@).node().parentNode.insertBefore d3.select(@).node(), d3.select('.node').node()
      
      nodeEnter.on 'click', (cd) ->
        returnDefault()
        # clicked node
        node = nodeEnter.filter (d) -> d == cd
        node.selectAll 'rect'
        .style 'stroke', selectedColor
        node.selectAll 'text'
        .style 'fill', selectedColor

        # ancestors
        upPaths = edgeEnter.filter (d) -> d.target == cd
        ancestors = nodeEnter.filter (d) -> upPaths.filter((p) -> p.source == d).size() > 0
        while upPaths.size() > 0
          upPaths.selectAll 'line'
          .style 'stroke', associatedColor
          .style 'stroke-width', '2px'
          upPaths.each makeFrontEdge
          ancestors.selectAll 'rect'
          .style 'stroke', associatedColor
          ancestors.selectAll 'text'
          .style 'fill', associatedColor
          upPaths = edgeEnter.filter (d) -> d.target in ancestors.data()
          ancestors = nodeEnter.filter (d) -> upPaths.filter((p) -> p.source == d).size() > 0

        # children
        downPaths = edgeEnter.filter (d) -> d.source == cd
        children = nodeEnter.filter (d) -> downPaths.filter((p) -> p.target == d).size() > 0
        while downPaths.size() > 0
          downPaths.selectAll 'line'
          .style 'stroke', associatedColor
          .style 'stroke-width', '2px'
          downPaths.each makeFrontEdge
          children.selectAll 'rect'
          .style 'stroke', associatedColor
          children.selectAll 'text'
          .style 'fill', associatedColor
          downPaths = edgeEnter.filter (d) -> d.source in children.data()
          children = nodeEnter.filter (d) -> downPaths.filter((p) -> p.target == d).size() > 0

      nodeEnter.append "rect"
      .attr "x", (d) -> -d.width/2
      .attr "y", -fontSize
      .attr "width", (d) -> d.width
      .attr "height", fontSize*2
      .attr "rx", 2
      .attr "ry", 2
      .style "fill", "white"
      .style "stroke", "black"
      .style "stroke-width", '1.5px'

      ### 的場梨沙ちゃんをよろしくお願いします ###
      nodeEnter.append "text"
      .style "text-anchor", "middle"
      .attr "y", 3
      .style "stroke-width", (d) -> if d.name == '的場梨沙' then '0px' else "1px"
      .style "stroke-opacity", 0.75
      .style "stroke", "white"
      .style "font-size", "#{fontSize}px"
      .text (d) -> d.name
      .style "pointer-events", "none"

      nodeEnter.append "text"
      .style "text-anchor", "middle"
      .attr "y", 3
      .style "font-size", "#{fontSize}px"
      .text (d) -> d.name
      .style "pointer-events", "none"

      ### 的場梨沙ちゃんをよろしくお願いします ###
      matobaRisa = document.getElementById 'matoba-risa'
      matobaRisaClick.innerText = matobaRisa.innerText
      matobaRisa.innerText = ''
      matobaRisa.appendChild matobaRisaClick