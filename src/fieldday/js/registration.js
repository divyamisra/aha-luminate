'use strict';
(function($) {
    $(document).ready(function() {

        // BEGIN LANDING PAGES
        /******************/
        /* SEARCH SCRIPTS */
        /******************/
        var eventType = 'Field%20Day';
        var eventType2 = $('body').data('event-type2') ? $('body').data('event-type2') : null;
        var regType = $('body').data('reg-type') ? $('body').data('reg-type') : null;
        var publicEventType = $('body').data('public-event-type') ? $('body').data('public-event-type') : null;
        var viewportWidth = window.innerWidth || document.documentElement.clientWidth;


        var isProd = (luminateExtend.global.tablePrefix === 'heartdev' ? false : true);
        var eventName = luminateExtend.global.eventName;
        var srcCode = luminateExtend.global.srcCode;
        var subSrcCode = luminateExtend.global.subSrcCode;
        var evID = $('body').data('fr-id') ? $('body').data('fr-id') : null;
        var consID = $('body').data('cons-id') ? $('body').data('cons-id') : null;
	var evDate = $('body').data('event-date') ? $('body').data('event-date') : null;
	var evDateYear = /(\d{4})/.test(evDate) ? RegExp.$1 : '2020';
	var coordEmail = $('input[name=coordinator_email]').val();


        var currentUrl = window.location.href;
        var searchType = getURLParameter(currentUrl, 'search_type');

        cd.getParticipants = function (firstName, lastName, searchAllEvents) {
          luminateExtend.api({
            api: 'teamraiser',
            data: 'method=getParticipants' +
              '&first_name=' + ((firstName !== undefined) ? firstName : '') +
              '&last_name=' + ((lastName !== undefined) ? lastName : '') +
              (searchAllEvents === true ? '&event_type=' + eventType : '&fr_id=' + evID) +
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

                  if ($.fn.DataTable) {
                    if ($.fn.DataTable.isDataTable('#participantResultsTable')) {
                      $('#participantResultsTable').DataTable().destroy();
                    }
                  }
                  $('#participantResultsTable tbody').empty();

                  $('.js__num-participant-results').text((totalParticipants === 1 ? '1 Result' : totalParticipants + ' Results'));

                  $(participants).each(function (i, participant) {

                    $('.js__participants-results-rows').append('<tr' + (i > 10 ? ' class="d-none"' : '') + '><td><a href="' + participant.personalPageUrl + '">' +
                      participant.name.first + ' ' + participant.name.last +
                      '</a></td><td>' +
                      ((participant.teamName !== null && participant.teamName !== undefined) ? '<a href="' + participant.teamPageUrl + '">' + participant.teamName + '</a>' : '') + '</td><td><a href="TR/?fr_id=' + participant.eventId + '&pg=entry">' +
                      participant.eventName + '</a></td><td class="col-cta"><a href="' + participant.donationUrl + '" aria-label="Donate to ' + participant.name.first + ' ' + participant.name.last + '" class="btn btn-rounded btn-primary btn-block">Donate</a></td></tr>');

                  });
                  if (totalParticipants > 10) {
                    $('.js__more-participant-results').removeAttr('hidden');
                  }

                  $('#participantResultsTable').DataTable({
                    "paging": false,
                    "searching": false,
                    "info": false,
                    "autoWidth": false
                  });
                  $('.dataTables_length').addClass('bs-select');
                  //add call to hook donate button with payment type selections
                  addPaymentTypesOnSearch();
                  $('.js__participant-results-container').removeAttr('hidden');

                  $('.js__more-participant-results').on('click', function (e) {
                    e.preventDefault();
                    $('.js__participants-results-rows tr').removeClass('d-none');
                    $(this).attr('hidden', true);
                    $('.js__end-participant-list').removeAttr('hidden');
                  });


                }
              },
              error: function (response) {
                $('#error-participant').removeAttr('hidden').text(response.errorResponse.message);

              }
            }
          });
        };

        cd.getTeams = function (teamName, searchType, isCrossEvent, firstName, lastName, companyId) {
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

                if ($.fn.DataTable) {
                  if ($.fn.DataTable.isDataTable('#teamResultsTable')) {
                    $('#teamResultsTable').DataTable().destroy();
                  }
                }
                $('#teamResultsTable tbody').empty();

                if (response.getTeamSearchByInfoResponse.totalNumberResults === '0') {
                  // no search results
                  $('#error-team').removeAttr('hidden').text('Team not found. Please try different search terms.');
                  $('.js__error-team-search').show();
                } else {
                  var teams = luminateExtend.utils.ensureArray(response.getTeamSearchByInfoResponse.team);

                  $(teams).each(function (i, team) {
                    if (searchType === 'registration') {

                      console.log('search type is reg. Team max size:' + team.maxTeamSize + ' and team members: ' + team.numMembers);
                      console.log(team.maxTeamSize + ' > ' + team.numMembers);

		      if (parseInt(team.maxTeamSize) > parseInt(team.numMembers)) {
	                      $('.list').append(
        	                '<div class="search-result-details row py-3"><div class="col-md-5"><strong><a href="' + team.teamPageURL + '" class="team-name-label" title="' + team.name + '" target=_blank><span class="team-company-label sr-only">Team Name:</span> ' + team.name + '</a></strong><br><span class="team-captain-label">Coach:</span> <span class="team-captain-name">' + team.captainFirstName + ' ' + team.captainLastName + '</span></div><div class="col-md-5 mt-auto">' + ((team.companyName !== null && team.companyName !== undefined) ? '<span class="team-company-label">Company:</span> <span class="team-company-name">' + team.companyName + '</span>' : '') + '</div><div class="col-md-2"><a href="' + luminateExtend.global.path.secure + 'TRR/?fr_tjoin=' + team.id + '&pg=tfind&fr_id=' + evID + '&s_captainConsId=' + team.captainConsId + '&s_regType=joinTeam&skip_login_page=true&s_teamName=' + team.name + '&s_teamGoal=' + (parseInt(team.goal)/100) + '&s_teamCaptain=' + team.captainFirstName + ' ' + team.captainLastName + '" title="Join ' + team.name + '" aria-label="Join ' + team.name + '" class="btn btn-block btn-primary button team-join-btn">Join</a></div></div>');
		      } else {
	                      $('.list').append(
        	                '<div class="search-result-details row py-3"><div class="col-md-5"><strong><a href="' + team.teamPageURL + '" class="team-name-label" title="' + team.name + '" target=_blank><span class="team-company-label sr-only">Team Name:</span> ' + team.name + '</a></strong><br><span class="team-captain-label">Coach:</span> <span class="team-captain-name">' + team.captainFirstName + ' ' + team.captainLastName + '</span></div><div class="col-md-5 mt-auto">' + ((team.companyName !== null && team.companyName !== undefined) ? '<span class="team-company-label">Company:</span> <span class="team-company-name">' + team.companyName + '</span>' : '') + '</div><div class="col-md-2 text-center"><br/>Team is full</div></div>');
		      }
                      $('.js__search-results-container').slideDown();
                      // $('.js__search-results-container').show();

                    } else {
                      $('.js__team-results-rows')
                        .append('<tr' + (i > 10 ? ' class="d-none"' : '') + '><td><a href="' + team.teamPageURL + '">' +
                          team.name + '</a></td><td><a href="TR/?px=' + team.captainConsId + '&pg=personal&fr_id=' + team.EventId + '">' + team.captainFirstName + ' ' + team.captainLastName + '</a></td><td>' +
                          ((team.companyName !== null && team.companyName !== undefined) ? '<a href="TR?company_id=' + team.companyId + '&fr_id=' + team.EventId + '&pg=company">' + team.companyName + '</a>' : '') +
                          '</td><td><a href="TR/?fr_id=' + team.EventId + '&pg=entry">' + team.eventName + '</a></td><td class="col-cta"><a href="' + team.teamDonateURL + '" class="btn btn-rounded btn-primary btn-block" title="Donate to ' + team.name + '" aria-label="Donate to ' + team.name + '">Donate</a></td></tr>');
                    }
                  });

                  if (searchType === 'registration') {
                    var options = {
                      valueNames: [
                        'team-name-label',
                        'team-captain-name',
                        'team-company-name'
                      ]
                    };
                    var teamsList = new List('custom_team_find', options);

                    if ($('.team-company-name').length > 0) {
                      $('.js__company-sort').show();
                    }

                  } else {
                    var totalTeams = parseInt(response.getTeamSearchByInfoResponse.totalNumberResults);

                    $('.js__num-team-results').text((totalTeams === 1 ? '1 Result' : totalTeams + ' Results'));

                    if (totalTeams > 10) {
                      $('.js__more-team-results').removeAttr('hidden');
                    }

                    $('.js__team-results-container').removeAttr('hidden');

                    $('.js__more-team-results').on('click', function (e) {
                      e.preventDefault();
                      $('.js__team-results-rows tr').removeClass('d-none');
                      $(this).attr('hidden', true);
                      $('.js__end-team-list').removeAttr('hidden');
                    });
                    $('#teamResultsTable').DataTable({
                      "paging": false,
                      "searching": false,
                      "info": false
                    });
                    $('.dataTables_length').addClass('bs-select');

                    $('.js__team-results-container').removeAttr('hidden');
                    //add call to hook donate button with payment type selections
                    addPaymentTypesOnSearch();
                  }
                }
              },
              error: function (response) {
                $('#error-team').removeAttr('hidden').text(response.errorResponse.message);

                $('.js__search-results').show();
                $('.js__search-results-container').show();
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

                  if ($.fn.DataTable) {
                    if ($.fn.DataTable.isDataTable('#companyResultsTable')) {
                      $('#companyResultsTable').DataTable().destroy();
                    }
                  }
                  $('#companyResultsTable tbody').empty();

                  $('.js__num-company-results').text((totalCompanies === 1 ? '1 Result' : totalCompanies + ' Results'));

                  $(companies).each(function (i, company) {
                    $('.js__company-results-rows').append('<tr' + (i > 10 ? ' class="d-none"' : '') + '><td><a href="' + company.companyURL + '">' +
                      company.companyName + '</a></td><td class="col-cta"><a href="' + company.companyURL + '" aria-label="Visit page for ' + company.companyName + '" class="btn btn-rounded btn-primary btn-block">View</a></td></tr>');
                  });

                  if (totalCompanies > 10) {
                    $('.js__more-company-results').removeAttr('hidden');
                  }

                  $('.js__company-results-container').removeAttr('hidden');

                  $('.js__more-company-results').on('click', function (e) {
                    e.preventDefault();
                    $('.js__company-results-rows tr').removeClass('d-none');
                    $(this).attr('hidden', true);
                    $('.js__end-company-list').removeAttr('hidden');
                  });

                  $('#companyResultsTable').DataTable({
                    "paging": false,
                    "searching": false,
                    "info": false,
                    "columns": [{
                        "width": "80%"
                      },
                      null
                    ]
                  });
                  $('.dataTables_length').addClass('bs-select');

                  $('.js__company-results-container').removeAttr('hidden');
                }
              },
              error: function (response) {
                $('.js__company-results-container').removeAttr('hidden').text(response.errorResponse.message);

              }
            }
          });
        };

        // Field Day 2020 Registration JS
        var fr_id = $('input[name=fr_id]').val();

        if (fr_id == 3476) {
            jQuery('#fr_goal').val('$625');
            jQuery('#suggested_goal_container').html("Suggested Goal: $625.00<br>In honor of our 25th anniversary, we invite you to set a goal of $625. That's 25 donations of $25!");
        }

        if ($('#user_type_page').length > 0) {
            $('.custom-progress-bar').hide();

            //remove aria description for bad field generated by Luminate for acc
            $('[aria-describedby=loginPasswordHelpBlock]').removeAttr("aria-describedby");

            console.log('doc ready fired');
            console.log('Current Application ID: 27');
            var evID = $('#f2fSendUserNameForm input[name="fr_id"]').val();
            var evID2 = $('#F2fRegPartType input[name="fr_id"]').val();
            var evID3 = $('form[name="FriendraiserFind"] input[name="fr_id"]').val();
            console.log('evid 1 = '+evID);
            console.log('evid 2 = '+evID2);
            console.log('evid 3 = '+evID3);
            var frId = evID;
            var trLoginSourceCode = (srcCode.length ? srcCode : 'trReg');
            var trSignupSourceCode = (srcCode.length ? srcCode : 'trReg');
            var trSocialSourceCode = (srcCode.length ? srcCode : 'trReg');

            var trLoginSubSourceCode = (subSrcCode.length ? subSrcCode : eventName + '_' + evID);
            var trSignupSubSourceCode = (subSrcCode.length ? subSrcCode : eventName + '_' + evID);
            var trSocialSubSourceCode = (subSrcCode.length ? subSrcCode : eventName + '_' + evID);

            var trRegInteractionID = evID;
            var trLoginInteractionID = evID;
            var trSocialInteractionID = evID;
            var trLoggedInInteractionID = evID;

            //Uptype customization
            /*$('#user_type_page #utype-login .show-login').click(function(){
                $('#user_type_page #f2fLoginForm, #user_type_page .show-login-container-2').show();
                $('#user_type_page #f2fSendUserNameForm, #user_type_page .show-login-container, #user_type_page .error-show-login-container, #user_type_page .updated-tech').hide();
            });*/

              cd.logInteraction = function (intTypeId, intSubject, intCallback) {
                var logInteractionCallback = {
                  success: function (response) {
                    console.log('interaction logged');
                  },
                  error: function (response) {
                    console.log('Error logging interaction');
                  }
                };
                luminateExtend.api({
                  api: 'cons',
                  useHTTPS: true,
                  requestType: 'POST',
                  requiresAuth: true,
                  data: 'method=logInteraction&interaction_subject=' + intSubject + '&interaction_type_id=' + intTypeId,
                  callback: logInteractionCallback
                });
              };

              var getRegInteractionCallback = {
                success: function (data) {
                  // console.log('getRegInteraction success: ' + JSON.stringify(data));
                  var hasInteraction = data.getUserInteractionsResponse.interaction;
                  if (!hasInteraction) {
                    // Does not have trRegInteraction. Check to see if has trLoginInteraction
                    getSocialInteraction();
                  }
                },
                error: function (data) {
                  console.log('getRegInteraction error: ' + JSON.stringify(data));
                }
              };

              var getSocialInteractionCallback = {
                success: function (data) {
                  // console.log('getSocialInteraction success: ' + JSON.stringify(data));
                  var hasInteraction = data.getUserInteractionsResponse.interaction;
                  if (!hasInteraction) {
                    // Does not have trRegInteraction OR trSocialInteraction. Assign a trLoggedInInteraction
                    getLoginInteraction();
                  }
                },
                error: function (data) {
                  console.log('getSocialInteraction error: ' + JSON.stringify(data));
                }
              };

              var getLoginInteractionCallback = {
                success: function (data) {
                  // console.log('getLoginInteraction success: ' + JSON.stringify(data));
                  var hasInteraction = data.getUserInteractionsResponse.interaction;
                  if (!hasInteraction) {
                    // Does not have trRegInteraction OR trSocialInteraction OR trLoginInteraction. Assign a trLoggedInInteraction
                    cd.logInteraction(trLoggedInInteractionID, evID);
                  }
                },
                error: function (data) {
                  console.log('getLoginInteraction error: ' + JSON.stringify(data));
                }
              };

              cd.getInteraction = function (intTypeId, intSubject, intCallback) {
                luminateExtend.api({
                  api: 'cons',
                  useHTTPS: true,
                  requestType: 'POST',
                  requiresAuth: true,
                  data: 'method=getUserInteractions&interaction_subject=' + intSubject + '&interaction_type_id=' + intTypeId,
                  callback: intCallback
                });
              };

              var getRegInteraction = function () {
                cd.getInteraction(trRegInteractionID, evID, getRegInteractionCallback);
              }

              var getSocialInteraction = function () {
                cd.getInteraction(trSocialInteractionID, evID, getSocialInteractionCallback);
              }

              var getLoginInteraction = function () {
                cd.getInteraction(trLoginInteractionID, evID, getLoginInteractionCallback);
              }

              if ($('#team_find_page').length > 0) {
                // check registrants interactions and assign trLoggedInInteraction if they do not have trRegInteraction OR trSocialInteraction OR trLoginInteraction
                getRegInteraction();
              }

            cd.consLogin = function (userName, password) {
                luminateExtend.api({
                  api: 'cons',
                  form: '.js__login-form',
                  requestType: 'POST',
                  data: 'method=login&user_name=' +
                    userName +
                    '&password=' +
                    password +
                    '&source=' +
                    trLoginSourceCode +
                    '&sub_source=' +
                    trLoginSubSourceCode +
                    '&send_user_name=true',
                  useHTTPS: true,
                  requiresAuth: true,
                  callback: {
                    success: function (response) {
                      console.log(
                        'login success. show reg options to proceed to next step.'
                      );
                      cd.logInteraction(trLoginInteractionID, evID);
                      window.location = window.location.href + '&s_regType=';
                    },
                    error: function (response) {
                      if (response.errorResponse.code === '22') {
                        /* invalid email */
                        $('.js__login-error-message').html(
                          'Oops! You entered an invalid email address.'
                        );
                      } else if (response.errorResponse.code === '202') {
                        /* invalid email */
                        $('.js__login-error-message').html(
                          'You have entered an invalid username or password. Please re-enter your credentials below.'
                        );
                      } else {
                        $('.js__login-error-message').html(
                          response.errorResponse.message
                        );
                      }
                      $('.js__login-error-container').removeClass('d-none');
                    }
                  }
                });
            };

            cd.consSignup = function (userName, password, email) {
                luminateExtend.api({
                  api: 'cons',
                  form: '.js__signup-form',
                  data: 'method=create&user_name=' + userName + '&password=' + password + '&primary_email=' + email + '&source=' + trSignupSourceCode + '&sub_source=' + trSignupSubSourceCode + '&teamraiser_registration=true',
                  useHTTPS: true,
                  requestType: 'POST',
                  requiresAuth: true,
                  callback: {
                    success: function (response) {
                      console.log('signup success');
                      cd.logInteraction(trRegInteractionID, evID);
                      var domainName = window.location.hostname,
                        domainNameParts = domainName.split('.');
                      if (domainNameParts.length > 2) {
                        domainName = domainNameParts[domainNameParts.length - 2] + '.' + domainNameParts[domainNameParts.length - 1];
                      }
                      domainName = '.' + domainName;
                      document.cookie = 'gtm_tr_reg_page_success_' + evID + '=true; domain=' + domainName + '; path=/';
                      window.location = window.location.href + '&s_regType=';
                    },
                    error: function (response) {
                      console.log('signup error: ' + JSON.stringify(response));
                      if (response.errorResponse.code === '11') {
                        /* email already exists */
                        cd.consRetrieveLogin(email, false);
                        $('.js__signup-error-message').html('Oops! An account already exists with matching information. A password reset has been sent to ' + email + '.');
                      } else if (response.errorResponse.code === '22') {
                        $('.js__signup-error-message').html("One or more attributes failed validation: \"Biographical Information/User Name\" Invalid characters in User Name (valid characters are letters, digits, '-', '_', '@', '.', '%', and ':')");

                      } else {
                        $('.js__signup-error-message').html(response.errorResponse.message);
                      }
                      $('.js__signup-error-container').removeClass('d-none');
                    }
                  }
                });
            };

            cd.consRetrieveLogin = function (accountToRetrieve, displayMsg) {
                luminateExtend.api({
                  api: 'cons',
                  form: '.js__retrieve-login-form',
                  requestType: 'POST',
                  data: 'method=login&send_user_name=true&email=' + accountToRetrieve,
                  useHTTPS: true,
                  requiresAuth: true,
                  callback: {
                    success: function (response) {
                      if (displayMsg === true) {
                        console.log('account retrieval success. show log in page again.');
                        $('.js__retrieve-login-container').addClass('d-none');
                        $('.js__login-container').removeClass('d-none');
                        $('.js__login-success-message').html('A password reset has been sent to ' + accountToRetrieve + '.');

                        $('.js__login-success-container').removeClass('d-none');
                      }

                    },
                    error: function (response) {
                      if (displayMsg === true) {
                        console.log('account retrieval error: ' + JSON.stringify(response));
                        $('.js__retrieve-login-error-message').html(response.errorResponse.message);
                        $('.js__retrieve-login-error-container').removeClass('d-none');
                      }
                    }
                  }
                });
            };

            var parsleyOptions = {
                successClass: 'has-success',
                errorClass: 'has-error',
                classHandler: function (_el) {
                  return _el.$element.closest('.form-group');
                }
            };

            // add front end validation
            $('.js__login-form').parsley(parsleyOptions);
            $('.js__signup-form').parsley(parsleyOptions);
            $('.js__retrieve-login-form').parsley(parsleyOptions);

            cd.resetValidation = function () {
                $('.js__login-form').parsley().reset();
            }
            // manage form submissions
            $('.js__login-form').on('submit', function (e) {
                e.preventDefault();
                var form = $(this);
                form.parsley().validate();
                if (form.parsley().isValid()) {
                  var consUsername = $('#loginUsername').val();
                  var consPassword = $('#loginPassword').val();
                  cd.consLogin(consUsername, consPassword);
                  cd.resetValidation();
                } else {
                  $('.js__signup-error-message').html('Please fix the errors below.');
                  $('.js__signup-error-container').removeClass('d-none');
                }
            });

            $('.js__signup-form').on('submit', function (e) {
                e.preventDefault();
                var form = $(this);
                form.parsley().validate();
                if (form.parsley().isValid()) {
                  var consUsername = $('#signupUsername').val();
                  var consPassword = $('#signupPassword').val();
                  var consEmail = $('#signupEmail').val();
                  cd.consSignup(consUsername, consPassword, consEmail);
                  cd.resetValidation();
                } else {
                  $('.js__signup-error-message').html('Please fix the errors below.');
                  $('.js__signup-error-container').removeClass('d-none');
                }
            });

            $('.js__retrieve-login-form').on('submit', function (e) {
                e.preventDefault();
                var form = $(this);
                form.parsley().validate();
                if (form.parsley().isValid()) {
                  var consEmail = $('#retrieveLoginEmail').val();
                  cd.consRetrieveLogin(consEmail, true);
                  cd.resetValidation();
                } else {
                  $('.js__retrieve-login-error-message').html('Please fix the errors below.');
                  $('.js__retrieve-login-error-container').removeClass('d-none');
                }
            });

            // show login retrieval form
            $('.js__show-retrieve-login').on('click touchstart', function (e) {
                e.preventDefault();
                cd.resetValidation();
                $('.js__login-container').addClass('d-none');
                $('.js__retrieve-login-container').removeClass('d-none');
            });

            // show login form
            $('.js__show-login').on('click touchstart', function (e) {
                e.preventDefault();
                cd.resetValidation();
                $('.js__retrieve-login-container').addClass('d-none');
                $('.js__signup-container').addClass('d-none');
                $('.js__login-container').removeClass('d-none');
            });
            // show signup form
            $('.js__show-signup').on('click touchstart', function (e) {
                e.preventDefault();
                cd.resetValidation();
                $('.js__retrieve-login-container').addClass('d-none');
                $('.js__login-container').addClass('d-none');
                $('.js__signup-container').removeClass('d-none');
            });

            $('.js__existing-record').on('click touchstart', function (e) {
                // existing record. show log in form
                $('.js__have-we-met-container').addClass('d-none');
                $('.js__login-container').removeClass('d-none');
		$('h1#user_type_campaign_banner_container').replaceWith(function() {
	            return '<h1 class="campaign-banner-container" id="user_type_campaign_banner_container">Welcome Back!</h1>';
	        });
            });
            $('.js__show-have-we-met').on('click touchstart', function (e) {
                // existing record. show log in form
                e.preventDefault();
                $('.js__login-container').addClass('d-none');
                $('.js__have-we-met-container').removeClass('d-none');
		$('h1#user_type_campaign_banner_container').replaceWith(function() {
	            return '<h1 class="campaign-banner-container" id="user_type_campaign_banner_container">Have We Met Before?</h1>';
	        });
            });
            $('.js__new-record').on('click touchstart', function (e) {
            // new participant. continue to tfind step
                $('#next_step').click();
            });

            $('.janrainEngage').html('<div class="btn-social-login btn-facebook"><i class="fab fa-facebook-f mr-2"></i> Create with Facebook</div><div class="btn-social-login btn-amazon"><i class="fab fa-amazon mr-2"></i> Create with Amazon</div>');

            $('#janrainModal img').attr('alt', 'Close social login lightbox');

            $('div#user_type_campaign_banner_container').replaceWith(function() {
                return '<h1 class="campaign-banner-container" id="user_type_campaign_banner_container">' + $(this).html() + '</h1>';
            });
        }
        if ($('#reg_payment_page').length > 0) {
            $('.custom-progress-bar').hide();
            $('div#reg_payment_campaign_banner_container').replaceWith(function() {
                return '<h1 class="campaign-banner-container" id="reg_payment_campaign_banner_container">' + $(this).html() + '</h1>';
            });
            $('h3#title_container').replaceWith('<h2 class="ObjTitle" id="title_container">Submit Payment</h2>');
        }
        $('#reg_total_label').html('Total:');

        // ptype page
        if ($('#participation_options_page').length > 0) {
	    $('#part_type_campaign_banner_container').prepend(evDateYear+" ");
	    $('#part_type_fundraising_goal_input_container').prepend("<h2>Set Your Personal Fundraising Goal!</h2>")
            $('div#part_type_campaign_banner_container').replaceWith(function() {
                return '<h1 class="campaign-banner-container" id="part_type_campaign_banner_container">' + $(this).html() + '</h1>';
            });
            $('#pt_title_container').replaceWith(function() {
                return '<h2 id="pt_title_container" class="section-header-text">' + $(this).html() + '</h2>';
            });

 	    $('#disc_code_container').append("<div><small>Is your company paying for your registration fee? Please enter your company code below.</small></div>")
        }

        // reg page
        if ($('#registration_options_page').length > 0) {
            $('#registration_options_page .header-container .campaign-banner-container').replaceWith(function() {
                return '<h1 class="campaign-banner-container">' + $(this).html() + '</h1>';
            });
            $('#title_container').replaceWith('<h2 class="ObjTitle" id="title_container">Tell us about you:</h2>');
        }

        //Rthanks
        if ($('#fr_thanks_page').length > 0) {
            $('.custom-progress-bar').hide();
        }
        //Form a team / join a team
        if ($('#team_find_page').length > 0) {
            $('.custom-progress-bar').hide();
            // BEGIN TFIND
            $('form[name=FriendraiserFind]').attr('hidden', true);

            $('select[name=fr_co_list]').change(function(){
                if ($(this).find('option:selected').text().indexOf("AT&T") > -1) {
                    console.log("found AT&T 4");
                    localStorage.companySelect = "AT&T";
                } else {
                    console.log("reset AT&T 4");
                    localStorage.companySelect = "";
                }
            });
            $('.list-component-cell-column-join-link a').click(function(){
                var compSel = $(this).closest('.list-component-row').find('.list-component-cell-column-company-name .list-component-cell-data-text').html();
                if (compSel.indexOf("AT&amp;T") > -1 || compSel.indexOf("AT&T") > -1) {
                    console.log("found AT&T 5");
                    localStorage.companySelect = "AT&T";
                } else {
                    console.log("reset AT&T 5");
                    localStorage.companySelect = "";
                }
            });

            $('form').validate({
		focusInvalid: false,
		invalidHandler: function(form, validator) {
			if (!validator.numberOfInvalids())
				return;

			$('html, body').animate({
				scrollTop: $(validator.errorList[0].element).offset().top
			}, 500);
		},
		errorPlacement: function(error, element) {
			if ($(element).attr("name") == "fr_part_radio") {
				$('#part_type_selection_container').append(error).css({"display":"block","text-align":"left"});
			} else {
				if ($(element).attr("name").indexOf("donation_level_form_input") > -1) {
					$('.enterAmt-other').after(error);
				} else {
					var placement = $(element).data('error');
					if (placement) {
						$(placement).append(error)
					} else {
						error.insertAfter(element);
					}
				}
			}
                }
            });
            $.validator.addMethod("validGoal",function(value, element) {
                    value = parseInt(value.replace("$","").replace(",",""));
                    if ($('input[name^=fr_team_goal]') && value < 1) {
                        return false;
                    } else {
                        return true;
                    }
                }, "The team goal should be greater than $0."
            );

	    $('select#fr_co_list').addClass("required").attr("title","Team Company is required");
	    $('select#fr_co_list option:first').attr("value","");
            $('#team_find_new_company_selection_container label').before('<span class="field-required" id="team_find_new_company_selection_required" aria-hidden="true"></span>');

	    $('input#fr_team_goal').addClass("validGoal required");
	    $('span.field-required').closest('.form-content').find('input, select').addClass("required");

	    $('input.required').each(function(){

		    var label = $(this).closest('.input-container').find('.input-label').html();
		    if (label != undefined) {
			    if (label.indexOf("Team Fundraising Goal") > -1) {
				    $(this).attr("title","The team goal should be greater than $0.");
			    } else {
				    $(this).attr("title",label.replace(":","") + " is required");
			    }
		    }
	    });

	    $('button.next-step').click(function(){
                if ($('select[name=fr_co_list]').length) {
                    if ($('select[name=fr_co_list] option:selected').text().indexOf("AT&T") > -1) {
                        console.log("found AT&T 6");
                        localStorage.companySelect = "AT&T";
                    } else {
                        console.log("reset AT&T 6");
                        localStorage.companySelect = "";
                    }
                }
                //store off personal goal in sess var by adding to action url
                $('form[name=FriendraiserFind]').prepend('<input type="hidden" id="teamCaptainSessionVar" name="s_teamCaptain" value="">');
                $('form[name=FriendraiserFind]').prepend('<input type="hidden" id="teamNameSessionVar" name="s_teamName" value="' + $('input#fr_team_name').val() + '">');
                $('form[name=FriendraiserFind]').prepend('<input type="hidden" id="teamGoalSessionVar" name="s_teamGoal" value="' + $('input#fr_team_goal').val() + '">');
		if ($('form[name=FriendraiserFind]').valid()) {
	                return true;
		} else {
			return false;
		}
            });

            if (regType === 'startTeam') {
    		        $('.campaign-banner-container').hide();
                $('#team_find_section_container').addClass("col-12 col-xl-10 offset-xl-1").removeClass("section-container");
                $('form[name=FriendraiserFind]').removeAttr('hidden');
                $('#team_find_section_body, #team_find_section_header').show();
                var trCompanyCount = $('#fr_co_list > option').length;
                if (trCompanyCount < 2) {
                    // no companies associated with this TR yet. Hide the team_find_new_team_company column
                    $('#team_find_new_team_company').hide();
                    $('#team_find_new_team_attributes').addClass('no-companies');
                    $('#team_find_new_team_name, #team_find_new_fundraising_goal').addClass('col-md-6');
                } else {
                    $('#team_find_new_company_selection_container').append("<span class='hint-text hidden-xs'>You can't skip this step! If you don't see your company in the list, please <a href='mailto:"+coordEmail+"'>contact your local staff</a> to get your company set up today!</span>");
                }
                $('#team_find_new_team_attributes').before($('#team_find_new_team_company'));
                $('#fr_team_name').attr('title','Team Name is required');
            } else if (regType === 'joinTeam') {
		$('.campaign-banner-container').hide();
    		$('#team_find_new_team_attributes').before($('#team_find_new_team_company'));
                if ($('#team_find_existing').length > 0) {

                    // BEGIN new team find form
                    // $('.js__join-team-container').html($('.js__reg-team-search-form'));
                    $('.js__reg-team-search-form').on('submit', function(e) {
                        e.preventDefault();
                        $('.alert').hide();

                        $('.list').html('');
                        // $('.js__search-results-container').html('');
                        var teamName = $('#regTeamName').val();
                        var firstName = $('#regTeamMemberFirst').val();
                        var lastName = $('#regTeamMemberLast').val();
                        var companyId = $('#regCompanyId').val();
                        // cd.getTeams(teamName, searchType);
                        cd.getTeams(teamName, 'registration', false, firstName, lastName, companyId);
      	                $('.js__reg-team-search-form .button').closest('.col-sm-4').after('<div class="col-sm-12 text-center pt-2">Can\'t find a team at your company? <a href="TRR/?pg=tfind&fr_id='+evID+'&fr_tm_opt=new&s_regType=startTeam">You can start one!</a></div>');
                    });

                    cd.getCompanyList = function(frId, companyId) {
                        // $('.js__loading').show();

                        luminateExtend.api({
                            api: 'teamraiser',
                            data: 'method=getCompanyList' +
                                '&fr_id=' + frId +
                                '&list_page_size=499' +
                                '&list_page_offset=0' +
                                '&response_format=json' +
                                '&list_sort_column=company_name' +
                                '&list_ascending=true',
                            callback: {
                                success: function(response) {
                                    // $('.js__loading').hide();


                                    var companyList = '',
                                        nationals = (response.getCompanyListResponse.nationalItem ? luminateExtend.utils.ensureArray(response.getCompanyListResponse.nationalItem) : []),
                                        regionals = (response.getCompanyListResponse.regionalItem ? luminateExtend.utils.ensureArray(response.getCompanyListResponse.regionalItem) : []),
                                        companies = (response.getCompanyListResponse.companyItem ? luminateExtend.utils.ensureArray(response.getCompanyListResponse.companyItem) : []);

                                    var sortCompanies = function(a, b) {
                                        var A = a.companyName.toLowerCase();
                                        var B = b.companyName.toLowerCase();
                                        if (A < B) {
                                            return -1;
                                        } else if (A > B) {
                                            return 1;
                                        } else {
                                            return 0;
                                        }
                                    };

                                    nationals.sort(sortCompanies);
                                    regionals.sort(sortCompanies);
                                    companies.sort(sortCompanies);

                                    if (nationals.length > 0) {
                                        companyList += '<optgroup label="National Companies">';
                                    }
                                    $.each(nationals, function() {
                                        if (this.companyName.indexOf('(sponsor)') != -1) {
                                            this.companyName = this.companyName.split('(sponsor)')[0];
                                        }
                                        companyList += '<option value="' + this.companyId + '">' + this.companyName + '</option>';
                                    });
                                    if (nationals.length > 0) {
                                        companyList += '</optgroup>';
                                    }
                                    if (regionals.length > 0) {
                                        companyList += '<optgroup label="Regional Companies">';
                                    }
                                    $.each(regionals, function() {
                                        if (this.companyName.indexOf('(sponsor)') != -1) {
                                            this.companyName = this.companyName.split('(sponsor)')[0];
                                        }
                                        companyList += '<option value="' + this.companyId + '">' + this.companyName + '</option>';
                                    });
                                    if (regionals.length > 0) {
                                        companyList += '</optgroup>';
                                    }
                                    if (companies.length > 0) {
                                        companyList += '<optgroup label="Local Companies, Schools and Organizations">';
                                    }
                                    $.each(companies, function() {
                                        if (this.companyName.indexOf('(sponsor)') != -1) {
                                            this.companyName = this.companyName.split('(sponsor)')[0];
                                        }
                                        companyList += '<option value="' + this.companyId + '">' + this.companyName + '</option>';
                                    });
                                    if (companies.length > 0) {
                                        companyList += '</optgroup>';
                                    }
                                    $('.js__reg-company-name').append(companyList);


                                },
                                error: function(response) {
                                    // $('.js__loading').hide();
                                    $('.js__error-team-search').text(response.errorResponse.message).show();
                                }
                            }
                        });
                    };

//                    Do not run getCompanyList for join team page. Use sorting process later in this file
//                    cd.getCompanyList(evID);
                    // END new team find form


                    // append cons ID to the join team button
                    if ($('#team_find_search_results_container').length > 0) {

                        var teamRows = $('.list-component-row');
                        $.each(teamRows, function(i, teamRow) {
                            var captainConsId, origJoinTeamUrl, modJoinTeamUrl;
                            var self = $(this);
                            var origTeamNameUrl = $(this).find('.list-component-cell-column-team-name a').attr('href');
                            var teamId = getURLParameter(origTeamNameUrl, 'team_id');

                            luminateExtend.api({
                                api: 'teamraiser',
                                data: 'method=getTeamCaptains&response_format=json&fr_id=' + evID + '&team_id=' + teamId,
                                callback: {
                                    success: function success(response) {
                                        var captainArray = luminateExtend.utils.ensureArray(response.getTeamCaptainsResponse.captain);
                                        var joinTeamName = 'Join ' + captainArray[0].teamName;
                                        captainConsId = captainArray[0].consId;
                                        origJoinTeamUrl = $(self).find('.list-component-cell-column-join-link a').attr('href');
                                        modJoinTeamUrl = origJoinTeamUrl + '&s_captainConsId=' + captainConsId;

                                        $(self).find('.list-component-cell-column-join-link a').attr('href', modJoinTeamUrl).attr('aria-label', joinTeamName);
                                    },
                                    error: function error(response) {}
                                }
                            });
                        });
                    }
                }
            }


            // rebuild LO's create team form
            var dynTeamGoal = $('.js__generated-team-goal');
            var currentTeamGoal, currentTeamGoalFormatted, minTeamGoalMsg;
            var loTeamGoal = $('#fr_team_goal');
            var promoCode = ($('body').data('promocode') !== undefined ? $('body').data('promocode') : "");

            // tfind

            var loDefaultGoal = $('#fr_team_goal').val();

            // check to see if Start a Team and Breakaway ptypes are available

            // if Start a Team and Breakaway ptypes are not available, remove those registration options and display a sponsor code field on the reg options step



            cd.getParticipationTypes = function(promo) {
                $('.js__reg-type-container .alert').addClass('hidden');
                var isStartTeamAvailable = false;
                var validPromo = false;
                var promoCodePtypesAvailable = false;

                luminateExtend.api({
                    api: 'teamraiser',
                    data: 'method=getParticipationTypes' +
                        '&fr_id=' + evID +
                        ((promo !== undefined) ? '&promotion_code=' + promo : '') +
                        '&response_format=json',
                    callback: {
                        success: function(response) {

                            if (response.getParticipationTypesResponse.participationType.length) {
                                // no search results
                                var participationTypes = luminateExtend.utils.ensureArray(response.getParticipationTypesResponse.participationType);
                                // var promoPtypeLoaded = false;
                                $(participationTypes).each(function(i, ptype) {
                                    // There is no promo code in session
                                    if (ptype.participationTypeRegistrationLimit && ptype.participationTypeRegistrationLimit.limitReached === 'false') {
                                        // Publicly available ptypes are available
                                        // ptype has a limit and it has NOT been reached
                                        if (ptype.name.indexOf('Start a Team') > -1) {
                                            if (ptype.participationTypeRegistrationLimit.limitReached === 'false') {
                                                isStartTeamAvailable = true;
                                            }
                                        }
                                    }

                                    // if(promo){
                                    // promo is loaded
                                    if (promo && ptype.promoCodeRequired === "true") {
                                        console.log('promo code only ptype available');
                                        // promo code is valid

                                        if (ptype.name.indexOf('Start a Team') > -1) {
                                            if (ptype.participationTypeRegistrationLimit.limitReached === 'false') {
                                                isStartTeamAvailable = true;
                                                // Promo code ptypes are available
                                                promoCodePtypesAvailable = true;
                                            }
                                        }
                                        validPromo = true;

                                        // }
                                    } else {
                                        // promo code is inavlid
                                        console.log('set promo to validPromo');
                                        if (validPromo === true) {
                                            return false;
                                        } else {
                                            validPromo = false;
                                        }
                                    }
                                    // }

                                });


                                if (isStartTeamAvailable === true) {
                                    $('.start-team-container').removeClass('hidden');
                                } else {
                                    $('.js__reg-options-promo-container, .js__promo-code-sold-out').removeClass('hidden');
                                }

                                if (promoCodePtypesAvailable) {
                                    console.log('promoCode ptypes are available and loaded');
                                    // add promo code to reg options links in case they are entering it for the first time on this step
                                    var regOptionLinks = $('.js__reg-type-form .step-button');

                                    $(regOptionLinks).each(function() {
                                        var origUrl = $(this).attr('href');
                                        var modUrl = origUrl + '&s_promoCode=' + promo;
                                        $(this).attr('href', modUrl);
                                    });
                                    if (!promoCode) {
                                        // show a custom message if a promo code is not already in session and someone manually enters a promo code and we DO retrieve an available ptype
                                        $('.js__promo-code-success').removeClass('hidden');
                                        $('html, body').animate({
                                            scrollTop: 0
                                        }, "slow");
                                    }
                                    $('.js__reg-options-promo-container').addClass('hidden');
                                    // } else if(promo && promoCodePtypesAvailable === false && validPromo === false){
                                } else if (promo && promoCodePtypesAvailable === false && validPromo === true) {

                                    console.log('promoCode in session but NO promoCode ptypes are available for registration');
                                    // show a custom message if someone manually enters a promo code and we DO NOT retrieve an available ptype
                                    $('.js__promo-code-sold-out').addClass('hidden');
                                    $('.js__promo-code-error, .js__reg-options-promo-container').removeClass('hidden');
                                } else if (promo && validPromo === false) {
                                    console.log('invalid promoss');
                                    $('.js__promo-code-sold-out').addClass('hidden');
                                    $('.js__promo-code-invalid, .js__reg-options-promo-container').removeClass('hidden');
                                }

                                $('.join-team-container').removeClass('hidden');
                            }
                        },
                        error: function(response) {
                            console.log(response.errorResponse.message);
                        }
                    }
                });

                if (promoCode) {
                    cd.getParticipationTypes(promoCode);
                } else {
                    cd.getParticipationTypes();
                }

                // manage manual submission of promo codes on reg options step
                $('.js__reg-options-promo-form').on('submit', function(e) {
                    e.preventDefault();
                    var manualPromoCode = $('#sponsorCode').val();
                    cd.getParticipationTypes(manualPromoCode);
                });

            } // end StationaryV2 event conditional

            var numTeamResults = $('#team_find_search_results_container .list-component-row').length;

            //if (numTeamResults < 20) {
            //    $('.list-component-paginator').hide();
            //}

            //$('#friend_potion_next')
            //    .wrap('<div class="order-1 order-sm-2 col-sm-4 offset-md-6 col-md-3 col-8 offset-2 mb-3"/>');

            //$('#team_find_section_footer')
            //    .prepend('<div class="order-2 order-sm-1 col-sm-4 col-md-3 col-8 offset-2 offset-sm-0"><a href="TRR/?pg=tfind&amp;fr_id=' + evID + '" class="button btn-secondary btn-block">Back</a></div>')

            // Add minimum validation to LOs team goal input
            /*
	    $(loTeamGoal)
                .val(2500)
                .wrap('<div class="input-group" />')
                .before('<div class="input-group-prepend"><div class="input-group-text py-0 px-1 border-right-0 bg-white">$</div></div>')
                .attr({
                    "min": 2500,
                    "step": "100",
                    "aria-label": "Goal amount (to the nearest dollar)",
                    "data-parsley-validation-threshold": "1",
                    "data-parsley-trigger": "keyup",
                    "data-parsley-type": "number",
                    "data-parsley-min-message": minTeamGoalMsg
                });

            $('#team_find_new_fundraising_goal_input_hint').before('<div class="team-goal-error"></div>');

            $('.js__show-reg-type').on('click', function(e) {
                e.preventDefault();
                $('.js__reg-type-container').removeClass('d-none');
            });


            var teamFindParsleyConfig = {
                errorsContainer: function(pEle) {
                    var $err = pEle.$element.parent().parent().find('.team-goal-error');
                    return $err;
                }
            }

            $('.js__show-team-details').on('click', function(e) {
                e.preventDefault();
                $('#fr_team_goal')
                    .attr({
                        "data-parsley-min-message": minTeamGoalMsg
                    });
                $('form[name=FriendraiserFind]').removeAttr('hidden');
                cd.calculateRegProgress();

                // add parsley validation to the form AFTER all of the elements have been moved around/created. Since minimum team goal is being set by the bikes step, we really shouldn't validate this until we update that min attribute and the user clicks 'next'
                $('#team_find_page > form').parsley(teamFindParsleyConfig);
            });
            */
            // if team name submission fails, show system default error messages instead of going back to the bike number selector
            //if ($('.ErrorMessage').length > 0) {
            //    $('.js__team-bikes-container').attr('hidden', true);
            //    $('form[name=FriendraiserFind]').removeAttr('hidden');
            //}

            //$('#team_find_page > form').parsley(teamFindParsleyConfig);

            // append session variable setting hidden input to track number of bikes selected so same value can be automatically selected in reg info step
            //$('form[name="FriendraiserFind"]').prepend('<input type="hidden" class="js__numbikes" name="s_numBikes" value="">');

            if ($('.field-error-text').length > 0 && $('.field-error-text:contains("There is already a team registered with that name")').length > 0) {
                // append "join team" link in error message with s_regType=joinTeam session var
                var joinTeamLink = $('.field-error-text a');
                var updatedJoinTeamLink = $(joinTeamLink).attr('href') + '&s_regType=joinTeam';
                $(joinTeamLink).attr('href', updatedJoinTeamLink);
            }

	    $('#team_find_new_team_attributes').before("<div class='mt-3'><p class='text-center'>Now create a fun team name and set your team's fundraising goal. (A team of 10 easily raises $2,000 so let's do this!)</p></div>")

            $('#team_find_new_fundraising_goal_input_hint').hide(); //text('You can increase your team\'s goal, but the amount shown below is your team\'s suggested fundraising minimum.');
            $('#previous_step span').text('Back');
        }
        // END TFIND


        if ($('#fr_team_goal').length <= 0) {
            $('#team_find_section_footer').hide();
        }
	// UTYPE
	if (jQuery('input[name=pg]').val() == "utype") {
   	    $('h1#user_type_campaign_banner_container').replaceWith(function() {
	        return '<h1 class="campaign-banner-container" id="user_type_campaign_banner_container">Have We Met Before?</h1>';
            });
	}

        // PTYPE
        if ($('#F2fRegPartType').length > 0) {
            if ($('.part-type-container').length == 1) {

		 if ($('input[name=discount_code]').length == 0) {
	                $('.part-type-container, #part_type_section_header').hide();
		} else {
	                $('#part_type_section_header').hide();
		}
                //$('.part-type-container').before("<div class='part_type_one_only'><strong>Set Your Fundraising Goal!</strong></div>");
            } else {
                $('input[name=fr_part_radio]:checked').removeAttr("checked");
                $('.part-type-container.selected').removeClass("selected");
            }
            $('#part_type_additional_gift_container .otherAmt span').html("$");

            //connect of for on label to missing id on field
            $('input.goal').attr('id',$('input.goal').closest('.part-type-decoration-messages').find('label').attr("for"));

            /* add role and label to donation buttons */
            $('.donation-form-fields').attr("role","radiogroup").attr({"aria-label":"Donation Amounts","aria-required":"true"});

            if (regType === 'startTeam') {
                $('#part_type_additional_gift_section_header').html('<div class="bold-label" id="regDonationLabel">Show your team how it\'s done: kick start your own fundraising with a personal donation!</div>');
            }
            if (regType === 'joinTeam') {
                $('#part_type_additional_gift_section_header').html('<div class="bold-label" id="regDonationLabel">Show your team how it\'s done: kick start your own fundraising with a personal donation!</div>');
	        //$('#part_type_additional_gift_section_header').prepend('<div class="bold-label" id="regDonationLabel">Show your dedication and make a donation towards your goal.</div>');
            }
            $('#part_type_additional_gift_section_header').before("<h2>Get Started with a Personal Donation</h2>");

            $('#part_type_donation_level_input_container').wrapInner('<fieldset role="radiogroup" class="donation-form-fields" aria-label="Donation Amounts" aria-required="true" />');
            $('.donation-form-fields').prepend('<legend class="sr-only">Donate Towards Your Goal Now</legend>');

            $('#part_type_individual_company_selection_container .input-container').prepend("<span class='hint-text'>Choose your company below. If your company does not show up, you can skip this step.</span>");

            /* setup form validation - additional donation amount must be >= $25 */
            $('input[name^=donation_level_form_input]').addClass("validDonation").attr("title","Your donation needs to be at least $25.");

            $('input[name=fr_part_radio]').addClass("required").attr("title","Participation type is required");

	    //hide back button and turn into link
	    $('button#previous_step').after('<a href="javascript:window.history.go(-1)" class="step-button previous-step backBtnReg">Back</a>').hide();

            $('form').validate({
		focusInvalid: false,
		invalidHandler: function(form, validator) {
			if (!validator.numberOfInvalids())
				return;

			$('html, body').animate({
				scrollTop: $(validator.errorList[0].element).offset().top
			}, 500);
		},
		errorPlacement: function(error, element) {
			if ($(element).attr("name") == "fr_part_radio") {
				$('#part_type_selection_container').append(error).css({"display":"block","text-align":"left"});
			} else {
				if ($(element).attr("name").indexOf("donation_level_form_input") > -1) {
					$('.enterAmt-other').after(error);
				} else {
					var placement = $(element).data('error');
					if (placement) {
						$(placement).append(error)
					} else {
						error.insertAfter(element);
					}
				}
			}
                }
            });
            $.validator.addMethod("validDonation",function(value, element) {
                    value = parseInt(value.replace("$","").replace(",",""));
                    if ($('input[name^=donation_level_form]').is(':checked') && value < 25) {
                        return false;
                    } else {
                        return true;
                    }
                }, "Donations of all amounts are greatly appreciated. Online donations have a $25 minimum."
            );

            $('select[name=fr_part_co_list]').change(function(){
                if (jQuery(this).find('option:selected').text().indexOf("AT&T") > -1) {
                    console.log("found AT&T 2");
                    localStorage.companySelect = "AT&T";
                } else {
                    console.log("reset AT&T 2");
                    localStorage.companySelect = "";
                }
            });
            $('button.next-step').click(function(){
                if ($('select[name=fr_part_co_list]').length) {
                    if ($('select[name=fr_part_co_list] option:selected').text().indexOf("AT&T") > -1) {
                        console.log("found AT&T 3");
                        localStorage.companySelect = "AT&T";
                    } else {
                        console.log("reset AT&T 3");
                        localStorage.companySelect = "";
                    }
                }
                if ($('form').valid()) {
                    //store off personal goal in sess var by adding to action url
                    $('#F2fRegPartType').prepend('<input type="hidden" id="personalGoal" name="s_personalGoal" value="' + $('input#fr_goal').val() + '">');
                    return true;
                } else {
                    return false;
                }
            });
        }

      if ($('body').is('.pg_reg')) {
  	    $('h1.campaign-banner-container').prepend(evDateYear+" ");
  	    /* zip only reg flow */
  	    $('#cons_zip_code').parent().parent().parent().parent().addClass('field-required consZip');

  	    if ($(".consZip span.field-required").length === 0) {
  	    	$('label[for="cons_zip_code"]').parent().before('<span class="field-required"></span>');
     	    }

  	    $('label:contains("t-shirt")').closest('.input-container').find('select').addClass("tshirtSize");
  	    $('span.field-required').closest('.form-content').find('input, select').addClass("required");
  	    $('input[value^="I accept"]').addClass("acceptRelease").next('label').addClass("acceptReleaseLabel");
        $('input[value^="I agree to"]').addClass("acceptPrivacy").next('label').addClass("acceptPrivacyLabel");

	    /*
	    var pattern = /\b(Release with Publicity Consent)/gi; // words you want to wrap
	    var replaceWith = '<a id="waiverPopLink" href="javascript:void(0);">$1</a>'; // Here's the wap
    	    $('.acceptReleaseLabel').each(function(){
		$(this).html($(this).html().replace(pattern,replaceWith));
 	    });
	    $('input[value^="I agree to"]').addClass("acceptPrivacy").next('label').addClass("acceptPrivacyLabel");
	    var pattern = /\b(Terms and Conditions \(PDF\))/gi; // words you want to wrap
	    var replaceWith = '<a href="#" target="_blank">$1</a>'; // Here's the wap
    	    $('.acceptPrivacyLabel').each(function(){
		$(this).html($(this).html().replace(pattern,replaceWith));
 	    });
	    var pattern = /\b(Privacy Policy)/gi; // words you want to wrap
	    var replaceWith = '<a href="https://www.heart.org/en/about-us/statements-and-policies/privacy-statement" target="_blank">$1</a>'; // Here's the wap
    	    $('.acceptPrivacyLabel').each(function(){
		$(this).html($(this).html().replace(pattern,replaceWith));
 	    });
            */

	    $('input.required').each(function(){
		    var label = $(this).closest('.input-container').find('.input-label').html();
		    if (label != undefined) {
			    if (label == "First" || label == "Last") {
				    label = label + " Name";
			    }
			    $(this).attr("title",label.replace(":","") + " is required");
		    }
	    });


      /*Removing Mobile Opt-in Option*/

      /*

	    //Add mobile opt in check box
	    var optinHTML = '<div id="mobile_optin_outer">' +
		                '<input type="checkbox" name="mobile_optin" id="mobile_optin">' +
		                '<label for="mobile_optin" class="wrapable">' +
		                    '<span id="optin_label"><strong>Mobile Opt in:</strong> By checking the box, I consent to receive up to 1 - 2 text messages per week from AHA supporting my Field Day efforts at the mobile number above. Selecting text option is not required for my participation. Message and data rates may apply. I can Reply STOP at any time to opt out.</span>' +
		                '</label>' +
		             '</div>';
	    // only add mobile opt in option if grou pid exists on body tag
            if ($('body').data("group-id") != undefined) {
		    $('#cons_info_component_container').append(optinHTML);
		    $('#mobile_optin').click(function(){
			    if ($(this).is(":checked")) {
			    	    $('.input-label:contains(Mobile Phone)').closest('label').next('input').addClass("phonecheck");
			    } else {
				    $('.input-label:contains(Mobile Phone)').closest('label').next('input').removeClass("phonecheck");
			    }
		    });
	    }
      */

      //$('.input-label:contains(Mobile Phone)').hide().attr('aria-hidden', 'true');
      //$('.regMobilePhone').hide().attr('aria-hidden', 'true');


	    var tshirtName = $('.input-label:contains("t-shirt")').closest('.input-container').find('select').attr("name");
	    var rules = {};
	    rules['cons_password'] = {required: true,minlength: 5};
	    rules['cons_rep_password'] = {required: true,minlength: 5,equalTo: "#cons_password"};
	    //rules[optinName] = {required: '#mobile_optin:checked',minlength: 2};
	    rules[tshirtName] = {valueNotEquals: 'NOREPLY'};
	    var messages = {};
	    messages['cons_password'] = {minlength: "Please enter 5 characters or more",required: "Please enter a password"};
	    messages['cons_rep_password'] = {required: "Please confirm your password",minlength: "Please enter 5 characters or more",equalTo: "Passwords do not match. Please re-enter password."};
	    //messages[optinName] = {required: "Mobile Opt in is selected.<br/>Please enter a mobile number."};
	    messages[tshirtName] = {required: "Please select a t-shirt size."};

	    $('button.previous-step').attr("formnovalidate","true");

	    //hide back button and turn into link
	    $('button#previous_step').after('<a href="javascript:window.history.go(-1)" class="step-button previous-step backBtnReg">Back</a>').hide();

   	    $.validator.addMethod("valueNotEquals", function(value, element, arg){
		return arg !== value;
	    }, "Please select a t-shirt size");

	  jQuery('#F2fRegContact').validate({
		focusInvalid: false,
		invalidHandler: function(form, validator) {
			if (!validator.numberOfInvalids())
				return;

			$('html, body').animate({
				scrollTop: $(validator.errorList[0].element).focus().offset().top
			}, 500);
		},
                rules: rules,
                messages: messages,
                errorElement: 'span',
                errorPlacement: function(error, element) {

			if ($(element).hasClass("survivorq")) {
        var a11yError = error.attr('role', 'alert');
				$('fieldset.survivor_yes_no').after(a11yError);

        var describedBy = error.attr('id');
        $(element).attr('aria-describedby', describedBy);
			} else {
				if ($(element).hasClass("acceptRelease")) {
          var a11yError = error.attr('role', 'alert');
					$('.acceptRelease').closest('.input-container').append(a11yError).css('display, block');

          var describedBy = error.attr('id');
          $(element).attr('aria-describedby', describedBy);
				} else if ($(element).hasClass("acceptPrivacy")) {
          var a11yError = error.attr('role', 'alert');
					$('.acceptPrivacy').closest('.input-container').append(a11yError);

          var describedBy = error.attr('id');
          $(element).attr('aria-describedby', describedBy);
        } else {
          if ($(element).parents('.privacyCheck').length) {

            var a11yError = error.attr('role', 'alert');
  					$('.privacyCheck').closest('.li').append(a11yError).css('display, block');

            var describedBy = error.attr('id');
            $(element).attr('aria-describedby', describedBy);

          } else if ($(element).hasClass("acceptPrivacy")) {
            var a11yError = error.attr('role', 'alert').css('display, block');
						$('.acceptPrivacy').closest('.input-container').append(a11yError);

            var describedBy = error.attr('id');
            $(element).attr('aria-describedby', describedBy);
					} else {
						var placement = $(element).data('error');
						if (placement) {
              var a11yError = error.attr('role', 'alert');
							$(placement).append(a11yError);

              var describedBy = error.attr('id');
              $(element).attr('aria-describedby', describedBy);
						} else {
							error.insertAfter(element).attr('role', 'alert');
              var describedBy = error.attr('id');
              $(element).attr('aria-describedby', describedBy);
						}
					}
				}
			}
      $(error).attr('role', 'alert')
      }


            });
            $.validator.addMethod("uncheck", function(value) {
               return /^[A-Za-z0-9\d=\-+#@%:,._*]*$/.test(value) // consists of only these
            },"Oops. Looks like you are using a character we don't recognize. Valid characters in your username are: letters, numbers, and these symbols: +, -, _, @, ., %, and :");

            $.validator.addMethod("pwcheck", function(value) {
               return /^[A-Za-z0-9\d=!\-+#\(\)\/$%@,;:=?\[\]^`{|~}._*]*$/.test(value) // consists of only these
            },"Oops. Looks like you are using a character we don't recognize. Valid characters are letters, numbers, and the following symbols: !#$%()*+,-./:;=?@[\]^_`{|}~");

            $.validator.addMethod("phonecheck", function(value) {
               return /^(((\+1)|1)?(| ))((\+\d{1,3}(-| )?\(?\d\)?(-| )?\d{1,3})|(\(?\d{2,3}\)?))(-| )?(\d{3,4})(-| )?(\d{4})(( x| ext)\d{1,5}){0,1}$/.test(value) // consists of only these
            },"Invalid phone number");

            $('input#cons_user_name').addClass("uncheck");
            $('input#cons_password').addClass("pwcheck");

            //remove label causing acc issues
            $('.cons-zip-label, .cons-full-name-label, .cons-email-label').remove();
            //for AT&T company - a question will be displayed for their employee id
            //first it must be hidden though
            jQuery('label span.input-label:contains(By submitting the information requested in this form)').closest('.survey-question-container').addClass("att_id").hide();
            //jQuery('label span.input-label:contains(Clear Vidyard ID)').closest('.survey-question-container').addClass("vidyard_id").hide();
            //add additional code here for saving company name and displaying field if company selected was AT&T

            setTimeout(function(){
                if (localStorage.companySelect == "AT&T") {
                    jQuery('.att_id').show();
                    jQuery('.att_id .input-container label .input-label').html(jQuery('.att_id .input-container label .input-label').html().replace("AT&amp;T Services, Inc.","<span class='att_id_blue'>AT&T Services, Inc.</span>"));
                    jQuery('.att_id .input-container label .input-label').prepend("<div class='att_id_title att_id_blue'>AT&T Employees:</div>");
                    localStorage.companySelect = "";
                }
            },500);
            jQuery('button.next-step').click(function(){
                localStorage.hfg = jQuery('label:contains(Healthy For Good)').prev('input:checked').length;
                localStorage.hfg_firstname = jQuery('input[name=cons_first_name]').val();
                localStorage.hfg_email = jQuery('input[name=cons_email]').val();
	        localStorage.mobile_optin = jQuery('input[name=mobile_optin]:checked').val();
                if (jQuery('input[name=pg]').val() == "reg") {
                    if (jQuery('form').valid()) {
                        return true;
                    } else {
                        return false;
                    }
                }
            });
        }

        if ($('#F2fRegContact, form[name="RegisterAnother"]').length > 0) {
            $('.p-bar-step-1, .p-bar-step-2').show();
            $('#progressText1').hide();
            $('.p-bar-step-1').css('background', '#f18b21');
        }
        if ($('input[name="pg"]').val() == 'waiver') {
	    $('h2.cstmTitle').prepend(evDateYear+" ");
	}
	if ($('#fr_reg_summary_page #FriendraiserUserWaiver').length > 0) {
            $('.p-bar-step-1, .p-bar-step-2, .p-bar-step-3').show();
            $('#progressText1, #progressText2').hide();
            $('.p-bar-step-1, .p-bar-step-2').css('background', '#f18b21');
            $('h3#title_container').replaceWith('<h1 class="ObjTitle" id="title_container">You are registering for:</h1>');
        }
        $('#sel_type_container').parent().addClass('aural-only');

        $('span.input-label:contains("Life is Why")').parent().parent().parent().parent().hide();
        $('.input-label:contains("Mobile Phone")').parent().parent().parent().parent().addClass('regMobilePhone');
        $('span.cons_email').parent().parent().addClass('consEmail');
        $('.survey-question-container.regMobilePhone').insertAfter('.cons-info-question-container.consEmail');

        $('#overlayWaiver, .lightboxWiaverClose').click(function() {
            $('#overlayWaiver, #lightboxWiaver').hide();
        });

        /* Page = Reg */
        if ($('input[name="pg"]').val() == 'reg') {
            $('#additional_questions_container .survey-question-container:contains("Facebook Fundraiser ID:")').hide();

            var screenReaderNameHint = '<p class="sr-only">You can use your email address or a unique name with any of the following: letters, numbers, and these symbols: plus, dash, underscore, at, period, percentage, and colon but no spaces!</p>';

            $('input#cons_user_name + span.input-hint').attr('aria-hidden', 'true').html("You can use your email address or a unique name with any of the following: letters, numbers, and these symbols: +, -, _, @, ., %, and : but no spaces!").after(screenReaderNameHint);

            var passwordHint = '<p class="sr-only">This needs to be at least 5 characters long and can contain any of the following: letters, numbers, and these symbols: exclamation, pound, dollar sign, left parenthesis, right parenthesis, asterisk, plus, minus, period, slash, colon, semi-colon, question mar, at, left bracket, right bracket, caret, underscore, left brace, right brach, pipe, tilda, degrees, and equal.</p>';

            $('input#cons_password + span.input-hint').attr('aria-hidden', 'true').html("This needs to be at least 5 characters long and can contain any of the following: letters, numbers, and these symbols: !#$%()*+,-./:;?@[\]^_`{|}~ o=").after(passwordHint);
        }
        $('#password_component_container #cons_rep_password').parent().parent().parent().addClass('left');
        $('#password_component_container #cons_password').parent().parent().parent().addClass('left');
        $('span.survey-question-label:contains("Would you like to be recognized as a survivor?")').parent().next().children().children().children('input').wrap('<div></div>');
        $('span.survey-question-label:contains("Would you like to be recognized as a survivor?")').parent().parent().addClass('survivor_yes_no').attr({"role":"radiogroup","aria-label":" Would you like to be recognized as a survivor?","aria-required":"true"});
        $('span.input-label:contains("SurvivorQ")').parent().parent().addClass('survivorSelect');
        $('span.input-label:contains("SurvivorQ")').parent().parent().parent().parent().hide();
	$('.survivor_yes_no li.input-container input[type="radio"]').attr("aria-required","true");
        if ($('.survivor_yes_no li.input-container input[value="No"]').is(':checked')) {
            $('.survivor_yes_no li.input-container input[value="No"]').parent().parent().addClass('survivor_active');
        } else if ($('.survivor_yes_no li.input-container input[value="Yes"]').is(':checked')) {
            $('.survivor_yes_no li.input-container input[value="Yes"]').parent().parent().addClass('survivor_active');
        }

        $('.survivor_yes_no input[type=radio]').addClass("required survivorq");

        $('.survivor_yes_no li').click(function() {
            $('.survivor_yes_no li').removeClass('survivor_active');
            $(this).addClass('survivor_active');
        });

        $('.cons-address-street-full-container').attr('aria-hidden', 'true').hide();
        $('#cons_city').parent().parent().parent().parent().attr('aria-hidden', 'true').hide();
        $('#cons_state').closest('.cons-full-address-container').attr('aria-hidden', 'true').hide();
        $('#cons_info_country_container').attr('aria-hidden', 'true').hide();
        $('.cons-city-town-label').attr('aria-hidden', 'true');

        $('.survivorq').focus(function(){
          $(this).parent().parent().addClass('survivor_active');
        })


        /*Donation Buttons*/
        $('.donation-level-row-label').parent().parent().addClass('donation-amt');
        $('.donation-level-row-label:contains("Additional Gift:")').parent().parent().addClass('enterAmt').removeClass('donation-amt');
        $('<span>$</span>').insertBefore('.donation-level-row-container.enterAmt input:last-child');
        $('#part_type_individual_company_selection_container').insertAfter('#part_type_selection_container');
        $('.donation-level-row-label-no-gift').insertBefore(jQuery('.donation-level-row-label-no-gift').parent());
        $('.donation-level-row-container.enterAmt label.donation-level-row-label').text('Other Amount');
	$('.donation-level-row-label-no-gift').parent().addClass('notTime');
	$('.enterAmt .input-container > span').next('input').andSelf().wrapAll("<div class='enterAmt-other hidden'></div>");

        $(".donation-level-amount-text").each(function() {
            $(this).text($(this).text().replace(".00", ""));
        });
        $('.donation-level-row-container.donation-amt').click(function() {
            $(this).find('input').prop('checked', true);
            $('.donation-level-row-container').removeClass('active');
            $(this).addClass('active');
            //$('#part_type_anonymous_input_container, #part_type_show_public_input_container').show();
            $('.donation-level-row-container.enterAmt input').val('');
	    $('.enterAmt-other').addClass("hidden");
	    $('form').validate().resetForm();
        });
        $('.donation-level-row-container.enterAmt').click(function() {
            $(this).find('input').prop('checked', true);
            if ($(this).find('input').val() == "") {
		 $(this).find('input').val(0);
	    }
	    $('.enterAmt-other').removeClass("hidden");
            $('.donation-level-row-container').removeClass('active');
	    $(this).addClass("active");
            //$('#part_type_anonymous_input_container, #part_type_show_public_input_container').show();
        });
        $('.donation-level-row-container.notTime').click(function() {
            $(this).find('input').prop('checked', true);
            $('.donation-level-row-container').removeClass('active');
	    $(this).addClass("active");
            //$('#part_type_anonymous_input_container, #part_type_show_public_input_container').show();
            $('.donation-level-row-container.enterAmt input').val('');
	    $('.enterAmt-other').addClass("hidden");
	    $('form').validate().resetForm();
	});
	//check if amounts preselected
        $('.donation-level-row-container.donation-amt input:checked').closest('.donation-level-row-container.donation-amt').addClass("active");
	$('.donation-level-row-container.enterAmt input:checked').closest('.donation-level-row-container.enterAmt').addClass("active");
	$('.donation-level-row-container.notTime input:checked').closest('.donation-level-row-container.notTime').addClass("active");

        $('.donation-level-row-container.donation-amt input').focus(function(){
	    $(this).click();
        });

	//QA

        if ($('#F2fRegPartType').length > 0 && $('#previous_step').length === 0) {
            $('#F2fRegPartType .section-footer button.next-step').after('<a href="TRR/?pg=utype&fr_id=' + fr_id + '" class="step-button previous-step backBtnReg">Back</a>');
        }

	//wrap additional amount radio and label in own div for acc
	$('.input-container label:contains(Other Amount)').prev('input').andSelf().wrapAll('<div class="donation-level-row-decoration-container"></div>');

        /* Page = Reg */
        if ($('input[name="pg"]').val() == 'regsummary') {

        console.log('reg page updates');

   	    $('h2.cstmTitle').prepend(evDateYear+" ");
            // if there is a donation then change button text
            if ($.trim($('.additional-gift-amount').html()) != "$0.00") {
                $('button.next-step').attr("value","Complete and Donate").find('span').html("Complete and Donate");
            }

            //move custom details into content
            $('.reg-summary-event-info').prepend($('#additionalRegDetails'));

    	    //save off mobile opt option
            if (localStorage.mobile_optin == "on") {
                luminateExtend.api({
                    api: 'cons',
                    useHTTPS: true,
                    requestType: 'POST',
                    requiresAuth: true,
                    data: 'method=logInteraction' +
                    '&response_format=json' +
    				'&interaction_type_id=0' +
    				'&interaction_subject=Hustle-OptIn' +
    				'&interaction_body=\'{"EventId":' + $('body').data("fr-id") + ',"GroupId":' + $('body').data("group-id") + ',"OptIn":"Yes"}\'' +
    				'&cons_id=' + $('body').data("cons-id"),
                    callback: {
			success: function (response) {
				if (response.updateConsResponse.message == "Interaction logged successfully.") {

				}
			},
			error: function (response) {
				console.log(response.errorResponse.message);
			}
                    }
                });
		if (isProd) {
	                $('<img width="1" height="1" style="display:none;" src="https://www2.heart.org/site/SPageServer?pagename=reus_fd_mobileopt_add_group&group_id=' + $('body').data("group-id") + '&pgwrap=n" id="mobileopt_add_group">').appendTo($('#fr_reg_summary_page'));
		} else {
	                $('<img width="1" height="1" style="display:none;" src="https://dev2.heart.org/site/SPageServer?pagename=reus_fd_mobileopt_add_group&group_id=' + $('body').data("group-id") + '&pgwrap=n" id="mobileopt_add_group">').appendTo($('#fr_reg_summary_page'));
		}
    	    }
        }

        /* Page = paymentForm */
  if ($('input[name="pg"]').val() == 'paymentForm') {
		$('h1#reg_payment_campaign_banner_container').prepend(evDateYear+" ");
		$('button.previous-step').attr("formnovalidate","true");

		$('.payment-type-selection-container h3').attr("id","payment-type-label");
		$('.payment-type-selections').attr({"role":"radiogroup","aria-labelledby":"payment-type-label","aria-required":"true"});
		$('.payment-type-selections inpyt[type=radio]').attr("role","radio");

		//remove paypal image and put text instead - passes accessibility
		$('.external-payment .payment-type-label').html("PayPal");

		$('span.field-required').closest('.form-content').find('input:visible, select').addClass("required");

		$('input.required').each(function(){
      var label = $(this).closest('.form-content').find('label').html();
  		$(this).attr("title",label.replace(":","") + " is required");
		});
		$('select.required').each(function(){
		    var label = $(this).closest('.form-content').find('label span.label-text').html();
		    if (label != undefined) {
		    	$(this).attr("title",label.replace(":","") + " is required");
		    }
		});

		//hide back button and use link instead
	   	$('button#btn_prev').after('<a href="javascript:window.history.go(-1)" class="step-button previous-step backBtnReg">Back</a>').hide();

       $('button.next-step').click(function(){
        if ($('.payment-type-option.selected input').val() == "paypal") {
            return true;
        } else {
            if ($('form').valid()) {
                return true;
            } else {
                return false;
            }
        }
    });
	}

        $('#reg_summary_header_container').insertAfter('.section-header');
        $('#previous_step span').text("Back");
        if ($('input[name=fr_tm_opt]').val() == 'existingnew') {
            $('#fr_team_goal').val('');
            $('#fr_team_name').val('');
        }

        $('.part-type-description-text:contains("Free")').html('&nbsp;');
        $('.survey-question-container legend span:contains("Publicity Release")').parent().parent().addClass('waiverCheck');
        $('.waiverCheck legend').addClass('aural-only');
        $('.waiverCheck label').html('<span class="field-required"></span> I accept and acknowledge that I have read and understand this Field Day <a id="waiverPopLink" href="javascript:void(0);">Release with Publicity Consent</a> and agree to them voluntarily.');
	$('.waiverCheck input[type="checkbox"]').attr("aria-required","true");
        $('.survey-question-container legend span:contains("Terms of Service")').parent().parent().addClass('privacyCheck');
        $('.privacyCheck legend').addClass('aural-only');
        var trName = $('.campaign-banner-container').text();
        trName = trName.replace(/'/g, '');
        // TODO - update terms of service code for Field Day
        $('.privacyCheck label').html('<span class="field-required"></span> I agree to the <a href="javascript:void(0)" onclick="window.open(\'DocServer/Field_Days_165966_2020.03.20_TOS.pdf\',\'_blank\',\'location=yes,height=570,width=520,scrollbars=yes,status=yes\');">Terms and Conditions (PDF)</a> and <a href="javascript:void(0)" onclick="window.open(\'https://www.heart.org/en/about-us/statements-and-policies/privacy-statement\',\'_blank\',\'location=yes,height=570,width=520,scrollbars=yes,status=yes\');">Privacy Policy</a>.');
	$('.privacyCheck input[type="checkbox"]').attr("aria-required","true");

	$('.survey-question-container legend span:contains("Healthy for good signup")').parent().parent().addClass('healthyCheck');
        $('.healthyCheck legend').addClass('aural-only');

        $('#waiverPopLink').click(function(e) {
            e.preventDefault();
            $('#overlayWaiver, #lightboxWiaver').fadeIn(400);
	    $('.lightboxWiaverClose').focus();
        });

        $('.healthyCheck label').text('Yes, sign me up for sharable tips, videos and hacks so I can be Healthy For Good.');
        $('#responsive_payment_typecc_numbername').attr('maxlength', '16');

        //access
        $('html').attr('xmlns', 'http://www.w3.org/1999/xhtml').attr('lang', 'en').attr('xml:lang', 'en');

        var contentMeta = $('meta[name="Keywords"]').attr('content').trim();
        $('meta[name="Keywords"]').attr('content', contentMeta);
        if ($('.progress-bar-step-container').length > 0) {
            var progressBarCurr = $('.progress-bar-step-container.progress-bar-step-current').attr('class').trim();
            $('.progress-bar-step-container.progress-bar-step-current').attr('class', progressBarCurr);
            var progressBar = $('.progress-bar-step-container').not('.progress-bar-step-container.progress-bar-step-current').attr('class').trim();
            $('.progress-bar-step-container').attr('class', progressBar);
        }
        if ($('.part-type-decoration-messages').length > 0) {
            var decorationMessages = $('.part-type-decoration-messages').attr('class').trim();
            $('.part-type-decoration-messages').attr('class', decorationMessages);
        }
        if ($('.tr_sponsorship_logo_image').length > 0) {
            $('.tr_sponsorship_logo_image').each(function() {
                var logoImage = $('.tr_sponsorship_logo_image').attr('alt').trim();
                $('.tr_sponsorship_logo_image').attr('alt', logoImage);
            });
        }
        /*if ($('.cons-info-question-container.cons-address-street-full-container').length > 0) {
            var consInfoQ = $('.cons-info-question-container.cons-address-street-full-container').not('.cons-info-question-container.cons-address-street-full-container.field-required').attr('class').trim();
            $('.cons-info-question-container.cons-address-street-full-container').attr('class',consInfoQ);
        }*/

        $('.heart-hero__event-name p').first().replaceWith(function() {
            return '<h1 class="event-name-header">' + $(this).html() + '</h1>';
        });

        /*
        $('span#pt_title_container').replaceWith(function() {
            return '<h1 id="pt_title_container" class="section-header-text">' + $(this).html() + '</h1>';
        });
        */

        $('#part_type_selection_container').wrapInner('<fieldset></fieldset>');
        $('#sel_type_container').wrap('<legend class="aural-only"></legend>');
        $('#part_type_selection_container .manageable-content legend').prependTo('#part_type_selection_container fieldset');

        $('#fr_part_co_list').before('<label class="aural-only" for="fr_part_co_list">Choose an existing company</label>');


        $('#part_type_donation_level_input_container').wrapInner('<fieldset></fieldset>');
        $('#part_type_donation_level_input_container fieldset').prepend('<legend class="aural-only">Choose an optional donation amount</legend>');

        $('span#title_container').replaceWith(function() {
            return '<h1 class="ObjTitle" id="title_container">' + $(this).html() + '</h1>';
        });

        $('.detail-show-link.detail-toggle-link img, .detail-hide-link.detail-toggle-link img').attr('alt', '');

        $('#team_find_new_team_company .input-label').attr('for', 'fr_co_list');

        $('#team_find_new_team_attributes span.field-required').attr('aria-hidden', 'true');

        if ($('#team_find_header_container .ErrorMessage.page-error .field-error-text').length > 0) {
            $('#team_find_header_container .ErrorMessage.page-error .field-error-text').attr('role', 'alert');
        }

        $('#team_find_new_fundraising_goal .form-content label').html('Team Fundraising Goal:<br>');
        $('#team_find_new_fundraising_goal .form-content span.hint-text').appendTo('#team_find_new_fundraising_goal label');

        $('#email_format_container label').attr('for', 'cons_email_format');

        $('#personal_info_section_one .cons-info-question-container.cons-full-name-container span.input-label.cons_first_name').text('First Name');
        $('#personal_info_section_one .cons-info-question-container.cons-full-name-container span.input-label.cons_last_name').text('Last Name');

        $('h3.ObjTitle:contains("Review your registration")').replaceWith(function() {
            return '<h1 class="ObjTitle" id="title_container">' + $(this).html() + '</h1>';
        });

        if ($('.donation-level-row-container.enterAmt').length > 0) {
            var otherID = $('.donation-level-row-container.enterAmt span:contains("Other amount")').next().attr('id');
            $('.donation-level-row-container.enterAmt span:contains("Other amount")').wrap('<label class="otherAmt" for="' + otherID + '"></label>');
        }

        $('#F2fRegPartType .required-indicator-legend-container').remove();

        /* end access edits */

        /* GA Codes */
        jQuery("#fr_find_search").blur(function() {
            _gaq.push(['t2._trackEvent', 'Register', 'click', 'Search for a team']);
        });
        jQuery("#friend_potion_next").blur(function() {
            _gaq.push(['t2._trackEvent', 'Register', 'click', 'Start a team']);
        });
        jQuery("a:contains('Join a Team')").blur(function() {
            _gaq.push(['t2._trackEvent', 'SwitchRegister', 'click', 'Join a team']);
        });
        jQuery("#individual_container").blur(function() {
            _gaq.push(['t2._trackEvent', 'Register', 'click', 'Join as an individual']);
        });
        jQuery("#utype-yes").blur(function() {
            _gaq.push(['t2._trackEvent', 'Fundraised Before', 'click', 'Yes']);
        });
        jQuery("#utype-no").blur(function() {
            _gaq.push(['t2._trackEvent', 'Fundraised Before', 'click', 'No']);
        });
        jQuery("input[name='fr_part_radio']").blur(function() {
            _gaq.push(['t2._trackEvent', 'Participation Type', 'click', 'Field Day']);
        });
        jQuery("input[name='fr_part_radio']").blur(function() {
            _gaq.push(['t2._trackEvent', 'Participation Type', 'click', 'Field Day']);
        });
        jQuery("#next_step").blur(function() {
            _gaq.push(['t2._trackEvent', 'Button', 'click', 'Next']);
        });
        jQuery(".backBtnReg").blur(function() {
            _gaq.push(['t2._trackEvent', 'Button', 'click', 'Back']);
        });
        jQuery(".notTime input").blur(function() {
            _gaq.push(['t2._trackEvent', 'Select Options', 'click', 'Not at this time']);
        });
        jQuery(".healthyCheck input").blur(function() {
            _gaq.push(['t2._trackEvent', 'Healthy Check', 'click', 'No']);
        });
        jQuery("a:contains('Edit')").blur(function() {
            _gaq.push(['t2._trackEvent', 'Complete Registration', 'click', 'Edit']);
        });
        jQuery("button[value='Complete Registration']").blur(function() {
            _gaq.push(['t2._trackEvent', 'Complete Registration', 'click', 'Complete']);
        });
        jQuery("#cancel_button").blur(function() {
            _gaq.push(['t2._trackEvent', 'Complete Registration', 'click', 'Cancel']);
        });
        jQuery("#reg_payment_page #responsive_payment_typecc_numbername").blur(function() {
            _gaq.push(['t2._trackEvent', 'Reg Payment', 'click', 'Credit Card']);
        });
        jQuery("#reg_payment_page #responsive_payment_typecc_exp_date_MONTH").blur(function() {
            _gaq.push(['t2._trackEvent', 'Reg Payment', 'click', 'Expire Month']);
        });
        jQuery("#reg_payment_page #responsive_payment_typecc_exp_date_YEAR").blur(function() {
            _gaq.push(['t2._trackEvent', 'Reg Payment', 'click', 'Expire Year']);
        });
        jQuery("#reg_payment_page #responsive_payment_typecc_cvvname").blur(function() {
            _gaq.push(['t2._trackEvent', 'Reg Payment', 'click', 'CCV']);
        });
        jQuery("#reg_payment_page #billing_first_namename").blur(function() {
            _gaq.push(['t2._trackEvent', 'Reg Payment', 'click', 'First Name']);
        });
        jQuery("#reg_payment_page #billing_last_namename").blur(function() {
            _gaq.push(['t2._trackEvent', 'Reg Payment', 'click', 'Last Name']);
        });
        jQuery("#reg_payment_page #billing_addr_street1name").blur(function() {
            _gaq.push(['t2._trackEvent', 'Reg Payment', 'click', 'Street 1']);
        });
        jQuery("#reg_payment_page #billing_addr_street2name").blur(function() {
            _gaq.push(['t2._trackEvent', 'Reg Payment', 'click', 'Street 2']);
        });
        jQuery("#reg_payment_page #billing_addr_cityname").blur(function() {
            _gaq.push(['t2._trackEvent', 'Reg Payment', 'click', 'City']);
        });
        jQuery("#reg_payment_page #billing_addr_state").blur(function() {
            _gaq.push(['t2._trackEvent', 'Reg Payment', 'click', 'State']);
        });
        jQuery("#reg_payment_page #billing_addr_zipname").blur(function() {
            _gaq.push(['t2._trackEvent', 'Reg Payment', 'click', 'Zip']);
        });
        jQuery("#reg_payment_page #billing_addr_country").blur(function() {
            _gaq.push(['t2._trackEvent', 'Reg Payment', 'click', 'Country']);
        });
        jQuery("#reg_payment_page #btn_next").blur(function() {
            _gaq.push(['t2._trackEvent', 'Reg Payment', 'click', 'Next']);
        });
        jQuery("#part_ctr_container").blur(function() {
            _gaq.push(['t2._trackEvent', 'Reg Completed', 'click', 'Access Participant Center']);
        });

        jQuery("a:contains('Start a Team')").click(function(){
            _gaq.push(['t2._trackEvent', 'Register Landing', 'click', 'Start Team']);
        });
        jQuery("a:contains('Join a Team')").click(function(){
            _gaq.push(['t2._trackEvent', 'Register Landing', 'click', 'Join a Team']);
        });
        jQuery("a:contains('Join as Individual')").click(function(){
            _gaq.push(['t2._trackEvent', 'Register Landing', 'click', 'Join as Indiv']);
        });
        jQuery(".regMobilePhone input").blur(function() {
            _gaq.push(['t2._trackEvent', 'provide details', 'click', 'mobile number']);
        });
        jQuery("#mobile_optin").click(function(){
            _gaq.push(['t2._trackEvent', 'provide details', 'click', 'mobile opt in']);
        });


        var radioValue = '';
        $('.survivor_yes_no input').change(function() {
            radioValue = $(this).val();
            $('.survivor_yes_no li').removeClass('survivor_active');

            if ($(this).is(":checked") && radioValue == "Yes") {
                $(this).parent().parent().addClass('survivor_active');
            }
            if ($(this).is(":checked") && radioValue == "No") {
                $(this).parent().parent().addClass('survivor_active');
            }

        });

        if ($('#part_type_selection_container').length > 0) {
            var pTypeCurrent = jQuery('#part_type_selection_container .part-type-container.selected').find('.part-type-name').text();
            console.log('pTypeCurrent = ' + pTypeCurrent);
            pTypeSetCookie(pTypeCurrent);

            $('#part_type_selection_container label').click(function() {
                var pType = $(this).find('.part-type-name').text();
                console.log('pType after click ' + pType);
                pTypeSetCookie(pType);
            });

        }

        if ($('.lightboxWiaverContent').length > 0) {
            console.log("yes we're on the waiver page");

            $.ajax({
                type: 'GET',
                url: 'CRTeamraiserAPI',
                data: {
                    method: 'getParticipationTypes',
                    api_key: 'wDB09SQODRpVIOvX',
                    v: '1.0',
                    fr_id: fr_id,
                },
                dataType: 'xml'
            }).done(function(data) {
                processPTypesData(data);
            });
        }

        if ($('#team_find_existing').length > 0) {
            if ($('#team_find_search_results_header_text').length > 0) {
                location.hash = "team_label_container";
                jQuery('#team_find_search_results_container').focus();
                jQuery('#team_find_search_results_header_text').css('display', 'inline-block');
                jQuery('<span style="display:inline-block;padding-left: 20px;"><a href="javascript:void(0)" id="searchAgain">(Search Again)</a></span>').insertAfter('#team_find_search_results_header_text')
                jQuery("#searchAgain").on('click', function(event) {
                    window.scrollTo(0, 0);
                })
            }
            jQuery('.list-component-row.list-row').each(function() {
                var join_link = jQuery(this).find('.list-component-cell-column-team-name a').attr('href');
                jQuery(this).find('.list-component-cell-column-team-name a').contents().unwrap();
                jQuery(this).find('.list-component-cell-column-join-link .list-component-cell-data-text a').after('<a href="' + join_link + '" style="color:#cd181d!important;background:white;background-color:white !important;border:2px solid #cd181d!important;margin:5px auto 0;display:block;width:132px" target="_blank">View</a>');
            });
            //jQuery('.list-component-cell-column-join-link .list-component-cell-data-text a').css('display','block');
        }

    });

    function getURLParameter(url, name) {
      return (RegExp(name + '=' + '(.+?)(&|$)').exec(url) || [, null])[1];
    }

    function processPTypesData(data) {
        var userParticipationType = readCookie('pType');
        console.log(userParticipationType);
        var waiver, waiverHTML;
        $(data).find('participationType').each(function() {
            var nodeName = $(this).find('name').text();
            var nodeNameTrim = nodeName.replace(/\s/g, "").replace(/amp;/g, "");
            if (nodeNameTrim == userParticipationType) {
                waiver = $(this).find('waiver').text();
                waiverHTML = waiver.replace(/(?:\r\n\r\n|\r\r|\n\n)/, '<p>').replace(/(?:\r\n\r\n|\r\r|\n\n)/g, '</p><p>').replace('our Privacy Policy', '<a href="http://www.Heart.org/Privacy">our Privacy Policy</a>');
                waiverHTML = waiverHTML + "</p>";
                /*$('.lightboxWiaverContent').html(waiverHTML);*/
            }
        });
    }

    function pTypeSetCookie(pType) {
        var pTypeTrim = pType.replace(/\s/g, "");
        //console.log(pTypeTrim);
        document.cookie = "pType=" + pTypeTrim;
    }

    function readCookie(name) {
        var nameEQ = name + "=";
        var ca = document.cookie.split(';');
        for (var i = 0; i < ca.length; i++) {
            var c = ca[i];
            while (c.charAt(0) == ' ') c = c.substring(1, c.length);
            if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length, c.length);
        }
        return null;
    }

            // For Start Team, Join Team, Individual Participation, alphabetize sub- and sub-sub-company names in company list

            function Child(name,val,subChildren) {
              this.name = name,
              this.val = val,
              this.subChildren = subChildren
            }

            function subChildCompare( a, b ) {
              if ( a.subName < b.subName ){
                return -1;
              }
              if ( a.subName > b.subName ){
                return 1;
              }
              return 0;
            }

            function childCompare( a, b ) {
              if ( a.name < b.name ){
                return -1;
              }
              if ( a.name > b.name ){
                return 1;
              }
              return 0;
            }

