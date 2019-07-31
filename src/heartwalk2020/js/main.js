'use strict';

(function ($) {
  $(document).ready(function ($) {

    /*************/
    /* Namespace */
    /*************/
    window.cd = {};

    /*******************/
    /* WRAPPER SCRIPTS */
    /*******************/

    var screenWidth = $(window).innerWidth();

    // Mobile nav toggle
    $('#mobile-toggle').click(function() {
      if ($('#navbar-container').hasClass('is-search')) {
        $('#navbar-container').removeClass('is-search');
        $('.mobile-search-trigger').removeClass('active');
      } else {
        $('#navbar-container').slideToggle('fast');
      }
      $('.navbar-toggler-icon').toggleClass('fa-align-justify').toggleClass('fa-times');
    });

    // Mobile search toggle
    $('.mobile-search-trigger').click(function() {
      if ($('.navbar-toggler-icon').hasClass('fa-times')) {
        $('#navbar-container').addClass('is-search');
        $('.mobile-search-trigger').addClass('active');
        $('.navbar-toggler-icon').toggleClass('fa-align-justify').toggleClass('fa-times');
      } else {
        $('.mobile-search-trigger').toggleClass('active');
        if ($('#navbar-container').hasClass('is-search')) {
          // Wait to toggle is-search class until the container
          // is fully closed so that the user doesn't see the
          // gray navigation appear as it closes
          $('#navbar-container').slideToggle('fast', function() {
            $('#navbar-container').toggleClass('is-search');
          });
        } else {
          $('#navbar-container').toggleClass('is-search');
          $('#navbar-container').slideToggle('fast');
        }
      }
    });

    // $('#find').on('click', function(e){
    //   e.preventDefault();
    //   $('.dropdown-menu-container.find, .dropdown-menu-container.find .dropdown-menu').toggle();
    // });

    // $('.js--nav-about').on('click', function(e){
    //   e.preventDefault();
    //   $('.dropdown-menu-container.about, .dropdown-menu-container.about .dropdown-menu').toggle();
    // });

    // $( "#find" ).focusin(function() {
    //   $('.dropdown-menu-container.find, .dropdown-menu-container.find .dropdown-menu').show();
    // });

    // $( ".js--nav-about" ).focusin(function() {
    //   $('.dropdown-menu-container.find, .dropdown-menu-container.find .dropdown-menu').hide();
    //   $('.dropdown-menu-container.about, .dropdown-menu-container.about .dropdown-menu').show();
    // });

    // $( ".js--top-menu-contact" ).focusout(function() {
    //   $('.dropdown-menu-container.about, .dropdown-menu-container.about .dropdown-menu').hide();
    // });



    /******************/
    /* SEARCH SCRIPTS */
    /******************/
    var eventType = 'Heart%20Walk';
    var eventType2 = $('body').data('event-type2') ? $('body').data('event-type2') : null;
    var regType = $('body').data('reg-type') ? $('body').data('reg-type') : null;
    var publicEventType = $('body').data('public-event-type') ? $('body').data('public-event-type') : null;

    var isProd = (luminateExtend.global.tablePrefix === 'heartdev' ? false : true);
    var eventName = luminateExtend.global.eventName;
    var srcCode = luminateExtend.global.srcCode;
    var subSrcCode = luminateExtend.global.subSrcCode;
    var evID = $('body').data('fr-id') ? $('body').data('fr-id') : null;
    var dfID = $('body').data('df-id') ? $('body').data('df-id') : null;
    var consID = $('body').data('cons-id') ? $('body').data('cons-id') : null;

    function getURLParameter(url, name) {
      return (RegExp(name + '=' + '(.+?)(&|$)').exec(url) || [, null])[1];
    }
    var currentUrl = window.location.href;
    var searchType = getURLParameter(currentUrl, 'search_type');
    var isCrossEventSearch = getURLParameter(currentUrl, 'cross_event');

    var addScrollLinks = function () {
      $('a.scroll-link')
        .on('click', function (event) {
          // On-page links
          // Figure out element to scroll to
          var target = $(this.hash);
          target = target.length ? target : $('[name=' + this.hash.slice(1) + ']');
          // Does a scroll target exist?
          if (target.length) {
            // Only prevent default if animation is actually gonna happen
            event.preventDefault();
              var scrollLocation = target.offset().top;
              // var scrollLocation = target.offset().top - 230;
            $('html, body').animate({
              scrollTop: scrollLocation
            }, 1000, function () {});
          }
        });
    }
    addScrollLinks();

    cd.getParticipants = function (firstName, lastName, isCrossEvent) {
      luminateExtend.api({
        api: 'teamraiser',
        data: 'method=getParticipants' +
        ((firstName !== undefined) ? '&first_name=' + firstName : '') +
        ((lastName !== undefined) ? '&last_name=' + lastName : '') +
        (isCrossEvent === true ? '&event_type=' + eventType : '&fr_id=' + evID) +
          '&list_page_size=499' +
          '&list_page_offset=0' +
          '&response_format=json' +
          '&list_sort_column=first_name' +
          '&list_ascending=true',
        callback: {
          success: function (response) {
            if (response.getParticipantsResponse.totalNumberResults === '0') {
              // no search results
              $('#error-participant').removeAttr('hidden').text('Participant not found. Please try different search terms.');
            } else {
              var participants = luminateExtend.utils.ensureArray(response.getParticipantsResponse.participant);
              var totalParticipants = parseInt(response.getParticipantsResponse.totalNumberResults);

              if ( $.fn.DataTable ) {
                if ( $.fn.DataTable.isDataTable('#participantResultsTable') ) {
                  $('#participantResultsTable').DataTable().destroy();
                }              }
              $('#participantResultsTable tbody').empty();

              $('.js--num-participant-results').text((totalParticipants === 1 ? '1 Result' : totalParticipants + ' Results'));

              $(participants).each(function (i, participant) {
                if (screenWidth >= 768) {
                  $('.js--participants-results-rows').append('<tr' + (i > 10 ? ' class="d-none"' : '') + '><td><a href="' + participant.personalPageUrl + '">' +
                  participant.name.first + ' ' + participant.name.last +
                  '</a></td><td>' +
                  ((participant.teamName !== null && participant.teamName !== undefined) ? '<a href="' + participant.teamPageUrl + '">' + participant.teamName + '</a>' : '') + '</td><td><a href="TR/?fr_id=' + participant.eventId + '&pg=entry">' +
                  participant.eventName + '</a></td><td class="col-cta"><a href="' + participant.donationUrl + '" aria-label="Donate to ' + participant.name.first + ' ' + participant.name.last + '" class="btn btn-primary btn-block btn-rounded">Donate</a></td></tr>');
                } else {
                  $('#participantResultsTable thead').remove();
                  $('.js--participants-results-rows').addClass('mobile').append('<tr><td><table><tr' + (i > 10 ? ' class="d-none"' : '') + '><td>Walker</td><td><a href="' + participant.personalPageUrl+ '">' +
                    participant.name.first + ' ' + participant.name.last + '</a></td></tr>' +
                    ((participant.teamName !== null && participant.teamName !== undefined) ? '<tr><td>Team</td><td><a href="' + participant.teamPageUrl + '">' + participant.teamName + '</a>' : '') +
                    '</td></tr><tr><td>Event Name</td><td><a href="TR/?fr_id=' + participant.eventId + '&pg=entry">' + participant.eventName + '</a></td></tr><tr><td colspan="2" class="text-center"><a href="' + participant.donationUrl + '" class="btn btn-primary btn-block btn-rounded" title="Donate to ' + participant.name.first + ' ' + participant.name.last + '" aria-label="Donate to ' + participant.name.first + ' ' + participant.name.last + '">Donate</a></td></tr></table></td></tr>');
                }


              });

              if(totalParticipants > 10) {
                $('.js--more-participant-results').removeAttr('hidden');
              }

              if (screenWidth >= 768) {
                $('#participantResultsTable').DataTable({
                  "paging":   false,
                  "searching":   false,
                  "info":     false,
                  "autoWidth": false
                });
              }
              $('.dataTables_length').addClass('bs-select');
              //add call to hook donate button with payment type selections
              addPaymentTypesOnSearch();
              $('.js--participant-results-container').removeAttr('hidden');

              $('.js--more-participant-results').on('click', function(e){
                e.preventDefault();
                $('.js--participants-results-rows tr').removeClass('d-none');
                $(this).attr('hidden', true);
                $('.js--end-participant-list').removeAttr('hidden');
              });

            }
          },
          error: function (response) {
            $('#error-participant').removeAttr('hidden').text(response.errorResponse.message);
            console.log('error response: ', response);
          }
        }
      });
    };

    cd.getTeams = function (teamName, isCrossEvent, firstName, lastName, companyId) {
      $('.js__team-results-rows').html('');
      luminateExtend.api({
        api: 'teamraiser',
        data: 'method=getTeamsByInfo' +
          '&team_name=' + teamName +
          (isCrossEvent === true ? '&event_type=' + eventType : '&fr_id=' + evID) +
          (firstName ? '&first_name=' + firstName : '') +
          (lastName ? '&last_name=' + lastName : '') +
          (companyId ? '&team_company_id=' + companyId : '') +
          '&list_page_size=499' +
          '&list_page_offset=0' +
          '&response_format=json' +
          '&list_sort_column=name' +
          '&list_ascending=true',
        callback: {
          success: function (response) {

            if ( $.fn.DataTable ) {
              if ( $.fn.DataTable.isDataTable('#teamResultsTable') ) {
                $('#teamResultsTable').DataTable().destroy();
              }
            }
            $('#teamResultsTable tbody').empty();

            if (response.getTeamSearchByInfoResponse.totalNumberResults === '0') {
              // no search results
              $('#error-team').removeAttr('hidden').text('Team not found. Please try different search terms.');
              $('.js--error-team-search').show();
            } else {
              var teams = luminateExtend.utils.ensureArray(response.getTeamSearchByInfoResponse.team);

              $(teams).each(function (i, team) {
                  if (screenWidth >= 768) {
                      $('.js--team-results-rows')
                          .append('<tr' + (i > 10 ? ' class="d-none"' : '') + '><td><a href="' + team.teamPageURL + '">' +
                              team.name + '</a></td><td><a href="TR/?px=' + team.captainConsId + '&pg=personal&fr_id=' + team.EventId + '">' + team.captainFirstName + ' ' + team.captainLastName + '</a></td><td>' +
                              ((team.companyName !== null && team.companyName !== undefined) ? '<a href="TR?company_id=' + team.companyId + '&fr_id=' + team.EventId + '&pg=company">' + team.companyName + '</a>' : '') +
                              '</td><td><a href="TR/?fr_id=' + team.EventId + '&pg=entry">' + team.eventName + '</a></td><td class="col-cta"><a href="' + team.teamDonateURL + '" class="btn btn-primary btn-block btn-rounded" title="Donate to ' + team.name + '" aria-label="Donate to ' + team.name + '">Donate</a></td></tr>');
                  } else {
                      $('#teamResultsTable thead').remove();
                      $('.js--team-results-rows')
                          .addClass('mobile')
                          .append('<tr><td><table><tr' + (i > 10 ? ' class="d-none"' : '') + '><td>Team</td><td><a href="' + team.teamPageURL + '">' +
                              team.name + '</a></td></tr><tr><td>Team Captain</td><td><a href="TR/?px=' + team.captainConsId + '&pg=personal&fr_id=' + team.EventId + '">' + team.captainFirstName + ' ' + team.captainLastName + '</a></td></tr>' +
                              ((team.companyName !== null && team.companyName !== undefined) ? '<tr><td>Company</td><td><a href="TR?company_id=' + team.companyId + '&fr_id=' + team.EventId + '&pg=company">' + team.companyName + '</a>' : '') +
                              '</td></tr><tr><td>Event Name</td><td><a href="TR/?fr_id=' + team.EventId + '&pg=entry">' + team.eventName + '</a></td></tr><tr><td colspan="2" class="text-center"><a href="' + team.teamDonateURL + '" class="btn btn-primary btn-block btn-rounded" title="Donate to ' + team.name + '" aria-label="Donate to ' + team.name + '">Donate</a></td></tr></table></td></tr>');
                  }
              });

              var totalTeams = parseInt(response.getTeamSearchByInfoResponse.totalNumberResults);

              $('.js--num-team-results').text((totalTeams === 1 ? '1 Result' : totalTeams + ' Results'));

              if(totalTeams > 10) {
                $('.js--more-team-results').removeAttr('hidden');
              }

              $('.js--team-results-container').removeAttr('hidden');

              $('.js--more-team-results').on('click', function(e){
                e.preventDefault();
                $('.js--team-results-rows tr').removeClass('d-none');
                $(this).attr('hidden', true);
                $('.js--end-team-list').removeAttr('hidden');
              });
              if (screenWidth >= 768) {
              $('#teamResultsTable').DataTable({
                "paging":   false,
                "searching":   false,
                "info":     false
              });
            }
              $('.dataTables_length').addClass('bs-select');
              //add call to hook donate button with payment type selections
              addPaymentTypesOnSearch();
              $('.js--team-results-container').removeAttr('hidden');

            }
          },
          error: function (response) {
            $('#error-team').removeAttr('hidden').text(response.errorResponse.message);
            $('.js--search-results').show();
            $('.js--search-results-container').show();
          }
        }
      });
    };

    cd.getCompanies = function (companyName, isCrossEvent) {
      luminateExtend.api({
        api: 'teamraiser',
        data: 'method=getCompaniesByInfo' +
          '&company_name=' + companyName +
          (isCrossEvent === true ? '&event_type=' + eventType : '&fr_id=' + evID) +
          '&list_page_size=499' +
          '&list_page_offset=0' +
          (isCrossEvent === true ? '&include_cross_event=true' : '') +
          '&response_format=json' +
          '&list_sort_column=company_name' +
          '&list_ascending=true',
        callback: {
          success: function (response) {
            if (response.getCompaniesResponse.totalNumberResults === '0') {
              // no search results
              $('#error-company').removeAttr('hidden').text('Company not found. Please try different search terms.');
            } else {
              var companies = luminateExtend.utils.ensureArray(response.getCompaniesResponse.company);
              var totalCompanies = parseInt(response.getCompaniesResponse.totalNumberResults);
              $('.js--num-companies').text(totalCompanies);

              $(companies).each(function (i, company) {
                $('.js__company-results-rows').append('<tr' + (i > 10 ? ' class="d-none"' : '') + '><td><a href="' + company.companyURL + '">' +
                  company.companyName + '</a></td><td class="col-cta"><a href="' + company.companyURL + '" aria-label="Visit page for ' + company.companyName + '" class="btn-rounded btn-primary btn-block">View</a></td></tr>');
              });

              $('.js--company-results-container').removeAttr('hidden');
              $('.js--company-results-container').removeAttr('hidden');
            }
          },
          error: function (response) {
            $('.js--company-results-container').removeAttr('hidden').text(response.errorResponse.message);
          }
        }
      });
    };

    // Header Search Forms
    // Search by Event
    $('.js--header-zip-search').on('submit', function (e) {
      e.preventDefault();
      var zipSearched = encodeURIComponent($('#zipSearch').val());
      window.location.href = luminateExtend.global.path.secure + 'SPageServer/?pagename=HeartWalk_Search&search_type=event&cross_event=' + (evID ? 'false' : 'true') + (evID ? '&fr_id=' + evID : '') + '&zip=' + zipSearched;
    });

    // Search page by Participant
    $('.js--header-walker-search').on('submit', function (e) {
      e.preventDefault();
      var firstName = encodeURIComponent($('#walkerSearchFirst').val());
      var lastName = encodeURIComponent($('#walkerSearchLast').val());
      window.location.href = luminateExtend.global.path.secure + 'SPageServer/?pagename=HeartWalk_Search&search_type=walker&cross_event=false&fr_id=' + evID + (firstName ? '&first_name=' + firstName : '') +
          (lastName ? '&last_name=' + lastName : '');
    });

    // Search by Team
    $('.js--header-team-search').on('submit', function (e) {
      e.preventDefault();
      var teamName = encodeURIComponent($('#teamSearch').val());
      cd.getTeams(teamName, null, (isCrossEventSearch === "true" ? true : false));
      window.location.href = luminateExtend.global.path.secure + 'SPageServer/?pagename=HeartWalk_Search&search_type=team&cross_event=' + (evID ? 'false' : 'true') + (evID ? '&fr_id=' + evID : '') + '&team_name=' + teamName;
    });


    /******************************/
    /* EVENT SEARCH SCRIPTS */
    /******************************/

    // Get events by name or state
    cd.getEvents = function (eventName, eventState) {
      $('.js--loading').show();
      $('.js--no-event-results').addClass('d-none');
      luminateExtend.api({
        api: 'teamraiser',
        data: 'method=getTeamraisersByInfo' +
          '&name=' + (eventState ? '%25%25' : eventName) +
          (eventState ? '&state=' + eventState : '') +
          '&event_type=' + eventType +
          '&response_format=json&list_page_size=499&list_page_offset=0&list_sort_column=event_date&list_ascending=true',
        callback: {
          success: function (response) {
            if (response.getTeamraisersResponse.totalNumberResults > '0') {
              $('.js--loading').hide();
              var events = luminateExtend.utils.ensureArray(response.getTeamraisersResponse.teamraiser);

              $(events).each(function (i, event) {
                var eventId = event.id;
                var eventName = event.name;
                var eventDate = luminateExtend.utils.simpleDateFormat(event.event_date,
                  'EEEE, MMMM d, yyyy');
                var eventTimestamp = new Date(event.event_date);
                var eventCity = event.city;
                var eventStateAbbr = event.state;
                var eventStateFull = event.mail_state;
                var eventLocation = event.location_name;
                var eventStatus = event.status;
                var eventType = event.public_event_type_name;
                var greetingUrl = event.greeting_url;
                var registerUrl = 'SPageServer/?pagename=cn_register&fr_id=' + eventId + '&s_regType=';
                var acceptsRegistration = event.accepting_registrations;
                var eventRow = '<li class="event-detail row col-12 col-lg-4 mb-4 fadein"><div class="event-detail-content col-10"><a class="js--event-name" href="' +
                  greetingUrl + '" aria-label="Visit ' + eventCity + ' ' + eventType + ' Event"><span class="city">' +
                  eventCity + '</span>, <span class="fullstate">' +
                  eventStateAbbr + '</span></a><span class="eventtype d-block">' +
                  eventType + ' Event</span><span class="event-date d-block">' +
                  eventDate + '</span></div><a href="' +
                  greetingUrl + '" class="event-detail-button btn col-2" aria-label="Visit event page for CycleNation ' + eventCity + '"><i class="fas fa-angle-right" aria-hidden="true" alt=""></i></a></li>';

                if (eventStatus === '1' || eventStatus === '2' || eventStatus === '3') {
                  $('.js--event-search-results').append(eventRow);
                }
              });
            } else {
              $('.js--loading').hide();
              $('.js--no-event-results').removeClass('d-none');
            }
          },
          error: function (response) {
            $('.js--loading').hide();
            console.log('getEvents error: ' + response.errorResponse.message);
          }
        }
      });
    };

    // Get events by zip

    cd.getEventsByDistance = function (zipCode) {
      $('.js--no-event-results').addClass('d-none');
      $('.js--loading').show();

      luminateExtend.api({
        api: 'teamraiser',
        data: 'method=getTeamraisersByDistance' +
          '&starting_postal=' + zipCode +
          '&distance_units=mi' +
          '&search_distance=200' +
          '&event_type=' + eventType +
          '&response_format=json&list_page_size=499&list_page_offset=0&list_sort_column=event_date&list_ascending=true',
        callback: {
          success: function (response) {
            if (response.getTeamraisersResponse.totalNumberResults > '0') {
              $('.js--loading').hide();
              var events = luminateExtend.utils.ensureArray(response.getTeamraisersResponse.teamraiser);
              var totalEvents = parseInt(response.getTeamraisersResponse.totalNumberResults);

              if ( $.fn.DataTable ) {
                if ( $.fn.DataTable.isDataTable('#eventResultsTable') ) {
                  $('#eventResultsTable').DataTable().destroy();
                }
              }
              $('#eventResultsTable tbody').empty();

              $('.js--num-event-results').text((totalEvents === 1 ? '1 Result' : totalEvents + ' Results'));

              $(events).each(function (i, event) {
                var eventDate = luminateExtend.utils.simpleDateFormat(event.event_date,
                  'EEE, MMM d, yyyy');
                var eventTimestamp = new Date(event.event_date);
                var eventStatus = event.status;
                var acceptsRegistration = event.accepting_registrations;

                if (screenWidth >= 768) {
                var eventRow = '<tr' + (i > 10 ? ' class="d-none"' : '') + '><td><a href="' +
                event.greeting_url + '">' + event.name + '</a></td><td data-order="' + event.event_date + '">' + eventDate + '</td><td data-order="' + parseFloat(event.distance) + '">' + event.distance + 'mi</td><td><a href="' + event.greeting_url + '" aria-label="More details about ' + event.name + '" class="btn btn-secondary btn-block btn-rounded">Details</a></td><td class="col-cta">' + (acceptsRegistration === 'true' ? '<a href="SPageServer/?pagename=heartwalk_register&fr_id=' + event.id + '" aria-label="Register for ' + event.name + '" class="btn btn-primary btn-block btn-rounded">Register</a>' : 'Registration Closed') + '</td></tr>';
              } else {
                $('#eventResultsTable thead').remove();
                $('.js--event-results-rows').addClass('mobile')

                var eventRow = '<tr><td><table><tr' + (i > 10 ? ' class="d-none"' : '') + '><td>Event Name</td><td><a href="' +
                event.greeting_url + '">' + event.name + '</a></td></tr>' +
                  '</td></tr><tr><td>Date</td><td>' + eventDate + '</td></tr><tr><td>Distance</td><td>' + event.distance + 'mi</td></tr><tr><td colspan="2" class="text-center">' + (acceptsRegistration === 'true' ? '<a href="SPageServer/?pagename=heartwalk_register&fr_id=' + event.id + '" class="btn btn-primary btn-block btn-rounded" title="Register for ' + event.name + '" aria-label="Register for ' + event.name + '">Register</a>' : 'Registration Closed') + '</td></tr></table></td></tr>';
              }
               

                if (eventStatus === '1' || eventStatus === '2' || eventStatus === '3') {
                  $('.js--event-results-rows').append(eventRow);
                }
              });

              if(totalEvents > 10) {
                $('.js--more-event-results').removeAttr('hidden');
              }

              $('.js--more-event-results').on('click', function(e){
                e.preventDefault();
                $('.js--event-results-rows tr').removeClass('d-none');
                $(this).attr('hidden', true);
                $('.js--end-event-list').removeAttr('hidden');
              });
              if (screenWidth >= 768) {
              $('#eventResultsTable').DataTable({
                "paging":   false,
                "searching":false,
                "info":     false
              });
            }
              $('.dataTables_length').addClass('bs-select');

              $('.js--event-results-container').removeAttr('hidden');
            } else {
              $('.js--loading').hide();
              $('.js--no-event-results').removeClass('d-none');
            }
          },
          error: function (response) {
            $('.js--loading').hide();
            console.log('getEvents error: ' + response.errorResponse.message);
          }
        }
      });
    };
    // END getEventsByDistance

    /***********************/
    /* THERMOMETER SCRIPTS */
    /***********************/

    cd.runThermometer = function (raised, goal) {
          var fundraiserRaised = Number(raised.replace(/[^0-9.-]+/g,''));
          var fundraiserGoal = Number(goal.replace(/[^0-9.-]+/g,''));

          var percentRaised = (fundraiserRaised / fundraiserGoal);
          if (isNaN(percentRaised)) {
              percentRaised = 0;
          }
          var percentRaisedFormatted = (percentRaised * 100) + '%';

          $('.js__progress-bar')
              .animate({width : percentRaisedFormatted}, 2000)
              .attr("aria-valuenow", percentRaised * 100);
          $('.js__percent-raised').each(function () {
              $(this).prop('Counter', 0).animate({
                  Counter: percentRaisedFormatted
              }, {
                  duration: 1000,
                  easing: 'swing',
                  step: function (now) {
                      $(this).text(Math.ceil(now) + '%');
                      if (now > 80 && now <= 100) {
                          $(this).addClass('invert-percent-raised');
                      } else if (now > 100) {
                          $(this).addClass('progress-goal-met');
                      }
                  }
              });
          });
      };

    /******************/
    /* ROSTER SCRIPTS */
    /******************/

    cd.getTopParticipants = function (eventId) {
      luminateExtend.api({
        api: 'teamraiser',
        data: 'method=getParticipants&first_name=%25%25%25&event_type=' + eventType + '&fr_id=' + eventId + '&list_sort_column=total&list_ascending=false&list_page_size=5&response_format=json',
        callback: {
          success: function (response) {
            if (!$.isEmptyObject(response.getParticipantsResponse)) {
              var participantData = luminateExtend.utils.ensureArray(response.getParticipantsResponse
                .participant);

              $(participantData).each(function () {
                console.log('getting top participants');
                var participantName = this.name.first + ' ' + this.name.last;
                var participantRaised = (parseInt(this.amountRaised) * 0.01);
                var participantRaisedFormmatted = participantRaised.toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,");
                var participantId = this.consId;
                var participantPage = this.personalPageUrl;
                var isCaptain = this.aTeamCaptain;
                var topWalkerHtml = '<li><div class="d-flex"><div class="flex-grow-1"><a href="' + participantPage + '">' + participantName + '</a></div><div class="raised">Raised<br><strong>$' + participantRaisedFormmatted + '</strong></div></div></li>';
                if(participantName !== "Null Null"){
                  $('.js--walker-top-list ul').append(topWalkerHtml);
                }
              });
            }
          },
          error: function (response) {
            console.log('getTopParticipants error: ' + response.errorResponse.message);
          }
        }
      }); 
    };
    // END TOP PARTICIPANTS

    // BEGIN TOP TEAMS
    cd.getTopTeams = function (eventId) {
      luminateExtend.api({
        api: 'teamraiser',
        data: 'method=getTeamsByInfo&fr_id=' + eventId + '&list_sort_column=total&list_ascending=false&list_page_size=5&response_format=json',
        callback: {
          success: function (response) {
            if (!$.isEmptyObject(response.getTeamSearchByInfoResponse)) {
              var teamData = luminateExtend.utils.ensureArray(response.getTeamSearchByInfoResponse.team);

              $(teamData).each(function (i) {
                var teamName = this.name;
                var teamRaised = (parseInt(this.amountRaised) * 0.01);
                var teamRaisedFormmatted = teamRaised.toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,");
                var teamId = this.id;

                var topTeamRow = '<li><div class="d-flex"><div class="flex-grow-1"><a href="TR/?team_id=' + teamId + '&amp;pg=team&amp;fr_id=' + evID + '">' + teamName + '</a></div><div class="raised">Raised<br><strong>$' + teamRaisedFormmatted + '</strong></div></div></li>';

                $('.js--team-top-list ul').append(topTeamRow);
              });
            }
          },
          error: function (response) {
            console.log('getTopTeams error: ' + response.errorResponse.message);
          }
        }
      }); 
    };

    // END TOP TEAMS

    // BEGIN TOP COMPANIES
    cd.getTopCompanies = function (eventId) {
      luminateExtend.api({
        api: 'teamraiser',
        data: 'method=getCompaniesByInfo&fr_id=' + eventId +
          '&include_cross_event=true&list_sort_column=total&list_ascending=false&list_page_size=5&response_format=json',
        callback: {
          success: function (response) {
            if (!$.isEmptyObject(response.getCompaniesResponse)) {
              var topCompanies = luminateExtend.utils.ensureArray(response.getCompaniesResponse
                .company);

                var totalCompanies = parseInt(response.getCompaniesResponse.totalNumberResults);
                $('.js--num-companies').text(totalCompanies);

              $(topCompanies).each(function () {
                var companyName = this.companyName;
                var companyRaised = (parseInt(this.amountRaised) * 0.01);
                var companyRaisedFormmatted = companyRaised.toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,");
                var topCompanyHtml = '<li><div class="d-flex"><div class="flex-grow-1"><a href="TR?company_id=' + this.companyId + '&fr_id=' + evID + '&pg=company">' + companyName + '</a></div><div class="raised">Raised<br><strong>$' + companyRaisedFormmatted + '</strong></div></div></li>';

                $('.js--company-top-list ul').append(topCompanyHtml);
              });
            }
          },
          error: function (response) {
            console.log('getTopCompanies error: ' + response.errorResponse.message);
          }
        }
      }); 
    };

    // EXPANDABLE DONOR ROLL
    $('.js--honor-roll-expander').on('click', function(e) {
        if ($(this).children('i').hasClass('fa-chevron-down')) {
            $(this).children('i').removeClass('fa-chevron-down');
            $(this).children('i').addClass('fa-chevron-up');
        } else {
            $(this).children('i').removeClass('fa-chevron-up');
            $(this).children('i').addClass('fa-chevron-down');
        }

        // In order for the animation to work we need an absolute
        // height value, so we calculate that by getting the total
        // height of the donations-container child divs plus their
        // margin value
        var totalHeight = 205;
        $('.donations-container div').each(function(i, div) {
            if (i > 4) {
                totalHeight += ($(div).height() + 20);
            }
        });

        if ($('.donations-container').height() == 205) {
            $('.donations-container').animate({height: totalHeight}, 400);
        } else {
            $('.donations-container').animate({height: 205}, 400);
        }
      $('.hidden-donor-row').toggleClass('d-none');

    });

    cd.reorderPageForMobile = function () {
        // Reorganize page for mobile views
        if (screenWidth <= 767) {
            $('.tr-page-info').insertAfter('.sidebar-hero');
            $('.fundraising-amounts').prepend($('.fundraising-amounts .col-12'));

            if ($('body').is('.pg_team')) {
                $('.team-roster').insertBefore($('.donor-roll'));

                $('.team-roster li .raised span').each(function(i, span) {
                    if ($(this).parent().prev('.donor-name').find('span.coach').length !== 0) {
                        $(this).insertAfter($(this).parent().prev('.donor-name').children('.coach'));
                    } else {
                        $(this).insertAfter($(this).parent().prev('.donor-name').children('a'));
                    }
                });

                $('.team-roster form .btn').html($('.team-roster form .btn i'));
            }

            if ($('body').is('.pg_company')) {
             
                $('.team-roster form .btn').html('<i class="fas fa-search"></i>');
                $('#participant-roster td:nth-child(3) a').html('Donate');
            }
        }
    };

    cd.initializeTeamRosterTable = function() {
        window.cdTeamRosterTable = $('#team-roster').DataTable({
          "paging":   false,
          "autoWidth": false,
          "order": [[ 1, 'desc' ]],
          "language": {
            "search": "Search for a Team"
          }
        });
        $('#team-roster_info, #team-roster_filter').wrapAll('<div class="row"></div>');
        $('#team-roster_info').insertBefore($('#team-roster_filter')).wrap('<div class="col-lg-6 col-md-12 sorter d-flex align-items-end"></div>');
        $('#team-roster_filter').wrap('<div class="col-lg-6 col-md-12"></div>');

        $('#team-roster_filter input[type="search"]').attr('id', 'team_search').wrap('<div class="input-group"></div>').addClass('form-control').after('<div class="input-group-append"><button class="btn btn-primary btn-outline-secondary" type="button">Search <i class="fas fa-search"></i></button></div>');

        $('#team-roster_filter label').attr('for', 'team_search');
    
    };

    cd.initializeParticipantRosterTable = function() {
        window.cdParticipantRosterTable = $('#participant-roster').DataTable({
          "paging":   false,
          "autoWidth": false,
          "order": [[ 2, 'desc' ]],
          "language": {
            "search": "Search for a Walker"
          }
        });

        $('#participant-roster_info, #participant-roster_filter').wrapAll('<div class="row"></div>');
        $('#participant-roster_info').insertBefore($('#participant-roster_filter')).wrap('<div class="col-lg-6 col-md-12 sorter d-flex align-items-end"></div>');
        $('#participant-roster_filter').wrap('<div class="col-lg-6 col-md-12"></div>');

        $('#participant-roster_filter input[type="search"]').attr('id', 'participant_search').wrap('<div class="input-group"></div>').addClass('form-control').after('<div class="input-group-append"><button class="btn btn-primary btn-outline-secondary" type="button">Search <i class="fas fa-search"></i></button></div>');

        $('#participant-roster_filter label').attr('for', 'participant_search');

    };

    cd.getTeamHonorRoll = function() {
        // populate donor honor roll
        if($('.team-honor-list-row').length > 0){
            $('.team-honor-list-row').each(function(i, donor){
                var donorName = $(this).find('.team-honor-list-name').text();
                var donorAmt = $(this).find('.team-honor-list-value').text();
                // console.log('donorName donorAmt', donorName + ' ' + donorAmt);
                $('.js--donor-roll').append('<div class="donor-row ' + (i > 4 ? 'hidden-donor-row d-none' : '') + '"><span class="name">' + donorName + '</span><span class="amount">' + donorAmt + '</span></div>');
                if(i === 5){
                    $('.js--honor-roll-expander').addClass('d-block').removeClass('hidden');
                }
            });
        }
    };

    cd.convertNumberToDollarAmount = function(number) {
        return (number + '').replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');
    };

    cd.setDonorRollHeight = function() {
        $('.donations-container div').each(function(i, div) {
            if (i > 4) {
                $('.donations-container').css('height', '205px');
            }
        });
    };
    if ($('body').is('.app_id_26') || $('body').is('.app_id_27')) {
      if($('.sponsor_slider .local_sponsors').length > 0){
        $('.sponsor_slider .local_sponsors').unslider({
          selectors: {
            container: 'div.tr_sponsorship_logos',
            slides: 'div.tr_sponsorship_logo'
          },
          autoplay: true
        });
      }

    }
    if ($('body').is('.pg_entry')) {
      // Greeting Page
        // populate greeting page content
        $('.js--greeting-text').html($('#fr_html_container').html());

        if(publicEventType === "Multi-Event"){
          // populate multi-event 
          var multiEventPageId = (isProd === true ? '3571' : '1110');

          var multiEventApiRequest = "TR?fr_id=" + evID + "&pg=informational&sid=" + multiEventPageId + " #page_body_container";

          $('.js--multi-event-locations').load(multiEventApiRequest);
        }
        

        // Event info section mobile expand/collapse functionality
        $('.event-info-expand').click(function() {
            $(this).children('.event-info-collapse').toggleClass('d-sm-none');
            var icon = $(this).children('h3').children('span').children('i');

            if ($(icon).hasClass('fa-plus')) {
                $(icon).removeClass('fa-plus').addClass('fa-minus');
            } else {
                $(icon).removeClass('fa-minus').addClass('fa-plus');
            }
        });

        // Update placeholder text in mobile for top walker search
        if(screenWidth <= 1065) {
            $('#walkerFirstName').attr('placeholder', 'First Name');
            $('#walkerLastName').attr('placeholder', 'Last Name');
        }

        // Launch thermometer
        var progress = $('#progress-amount').text();
        var goal = $('#goal-amount').text();
        cd.runThermometer(progress, goal);
            // Build roster on greeting page
            cd.getTopParticipants(evID);
            cd.getTopTeams(evID);
            cd.getTopCompanies(evID);

        // Walker Search
        $('.js--greeting-walker-search-form').on('submit', function (e) {
          e.preventDefault();
          var firstName = encodeURIComponent($('#walkerFirstName').val());
          var lastName = encodeURIComponent($('#walkerLastName').val());
          window.location.href = luminateExtend.global.path.secure + 'SPageServer/?pagename=HeartWalk_Search&search_type=walker&cross_event=false&fr_id=' + evID + (firstName ? '&first_name=' + firstName : '') +
          (lastName ? '&last_name=' + lastName : '');
        });

        // Team Search
        $('.js--greeting-team-search-form').on('submit', function (e) {
          e.preventDefault();
          var teamName = encodeURIComponent($('#teamName').val());
          cd.getTeams(teamName, null, (isCrossEventSearch === "true" ? true : false));
          window.location.href = luminateExtend.global.path.secure + 'SPageServer/?pagename=HeartWalk_Search&search_type=team&cross_event=false&fr_id=' + evID + '&team_name=' + teamName;
        });
    }

    if($('.tr_sponsorship_logos').length > 0){
      jQuery('.tr_sponsorship_logos a').on('click', function(e){
        e.preventDefault();
        var sponsorUrl = jQuery(this).attr('href');
          if (confirm("These are proud sponsors of the American Heart Association's Heart Walk. By clicking on this link, you will be taken outside American Heart Association and this is not an endorsement of either the linked-to entity or any product or service.")) {
            window.location.href = sponsorUrl;
          } 
      });
    }

    if ($('body').is('.pg_personal')) {
      // Personal Page
        var progress = $('#progress-amount').text();
        var goal = $('#goal-amount').text();
        cd.runThermometer(progress, goal);
        cd.reorderPageForMobile();
        cd.setDonorRollHeight();

        // populate custom personal page content
        $('.js--personal-text').html($('#fr_rich_text_container').html());

        // populate donor honor roll
        cd.getTeamHonorRoll();


        // Build personal donation form
        cd.getDonationFormInfo = function(options) {
          luminateExtend.api({
            api: 'donation', 
            requestType: 'POST', 
            data: 'method=getDonationFormInfo&fr_id=' + evID + '&form_id=' + dfID, 
            requiresAuth: true, 
            callback: {
              success: function(response) {
                  var i = 0,
                  donationLevels = luminateExtend.utils.ensureArray(response.getDonationFormInfoResponse.donationLevels.donationLevel);

                  $.each(donationLevels, function(i){
                    var userSpecified = this.userSpecified,
                    amountFormatted = this.amount.formatted.replace('.00',''),
                    levelID = this.level_id;

                    i++;

                    if(userSpecified == 'false'){
                      // build pre-defined giving levels
                      $('.donation-amounts').append('<label class="form-check-label donation-amount-btn btn mb-3" for="personalDonAmt' + i + '" data-level-id="' + levelID + '"> <input class="form-check-input" type="radio" name="personalDonAmt" id="personalDonAmt' + i + '" value="' + levelID + '"> ' + amountFormatted + '</label>');                      
                    } else {
                      // build user-specified level
                      $('.donation-amounts').append('<div class="custom-amount"> <input class="form-check-input sr-only" type="radio" name="personalDonAmt" id="personalDonAmt' + i + '" value="' + levelID + '"> <label class="js--don-amt-other sr-only" for="personalDonAmt' + i + '" data-level-id="' + levelID + '">Enter your own amount</label> <label class="form-label d-inline-block" for="personalOtherAmt">Custom Amount:</label><br/> <input type="text" id="personalOtherAmt" class="form-control d-inline-block js--personal-amt-other"/> </div>');                     
                    }
                  });


                      $('.js--personal-don-form').removeClass('hidden');
                      var defaultDonUrl = $('.js--personal-don-submit').data('don-url');
                      var finalDonUrl = null;
                      $('.js--personal-don-submit').attr('data-final-don-url', defaultDonUrl);

                      // define donation widget button behavior
                      $('.js--personal-don-form label').on('click', function(){
                        $('.js--personal-amt-other').val('');
                        $('.js--personal-don-form .donation-amount-btn').removeClass('active');
                        $('.paymentSelType').addClass('hidden');
                        $(this).addClass('active');
                        $('.js--don-amt').text($(this).text());
                        finalDonUrl = defaultDonUrl + '&set.DonationLevel=' + $(this).data('level-id');
                        $('.js--personal-don-submit').attr('data-final-don-url', finalDonUrl);

                     });
                  
                      // format "other" amount before submitting to native donation form
                      // $('.js--personal-amt-other').on('blur', function(e){
                      //   var keyCode = (e.keyCode ? e.keyCode : e.which);
                      //   if (keyCode !== 9) {
                      //   var customAmt = parseInt($(this).val()) * 10;

                      //   finalDonUrl = defaultDonUrl + '&set.DonationLevel=' + $('.js--don-amt-other').data('level-id') + (isNaN(customAmt) === true ? '' : '&set.Value=' + customAmt);

                      //   if($(this).val()){
                      //     $('.js--don-amt').text('$' + $(this).val());
                      //   } else if($('.custom-amount .form-check-input').is(':checked') === true) {
                      //     $('.js--don-amt').text('');
                      //   }
                      //   console.log('final url BLUR: ', finalDonUrl);
                      // } 
                      // });

                      $('.js--personal-amt-other').on('keyup', function(e){
                        var keyCode = (e.keyCode ? e.keyCode : e.which);
                        console.log('keyCode: ', keyCode);
                        $('.paymentSelType').addClass('hidden');
                        if (keyCode != 9) {
                          $('.js--personal-don-form .donation-amount-btn').removeClass('active');
                          $('.custom-amount input[name="personalDonAmt"]').prop('checked', true);
                          if($(this).val()){
                            $('.js--don-amt').text('$' + $(this).val());
                          } else {
                            $('.js--don-amt').text('');
                          }
                          var customAmt = parseInt($(this).val()) * 100;
  
                          finalDonUrl = defaultDonUrl + '&set.DonationLevel=' + $('.js--don-amt-other').data('level-id') + (isNaN(customAmt) === true ? '' : '&set.Value=' + customAmt);
                          $('.js--personal-don-submit').attr('data-final-don-url', finalDonUrl);
                        }
                      });

                      // Set default donation amount
                      $('input[name="personalDonAmt"]').eq(0).click().prop('checked', true).closest('.donation-amount-btn').addClass('active');
                      $('.js--don-amt').text($('.form-check-label').eq(0).text().trim());

                      // redirect is now managed in amazonpay.js
                      // $('.js--personal-don-form').on('submit', function(e){
                      //   e.preventDefault();
                      //   // redirect to personal donation form with preselected amount
                      //   window.location.href = finalDonUrl;
                      // });

              }, 
              error: function(response) {
                  // $('.field-error-text').text(response.errorResponse.message);
                  // $('.ErrorContainer').removeClass('hidden');
              }
            }
          });
        };
        cd.getDonationFormInfo();
    }

    if ($('body').is('.pg_team')) {
      // Team Page
        var progress = $('#progress-amount').text();
        var goal = $('#goal-amount').text();
        cd.runThermometer(progress, goal);
        cd.setDonorRollHeight();
        cd.reorderPageForMobile();

        // populate custom team page content		
        $('.js--team-text').html($('#fr_rich_text_container').html());		
        // populate donor honor roll		
        cd.getTeamHonorRoll();

      // build team roster
        cd.getTeamRoster = function () {
          var teamId = getURLParameter(currentUrl, 'team_id');
          luminateExtend.api({
            api: 'teamraiser',
            data: 'method=getParticipants' +
              '&first_name=%25%25%25&fr_id=' + evID +
              '&list_filter_column=reg.team_id' +
              '&list_filter_text=' + teamId +
              '&list_page_size=499' +
              '&list_page_offset=0' +
              '&response_format=json' +
              '&list_sort_column=first_name' +
              '&list_ascending=true',
            callback: {
              success: function (response) {
                if (response.getParticipantsResponse.totalNumberResults === '0') {
                  // no search results
        
                } else {
                  var participants = luminateExtend.utils.ensureArray(response.getParticipantsResponse.participant);
                  var totalParticipants = parseInt(response.getParticipantsResponse.totalNumberResults);
        
                  // if ( $.fn.DataTable ) {
                  //   if ( $.fn.DataTable.isDataTable('#participantResultsTable') ) {
                  //     $('#participantResultsTable').DataTable().destroy();
                  //   }              }
                  // $('#participantResultsTable tbody').empty();
        
                  // $('.js--num-participant-results').text((totalParticipants === 1 ? '1 Result' : totalParticipants + ' Results'));
        
                  $(participants).each(function (i, participant) {
        
                    var participantRaised = (parseInt(participant.amountRaised) * 0.01);
                    var participantRaisedFormmatted = participantRaised.toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,");
        
                    $('#team-roster tbody').append('<tr class="' + (i > 4 ? 'd-none' : '') + '"><td class="donor-name"><a href="' + participant.personalPageUrl + '">' +
                      participant.name.first + ' ' + participant.name.last +
                      '</a>' + (participant.aTeamCaptain === "true" ? ' <span class="coach">- Coach</span>' : '') + '</td><td class="raised" data-sort="' + participantRaisedFormmatted + '"><span><strong>$' + participantRaisedFormmatted + '</strong></span></td><td><a href="' + participant.donationUrl + '">' + (screenWidth <= 480 ? 'Donate' : 'Donate to ' + participant.name.first) + '</a></td></tr>');
                      if(participant.aTeamCaptain === 'true'){
                        $('.js--team-captain-link').attr('href', participant.personalPageUrl).text(participant.name.first + ' ' + participant.name.last);
                      }
                  });
        
                  if(totalParticipants > 5) {
                    $('.js--more-participant-results').removeAttr('hidden');
                  }
                  cd.initializeTeamRosterTable();

                  // $('#team-roster').DataTable({
                  //   "info":     false,
                  //   "autoWidth": false
                  // });

                  // $('.dataTables_length').addClass('bs-select');
                  // $('.js--participant-results-container').removeAttr('hidden');
                  //add call to hook donate button with payment type selections
                  addPaymentTypesOnSearch();
                  $('.js--more-participant-results').on('click', function(e){
                    e.preventDefault();
                    $('#team-roster tr').removeClass('d-none');
                    $(this).attr('hidden', true);
                  });
                }
              }
            },
            error: function (response) {
              $('#error-participant').removeAttr('hidden').text(response.errorResponse.message);
              console.log('error response: ', response);
            }
          });
        };
        cd.getTeamRoster();

    }

    if ($('body').is('.pg_company')) {
      // Company Page

        // Populate company name from page title
        var pageTitle = jQuery('head title').text().trim();
        var start_pos = pageTitle.indexOf(':') + 1;
        var end_pos = pageTitle.indexOf('-',start_pos);
        var companyName = pageTitle.substring(start_pos,end_pos).trim();
        $('.js--company-name').text(companyName);

        // Populate total raised
        var raised = $('.company-tally-container--amount .company-tally-ammount').text();
        if (raised) {
            $('#progress-amount').html(raised);
        }

        // Get company goal
        $('.indicator-title:contains("Company Fundraising")').closest('.tr-status-indicator-container').addClass('default-company-thermometer');
        var companyoGoalText = $('.default-company-thermometer .total-goal-value').text();
        var companyGoal = companyoGoalText.split('.');
        $('#goal-amount').html(companyGoal[0]);

        // populate custom personal page content
        $('.js--company-text').html($('#fr_rich_text_container').html());

        var progress = $('#progress-amount').text();
        var goal = $('#goal-amount').text();
        cd.runThermometer(progress, goal);
        cd.reorderPageForMobile();


        // Reset selected sort option
        $('.nav-tabs .nav-link').click(function() {
            $('.selected-sort-option').html('Amount Raised');
        });

        // Build company team roster
         // build team roster
  var companyId = getURLParameter(currentUrl, 'company_id');

  console.log('companyId: ', companyId);
 cd.getCompanyTeams = function () {
  luminateExtend.api({
    api: 'teamraiser',
    data: 'method=getTeamsByInfo' +
      '&team_name=%25%25%25' + 
      '&fr_id=' + evID +
      '&team_company_id=' + companyId +
      '&list_page_size=499' +
      '&list_page_offset=0' +
      '&response_format=json' +
      '&list_sort_column=team_name' +
      '&list_ascending=true',
    callback: {
      success: function (response) {
        if (response.getTeamSearchByInfoResponse.totalNumberResults === '0') {
          // no search results

        } else {
          var teams = luminateExtend.utils.ensureArray(response.getTeamSearchByInfoResponse.team);
          var totalTeams = parseInt(response.getTeamSearchByInfoResponse.totalNumberResults);
          var totalTeamsText = totalTeams > 1 ? ' Teams' : ' Team';
          $('.js--num-company-teams').text(totalTeams + totalTeamsText);

          $(teams).each(function (i, team) {
            var companyName = team.companyName;
            var teamRaised = (parseInt(team.amountRaised) * 0.01);
            var teamRaisedFormmatted = teamRaised.toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,");

            $('#team-roster tbody').append('<tr class="' + (i > 4 ? 'd-none' : '') + '"> <td class="donor-name"> <a href="' + team.teamPageURL + '" data-sort="' + team.name + '">' + team.name + '</a> </td><td class="donor-name"> <a href="TR/?px=' + team.captainConsId + '&pg=personal&fr_id=' + team.EventId + '" data-sort="' + team.captainFirstName + ' ' + team.captainLastName + '">' + team.captainFirstName + ' ' + team.captainLastName + '</a> </td><td class="raised" data-sort="' + teamRaisedFormmatted + '"> <span><strong>$' + teamRaisedFormmatted + '</strong></span> </td><td> <a href="' + team.joinTeamURL + '">' + (screenWidth <= 480 ? 'Join' : 'Join Team') + '</a> </td></tr>');
          });
          
          console.log('totalTeams: ', totalTeams);
          if(totalTeams > 5) {
            $('.js--more-team-results').removeAttr('hidden');
          }
          cd.initializeTeamRosterTable();

          $('.js--more-team-results').on('click', function(e){
            e.preventDefault();
            $('#team-roster tr').removeClass('d-none');
            $(this).attr('hidden', true);
          });
        }
      }
    },
    error: function (response) {
      $('#error-participant').removeAttr('hidden').text(response.errorResponse.message);
      console.log('error response: ', response);
    }
  });
};
cd.getCompanyTeams();


 // build team roster
 cd.getCompanyParticipants = function () {
  $('#participant-roster tbody').html('');
  luminateExtend.api({
    api: 'teamraiser',
    data: 'method=getParticipants' +
      '&team_name=%25%25%25&fr_id=' + evID +
      '&list_filter_column=team.company_id' +
      '&list_filter_text=' + companyId +
      '&list_page_size=499' +
      '&list_page_offset=0' +
      '&response_format=json',
    callback: {
      success: function (response) {
        if (response.getParticipantsResponse.totalNumberResults === '0') {
          // no search results

        } else {
          var participants = luminateExtend.utils.ensureArray(response.getParticipantsResponse.participant);
          var totalParticipants = parseInt(response.getParticipantsResponse.totalNumberResults);
          var totalParticipantsText = totalParticipants > 1 ? ' Walkers' : ' Walker';
          $('.js--num-company-participants').text(totalParticipants + totalParticipantsText);

          $(participants).each(function (i, participant) {

            var participantRaised = (parseInt(participant.amountRaised) * 0.01);
            var participantRaisedFormmatted = participantRaised.toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,");

            $('#participant-roster tbody').append('<tr class="' + (i > 4 ? 'd-none' : '') + '"><td class="donor-name"><a href="' + participant.personalPageUrl + '">' +
              participant.name.first + ' ' + participant.name.last +
              '</a>' + (participant.aparticipantCaptain === "true" ? ' <span class="coach">- Coach</span>' : '') + '</td><td class="raised" data-sort="' + participantRaisedFormmatted + '"><span><strong>$' + participantRaisedFormmatted + '</strong></span></td><td><a href="' + participant.donationUrl + '">' + (screenWidth <= 480 ? 'Donate' : 'Donate to ' + participant.name.first) + '</a></td></tr>');
          });

          if (totalParticipants > 5) {
            $('.js--more-participant-results').removeAttr('hidden');
          }
          cd.initializeParticipantRosterTable();
          //add call to hook donate button with payment type selections
          addPaymentTypesOnSearch();
          $('.js--more-participant-results').on('click', function (e) {
            e.preventDefault();
            $('#participant-roster tr').removeClass('d-none');
            $(this).attr('hidden', true);
          });
        }
      }
    },
    error: function (response) {
      $('#error-participant').removeAttr('hidden').text(response.errorResponse.message);
      console.log('error response: ', response);
    }
  });
};
cd.getCompanyParticipants();


    }

    if ($('body').is('.pg_informational')) {
      // Custom TR Page
    }
    if ($('body').is('.pg_HeartWalk_Search')) {
      // HeartWalk Search Page
      var clearSearchResults = function(){
        $('.js--event-results-container, .alert').attr('hidden', true);
        $('.js--event-results-rows').html('');
        $('.js--participant-results-container, .alert').attr('hidden', true);
        $('.js--participants-results-rows').html('');
        $('.js--team-results-container, .alert').attr('hidden', true);
        $('.js--team-results-rows').html('');
      }

    // Search by Event
    $('.js--zip-search-form').on('submit', function (e) {
      e.preventDefault();
      clearSearchResults();
      var zipSearched = encodeURIComponent($('#zipCodeSearch').val());
      cd.getEventsByDistance(zipSearched);
    });

    // Search page by Participant
    $('.js--walker-search-form').on('submit', function (e) {
      e.preventDefault();
      clearSearchResults();
      var firstName = encodeURIComponent($('#walkerFirstName').val());
      var lastName = encodeURIComponent($('#walkerLastName').val());

      cd.getParticipants(firstName, lastName, (isCrossEventSearch === "true" ? true : false));
    });

    // Search by Team
    $('.js--team-search-form').on('submit', function (e) {
      e.preventDefault();
      clearSearchResults();
      var teamName = encodeURIComponent($('#teamNameSearch').val());
      cd.getTeams(teamName, null, (isCrossEventSearch === "true" ? true : false));
    });


    if(searchType){
      cd.autoSearchParticipant = function () {
        var firstNameVal = getURLParameter(currentUrl, 'first_name') ? getURLParameter(currentUrl, 'first_name') : '';
        var lastNameVal = getURLParameter(currentUrl, 'last_name') ? getURLParameter(currentUrl, 'last_name') : '';

        console.log('firstNameVal: ', firstNameVal);
        console.log('lastNameVal: ', lastNameVal);


        if(!firstNameVal && !lastNameVal){
          // General participant search from greeting page. Show all walkers
          console.log('run general search for all walkers');
          cd.getParticipants('%25%25%25', '%25%25%25', (isCrossEventSearch === "true" ? true : false));
        } else {
          firstNameVal = decodeURIComponent(firstNameVal);
          lastNameVal = decodeURIComponent(lastNameVal);

          $('#walkerFirstName').val(firstNameVal);
          $('#walkerLastName').val(lastNameVal);
  
          cd.getParticipants(firstNameVal, lastNameVal, (isCrossEventSearch === "true" ? true : false));
        }

      }

      cd.autoSearchTeam = function () {
        var teamName = getURLParameter(currentUrl, 'team_name') ? getURLParameter(currentUrl, 'team_name') : '';
        teamName = decodeURIComponent(teamName);
        $('#teamNameSearch').val(teamName);

        cd.getTeams(teamName, null, (isCrossEventSearch === "true" ? true : false));
      }

      cd.autoSearchEvents = function () {
        var searchZip = getURLParameter(currentUrl, 'zip') ? getURLParameter(currentUrl, 'zip') : '';
        $('#zipCodeSearch').val(searchZip);

        cd.getEventsByDistance(searchZip);
      }

      if(searchType === 'event'){
        cd.autoSearchEvents();
      } else if(searchType === 'walker'){
        cd.autoSearchParticipant();
        // Switch to walker tab
        $('#searchWalkerTab').tab('show');
      } else if(searchType === 'team'){
        cd.autoSearchTeam();
        // Switch to team tab
        $('#searchTeamTab').tab('show');
      }
    }
    }
  });
}(jQuery));

