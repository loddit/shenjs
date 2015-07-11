Devices = new Meteor.Collection 'devices'
Jumps = new Meteor.Collection 'jumps'

if Meteor.isClient
  currentPageNumber = 1

  scrollToPage = (pageNumber) ->
    pageDOM = document.querySelectorAll('.page')[pageNumber - 1]
    if pageDOM
      scrollTo(pageDOM.offsetTop)

  Template.counter.helpers
    count: -> Devices.find({}).count()

  unless Session.get 'myDeviceId'
    myDeviceId = Devices.insert
      userAgent: window.navigator.userAgent
    Session.set 'intervalId', Meteor.setInterval ->
      Meteor.call('heartbeat', myDeviceId)
    , 1000
    Session.set 'myDeviceId', myDeviceId

  Jumps.find({}).observe
    added: (jump) ->
      pageNumber = jump.number
      if pageNumber isnt currentPageNumber
        currentPageNumber = pageNumber
        scrollToPage(currentPageNumber)

  keyguru ['up'], (event) ->
    event.preventDefault()
    if currentPageNumber > 1
      currentPageNumber--
      scrollToPage(currentPageNumber)
      Jumps.insert
        number: currentPageNumber

  keyguru ['down'], (event) ->
    event.preventDefault()
    if currentPageNumber < document.querySelectorAll('.page').length
      currentPageNumber++
      scrollToPage(currentPageNumber)
      Jumps.insert
        number: currentPageNumber

if Meteor.isServer
  Meteor.methods
    heartbeat: (deviceId) ->
      Devices.update
        _id: deviceId
      ,
        $set:
          ts: Date.now()

  Jumps.find({}).observe
    added: (jump) ->
      setTimeout ->
        Jumps.remove jump._id
      ,1000

  Meteor.startup ->
    Meteor.setInterval ->
      Devices.remove {ts: {$lt: Date.now() - 3000}}
      console.log Devices.find({}).fetch().length
    , 1000
