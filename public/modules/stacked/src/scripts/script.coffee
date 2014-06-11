person1 = 'anne-hidalgo'
person2 = 'christiane-taubira'
margin = {top: 60, right: 20, bottom: 60, left: 40}
# width = 1020- margin.left - margin.right
width = 1020
# height = 355- margin.top - margin.bottom
height = 355
marginRect = 25
x = d3.scale.ordinal()
    .rangeRoundBands([0, width])
y = d3.scale.linear()
    .range([0, height])

stacked_graph = d3.select('body')
  .append('svg')
    .attr('id', 'stacked')
    .attr('width', width)
    .attr('height', height+margin.top+margin.bottom)

draw_stacked = (data_json) ->
  stacked_data = d3.layout.stack()(data_json.channelMap.map( (data_nd) ->
    data_json.channelDatas.map( (d) -> x:d.channelName, y: +d[data_nd] )

  ))

  console.log(stacked_data)

  # console.log(stacked_data)

  x.domain(stacked_data[0].map( (d) -> d.x ))
  y.domain([0, d3.max(stacked_data[stacked_data.length - 1], (d) -> d.y0 + d.y )])


  stacked_graph.selectAll('g.stacked-g')
      .data(stacked_data)
    .enter().append('g')
      .attr('class', (d,i) -> 'stacked-g person'+(i+1)+" "+ data_json.channelMap[i])
      .attr('transform', 'translate(0,' + (height + margin.top) + ')')

  stacked_graph.selectAll('g.stacked-g')
    .selectAll('rect')
     .data(Object)
   .enter().append('rect')
     .attr('x', (d) -> x(d.x)+33)
     .attr('y', (d) -> -y(d.y0) - y(d.y) )
     .attr('height', (d) -> y(d.y))
     # .attr('width', (x.rangeBand()-marginRect))
     .attr('width', 35)

  stacked_graph.select('g.person1')
      .selectAll('image')
        .data(data_json.channelDatas)
      .enter().append('image')
        .attr('xlink:href', (d) -> d.channelLogo)
        .data(Object)
        .attr('height', 80)
        .attr('width', 70)
        .attr('x', (d) -> x(d.x)+15)
        .attr('y', 0)


draw_axis = () ->
  yAxis = d3.svg.axis()
        .scale y
        .orient 'left'
        .ticks 4
        .tickSize(-width, 0, 0)

  stacked_graph.append('g')
        .attr('class', 'grid')
        .attr("transform", "translate(0,60)")
        .call(yAxis)


d3.json 'person-' + person1 + "-" + person2 + '.json', (error, data) ->
  if error then return console.warn(error)

  draw_axis()
  draw_stacked(data)
