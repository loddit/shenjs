Devices = new Meteor.Collection 'devices'

if Meteor.isClient
  currentPage = 1

  scrollToPage = (pageNumber) ->
    pageDOM = document.querySelectorAll('.page')[pageNumber - 1]
    if pageDOM
      scrollTo(pageDOM.offsetTop)

  unless Session.get 'myDeviceId'
    myDeviceId = Devices.insert
      userAgent: window.navigator.userAgent
      currentPage: currentPage
    Session.set 'intervalId', Meteor.setInterval ->
      Meteor.call('heartbeat', myDeviceId)
    , 300
    Session.set 'myDeviceId', myDeviceId

  keyguru ['up'], (event) ->
    event.preventDefault()
    if currentPage > 1
      currentPage--
      scrollToPage(currentPage)

  keyguru ['down'], (event) ->
    event.preventDefault()
    if currentPage < document.querySelectorAll('.page').length
      currentPage++
      scrollToPage(currentPage)

if Meteor.isServer
  Meteor.methods
    heartbeat: (deviceId) ->
      Devices.update
        _id: deviceId
      ,
        $set:
          ts: Date.now()

  Meteor.startup ->
    Meteor.setInterval ->
      Devices.remove {ts: {$lt: Date.now() - 1000}}
      console.log Devices.find({}).fetch().length
    , 1000

