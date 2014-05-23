margin = {top: 20, right: 20, bottom: 30, left: 50}
width = 960 - margin.left - margin.right
height = 500 - margin.top - margin.bottom

parseDate = d3.time.format('%Y-%m').parse

x = d3.time.scale()
.range [0, width]

y = d3.scale.linear()
.range [height, 0]

xAxis = d3.svg.axis()
  .scale x
  .orient 'bottom'

yAxis = d3.svg.axis()
  .scale y
  .orient 'left'

area = d3.svg.area()
  .x (d) -> return x d.mentionDate
  .y0 height
  .y1 (d) -> return y d.mentionCount

svg = d3.select 'body'
  .append 'svg'
    .attr 'width', width + margin.left + margin.right
    .attr 'height', height + margin.top + margin.bottom
    .append 'g'
    .attr 'transform', 'translate(' + margin.left + ',' + margin.top + ')'

d3.json 'person-segolene-royal.json', (error, data) ->
  for d,i in data.person.timelineMentions
    d.index = i
    d.mentionDate = parseDate d.mentionDate
    d.mentionCount = +d.mentionCount

  x.domain d3.extent data.person.timelineMentions, (d) -> return d.mentionDate
  y.domain [0, d3.max data.person.timelineMentions, (d) -> return d.mentionCount]

  svg.append 'path'
    .datum data.person.timelineMentions
    .attr 'class', 'area'
    .attr 'd', area

  svg.append 'g'
    .attr 'class', 'x axis'
    .attr 'transform', 'translate(0,' + height + ')'
    .call xAxis