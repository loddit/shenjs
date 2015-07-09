if Meteor.isClient
  console.log "Shenjs"

if Meteor.isServer
  Meteor.startup ->
    console.log "Shenjs"
