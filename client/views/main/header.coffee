
#resetAnimation = function(time){ _.delay(function() {$(".sky-form").removeClassStartingWith("slide").removeClass("magicTime")}, time) }

Template.header.events
  'click .profile .tile ':(e)->
    e.preventDefault()
    Router.go('/profile')


Template.header.helpers
  loggedUser:->
    Meteor.user()
  isInterpreter:->
    Meteor.user().type == INTERPRETER
  title:->
    Session.get('page-title')
  avatar_uploading:->
    Session.get('avatar-uploading')
  brand:->
    App.brand

App.brand=->
  if(Session.get('NOD'))
      return 'NOD'
  return 'TalkPal'


