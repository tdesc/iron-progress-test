;(function () {

    "use strict";
////////////////////////////////////////////////////////////////////
// Routing
//


// override with mini-pages navigate method
    Meteor.navigateTo = function (path) {
        Router.go(path);
    };

    var filters = {

        /**
         * ensure user is logged in and
         * email verified
         */
        authenticate: function () {

            console.log('#authenticate: start');

            var user = Meteor.user();
                  if (!user) {
                    this.redirect('/');
                    console.log('#filter: signin');
                    this.layout('landing_layout');
                    this.render('landing_header', {to: 'header'});
                    this.render('landing');

                    if( Meteor.loggingIn() )
                    {
                        console.log('# loggin')
                    }
                }else
            {

                this.render('header', {to: 'header'});
                this.next()
                console.log('#autentificate success')
            }
        }
    };  // end filters



    Router.configure({
        layoutTemplate: 'layout',

        notFoundTemplate: 'notFound',
        yieldTemplates: {
            'header': {to: 'header'}
        },
        onAfterAction: function()
        {
            console.log('######## GLOBAL onAfterAction ########');
        }
    });

    Router.map(function () {
        this.route('home', {
            controller: Controller.ConferenceList,
            path: '/',
            layout: 'home',
            progress: {
                enabled: false
            },
            onBeforeAction: filters.authenticate
        });

    });

    //Router.plugin('dataNotFound',{notFoundTemplate: 'notFound'})

}());

