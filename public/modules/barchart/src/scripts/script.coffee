person = 'anne-hidalgo'
margin = {top: 60, right: 20, bottom: 60, left: 40}
# width = 1020- margin.left - margin.right
width = 1020
# height = 355- margin.top - margin.bottom
height = 355
x = d3.scale.ordinal()
    .rangeRoundBands([0, width], .1)
y = d3.scale.linear()
    .range([height, 0])



d3.json 'person-' + person + '.json', (error, data) ->
  if error then return console.warn(error)

  #parseInt JSON data
  for d,i in data.channels
    d.channelCount = +d.channelCount


  

  # x.domain(channelNames.map)
  # y.domain([0, d3.max(channelCounts)])

  x.domain(data.channels.map((d) -> d.channelName))
  y.domain([0, d3.max(data.channels, (d) -> d.channelCount)])

  xAxis = d3.svg.axis()
          .scale(x)
          .orient('bottom')


  bar_svg = d3.select('body')
        .append('svg')
          .attr('id', 'barchart')
          .attr('width', width)
          .attr('height', height+margin.top+margin.bottom)
  
  bar_svg.append('filter')
      .attr('id', 'f1')
      .attr('width', '150%')
      .attr('height', '150%')
    .append('feOffset')
      .attr('result', 'offOut')
      .attr('in', 'SourceAlpha')
      .attr('dx', 0)
      .attr('dy', 3)

  bar_svg.select('filter')
    .append( 'feGaussianBlur' )
      .attr( 'stdDeviation', 1 )
      .attr( 'result', 'blur' )


  bar_svg.selectAll('g')
        .data(data.channels)
      .enter().append('g')
        .attr('transform', 'translate(0,'+margin.top+')')
      .append('rect')
        .attr('class', 'bar')
        .attr('x', (d,i) -> x(d.channelName)+27)
        .attr('width', 35)
        .attr('y', (d) -> y(d.channelCount))
        .attr('height', (d,i) -> height-y(d.channelCount))

  bar_svg.selectAll('g')
        .data(data.channels)
      .append('image')
        .attr('xlink:href', (d) -> d.channelLogo)
        .attr('height', 80)
        .attr('width', 70)
        .attr('x', (d,i) -> x(d.channelName)+10)
        .attr('y', height)

  bar_svg.selectAll('g')
      .append('rect')
      .data(data.channels)
        .attr( 'filter', 'url(#f1)' ) 
        .attr('class', 'tooltip shadow')
        .attr('height', 45)
        .attr('width', 76)
        .attr('x', (d,i) -> x(d.channelName)+5)
        .attr('y', (d) -> y(d.channelCount)-55)
        .attr('rx', 20)
        .attr('ry', 25)

  bar_svg.selectAll('g')
      .append('rect')
      .data(data.channels)
        .attr('class', 'tooltip')
        .attr('height', 45)
        .attr('width', 76)
        .attr('x', (d,i) -> x(d.channelName)+5)
        .attr('y', (d) -> y(d.channelCount)-55)
        .attr('rx', 20)
        .attr('ry', 25)

  bar_svg.selectAll('g')
      .append('text')
      .data(data.channels)
        .attr('text-anchor', 'middle')
        .attr('class', 'tooltip name')
        .attr('x', (d,i) -> x(d.channelName)+(x.rangeBand()/2)-3)
        .attr('y', (d) -> y(d.channelCount)-35)
        .text((d) -> d.channelName)

  bar_svg.selectAll('g')
      .append('text')
      .data(data.channels)
        .attr('text-anchor', 'middle')
        .attr('class', 'tooltip count')
        .attr('x', (d,i) -> x(d.channelName)+(x.rangeBand()/2)-3)
        .attr('y', (d) -> y(d.channelCount)-20)
        .html((d) -> d.channelCount)


  return