
/* 的場梨沙ちゃんをよろしくお願いします */

(function() {
  var matobaRisaClick,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  matobaRisaClick = document.createElement('a');

  matobaRisaClick.href = '#';

  matobaRisaClick.addEventListener('click', function(e) {
    var risa;
    e.preventDefault();
    risa = d3.selectAll('.node').filter(function(d) {
      return d.name === '的場梨沙';
    });
    return risa.on('click')(risa.datum());
  });

  document.addEventListener('DOMContentLoaded', function(loadEvent) {
    return d3.json('data/data.json', function(err, allData) {
      var belongs, canvasWidth, cellSpace, centerX, classes, defxs, edgeEnter, edges, fontSize, force, getAncestors, getChildren, getTextWidth, levelAllWidths, levelHeight, linkForce, makeFrontEdge, matobaRisa, measureWidth, nodeEnter, nodes, ref, results, returnDefault, rowSpace, updateNetwork, wrapWidth, yPositions;
      if (err) {
        return console.log(err);
      }
      fontSize = 9;
      canvasWidth = 1800;
      levelHeight = 120;
      cellSpace = 1;
      classes = {
        selected: 'selected',
        inclusion: 'inclusion',
        associated: 'associated'
      };
      centerX = canvasWidth / 2;
      wrapWidth = canvasWidth - 200;
      rowSpace = 2 * fontSize + cellSpace;
      measureWidth = document.getElementById('measureWidth');
      getTextWidth = function(text) {
        measureWidth.textContent = text;
        measureWidth.style.fontSize = fontSize + "px";
        return measureWidth.getBBox().width;
      };
      results = [];
      for (belongs in allData) {
        nodes = allData[belongs];
        if (belongs !== 'CinderellaGirls') {
          continue;
        }
        defxs = [{}, {}, {}, {}, {}, {}, {}];
        levelAllWidths = [0, 0, 0, 0, 0, 0, 0];
        nodes = nodes.map(function(n) {
          n.level = n.members.length > 5 ? 6 : n.members.length;
          if (n.level === 1 && n.members[0] === n.name) {
            n.level = 0;
          }
          n.width = getTextWidth(n.name) + 10;
          return n;
        }).sort(function(a, b) {
          return a.level - b.level;
        });
        nodes.forEach(function(n) {
          return levelAllWidths[n.level] = n.width + (levelAllWidths[n.level] || 0);
        });
        levelAllWidths.forEach(function(w, l) {
          return defxs[l].line = Math.ceil(w / wrapWidth);
        });
        yPositions = defxs.map(function(v) {
          return v.line;
        }).reverse().reduce(function(b, v) {
          var bb;
          if (b.length > 0) {
            bb = b[b.length - 1];
            b.push({
              top: bb.bottom + levelHeight,
              bottom: bb.bottom + levelHeight + (v - 1) * rowSpace
            });
            return b;
          } else {
            return [
              {
                top: rowSpace,
                bottom: v * rowSpace
              }
            ];
          }
        }, []).map(function(v) {
          return v.top;
        }).reverse();
        nodes = nodes.map(function(n) {
          var l, temp;
          temp = (function() {
            var j, ref, results1;
            results1 = [];
            for (l = j = 0, ref = defxs[n.level].line; 0 <= ref ? j < ref : j > ref; l = 0 <= ref ? ++j : --j) {
              results1.push(defxs[n.level][l] || 0);
            }
            return results1;
          })();
          n.sublevel = temp.indexOf(Math.min.apply(Math, temp));
          n.fx = (defxs[n.level][n.sublevel] || 0) + n.width / 2 + cellSpace;
          n.fy = (yPositions[n.level] || rowSpace) + n.sublevel * rowSpace;
          defxs[n.level][n.sublevel] = (defxs[n.level][n.sublevel] || 0) + n.width + cellSpace;
          return n;
        }).map(function(n) {
          n.fx += centerX - defxs[n.level][n.sublevel] / 2;
          return n;
        });
        edges = nodes.map(function(n) {
          return n.includes.map(function(i) {
            return {
              source: n.name,
              target: i
            };
          });
        });
        edges = (ref = []).concat.apply(ref, edges);
        linkForce = d3.forceLink(edges).id(function(d) {
          return d.name;
        });
        updateNetwork = function(e) {
          d3.select("svg.main").selectAll("line").attr("x1", function(d) {
            return d.source.x;
          }).attr("y1", function(d) {
            return d.source.y;
          }).attr("x2", function(d) {
            return d.target.x;
          }).attr("y2", function(d) {
            return d.target.y;
          });
          return d3.select("svg.main").selectAll("g.node").attr("transform", function(d) {
            return "translate(" + d.x + "," + d.y + ")";
          });
        };
        force = d3.forceSimulation(nodes).force("link", linkForce).on("tick", updateNetwork);
        edgeEnter = d3.select("svg.main").selectAll("g.edge").data(edges).enter().append("g").attr("class", "edge");
        edgeEnter.append("line");
        nodeEnter = d3.select("svg.main").selectAll("g.node").data(nodes, function(d) {
          return d.name;
        }).enter().append("g").attr("class", "node");
        returnDefault = function() {
          var k, results1, v;
          results1 = [];
          for (k in classes) {
            v = classes[k];
            edgeEnter.classed(v, false);
            results1.push(nodeEnter.classed(v, false));
          }
          return results1;
        };
        makeFrontEdge = function() {
          return d3.select(this).node().parentNode.insertBefore(d3.select(this).node(), d3.select('.node').node());
        };
        getAncestors = function(node) {
          var res, up;
          res = [[], []];
          while (true) {
            up = edgeEnter.filter(function(d) {
              var ref1;
              return ref1 = d.target, indexOf.call(node.data(), ref1) >= 0;
            });
            node = nodeEnter.filter(function(d) {
              return !up.filter(function(p) {
                return p.source === d;
              }).empty();
            });
            res = [res[0].concat(up.data()), res[1].concat(node.data())];
            if (up.empty()) {
              break;
            }
          }
          return [
            edgeEnter.filter(function(d) {
              return indexOf.call(res[0], d) >= 0;
            }), nodeEnter.filter(function(d) {
              return indexOf.call(res[1], d) >= 0;
            })
          ];
        };
        getChildren = function(node) {
          var down, res;
          res = [[], []];
          while (true) {
            down = edgeEnter.filter(function(d) {
              var ref1;
              return ref1 = d.source, indexOf.call(node.data(), ref1) >= 0;
            });
            node = nodeEnter.filter(function(d) {
              return !down.filter(function(p) {
                return p.target === d;
              }).empty();
            });
            res = [res[0].concat(down.data()), res[1].concat(node.data())];
            if (down.empty()) {
              break;
            }
          }
          return [
            edgeEnter.filter(function(d) {
              return indexOf.call(res[0], d) >= 0;
            }), nodeEnter.filter(function(d) {
              return indexOf.call(res[1], d) >= 0;
            })
          ];
        };
        nodeEnter.on('click', function(cd) {
          var ancestors, children, downPaths, node, ref1, ref2, upPaths;
          returnDefault();
          node = nodeEnter.filter(function(d) {
            return d === cd;
          });
          node.classed(classes.selected, true);
          ref1 = getAncestors(node), upPaths = ref1[0], ancestors = ref1[1];
          ref2 = getChildren(node), downPaths = ref2[0], children = ref2[1];
          getChildren(ancestors).map(function(g) {
            return g.classed(classes.associated, true);
          })[0].each(makeFrontEdge);
          getAncestors(children).map(function(g) {
            return g.classed(classes.associated, true);
          })[0].each(makeFrontEdge);
          [upPaths, downPaths].map(function(s) {
            return s.each(makeFrontEdge);
          });
          return [upPaths, ancestors, downPaths, children].map(function(s) {
            s.classed(classes.associated, false);
            return s.classed(classes.inclusion, true);
          });
        });
        nodeEnter.append("rect").attr("x", function(d) {
          return -d.width / 2;
        }).attr("y", -fontSize).attr("width", function(d) {
          return d.width;
        }).attr("height", fontSize * 2).attr("rx", 2).attr("ry", 2);

        /* 的場梨沙ちゃんをよろしくお願いします */
        nodeEnter.append("text").classed('svg-text-inner', true).attr("y", 3).style("font-size", function(d) {
          if (d.name === '的場梨沙') {
            return (fontSize + 0.5) + "px";
          } else {
            return fontSize + "px";
          }
        }).text(function(d) {
          return d.name;
        });
        returnDefault();

        /* 的場梨沙ちゃんをよろしくお願いします */
        matobaRisa = document.getElementById('matoba-risa');
        matobaRisaClick.innerText = matobaRisa.innerText;
        matobaRisa.innerText = '';
        results.push(matobaRisa.appendChild(matobaRisaClick));
      }
      return results;
    });
  });

}).call(this);
