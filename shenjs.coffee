Devices = new Meteor.Collection 'devices'
PageIndexes = new Meteor.Collection 'page_indexes'

if Meteor.isClient
  currentPageNumber = 1

  scrollToPage = (pageNumber) ->
    pageDOM = document.querySelectorAll('.page')[pageNumber - 1]
    if pageDOM
      scrollTo(pageDOM.offsetTop)

  unless Session.get 'myDeviceId'
    myDeviceId = Devices.insert
      userAgent: window.navigator.userAgent
    Session.set 'intervalId', Meteor.setInterval ->
      Meteor.call('heartbeat', myDeviceId)
    , 300
    Session.set 'myDeviceId', myDeviceId

  PageIndexes.find({}).observe
    added: (pageIndex) ->
      pageNumber = pageIndex.number
      if pageNumber isnt currentPageNumber
        currentPageNumber = pageNumber
        scrollToPage(currentPageNumber)

  keyguru ['up'], (event) ->
    event.preventDefault()
    if currentPageNumber > 1
      currentPageNumber--
      scrollToPage(currentPageNumber)
      PageIndexes.insert
        number: currentPageNumber

  keyguru ['down'], (event) ->
    event.preventDefault()
    if currentPageNumber < document.querySelectorAll('.page').length
      currentPageNumber++
      scrollToPage(currentPageNumber)
      PageIndexes.insert
        number: currentPageNumber

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

