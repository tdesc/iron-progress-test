
Controller.ConferenceList = RouteController.extend
  onBeforeAction:->
    console.log('############# onBeforeAction ############')
    this.next()

  waitOn:->
    console.log('############# WAIT-ON ############');
    return [
        App.subs.subscribe('rooms',Meteor.userId())
        App.subs.subscribe('participants',_.pluck(Rooms.find().fetch(),'_id'))
    ]


Template.home.rendered =->
  App.updateSideMenu()

  Grid.init()
  Meteor.setTimeout ->
    $(".scrollbox").mCustomScrollbar
      theme:"dark-thin",
      scrollInertia: false,
      scrollButtons:
        enable: true
  ,600

Template.home.helpers
  allow_controls:->
    Session.get('conferenceList').length
  items:->
    getConferences(Meteor.userId())


Template.home.events

  "click button[name='new']":->
    ga("send", "event", "conference","new");
    Meteor.call('conference', 'new', (err, id)->
      if err
        App.errorNotify(err)
      else
        Meteor.navigateTo('/conference/'+ id)
    )

  'click .tile': (e) ->
    e.preventDefault()
    Meteor.navigateTo("/profile/"+this._id)

updateScroll=->
  Meteor.setTimeout ->
    $('.scrollbox').mCustomScrollbar("update")
  ,300

Template.expandItem.events
  'click button[name=open]': (e) ->
    e.preventDefault()
    Meteor.navigateTo('/conference/'+ this._id)

  'click button.remove': (e) ->
    e.preventDefault()
    Meteor.call('conference','delete',[this._id],(err)->
      if err
        App.errorNotify(err)
      else
        App.successNotify('Conference removed')
        updateScroll()
    )


Template.expandItem.helpers
  owner:->
    owner(this.ownerId)

  canEdit:->
    Meteor.userId() == this.ownerId
  participants:->
    Meteor.users.find({_id:{ $in: _.pluck(this.participants,'userId')}})

  start_date:->
    moment(this.date).format('LL')
  start_time:->
    moment(this.date).format('HH:mm')

  count:->
    this.participants.length

Template.listItem.helpers
  isNotOwner:->
    Meteor.userId() != this._id

  owner:->
    owner(this.ownerId)

  owner_type:->
    if this.type == USER
      return mf("card.template.user",null,"User")
    if this.type == INTERPRETER
      return mf("card.template.interpreter",null,"Interpreter")

  canEdit:->
    Meteor.userId() == this.ownerId

  datetime:->
    datetime(this.date)



owner =(id)->
  Meteor.users.findOne(id)


datetime=(date)->
  moment(date).format('lll')

Template.grid.helpers
  conferences:->
    getConferences(Meteor.userId())