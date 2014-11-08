Template.layout.events
  'click .content':(e)->
    if $('.content-wrap').hasClass('show-menu')
      e.preventDefault()
      App.toggleMenu()

  'click #menu-icon':(e)->
    e.preventDefault()
    e.stopPropagation()
    App.toggleMenu()

Template.layout.helpers
  media_query:->
    if Session.get('media-query')
      console.log('#media_query')
      'media-query'
