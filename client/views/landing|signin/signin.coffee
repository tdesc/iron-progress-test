Template.signin.rendered=->
  App.initLoginField('login', 'input-login')

Template.signin.events

  'click button': (e)->
    e.preventDefault()

  'click button.signin:not(.disabled)': (e,t)->
    e.preventDefault()

    classie.add( e.target, 'disabled' );
    $icon = $(e.target).find('.fa')

    $icon.removeClass('fa-rocket').addClass('fa-spinner fa-spin')

    login = t.find('[name=login]')
    password = t.find('[name=password]')

    App.loginWithPassword(login.value,password.value).done(->
      Session.set('verify_template',false)
      Session.set('reactiveLogin', true)
      if Session.get('conferenceId')
        Meteor.navigateTo('/conference/' + Session.get('conferenceId'))
      else
        Meteor.navigateTo('/conferences')
    ).fail((err)->

      if err.error == 400 then login.focus()
      if err.error == 401 then password.focus()
      if err.error == 553
        Session.set('verify_template',true)
        if Session.get('loginAttempt') == 'tel'
          App.successNotify(mf("signin.template.enter_verification_code",null,'Enter verification code') )
          $('[name=verification]').focus()
        else if Session.get('loginAttempt') == 'email'
          Session.set('verification_sent',_.join(' ',mf("signin.template.verification_sent",null,'Verification sent to') ,Session.get('login')))
          App.successNotify(_.join(' ',mf("signin.template.verify_link",null,'Verify by opening a link via email') ,Session.get('login')))
        return

      Session.set('verify_template',false)
      App.errorNotify(err)
    ).always(->
      classie.remove( e.target, 'disabled' );
      $icon.removeClass('fa-spinner fa-spin').addClass('fa-rocket')
    )

  'click button.new-account' :(e,t)->
    e.preventDefault();
    login = t.find('[name=login]').value.trim()
    password = t.find('[name=password]').value.trim()

    classie.add( e.target, 'disabled' );
    $icon = $(e.target).find('.fa')

    $icon.removeClass('fa-user').addClass('fa-spinner fa-spin')

    App.signupPassword( login, password).done(->

    ).fail((err)->
      if err.error == 403
        return App.errorNotify mf("signin.template.phone_exists",null,'Phone already exists')
      if err.error == 553
        Session.set('verify_template',true)
        if Session.get('loginAttempt') == 'email'
          Session.set('verification_sent',_.join(' ',mf("signin.template.verification_sent",null,'Verification sent to') ,login))

        App.successNotify(_.join(' ',mf("signin.template.verification_sent",null,'Verification sent to') ,login))
        return

      App.errorNotify(err)

    ).always(->
      classie.remove( e.target, 'disabled' );
      $icon.removeClass('fa-spinner fa-spin').addClass('fa-user')
    )

  'click button.verify': (e,t)->
    e.preventDefault();
    classie.add( e.target, 'disabled' );
    login = t.find('[name=login]').value.trim()
    password = t.find('[name=password]').value.trim()

    verification = t.find('[name=verification]')
    if verification and verification.value
      Meteor.promiseCall('verifySmsCode', verification.value.trim()).done((result)->
        Accounts.verifyEmail(result,(err)->
          if err
            App.errorNotify(err);
          else
            App.loginWithPassword(login,password)
        )
      ).fail((err)->
        App.errorNotify(err)
      ).always(->
        classie.remove( e.target, 'disabled' );
      )

  'click #login-with-facebook': (e)->
    e.preventDefault()
    App.loginWithFacebook()

  'click #login-with-twitter': (e)->
    e.preventDefault()
    App.loginWithTwitter()

  'click #login-with-linkedin': (e,t)->
    e.preventDefault();
    App.loginWithLinkedin()

  'click .resend':(e,t)->
    e.preventDefault()
    classie.add( e.target, 'disabled' );

    login = t.find('[name=login]').value.trim()

    if not login
      return App.errorNotify("Please enter valid phone or email")

    Session.set('login', login)
    resent_verify()

  'click .forgot':(e)->
    e.preventDefault()
    showModalDialog(Template.forgotPassword)

Template.signin.helpers
  verify_signin:->
    Session.get('verify_template')
  verify_phone:->
    Session.get('loginAttempt') == 'tel'
  verify_email:->
    Session.get('loginAttempt') == 'email'
  verification_sent:->
    Session.get('verification_sent')

resent_verify = _.debounce(->
  Meteor.call('resendVerificationEmail', Session.get('login'), (err)->
    if err
      App.errorNotify(err);
    else
      App.successNotify(_.join(' ','Verification send to',Session.get('login')))

    $('.resend').removeClass('disabled');
  )
,800)

Template.forgot_password_modal.rendered=->
  App.initLoginField('remember')

Template.forgot_password_modal.events
  'click .icon-cancel-2':(e)->
    e.preventDefault()
    closeModalDialog()

  'click button.reset': (e,template)->
    e.preventDefault();
    login = template.find('[name=remember]').value.trim()

    login = login.replace(/\s+/g, '');
    phone = login if isValidNumber(login)
    email = login if validateEmail(login)

    if not phone and not email
      App.errorNotify("Please enter valid phone or email")
      return

    Accounts.forgotPassword({email: login}, (err)->
      if err
        App.errorNotify(err)
      else
        if phone
          App.successNotify("Sms with reset code sent &amp; Please check your phone.")
          Meteor.navigateTo('/reset-password')

        if email
          App.successNotify("Email Sent &amp; Please check your email.")
        closeModalDialog()
    )
