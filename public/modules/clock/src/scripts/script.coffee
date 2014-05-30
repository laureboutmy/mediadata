### Var / Functions ###

# Store person names (slugs)
person = 'christiane-taubira'

# Append svg container
svg = d3.select 'svg'
  .append 'g'
    .attr 'id', 'clock'

# New JSON object to store chart-oriented data (24 slots for 24 hours)
chartData = []
for i in [1 .. 24]
  chartData.push {}

# Width of the whole visualization; used for centering
visWidth = 200

# manual/sloppy, must be changed when data change #
###########
unzoom = 5
###########

# Path/circle radius scaling
radiusScale = d3.scale.linear().domain([0, 20]).range([100, visWidth-40]).clamp(false);

# Arc settings
arcOptions = {
  width: 7.1,
  from: 50,
  to: (d) -> d.outerRadius
}

# Arc function
arc = (d,o) ->
  return d3.svg.arc()
    .startAngle (d) -> if d.mentions > 0 then (d.time * 15 - o.width) * Math.PI/180 else 0
    .endAngle (d) -> if d.mentions > 0 then (d.time * 15 + o.width) * Math.PI/180 else 0
    .innerRadius o.from
    .outerRadius (d) -> if d.mentions > 0 then o.to d else 0

### Make the chart ###

# Draw the clock's content using json file + new json object
drawClockContent = (parent, newJSON, arcOptions) ->
  d3.json 'person-' + person + '.json', (error, data) ->
    for d,i in data.broadcastHoursByDay
      # Make JSON values usable (string -> int)
      d.broadcastHour = +d.broadcastHour
      d.broadcastCount = +d.broadcastCount

    # Init keys in new json
    for d,i in data.broadcastHoursByDay
      newJSON[d.broadcastHour].mentions = 0
      newJSON[d.broadcastHour].outerRadius = 0
      newJSON[d.broadcastHour].time = d.broadcastHour
    console.log newJSON

    # Fill-in empty keys in new json to prevent svg errors
    for d,i in newJSON
      if !d.time
        d.time = i
      if !d.mentions
        d.mentions = 0
      if !d.outerRadius
        d.outerRadius = 0
    
    # Store max value for the day / hour of max value
    maxValue = [0,]

    # Select a day and store chart-oriented data in new json
    for d,i in data.broadcastHoursByDay
      if d.broadcastWeekday == 'Monday'
        console.log d.broadcastCount
        newJSON[d.broadcastHour].mentions += d.broadcastCount
        newJSON[d.broadcastHour].outerRadius = radiusScale(newJSON[d.broadcastHour].mentions) / unzoom + 50 # manual, bad
        if d.broadcastCount > maxValue[0]
          maxValue[0] = d.broadcastCount
          maxValue[1] = d.broadcastHour
    console.log maxValue

    # Append paths / Show labels paths mouseover
    parent.append 'svg:g'
        .attr 'class', 'arcs'
        .selectAll 'path'
        .data newJSON
      .enter().append 'svg:path'
        .attr 'd', arc newJSON,arcOptions
        .attr 'transform', 'translate(' + visWidth + ',' + visWidth + ')'
        .on 'mouseover', (d) -> 
          d3.select '.time'
            .text d.time + ' heures'
          d3.select '.value' 
            .text d.mentions

    # Append center labels
    cw = parent.append 'svg:g'
      .attr 'class', 'center'
    cw.append 'svg:text'
        .data newJSON
        .attr 'transform', 'translate(' + visWidth + ',' + visWidth + ')'
        .attr 'class', 'time'
        .text maxValue[1] + ' heures'
    cw.append 'svg:text'
        .data newJSON
        .attr 'transform', 'translate(' + visWidth + ',' + (visWidth+20) + ')'
        .attr 'class', 'value'
        .text maxValue[0]

# Draw the clock element
drawClock = (d) ->
  # Clock's size parameters
  w = 400
  h = 400
  r = Math.min(w, h) / 2                       # center
  p = 24                                       # labels padding
  labels = ['00:00','06:00','12:00','18:00']   # labels names

  # The clock element
  clock = d3.select 'svg g'

  # Circle settings
  ticks = d3.range(20, 20.1);
  radiusFunction = radiusScale;

  # Append circle
  clock.append 'svg:g'
      .attr 'class', 'circle'
    .selectAll 'circle'
      .data ticks
    .enter().append 'svg:circle'
      .attr 'cx', r 
      .attr 'cy', r
      .attr 'r', radiusScale

  # Append outside labels
  clock.append 'svg:g'
    .attr 'class', 'labels'
    .selectAll 'text'
      .data d3.range(0, 360, 90)
    .enter().append 'svg:text'
      .attr 'transform', (d) ->
          return 'translate(' + r + ',' + p + ') rotate(' + d + ',0,' + (r-p) + ')'
      .text (d) -> d / 15 + ':00'

  drawClockContent(clock, chartData, arcOptions)

# Init
drawClock(chartData)