//start sort function
            if (!String.prototype.startsWith) {
             Object.defineProperty(String.prototype, 'startsWith', {
                 value: function(search, rawPos) {
                     var pos = rawPos > 0 ? rawPos|0 : 0;
                     return this.substring(pos, pos + search.length) === search;
                 }
             });
            }

            if ($('#fr_co_list').length > 0 || $('#fr_part_co_list').length > 0){

              $.coList = $('#fr_co_list');
              if ($('#fr_part_co_list').length > 0){
                $.coList = $('#fr_part_co_list');
              }

              $.coList.children('option').each(function(){
                var val = $(this).html();
                if (val.startsWith('&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;') === true){
                  $(this).addClass('subSubCompany');
                }
              });

              $.coList.children('option').each(function(){
                var val = jQuery(this).html();
                if (val.startsWith('&nbsp;&nbsp;&nbsp;&nbsp;') === true && !$(this).hasClass('subSubCompany')){
                  $(this).addClass('subCompany');
                }
              });

              $('.subSubCompany').each(function(){
                if ($(this).prev().hasClass('subCompany')){
                  $(this).prev().addClass('subParentCompany');
                }
              });

              $('.subCompany').each(function(){
                if (!$(this).prev().hasClass('subCompany') && !$(this).prev().hasClass('subSubCompany')){
                  $(this).prev().addClass('parentCompany');
                }
              });

              $.coList.children('option').each(function(){
                if (!$(this).hasClass('parentCompany') && !$(this).hasClass('subCompany') && !$(this).hasClass('subSubCompany')) {
                  $(this).addClass('parentCompany');
                }
              });

              $('.parentCompany').each(function(){
                var parentName = $(this).text();
                parentName = parentName.replace(/\s/g, '');
                parentName = parentName.replace(/[^a-z0-9]/gi,'');
                $(this).nextUntil('.parentCompany').addClass(parentName);
              });


              $('.subSubCompany').each(function(){
                if ($(this).next().hasClass('parentCompany') === true || $(this).next().hasClass('subCompany') === true || $(this).next().hasClass('subParentCompany') === true) {
                  $(this).next().addClass('switchCompany');
                }
              });


              $('.parentCompany').each(function(){
                if ($(this).next('option').hasClass('subCompany')){
                  var parentName = $(this).text();
                  $.parentCompany = $(this);

                  var parentClass = parentName
                  parentClass = parentClass.replace(/\W/g, '');
                  parentClass = parentClass.replace(/\W/g, '');
                  var children = [];

                  var subParentNum = 0;
                  $('.'+parentClass + '.subParentCompany').each(function(){
                    subParentNum ++;
                    var subParentClass = String(subParentNum);
                    $(this).addClass(subParentClass);
                  });

                  $(this).nextUntil('.parentCompany').each(function(){
                    var name = $(this).text();
                    var val = $(this).val();
                    if ($(this).hasClass('subParentCompany')){
                      var subChildren = [];

                      if (subParentNum > 0){
                        $(this).nextUntil('.switchCompany').each(function(){
                          var subName = $(this).text();
                          var subVal = $(this).val();
                          subChildren.push({
                            subName: subName,
                            subVal: subVal
                          });
                          subChildren.sort( subChildCompare );
                        });

                        var child = new Child(name,val,subChildren);

                        children.push(child);
                      }
                      else{

                        $(this).nextUntil('.subCompany').each(function(){
                          var subName = $(this).text();
                          var subVal = $(this).val();
                          subChildren.push({
                            subName: subName,
                            subVal: subVal
                          });

                          subChildren.sort( subChildCompare );
                        });

                        var child = new Child(name,val,subChildren);

                        children.push(child);
                      }
                    }
                    else if ($(this).hasClass('subCompany')){
                      var child = new Child(name,val);
                       children.push(child);
                    }
                  });

                  children.sort( childCompare );
                  children.reverse();

                   $(this).nextUntil('.parentCompany').remove();

                  $.each(children,function(){
                    var options = '';
                    var option = '<option value="'+this.val+'" class="subCompany">'+this.name+'</option>';
//                    console.log('option ' + option);
                    options += option;

                    if ($(this.subChildren).length > 0){
                      $(this.subChildren).each(function(){
                        var suboption = '<option value="'+this.subVal+'" class="subSubCompany">'+this.subName+'</option>';
                       console.log('suboption ' + this.subName);
                        options += suboption;
                      });
                    }
                    $($.parentCompany).after(options);
                  });
                }
              });

              if ($('.js__reg-company-name').length > 0) {
                $.sortedCoList = $('#fr_co_list').html();
                $('.js__reg-company-name').append($.sortedCoList);
              }
            }

            if ($('body').is('.pg_regsummary')) {
              $('.progress-bar-container')
              $('.reg-summary-address-info .reg-summary-edit-link a').remove();
              $('.js--edit-ptype').attr('aria-label', 'Edit your fundraising goal').html('Edit your fundraising goal');
              if ( $('.team-status').html() === 'You are Starting a Team') {
                $('#another_button').remove();
              }
            }


            if ($('body').is('.pg_tfind')) {
              $('#fr_team_name').attr('title', 'Team Name required');
            }

            if ($('#F2fRegContact').length > 0 ) {
              $('.error').attr('role', 'alert');
              $('.consZip .input-container').attr('role', 'alert');
              console.log('adding alerts');
            }

            if ( $('.part-type-fee-text').is(':empty') ) {
              $('.part-type-fee-text').remove();
            }

            if ($('body').is('.pg_tfind')) {
              setTimeout(function(){ document.getElementById('fr_team_name').title = 'Team Name required'; }, 1000);
            }

})(jQuery);