var cdSortByColumnNumber = 1;
var cdSortByText = 'Amount Raised';
var direction = 'desc';

var cdSortRoster = function (element, isParticipantRoster) {
    var roster = isParticipantRoster ? cdParticipantRosterTable : cdTeamRosterTable;
    direction = roster.order()[0][1] === 'desc' ? 'asc' : 'desc';
    roster.order([cdSortByColumnNumber, direction]).draw();
    $('.selected-sort-option').html(cdSortByText);
    setIconDirection(element);
};

var cdSetSortBy = function (columnNumber, element, isParticipantRoster) {
    cdSortByColumnNumber = columnNumber;
    cdSortByText = $(element).text();
    var sortIconElement = $(element).parent().prev('.selected-sort-option');
    direction = 'desc';
    setIconDirection(element);
    cdSortRoster(sortIconElement, isParticipantRoster ? isParticipantRoster : false);
};

var setIconDirection = function (element) {
    var icon = $(element).children('i');

    if (direction === 'asc') {
        icon.removeClass('fa-chevron-down');
        icon.addClass('fa-chevron-up');
    } else {
        icon.removeClass('fa-chevron-up');
        icon.addClass('fa-chevron-down');
    }
};

var toggleMultiEventInfo = function(elem) {
  $(elem).toggleClass('open');
  $('.js--multi-event-locations').slideToggle();

  if ($('.multi-event-info-toggler i').hasClass('fa-plus')) {
      $('.multi-event-info-toggler i').removeClass('fa-plus');
      $('.multi-event-info-toggler i').addClass('fa-minus');
  } else {
      $('.multi-event-info-toggler i').addClass('fa-plus');
      $('.multi-event-info-toggler i').removeClass('fa-minus');
  }
};