// Generated by CoffeeScript 1.7.1
(function() {
  var bundle, cluster, diameter, innerRadius, line, link, mouseouted, mouseovered, node, packageHierarchy, packageImports, person1, person2, radius, svg;

  person1 = 'anne-hidalgo';

  person2 = 'christiane-taubira';

  diameter = 720;

  radius = diameter / 2;

  innerRadius = radius - 120;

  cluster = d3.layout.cluster().size([360, innerRadius]).sort(null).value(function(d) {
    return d.size;
  });

  bundle = d3.layout.bundle();

  line = d3.svg.line.radial().interpolate("bundle").tension(.85).radius(function(d) {
    return d.y;
  }).angle(function(d) {
    return d.x / 180 * Math.PI;
  });

  svg = d3.select('body').append('svg').attr('width', diameter).attr('height', diameter).append('g').attr('class', 'g-round').attr('transform', 'translate(' + radius + ',' + radius + ')');

  link = svg.append('g').selectAll('.link');

  node = svg.append('g').selectAll('.node');

  d3.json('readme_team.json', function(error, classes) {
    var links, nodes;
    nodes = cluster.nodes(packageHierarchy(classes));
    links = packageImports(nodes);
    link = link.data(bundle(links)).enter().append('path').each(function(d) {
      d.source = d[0];
      d.target = d[d.length - 1];
    }).attr('class', 'link ').attr('d', line);
    node = node.data(nodes.filter(function(n) {
      return !n.children;
    })).enter().append('text').attr('class', function(d) {
      return 'node ' + d["class"];
    }).attr('dy', '.31em').attr("transform", function(d) {
      return "rotate(" + (d.x - 90) + ")translate(" + (d.y + 8) + ",0)" + (d.x < 180 ? "" : "rotate(180)");
    }).style('text-anchor', function(d) {
      if (d.x < 180) {
        return "start";
      } else {
        return "end";
      }
    }).text(function(d) {
      return d.key;
    }).on('mouseover', mouseovered).on('mouseout', mouseouted);
  });

  mouseovered = function(d) {
    node.each(function(n) {
      return n.target = n.source = false;
    });
    link.classed("link--target", function(l) {
      if (l.target === d) {
        return l.source.source = true;
      }
    }).classed("link--source", function(l) {
      if (l.source === d) {
        return l.target.target = true;
      }
    }).filter(function(l) {
      return l.target === d || l.source === d;
    }).each(function() {
      return this.parentNode.appendChild(this);
    });
    node.classed('node--target', function(n) {
      return n.target;
    }).classed('node--source', function(n) {
      return n.source;
    });
  };

  mouseouted = function(d) {
    link.classed("link--target", false).classed("link--source", false);
    node.classed("node--target", false).classed("node--source", false);
  };

  d3.select(self.frameElement).style('height', diameter + 'px');

  packageHierarchy = function(classes) {
    var find, map;
    map = {};
    find = function(groupe, data) {
      var i, nodes;
      nodes = map[groupe];
      if (!nodes) {
        nodes = map[groupe] = data || {
          groupe: groupe,
          children: []
        };
        if (groupe.length) {
          nodes.parent = find(groupe.substring(0, i = groupe.lastIndexOf('.')));
          nodes.parent.children.push(nodes);
          nodes.key = groupe.substring(i + 1);
          if (nodes.parent.groupe === person1) {
            nodes["class"] = 'person1';
          }
          if (nodes.parent.groupe === person2) {
            nodes["class"] = 'person2';
          }
          if (nodes.parent.groupe === person1 + '.' + person2) {
            nodes["class"] = 'person1_person2';
          }
        }
      }
      return nodes;
    };
    classes.forEach(function(d) {
      return find(d.groupe, d);
    });
    return map[''];
  };

  packageImports = function(nodes) {
    var linked, map;
    map = {};
    linked = [];
    nodes.forEach(function(d) {
      map[d.groupe] = d;
    });
    nodes.forEach(function(d) {
      if (d.linked) {
        d.linked.forEach(function(i) {
          linked.push({
            source: map[d.groupe],
            target: map[i]
          });
        });
      }
    });
    return linked;
  };

}).call(this);