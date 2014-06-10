person1 = 'anne-hidalgo'
person2 = 'christiane-taubira'

diameter = 720
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
      .attr('class', 'g-round')
      .attr('transform', 'translate('+ radius + ',' + radius + ')')

link = svg.append('g').selectAll('.link')
node = svg.append('g').selectAll('.node')

d3.json 'readme_team.json', (error, classes) -> 
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
      .attr('class', 'link ')
      .attr('d', line)

  node = node
      .data(nodes.filter((n) -> !n.children))
    .enter().append('text')
      .attr('class', (d) -> 'node ' + d.class)
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

  find = (groupe, data) ->
    
    nodes = map[groupe]

    # if(!nodes)
    unless nodes
      nodes = map[groupe] = data or
        groupe: groupe
        children: []

      if groupe.length
        nodes.parent = find(groupe.substring(0, i = groupe.lastIndexOf('.')))
        nodes.parent.children.push nodes
        nodes.key = groupe.substring(i + 1)
        
        # if (groupe) == person1
        nodes.class = 'person1' if nodes.parent.groupe is person1
        nodes.class = 'person2' if nodes.parent.groupe is person2
        nodes.class = 'person1_person2' if nodes.parent.groupe is person1+'.'+person2
          

    return nodes

  classes.forEach (d) ->
    find d.groupe, d


  map['']

# Return a list of imports for the given array of nodes.
packageImports = (nodes) ->
  map = {}
  imports = []
  
  # Compute a map from groupe to node.
  nodes.forEach (d) ->
    map[d.groupe] = d
    return

  
  # For each import, construct a link from the source to target node.
  nodes.forEach (d) ->
    if d.imports
      d.imports.forEach (i) ->
        imports.push
          source: map[d.groupe]
          target: map[i]

        return

    return

  imports




