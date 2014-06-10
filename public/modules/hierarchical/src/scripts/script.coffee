diameter = 960
radius = diameter / 2
innerRadius = radius - 120

cluster = d3.layout.cluster()
    .size([360, innerRadius])
    .sort(null)
    .value((d) -> d.size)

bundle = d3.layout.bundle()

line = d3.svg.line.radial()
    .interpolate("bundle")
    .tension(.85)
    .radius((d) -> d.y)
    .angle((d) -> d.x / 180 * Math.PI)

svg = d3.select('body')
    .append('svg')
      .attr('width', diameter)
      .attr('height', diameter)
    .append('g')
      # .attr("transform", "translate(" + radius + "," + radius + ")")
      .attr('transform', 'translate('+ radius + ',' + radius + ')')



link = svg.append('g').selectAll('.link')
node = svg.append('g').selectAll('.node')

d3.json 'readme-flare-imports.json', (error, classes) -> 
  nodes = cluster.nodes(packageHierarchy(classes))
  links = packageImports(nodes)

  link = link
      .data(bundle(links))
    .enter().append('path')
      .each((d) -> 
        d.source=d[0] 
        d.target=d[d.length-1]
        return
      )
      .attr('class', 'link')
      .attr('d', line)

  node = node
      .data(nodes.filter((n) -> !n.children))
    .enter().append('text')
      .attr('class', 'node')
      .attr('dy', '.31em')
      .attr("transform", (d) -> "rotate(" + (d.x - 90) + ")translate(" + (d.y + 8) + ",0)" + ((if d.x < 180 then "" else "rotate(180)")))
      .style('text-anchor', (d) -> (if d.x < 180 then "start" else "end"))
      .text((d) -> d.key)
      .on('mouseover', mouseovered)
      .on('mouseout', mouseouted)

  return

mouseovered = (d) ->
  node
      .each((n) -> n.target = n.source = false)

  link
      .classed("link--target", (l) -> l.source.source = true  if l.target is d)
      .classed("link--source", (l) -> l.target.target = true  if l.source is d)
      .filter((l) -> l.target is d or l.source is d)
      .each -> @parentNode.appendChild this


  node
      .classed('node--target', (n) -> n.target)
      .classed('node--source', (n) -> n.source)

  return

mouseouted = (d) ->
  link
      .classed("link--target", false)
      .classed("link--source", false)
  node
      .classed("node--target", false)
      .classed("node--source", false)
  return

d3.select(self.frameElement).style('height', diameter + 'px')

# Lazily construct the package hierarchy from class names.
packageHierarchy = (classes) ->
  map = {}

  find = (name, data) ->
    
    nodes = map[name]

    # if(!nodes)
    unless nodes
      nodes = map[name] = data or
        name: name
        children: []

      if name.length
        nodes.parent = find(name.substring(0, i = name.lastIndexOf('.')))
        console.log(nodes.parent)
        nodes.parent.children.push nodes
        nodes.key = name.substring(i + 1)

    return nodes

  classes.forEach (d) ->
    console.log(d)
    find d.name, d


  map['']

# Return a list of imports for the given array of nodes.
packageImports = (nodes) ->
  map = {}
  imports = []
  
  # Compute a map from name to node.
  nodes.forEach (d) ->
    map[d.name] = d
    return

  
  # For each import, construct a link from the source to target node.
  nodes.forEach (d) ->
    if d.imports
      d.imports.forEach (i) ->
        imports.push
          source: map[d.name]
          target: map[i]

        return

    return

  imports




