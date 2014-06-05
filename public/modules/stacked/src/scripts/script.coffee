person1 = 'anne-hidalgo'
person2 = 'christiane-taubira'
margin = {top: 60, right: 20, bottom: 60, left: 40}
# width = 1020- margin.left - margin.right
width = 1020
# height = 355- margin.top - margin.bottom
height = 355
x = d3.scale.ordinal()
    .rangeRoundBands([0, width], .1)
y = d3.scale.linear()
    .range([height, 0])
stackedObj = []


d3.json 'person-' + person1 + '.json', (error, data1) ->
  if error then return console.warn(error)

  d3.json 'person-' + person2 + '.json', (error, data2) ->
    if error then return console.warn(error)

    # for channel in data1.channels
      # for count in data2.channels
        # console.log(channel.channelName + '  ' + count.channelCount)
    
    for k, v of data1.channels
      console.log(v.channelName)
      stackedObj.push(v.channelName)
      console.log(stackedObj)
    
    


  return