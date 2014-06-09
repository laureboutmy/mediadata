person1 = 'anne-hidalgo'
person2 = 'christiane-taubira'
margin = {top: 60, right: 20, bottom: 60, left: 40}
# width = 1020- margin.left - margin.right
width = 1020
# height = 355- margin.top - margin.bottom
height = 355
fill_color = d3.scale.ordinal().range(["#a36556", "#4c223a", "#3c180a", "#e5cf3e", "#194276", "#35b1a7", "#2b9855"])
marginRect = 25
x = d3.scale.ordinal()
    .rangeRoundBands([0, width])
y = d3.scale.linear()
    .range([0, height])

stacked_graph = d3.select('body')
  .append('svg')
    .attr('width', width)
    .attr('height', height)
  .append('svg:g')
    .attr('transform', 'translate(0,' + height + ')')


draw_stacked = (data_json) ->
  stacked_data = d3.layout.stack()(data_json.channelMap.map( (data_nd) ->  
    data_json.channelDatas.map( (d) -> x:d.channelName, y: +d[data_nd] )
  ))

  x.domain(stacked_data[0].map( (d) -> d.x ))
  y.domain([0, d3.max(stacked_data[stacked_data.length - 1], (d) -> d.y0 + d.y )])

  stacked_g = stacked_graph.selectAll('g')
                  .data(stacked_data)
                .enter().append('g')
                  .attr('class', (d,i) -> data_json.channelMap[i])
                  .attr('fill', (d,i) -> fill_color(i))

  stacked_rect = stacked_g.selectAll('rect')
                    .data(Object)
                  .enter().append('rect')
                    .attr('x', (d) -> x(d.x) )
                    .attr('y', (d) -> -y(d.y0) - y(d.y) )
                    .attr('height', (d) -> y(d.y))
                    .attr('width', (x.rangeBand()-marginRect))





d3.json 'person-' + person1 + "-" + person2 + '.json', (error, data) ->
  if error then return console.warn(error)

  draw_stacked(data)
