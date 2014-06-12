person1 = 'anne-hidalgo'
person2 = 'christiane-taubira'
margin = {top: 60, right: 20, bottom: 60, left: 40}
width = 1020
height = 355
marginRect = 25
stacked_data = undefined
x = d3.scale.ordinal()
    .rangeRoundBands([0, width])
y = d3.scale.linear()
    .range([0, height])

svg = () ->
  d3.select('body')
    .append('svg')
      .attr('id', 'stacked')
      .attr('width', width)
      .attr('height', height+margin.top+margin.bottom)


getScale = (data) ->
  stacked_data = d3.layout.stack()(data.channelMap.map( (data_nd) ->
    # console.log(data_nd)
    data.channelDatas.map( (d) -> x:d.channelName, y: +d[data_nd] )
  ))
  
  x.domain(stacked_data[0].map( (d) -> d.x ))
  y.domain([0, d3.max(stacked_data[stacked_data.length - 1], (d) -> d.y0 + d.y )])


drawContent = (data) ->

  d3.select('#stacked').selectAll('g.stacked-g')
      .data(stacked_data)
    .enter().append('g')
      .attr('class', (d,i) -> 'stacked-g person'+(i+1)+" "+ data.channelMap[i])
      .attr('transform', 'translate(0,' + (height + margin.top) + ')')

  d3.select('#stacked').selectAll('g.stacked-g')
    .selectAll('g')
     .data(Object)
   .enter().append('g')
    .append('rect')
      .attr('x', (d) -> x(d.x)+33)
      .attr('y', (d) -> -y(d.y0) - y(d.y) )
      .attr('height', (d) -> y(d.y))
     # .attr('width', (x.rangeBand()-marginRect))
      .attr('width', 35)

  d3.select('#stacked').select('g.person1')
      .selectAll('image')
        .data(data.channelDatas)
      .enter().append('image')
        .attr('xlink:href', (d) -> d.channelLogo)
        .data(Object)
        .attr('height', 80)
        .attr('width', 70)
        .attr('x', (d) -> x(d.x)+15)
        .attr('y', 0)

draw_tooltip = (data) ->
  ## TOOLTIP ##
   # console.log(stacked_data)
  total_height = []
  i = 0
  while i < stacked_data[0].length
    total_height[i] = (y(stacked_data[0][i].y) + y(stacked_data[1][i].y))
    ++i

  # total_height = total_height.concat(total_height)
  # Filtre servant à faire l'ombre du tooltip
  d3.select('#stacked').append('filter')
      .attr('id', 'f1')
      .attr('width', '150%')
      .attr('height', '150%')
    .append('feOffset')
      .attr('result', 'offOut')
      .attr('in', 'SourceAlpha')
      .attr('dx', 0)
      .attr('dy', 3)

  d3.select('#stacked').select('filter')
    .append( 'feGaussianBlur' )
      .attr( 'stdDeviation', 1 )
      .attr( 'result', 'blur' )


  d3.select('#stacked').selectAll('g.stacked-g g')
    .append('rect')
      .attr( 'filter', 'url(#f1)' ) 
      .attr('class', 'tooltip shadow')
      .attr('height', 45)
      .attr('width', 100)
      .attr('x', (d) -> x(d.x))
      .attr('y', (d,i) -> -y(d.y0) - (if typeof total_height[i] == 'undefined' then  y(d.y) else total_height[i])-55 )
      .attr('rx', 20)
      .attr('ry', 25)

  console.log 'total_height -->', total_height
  d3.select('#stacked').selectAll('g.stacked-g g')
    .append('rect')
      .attr('class', 'tooltip')
      .attr('height', 45)
      .attr('width', 100)
      .attr('x', (d) -> x(d.x))
      .attr('y', (d,i) -> -y(d.y0) - (if typeof total_height[i] == 'undefined' then  y(d.y) else total_height[i])-55 )
      .attr('rx', 20)
      .attr('ry', 25)


  d3.select('#stacked').selectAll('g.stacked-g g')
    .append('text')
    .attr('text-anchor', 'middle')
    .attr('x', (d) -> x(d.x)+45)
    .attr('y', (d,i) -> -y(d.y0) - (if typeof total_height[i] == 'undefined' then  y(d.y) else total_height[i])-33 )
    .text((d)->d.x)


  d3.select('#stacked').selectAll('g.stacked-g g')
    .append('text')
    .attr('text-anchor', 'middle')
    .attr('x', (d) -> x(d.x)+45)
    .attr('y', (d,i) -> -y(d.y0) - (if typeof total_height[i] == 'undefined' then  y(d.y) else total_height[i])-18 )
    .text((d)->d.y)

      

  # Rect superieur avec un Background #fff
  # d3.select('#stacked').selectAll('g.stacked-g')
    # .data(Object)
    #   .append('rect')  
    #     .attr('class', 'tooltip')
    #     .attr('height', 45)
    #     .attr('width', 76)
    #     .attr('x', (d,i) -> x(d.channelName)+5)
    #     .attr('y', (d) -> y(d.channelCount)-55)
    #     .attr('rx', 20)
    #     .attr('ry', 25)

  # Nom de la chaine
  # d3.select('#stacked').selectAll('g')
  #   .data(Object)
  #     .append('text')  
  #       .attr('text-anchor', 'middle')
  #       .attr('class', 'tooltip name')
  #       .attr('x', (d,i) -> x(d.channelName)+(x.rangeBand()/2)-3)
  #       .attr('y', (d) -> y(d.channelCount)-35)
  #       .text((d) -> d.channelName)

  # Nombre de mentions par chaines
  # d3.select('#stacked').selectAll('g')
  #   .data(Object)
  #     .append('text')  
  #       .attr('text-anchor', 'middle')
  #       .attr('class', 'tooltip count')
  #       .attr('x', (d,i) -> x(d.channelName)+(x.rangeBand()/2)-3)
  #       .attr('y', (d) -> y(d.channelCount)-20)
  #       .html((d) -> d.channelCount)

draw_axis = () ->
  yAxis = d3.svg.axis()
        .scale y
        .orient 'left'
        .ticks 4
        .tickSize(-width, 0, 0)

  d3.select('#stacked').append('g')
        .attr('class', 'grid')
        .attr("transform", "translate(0,60)")
        .call(yAxis)


d3.json 'person-' + person1 + "-" + person2 + '.json', (error, data) ->
  if error then return console.warn(error)
  svg()
  draw_axis()
  getScale(data)
  drawContent(data)
  draw_tooltip(data)

  # console.log 'stacked', stacked_data[0][0].x
