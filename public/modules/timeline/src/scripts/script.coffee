### Setup ###

# Store person names (slugs)
person1 = 'segolene-royal'
person2 = 'christiane-taubira'

# Store minimum/maximum X/Y values from each dataset
minXValues = []
minYValues = []
maxXValues = []
maxYValues = []
# Store minimum/maximum X/Y values from both datasets
minMaxX = []
minMaxY = []

# Convert YYYY-MM format to full/exploitable date
parseDate = d3.time.format('%Y-%m').parse

# Set up chart size
margin = {top: 20, right: 20, bottom: 30, left: 50}
width = 960
height = 300

# Append svg element
svg = d3.select 'body'
  .append 'svg'
    .attr 'width', width + margin.left + margin.right
    .attr 'height', height + margin.top + margin.bottom
  .append 'g'
    .attr 'transform', 'translate(' + margin.left + ',' + margin.top + ')'

# Set up X/Y axes
x = d3.time.scale()
.range [0, width]

y = d3.scale.linear()
.range [height, 0]

xAxis = d3.svg.axis()
  .scale x
  .orient 'bottom'
  .ticks d3.time.year, 2 # manual, should be auto

yAxis = d3.svg.axis()
  .scale y
  .orient 'left'
  .ticks 5

# Set up area element
area = d3.svg.area()
  .x (d) -> return x d.mentionDate
  .y0 height
  .y1 (d) -> return y d.mentionCount

# Set up path element
valueline = d3.svg.line()
  .x (d) -> return x d.mentionDate
  .y (d) -> return y d.mentionCount

# Set up grid element
yGrid = () ->
  return d3.svg.axis()
    .scale y
    .orient 'left'
    .ticks 5

### Make the chart ###
chart = 
  # Find min/max values in dataset
  findMinMaxValues: (person) ->
    d3.json 'person-' + person + '.json', (error, data) ->
      for d,i in data.person.timelineMentions
        d.index = i
        d.mentionDate = parseDate d.mentionDate
        d.mentionCount = +d.mentionCount

      minXValues.push d3.min data.person.timelineMentions, (d) -> return d.mentionDate
      maxXValues.push d3.max data.person.timelineMentions, (d) -> return d.mentionDate
      minYValues.push d3.min data.person.timelineMentions, (d) -> return d.mentionCount
      maxYValues.push d3.max data.person.timelineMentions, (d) -> return d.mentionCount

    console.log person + ' loaded!'

  # Append chart elements from dataset
  appendChart: (person, datasetnumber) ->
    d3.json 'person-' + person + '.json', (error, data) ->
      for d,i in data.person.timelineMentions
        d.index = i
        d.mentionDate = parseDate d.mentionDate
        d.mentionCount = +d.mentionCount

      if datasetnumber is 1 # (don't draw two grids)
        # Draw horizontal grid
        svg.append 'g'
          .attr 'class', 'grid'
          .call(yGrid()
            .tickSize(-width, 0, 0)
            .tickFormat '')

      # Draw main path
      svg.append 'path'
        .attr 'class', 'line' + datasetnumber
        .attr 'd', valueline data.person.timelineMentions

      # Draw area
      svg.append 'path'
        .datum data.person.timelineMentions
        .attr 'class', 'area' + datasetnumber
        .attr 'd', area

      # Draw dots
      svg.selectAll 'circle' + datasetnumber
        .data data.person.timelineMentions
        .enter()
        .append 'circle'
          .attr 'class', 'circle' + datasetnumber
          .attr 'r', 3.5
          .attr 'cx', (d) -> return x d.mentionDate
          .attr 'cy', (d) -> return y d.mentionCount

      if datasetnumber is 1 # (don't draw two X/Y axes)
        # Draw X/Y axes
        svg.append 'g'
          .attr 'class', 'x axis'
          .attr 'transform', 'translate(0,' + height + ')'
          .call xAxis

        svg.append 'g'
          .attr 'class', 'y axis'
          .call yAxis
        .append 'text'
          .attr 'transform', 'rotate(-90)'
          .attr 'y' , 6
          .attr 'dy', '.71em'
          .style 'text-anchor', 'end'
      console.log person + ' drawn!'

  # Draw the chart / draw X/Y axes
  drawChart: (person1, person2) ->
    d3.json 'person-' + person1 + '.json', (error, data) ->
      for d,i in data.person.timelineMentions
        d.index = i
        d.mentionDate = parseDate d.mentionDate
        d.mentionCount = +d.mentionCount

      minXValue = d3.min minXValues
      maxXValue = d3.max maxXValues
      minMaxX.push minXValue, maxXValue
      minYValue = d3.max minYValues
      maxYValue = d3.max maxYValues
      minMaxY.push minYValue, maxYValue

      # console.log minMaxX
      # console.log minMaxY

      # Generate X/Y axes
      x.domain minMaxX
      y.domain minMaxY

      # Append everything
      chart.appendChart person1, 1
      if person2
        chart.appendChart person2, 2

  # Make the chart
  exec: () ->
    if person2
      chart.findMinMaxValues person2
      chart.findMinMaxValues person1
      chart.drawChart person1, person2
    else
      chart.findMinMaxValues person1
      chart.drawChart person1

# Don't make the chart before json is loaded
### sloppy ? ###
queue()
  .defer d3.json, 'person-' + person1 + '.json'
  .defer d3.json, 'person-' + person2 + '.json'
  .await chart.exec()