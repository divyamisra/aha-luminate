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
        $('#mobile-toggle').click(function () {
            if ($('#navbar-container').hasClass('is-search')) {
                $('#navbar-container').removeClass('is-search');
                $('.mobile-search-trigger').removeClass('active');
            } else {
                $('#navbar-container').slideToggle('fast');
            }
            $('.navbar-toggler-icon').toggleClass('fa-align-justify').toggleClass('fa-times');

            $('.pg_company .tr-page-container, .pg_personal .tr-page-container, .pg_tea .tr-page-container').toggleClass('static');

            $('.pg_company header, .pg_personal header, .pg_team header').toggleClass('mobile-open');

            if ( $('#navbar-container').is(':visible') ) {
              $('.pg_company .tr-page-container, .pg_personal .tr-page-container, .pg_tea .tr-page-container').addClass('static');

              $('.pg_company header, .pg_personal header, .pg_team header').addClass('mobile-open');
            } else {
              $('.pg_company .tr-page-container, .pg_personal .tr-page-container, .pg_tea .tr-page-container').removeClass('static');

              $('.pg_company header, .pg_personal header, .pg_team header').removeClass('mobile-open');
            }
        });

        // Mobile search toggle
        $('.mobile-search-trigger').click(function () {


            if ($('.navbar-toggler-icon').hasClass('fa-times')) {
                $('#navbar-container').addClass('is-search');
                $('.mobile-search-trigger').addClass('active');
                $('.navbar-toggler-icon').toggleClass('fa-align-justify').toggleClass('fa-times');
            } else {
                $('.mobile-search-trigger').toggleClass('active');
                $('.pg_company .tr-page-container, .pg_personal .tr-page-container, .pg_team .tr-page-container').addClass('static');
                if ($('#navbar-container').hasClass('is-search')) {
                    // Wait to toggle is-search class until the container
                    // is fully closed so that the user doesn't see the
                    // gray navigation appear as it closes
                    $('#navbar-container').slideToggle('fast', function () {
                        $('#navbar-container').toggleClass('is-search');
                    });
                } else {
                    $('#navbar-container').toggleClass('is-search');
                    $('#navbar-container').slideToggle('fast');
                }
            }

            if ( $('.mobile-search-trigger').removeClass('active') ) {
              $('.pg_company .tr-page-container, .pg_personal .tr-page-container, .pg_tea .tr-page-container').addClass('static');

              $('.pg_company header, .pg_personal header, .pg_team header').addClass('mobile-open');
            } else {
              $('.pg_company .tr-page-container, .pg_personal .tr-page-container, .pg_tea .tr-page-container').removeClass('static');

              $('.pg_company header, .pg_personal header, .pg_team header').removeClass('mobile-open');
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
        var eventType = 'Field%20Day';
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
        var teamId = getURLParameter(currentUrl, 'team_id');
        var companyIdParam = getURLParameter(currentUrl, 'company_id');

        var skipLink = document.getElementById('skip-main');

        var companyCSV = 'https://dev2.heart.org/fieldday_company_data/supplemental_company_data.csv';

        skipLink.addEventListener('click', function (e) {
            e.preventDefault();
            document.getElementById('contentStart').focus();
            document.getElementById('contentStart').scrollIntoView();
        });

        if ($('body').is('.pg_FieldDay_HQ')) {
            $('.js__skip-to').on('click', function (e) {
                e.preventDefault();
                $('html, body').animate({
                    scrollTop: $('#pcBodyContainer').offset().top
                }, 500);
            });
        }

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
                        }, 1000, function () {
                        });
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
                            $('#error-participant').removeAttr('hidden').text('Teammate not found. Please try different search terms.');
                        } else {
                            var participants = luminateExtend.utils.ensureArray(response.getParticipantsResponse.participant);
                            var totalParticipants = parseInt(response.getParticipantsResponse.totalNumberResults);

                            if ($.fn.DataTable) {
                                if ($.fn.DataTable.isDataTable('#participantResultsTable')) {
                                    $('#participantResultsTable').DataTable().destroy();
                                }
                            }
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
                                    $('.js--participants-results-rows').addClass('mobile').append('<tr><td><table><tr' + (i > 10 ? ' class="d-none"' : '') + '><td>Teammate</td><td><a href="' + participant.personalPageUrl + '">' +
                                        participant.name.first + ' ' + participant.name.last + '</a></td></tr>' +
                                        ((participant.teamName !== null && participant.teamName !== undefined) ? '<tr><td>Team</td><td><a href="' + participant.teamPageUrl + '">' + participant.teamName + '</a>' : '') +
                                        '</td></tr><tr><td>Event Name</td><td><a href="TR/?fr_id=' + participant.eventId + '&pg=entry">' + participant.eventName + '</a></td></tr><tr><td colspan="2" class="text-center"><a href="' + participant.donationUrl + '" class="btn btn-primary btn-block btn-rounded" title="Donate to ' + participant.name.first + ' ' + participant.name.last + '" aria-label="Donate to ' + participant.name.first + ' ' + participant.name.last + '">Donate</a></td></tr></table></td></tr>');
                                }


                            });

                            if (totalParticipants > 10) {
                                $('.js--more-participant-results').removeAttr('hidden');
                            }

                            if (screenWidth >= 768) {
                                $('#participantResultsTable').DataTable({
                                    "paging": false,
                                    "searching": false,
                                    "info": false,
                                    "autoWidth": false
                                });
                            }
                            $('.dataTables_length').addClass('bs-select');
                            //add call to hook donate button with payment type selections
                            addPaymentTypesOnSearch();
                            $('.js--participant-results-container').removeAttr('hidden');

                            $('.js--more-participant-results').on('click', function (e) {
                                e.preventDefault();
                                $('.js--participants-results-rows tr').removeClass('d-none');
                                $(this).attr('hidden', true);
                                $('.js--end-participant-list').removeAttr('hidden');
                            });

                        }
                    },
                    error: function (response) {
                        $('#error-participant').removeAttr('hidden').text(response.errorResponse.message);
                    }
                }
            });
        };

        cd.getTeams = function (teamName, isCrossEvent) {
            $('.js__team-results-rows').html('');
            luminateExtend.api({
                api: 'teamraiser',
                data: 'method=getTeamsByInfo' +
                    '&team_name=' + teamName +
                    (isCrossEvent === true ? '&event_type=' + eventType : '&fr_id=' + evID) +
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

                            if (totalTeams > 10) {
                                $('.js--more-team-results').removeAttr('hidden');
                            }

                            $('.js--team-results-container').removeAttr('hidden');

                            $('.js--more-team-results').on('click', function (e) {
                                e.preventDefault();
                                $('.js--team-results-rows tr').removeClass('d-none');
                                $(this).attr('hidden', true);
                                $('.js--end-team-list').removeAttr('hidden');
                            });
                            if (screenWidth >= 768) {
                                $('#teamResultsTable').DataTable({
                                    "paging": false,
                                    "searching": false,
                                    "info": false
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
            cd.getCompanyData();
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

                      if ($.fn.DataTable) {
                          if ($.fn.DataTable.isDataTable('#companyResultsTable')) {
                              $('#companyResultsTable').DataTable().destroy();
                          }
                      }
                      $('#companyResultsTable tbody').empty();
                        if (response.getCompaniesResponse.totalNumberResults === '0') {
                            // no search results
                            $('#error-company').removeAttr('hidden').text('Company not found. Please try different search terms.');
                        } else {
                            var companies = luminateExtend.utils.ensureArray(response.getCompaniesResponse.company);
                            var totalCompanies = parseInt(response.getCompaniesResponse.totalNumberResults);
                            $('.js--num-company-results').text((totalCompanies === 1 ? '1 Result' : totalCompanies + ' Results'));

                            $(companies).each(function (i, company) {

                              var companyId = company.companyId;
                              var companyLocation;
                              var companyLead;

                              companyLocation = $('#company-id-'+ companyId + ' .js--company-data-location').html();
                              companyLead = $('#company-id-'+ companyId + ' .js--company-data-coordinator').html();

                              if (screenWidth >= 768) {
                              $('.js--company-results-rows').append('<tr' + (i > 10 ? ' class="d-none"' : '') + '><td><a href="' + company.companyURL + '">' +
                                  company.companyName + '</a></td><td class="col-cta">' + (companyLead !== undefined ? companyLead : '') + '</td><td class="col-cta">' + (companyLocation !== undefined ? companyLocation : '') + '</td><td class="col-cta"><a class="btn btn-primary btn-block btn-rounded" title="Details about ' + company.companyName + '" href="' + company.companyURL + '">' + 'Details</a></td></tr>');
                              } else {
                                  $('#companyResultsTable thead').remove();
                                  $('.js--company-results-rows')
                                      .addClass('mobile')
                                      .append('<tr><td><table><tr' + (i > 10 ? ' class="d-none"' : '') + '><td>Company</td><td><a href="' + company.companyURL + '">' +
                                          company.companyName + '</a></td></tr><tr><td>Company Lead</td><td>' + (companyLead !== undefined ? companyLead : '') + '</td></tr>' +
                                          ((team.companyName !== null && team.companyName !== undefined) ? '<tr><td>Company</td><td><a href="TR?company_id=' + team.companyId + '&fr_id=' + team.EventId + '&pg=company">' + team.companyName + '</a>' : '') +
                                          '</td></tr><tr><td>Event Location</td><td class="col-cta">' + (companyLocation !== undefined ? companyLocation : '') + '</td></tr><tr><td class="col-cta"><a class="btn btn-primary btn-block btn-rounded" title="Details about ' + company.companyName + '" href="' + company.companyURL + '">' + 'Details</a></td></tr></table></td></tr>');
                              }
                            });

                            $('.js--company-results-container').removeAttr('hidden');
                            $('.js--company-results-container').removeAttr('hidden');

                            if (screenWidth >= 768) {
                                $('#companyResultsTable').DataTable({
                                    "paging": false,
                                    "searching": false,
                                    "info": false,
                                    "autoWidth": false
                                });
                            }

                            $('.dataTables_length').addClass('bs-select');
                        }
                    },
                    error: function (response) {
                        $('.js--company-results-container').removeAttr('hidden').text(response.errorResponse.message);
                    }
                }
            });
        };

        cd.getTeamCaptains = function () {
            luminateExtend.api({
                api: 'teamraiser',
                data: 'method=getTeamCaptains' +
                    '&fr_id=' + evID +
                    '&team_id=' + teamId +
                    '&response_format=json',
                callback: {
                    success: function (response) {
                            var captains = luminateExtend.utils.ensureArray(response.getTeamCaptainsResponse.captain);

                            $(captains).each(function (i, captain) {
                              var captainName = captain.name.first + ' ' + captain.name.last;
                              var captainPage = captain.personalPageUrl;

                            $('<p><a aria-label="Visit fundraising page for Team Captain ' + captainName +'" href="'+ captainPage +'">' + captainName +' </p>').appendTo('.js--team-captain');
                            });

                    },
                    error: function (response) {
                        console.log(response.errorResponse.message);
                    }
                }
            });
        };

        // Header Search Forms
        //search by company
        $('.js--header-company-search').on('submit', function (e) {
            e.preventDefault();
            var companySearched = encodeURIComponent($('#companySearch').val());
            if ( $('body').is('.pg_FieldDay_General') || $('body').is('.pg_FieldDay_Landing_Page') ) {
              window.location.href = luminateExtend.global.path.secure + 'SPageServer/?pagename=FieldDay_Search&search_type=company&cross_event=true&company=' + companySearched;
            } else {
              window.location.href = luminateExtend.global.path.secure + 'SPageServer/?pagename=FieldDay_Search&search_type=company'  + (evID ? '&cross_event=false&fr_id=' + evID : '&cross_event=true') + '&company=' + companySearched;
            }
        });

        // Search by Event
        $('.js--header-zip-search').on('submit', function (e) {
            e.preventDefault();
            var zipSearched = encodeURIComponent($('#zipSearch').val());
            if ( $('body').is('.pg_FieldDay_General') || $('body').is('.pg_FieldDay_Landing_Page') ) {
              window.location.href = luminateExtend.global.path.secure + 'SPageServer/?pagename=FieldDay_Search&search_type=zip&cross_event=true&zip=' + zipSearched;
            } else {
              window.location.href = luminateExtend.global.path.secure + 'SPageServer/?pagename=FieldDay_Search&search_type=zip'  + (evID ? '&cross_event=false&fr_id=' + evID : '&cross_event=true') + '&zip=' + zipSearched;
            }
        });

        //
        $('.js--header-state-search').on('submit', function (e) {
            e.preventDefault();
            var stateSearch = encodeURIComponent($('#stateSearch').val());
            if ( $('body').is('.pg_FieldDay_General') || $('body').is('.pg_FieldDay_Landing_Page') ) {
              window.location.href = luminateExtend.global.path.secure + 'SPageServer/?pagename=FieldDay_Search&search_type=state&cross_event=true&state=' + stateSearched;
            } else {
              window.location.href = luminateExtend.global.path.secure + 'SPageServer/?pagename=FieldDay_Search&search_type=state'  + (evID ? '&cross_event=false&fr_id=' + evID : '&cross_event=true') + '&state=' + stateSearched;
            }
        });


        $('#stateSearch').on('change', function () {
            var stateSearch = encodeURIComponent($('#stateSearch').val());
            if ( $('body').is('.pg_FieldDay_General') || $('body').is('.pg_FieldDay_Landing_Page') ) {
              window.location.href = luminateExtend.global.path.secure + 'SPageServer/?pagename=FieldDay_Search&search_type=state&cross_event=true&state=' + stateSearch;
            } else {
              window.location.href = luminateExtend.global.path.secure + 'SPageServer/?pagename=FieldDay_Search&search_type=state'  + (evID ? '&cross_event=false&fr_id=' + evID : '&cross_event=true') + '&state=' + stateSearch;
            }
        });

        // Search page by Participant
        $('.js--header-participant-search').on('submit', function (e) {
            e.preventDefault();
            var firstName = encodeURIComponent($('#participantSearchFirst').val());
            var lastName = encodeURIComponent($('#participantSearchLast').val());

            if ( $('body').is('.pg_FieldDay_General') || $('body').is('.pg_FieldDay_Landing_Page') ) {
              window.location.href = luminateExtend.global.path.secure + 'SPageServer/?pagename=FieldDay_Search&search_type=participant&cross_event=true' + (firstName ? '&first_name=' + firstName : '') + (lastName ? '&last_name=' + lastName : '');
            } else {
              window.location.href = luminateExtend.global.path.secure + 'SPageServer/?pagename=FieldDay_Search&search_type=participant'  + (evID ? '&cross_event=false&fr_id=' + evID : '&cross_event=true') + (firstName ? '&first_name=' + firstName : '') + (lastName ? '&last_name=' + lastName : '');
            }
        });

        // Search by Team
        $('.js--header-team-search').on('submit', function (e) {
            e.preventDefault();
            var teamName = encodeURIComponent($('#teamSearch').val());
            cd.getTeams(teamName, (isCrossEventSearch === "true" ? true : false));

            if ( $('body').is('.pg_FieldDay_General') || $('body').is('.pg_FieldDay_Landing_Page') ) {
              window.location.href = luminateExtend.global.path.secure + 'SPageServer/?pagename=FieldDay_Search&search_type=team&cross_event=true&team_name=' + teamName;
            } else {
              window.location.href = luminateExtend.global.path.secure + 'SPageServer/?pagename=FieldDay_Search&search_type=team'  + (evID ? '&cross_event=false&fr_id=' + evID : '&cross_event=true') + '&team_name=' + teamName;
            }
        });


        /******************************/
        /* EVENT SEARCH SCRIPTS */
        /******************************/

        // Get events by zip
        cd.getEventsByDistance = function (zipCode, isCrossEvent) {
            $('#eventStateResultsTable').addClass('d-none');
            $('#eventResultsTable').removeClass('d-none');
            $('#error-event').addClass('d-none');

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

                            if ($.fn.DataTable) {
                                if ($.fn.DataTable.isDataTable('#eventResultsTable')) {
                                    $('#eventResultsTable').DataTable().destroy();
                                }
                            }
                            $('#eventResultsTable tbody').empty();

                            $('.js--num-event-results').text((totalEvents === 1 ? '1 Result' : totalEvents + ' Results'));

                            $(events).each(function (i, event) {
                                var eventStatus = event.status;
                                var acceptsRegistration = event.accepting_registrations;

                                if (screenWidth >= 768) {
                                    var eventRow = '<tr' + (i > 10 ? ' class="d-none"' : '') + '><td><a href="' +
                                        event.greeting_url + '">' + event.name + '</a></td><td>' + event.city + ', ' +  event.state + '</td><td data-order="' + parseFloat(event.distance) + '">' + event.distance + 'mi</td><td><a href="' + event.greeting_url + '" aria-label="More details about ' + event.name + '" class="btn btn-secondary btn-block btn-rounded">Details</a></td><td class="col-cta">' + (acceptsRegistration === 'true' ? '<a href="SPageServer/?pagename=fieldday_register&fr_id=' + event.id + '" aria-label="Register for ' + event.name + '" class="btn btn-primary btn-block btn-rounded">Register</a>' : 'Registration Closed') + '</td></tr>';
                                } else {
                                    $('#eventResultsTable thead').remove();
                                    $('.js--event-results-rows').addClass('mobile')

                                    var eventRow = '<tr><td><table><tr' + (i > 10 ? ' class="d-none"' : '') + '><td>Event Name</td><td><a href="' +
                                        event.greeting_url + '">' + event.name + '</a></td></tr>' +
                                        '</td></tr><tr><td>Date</td></tr><tr><td>Distance</td><td>' + event.distance + 'mi</td></tr><tr><td colspan="2" class="text-center">' + (acceptsRegistration === 'true' ? '<a href="SPageServer/?pagename=fieldday_register&fr_id=' + event.id + '" class="btn btn-primary btn-block btn-rounded" title="Register for ' + event.name + '" aria-label="Register for ' + event.name + '">Register</a>' : 'Registration Closed') + '</td></tr></table></td></tr>';
                                }


                                if (eventStatus === '1' || eventStatus === '2' || eventStatus === '3') {
                                    $('.js--event-results-rows').append(eventRow);
                                }
                            });

                            if (totalEvents > 10) {
                                $('.js--more-event-results').removeClass('hidden');
                            }

                            $('.js--more-event-results').on('click', function (e) {
                                e.preventDefault();
                                $('.js--event-results-rows tr').removeClass('d-none');
                                $(this).addClass('hidden');
                                $('.js--end-event-list').removeAttr('hidden');
                            });
                            if (screenWidth >= 768) {
                                $('#eventResultsTable').DataTable({
                                    "paging": false,
                                    "searching": false,
                                    "info": false
                                });
                            }
                            $('.dataTables_length').addClass('bs-select');

                            $('.js--event-results-container').removeAttr('hidden');
                        } else {
                            $('.js--loading').hide();
                            $('#error-event').removeClass('d-none');
                            $('#error-event').removeAttr('hidden');
                        }
                    },
                    error: function (response) {
                        $('.js--loading').hide();
                    }
                }
            });
        };
        // END getEventsByDistance

        // Get events by state
        cd.getEventsByState = function (eventState, isCrossEvent) {
          $('#eventResultsTable').addClass('d-none');
          $('#eventStateResultsTable').removeClass('d-none');
          $('#error-event').addClass('d-none');
            $('.js--loading').show();

            luminateExtend.api({
            api: 'teamraiser',
            data: 'method=getTeamraisersByInfo' +
                '&state=' + eventState +
                '&event_type=' + eventType +
                '&search_distance=200' +
                '&response_format=json&list_page_size=499&list_page_offset=0&list_sort_column=event_date&list_ascending=true',
            callback: {
                    success: function (response) {
                        if (response.getTeamraisersResponse.totalNumberResults > '0') {
                            $('.js--loading').hide();
                            var events = luminateExtend.utils.ensureArray(response.getTeamraisersResponse.teamraiser);
                            var totalEvents = parseInt(response.getTeamraisersResponse.totalNumberResults);

                            if ($.fn.DataTable) {
                                if ($.fn.DataTable.isDataTable('#eventStateResultsTable')) {
                                    $('#eventStateResultsTable').DataTable().destroy();
                                }
                            }
                            $('#eventStateResultsTable tbody').empty();

                            $('.js--num-event-results').text((totalEvents === 1 ? '1 Result' : totalEvents + ' Results'));

                            $(events).each(function (i, event) {

                                var eventStatus = event.status;
                                var acceptsRegistration = event.accepting_registrations;

                                if (screenWidth >= 768) {
                                    var eventRow = '<tr' + (i > 10 ? ' class="d-none"' : '') + '><td><a href="' +
                                        event.greeting_url + '">' + event.name + '</a></td><td>' + event.city + ', ' +  event.state + '</td><td><a href="' + event.greeting_url + '" aria-label="More details about ' + event.name + '" class="btn btn-secondary btn-block btn-rounded">Details</a></td><td class="col-cta">' + (acceptsRegistration === 'true' ? '<a href="SPageServer/?pagename=fieldday_register&fr_id=' + event.id + '" aria-label="Register for ' + event.name + '" class="btn btn-primary btn-block btn-rounded">Register</a>' : 'Registration Closed') + '</td></tr>';
                                } else {
                                    $('#eventStateResultsTable thead').remove();
                                    $('.js--event-state-results-rows').addClass('mobile')

                                    var eventRow = '<tr><td><table><tr' + (i > 10 ? ' class="d-none"' : '') + '><td>Event Name</td><td><a href="' +
                                        event.greeting_url + '">' + event.name + '</a></td></tr>' +
                                        '</td></tr><tr><td>Date</td></tr><tr><td colspan="2" class="text-center">' + (acceptsRegistration === 'true' ? '<a href="SPageServer/?pagename=fieldday_register&fr_id=' + event.id + '" class="btn btn-primary btn-block btn-rounded" title="Register for ' + event.name + '" aria-label="Register for ' + event.name + '">Register</a>' : 'Registration Closed') + '</td></tr></table></td></tr>';
                                }


                                if (eventStatus === '1' || eventStatus === '2' || eventStatus === '3') {
                                    $('.js--event-state-results-rows').append(eventRow);
                                }
                            });

                            if (totalEvents > 10) {
                                $('.js--more-event-results').removeClass('hidden');
                            }

                            $('.js--more-event-results').on('click', function (e) {
                                e.preventDefault();
                                $('.js--event-state-results-rows tr').removeClass('d-none');
                                $(this).addClass('hidden');
                                $('.js--end-event-list').removeAttr('hidden');
                            });
                            if (screenWidth >= 768) {
                                $('#eventStateResultsTable').DataTable({
                                    "paging": false,
                                    "searching": false,
                                    "info": false
                                });
                            }
                            $('.dataTables_length').addClass('bs-select');

                            $('.js--event-results-container').removeAttr('hidden');
                        } else {
                          $('.js--loading').hide();
                          $('#error-event').removeClass('d-none');
                          $('#error-event').removeAttr('hidden');
                        }
                    },
                    error: function (response) {
                        $('.js--loading').hide();
                    }
                }
            });
        };
        // END getEventsByState

        // Get events by name or state
        cd.getEvents = function (eventName, eventState) {
            $('.js--loading').show();
            $('.js--no-event-results').addClass('d-none');
            $('.js--no-event-results').removeAttr('role');


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
                                    eventType + ' Event</span></div><a href="' +
                                    greetingUrl + '" class="event-detail-button btn col-2" aria-label="Visit event page for CycleNation ' + eventCity + '"><i class="fas fa-angle-right" aria-hidden="true" alt=""></i></a></li>';

                                if (eventStatus === '1' || eventStatus === '2' || eventStatus === '3') {
                                    $('.js--event-search-results').append(eventRow);
                                }
                            });
                        } else {
                            $('.js--loading').hide();
                            $('.js--no-event-results').removeClass('d-none').html('<span>We&rsquo;re not seeing anything. Maybe try different search term?</span>');
                            $('.js--no-event-results').attr('role', 'alert');
                        }
                    },
                    error: function (response) {
                        $('.js--loading').hide();
                    }
                }
            });
        };

        // Get events by zip

        cd.getEventsByDistanceLanding = function (zipCode) {
            $('.js--no-event-results').addClass('d-none');
            $('.js--no-event-results').removeAttr('role');

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

                            $(events).each(function (i, event) {

                                var eventStatus = event.status;
                                var acceptsRegistration = event.accepting_registrations;

                                var eventRow = '<div class="event-results__company row' + (i > 10 ? ' class="d-none"' : '') + '"><div class="col-12 col-md-6 d-flex align-items-center justify-content-center"><h3>' + event.name + '</h3></div><div class="col-12 col-md-6 d-flex align-items-center justify-content-center"><a href="' +
                                        event.greeting_url + '" class="btn btn-primary">Find a Company</a></div></div>';


                                if (eventStatus === '1' || eventStatus === '2' || eventStatus === '3') {
                                    $('.js--event-search-results').append(eventRow);
                                }
                            });

                            if (totalEvents > 10) {
                                $('.js--more-event-results').removeClass('hidden');
                            }

                            $('.js--more-event-results').on('click', function (e) {
                                e.preventDefault();
                                $('.js--event-search-results row').removeClass('d-none');
                                $(this).addClass('hidden');
                                $('.js--end-event-list').removeAttr('hidden');
                            });

                            $('.js--event-results-container').removeAttr('hidden');
                        } else {
                            $('.js--loading').hide();
                            $('.js--no-event-results').removeClass('d-none');
                            $('.js--no-event-results').attr('role', 'alert');
                        }
                    },
                    error: function (response) {
                        $('.js--loading').hide();
                    }
                }
            });
        };
        // END getEventsByDistance

        // getEventsByStateLanding
        cd.getEventsByStateLanding = function (eventState) {
            $('.js--no-event-results').addClass('d-none');
            $('.js--no-event-results').removeAttr('role');

            $('.js--loading').show();

            luminateExtend.api({
                api: 'teamraiser',
                data: 'method=getTeamraisersByInfo' +
                    '&state=' + eventState +
                    '&event_type=' + eventType +
                    '&search_distance=200' +
                    '&response_format=json&list_page_size=499&list_page_offset=0&list_sort_column=event_date&list_ascending=true',
                callback: {
                    success: function (response) {
                        if (response.getTeamraisersResponse.totalNumberResults > '0') {
                            $('.js--loading').hide();
                            var events = luminateExtend.utils.ensureArray(response.getTeamraisersResponse.teamraiser);
                            var totalEvents = parseInt(response.getTeamraisersResponse.totalNumberResults);

                            $(events).each(function (i, event) {

                                var eventStatus = event.status;
                                var acceptsRegistration = event.accepting_registrations;

                                var eventRow = '<div class="event-results__company row' + (i > 10 ? ' class="d-none"' : '') + '"><div class="col-12 col-md-6 d-flex align-items-center justify-content-center"><h3>' + event.name + '</h3></div><div class="col-12 col-md-6 d-flex align-items-center justify-content-center"><a class="btn btn-primary" href="' +
                                        event.greeting_url + '" class="btn btn-primary">Find a Company</a></div></div>';


                                if (eventStatus === '1' || eventStatus === '2' || eventStatus === '3') {
                                    $('.js--event-search-results').append(eventRow);
                                }
                            });

                            if (totalEvents > 10) {
                                $('.js--more-event-results').removeClass('hidden');
                            }

                            $('.js--more-event-results').on('click', function (e) {
                                e.preventDefault();
                                $('.js--event-search-results row').removeClass('d-none');
                                $(this).addClass('hidden');
                                $('.js--end-event-list').removeAttr('hidden');
                            });

                            $('.js--event-results-container').removeAttr('hidden');
                        } else {
                            $('.js--loading').hide();
                            $('.js--no-event-results').removeClass('d-none');
                            $('.js--no-event-results').attr('role', 'alert');
                        }
                    },
                    error: function (response) {
                        $('.js--loading').hide();
                    }
                }
            });
        };
        // END getEventsByStateLanding


        // getCompaniesLandingPage
        cd.getCompaniesLanding = function (companyName) {
            cd.getCompanyData();
            $('.js--no-participant-results, .js--participant-no-event-results').addClass('d-none');
            $('.js--no-participant-results, .js--participant-no-event-results').removeAttr('role');
            $('.js--participant-loading').show();

            luminateExtend.api({
                api: 'teamraiser',
                data: 'method=getCompaniesByInfo' +
                    '&company_name=' + companyName +
                    '&event_type=' + eventType +
                    '&response_format=json&list_page_size=499&list_page_offset=0',
                callback: {
                    success: function (response) {
                        if (response.getCompaniesResponse.totalNumberResults > '0') {
                            $('.js--participant-loading').hide();
                            var companies = luminateExtend.utils.ensureArray(response.getCompaniesResponse.company);
                            var totalEvents = parseInt(response.getCompaniesResponse.totalNumberResults);

                            $(companies).each(function (i, company) {

                                var companyId = company.companyId;

                                var companyLocation;

                                companyLocation = $('#company-id-'+ companyId + ' .js--company-data-location').html();


                                var eventRow = '<div class="row py-3' + (i > 10 ? ' d-none' : '') + '"><div class="landing-participant-search__name col-12 col-lg-6"><p><a href="'+ company.companyURL +'">'+ company.companyName +'</a><br>';

                                if (companyLocation !== undefined ) {
                                  eventRow += '<span class="js--company-location">'+ companyLocation +'</span>'
                                }

                                eventRow +='</p></div><div class="landing-participant-search__register col-12 col-lg-6"><p><a href="'+ company.companyURL +'" class="btn btn-primary">Register</a></p></div>';

                                $('.js--participant-search-results').append(eventRow);

                            });

                            if (totalEvents > 10) {
                                $('.js--participant-more-event-results').removeClass('hidden');
                            }

                            $('.js--participant-more-event-results').on('click', function (e) {
                                e.preventDefault();
                                $('.js--participant-search-results .row').removeClass('d-none');
                                $(this).addClass('hidden');
                            });

                            $('.js--participant-search-results').removeAttr('hidden');
                        } else {
                            $('.js--participant-loading').hide();
                            $('.js--participant-no-event-results').removeClass('d-none');
                            $('.js--no-participant-results, .js--participant-no-event-results').addAttr('role', 'alert');
                        }
                    },
                    error: function (response) {
                        $('.js--participant-loading').hide();
                    }
                }
            });
        };
        // END getCompaniesLandingPage


        // getCompaniesLandingPage
        cd.getParticipantsLanding = function (firstName, lastName) {
            $('.js--no-participant-results, .js--participant-no-event-results').addClass('d-none');
            $('.js--participant-loading').show();

            luminateExtend.api({
                api: 'teamraiser',
                data: 'method=getParticipants' +
                    '&first_name=' + (firstName ? firstName : '%25%25') +
                    '&lastName=' + (lastName ? lastName : '%25%25') +
                    '&event_type=' + eventType +
                    '&response_format=json&list_page_size=499&list_page_offset=0',
                callback: {
                    success: function (response) {
                        if (response.getParticipantsResponse.totalNumberResults > '0') {
                            $('.js--participant-loading').hide();
                            var participants = luminateExtend.utils.ensureArray(response.getParticipantsResponse.participant);
                            var totalEvents = parseInt(response.getParticipantsResponse.totalNumberResults);

                            $(participants).each(function (i, participant) {

                                var eventRow = '<div class="row py-3 ' + (i > 10 ? ' d-none' : '') + '"><div class="landing-participant-search__name col-12 col-lg-6"><p><a href="'+ participant.personalPageUrl + '">' + participant.name.first + ' ' + participant.name.last +'</a><br>' +
                              (participant.teamName ? participant.teamName : "")  + '</p></div><div class="landing-participant-search__register col-12 col-lg-6"><p><a href="'+ participant.donationUrl +'" class="btn btn-primary">Donate</a></p></div>';

                                $('.js--participant-search-results').append(eventRow);

                            });

                            if (totalEvents > 10) {
                                $('.js--participant-more-event-results').removeClass('hidden');
                            }

                            $('.js--participant-more-event-result').on('click', function (e) {
                                e.preventDefault();
                                $('.js--participant-search-results .row').removeClass('d-none');
                                $(this).addClass('hidden');
                            });

                            $('.js--participant-search-results').removeAttr('hidden');
                        } else {
                            $('.js--participant-loading').hide();
                            $('.js--participant-no-event-results').removeClass('d-none');
                        }
                    },
                    error: function (response) {
                        $('.js--participant-loading').hide();
                    }
                }
            });
        };
        // END getCompaniesLandingPage




        /***********************/
        /* THERMOMETER SCRIPTS */
        /***********************/

        cd.runThermometer = function (raised, goal) {
            var fundraiserRaised = Number(raised.replace(/[^0-9.-]+/g, ''));
            var fundraiserGoal = Number(goal.replace(/[^0-9.-]+/g, ''));

            var percentRaised = (fundraiserRaised / fundraiserGoal);
            if (isNaN(percentRaised)) {
                percentRaised = 0;
            }
            var percentRaisedFormatted = (percentRaised * 100) + '%';

            $('.js__progress-bar')
                .animate({width: percentRaisedFormatted}, 2000)
                .attr("aria-valuenow", percentRaised * 100);
            $('.js__progress-bar svg').show();
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
                data: 'method=getParticipants&first_name=%25%25%25&event_type=' + eventType + '&fr_id=' + eventId + '&list_sort_column=total&list_ascending=false&list_page_size=10&response_format=json',
                callback: {
                    success: function (response) {
                        if (!$.isEmptyObject(response.getParticipantsResponse)) {
                            var counter = 0;
                            var participantData = luminateExtend.utils.ensureArray(response.getParticipantsResponse
                                .participant);

                            $(participantData).each(function () {
                                if (counter <= 4) {
                                    var participantName = this.name.first + ' ' + this.name.last;
                                    var participantRaised = (parseInt(this.amountRaised) * 0.01).toFixed(2);

                                    var participantRaisedFormmatted = participantRaised.toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,").replace('.00', '');
                                    var participantId = this.consId;
                                    var participantPage = this.personalPageUrl;
                                    var isCaptain = this.aTeamCaptain;
                                    var topWalkerHtml = '<li><div class="d-flex"><div class="flex-grow-1"><a href="' + participantPage + '">' + participantName + '</a></div><div class="raised">Raised<br><strong>$' + participantRaisedFormmatted + '</strong></div></div></li>';
                                    if (participantName !== "null null") {
                                        $('.js--participant-top-list ul').append(topWalkerHtml);
                                        counter = counter + 1;
                                    }
                                }
                            });
                        }
                    },
                    error: function (response) {
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
                                var teamRaised = (parseInt(this.amountRaised) * 0.01).toFixed(2);

                                var teamRaisedFormmatted = teamRaised.toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,").replace('.00', '');
                                var teamId = this.id;

                                var topTeamRow = '<li><div class="d-flex"><div class="flex-grow-1"><a href="TR/?team_id=' + teamId + '&amp;pg=team&amp;fr_id=' + evID + '">' + teamName + '</a></div><div class="raised">Raised<br><strong>$' + teamRaisedFormmatted + '</strong></div></div></li>';

                                $('.js--team-top-list ul').append(topTeamRow);
                            });
                        }
                    },
                    error: function (response) {
                        // console.log('getTopTeams error: ' + response.errorResponse.message);
                    }
                }
            });
        };

        // END TOP TEAMS

        // BEGIN TOP COMPANIES
// TODO - replace with companyList

        cd.getCompanyList = function (eventId) {
            luminateExtend.api({
                api: 'teamraiser',
                data: 'method=getCompanyList&fr_id=' + eventId +
                    '&include_all_companies=true&response_format=json',
                callback: {
                    success: function (response) {
                        var childCompanyIdMap, companyItems, ref, rootAncestorCompanies;
                        companyItems = ((ref = response.getCompanyListResponse) != null ? ref.companyItem : void 0) || [];
                        if (!$.isArray(companyItems)) {
                            companyItems = [companyItems];
                        }
                        rootAncestorCompanies = [];
                        childCompanyIdMap = {};
                        $.each(companyItems, function (i, companyItem) {
                            var rootAncestorCompany;
                            if (companyItem.parentOrgEventId == '0') {
                                rootAncestorCompany = {
                                    eventId: eventId,
                                    companyId: companyItem.companyId,
                                    companyName: companyItem.companyName,
                                    amountRaised: companyItem.amountRaised ? Number(companyItem.amountRaised) : 0
                                };
                                rootAncestorCompanies.push(rootAncestorCompany);
                            }
                        });
                        $.each(companyItems, function (i, companyItem) {
                            var parentOrgEventId;
                            parentOrgEventId = companyItem.parentOrgEventId;
                            if (parentOrgEventId != "0") {
                                childCompanyIdMap['company-' + companyItem.companyId] = parentOrgEventId;
                            }
                        });
                        $.each(childCompanyIdMap, function (key, value) {
                            if (childCompanyIdMap['company-' + value]) {
                                childCompanyIdMap[key] = childCompanyIdMap['company-' + value];
                            }
                        });
                        $.each(childCompanyIdMap, function (key, value) {
                            if (childCompanyIdMap['company-' + value]) {
                                childCompanyIdMap[key] = childCompanyIdMap['company-' + value];
                            }
                        });
                        $.each(companyItems, function (i, companyItem) {
                            var childCompanyAmountRaised, rootParentCompanyId;
                            if (companyItem.parentOrgEventId != '0') {
                                rootParentCompanyId = childCompanyIdMap['company-' + companyItem.companyId];
                                childCompanyAmountRaised = companyItem.amountRaised ? Number(companyItem.amountRaised) : 0;
                                $.each(rootAncestorCompanies, function (rootAncestorCompanyIndex, rootAncestorCompany) {
                                    if (rootAncestorCompany.companyId === rootParentCompanyId) {
                                        rootAncestorCompanies[rootAncestorCompanyIndex].amountRaised = rootAncestorCompanies[rootAncestorCompanyIndex].amountRaised + childCompanyAmountRaised;
                                    }
                                });
                            }
                        });

                        //$.each(rootAncestorCompanies, function(rootAncestorCompanyIndex, rootAncestorCompany) {
                        //   rootAncestorCompanies[rootAncestorCompanyIndex].amountRaisedFormatted = $filter('currency')(rootAncestorCompany.amountRaised / 100, '$', 0);
                        //});
                        var sortedAncestorCompanies = rootAncestorCompanies.sort(function (a, b) {
                            return b.amountRaised - a.amountRaised
                        });
                        //var sortedAncestorCompanies = $filter('orderBy')(rootAncestorCompanies, 'amountRaised', true);
                        $(sortedAncestorCompanies).each(function (i) {
                            if (i < 5) {
                                var companyName = this.companyName;
                                var companyRaised = (parseInt(this.amountRaised) * 0.01).toFixed(2);
                                var companyRaisedFormmatted = companyRaised.toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,").replace('.00', '');
                                var topCompanyHtml = '<li><div class="d-flex"><div class="flex-grow-1"><a href="TR?company_id=' + this.companyId + '&fr_id=' + evID + '&pg=company">' + companyName + '</a></div><div class="raised">Raised<br><strong>$' + companyRaisedFormmatted + '</strong></div></div></li>';
                                $('.js--company-top-list ul').append(topCompanyHtml);
                            }
                        });
                    },
                    error: function (response) {
                        // console.log('getCompanyList error: ' + response.errorResponse.message);
                    }
                }
            });
        };

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
                        }
                    },
                    error: function (response) {
                        // console.log('getTopCompanies error: ' + response.errorResponse.message);
                    }
                }
            });
        };

        //CUSTOM COMPANY DATA FUNCTIONS


        cd.getCompanyByID = function(arr, value) {
     	  for (var i=0, iLen=arr.length; i<iLen; i++) {
     	    if (arr[i].companyid == value) return arr[i];
     		 }
     		}

       cd.getCompanyData = function() {
   			Papa.parse(companyCSV, {
   				header: true,
   				download: true,
   				dynamicTyping: true,
   				complete: function(results) {
   					var companies = results.data;
   					$('<div class="js--company-data hidden"></div>').insertAfter('main');
   			 	  for (var i=0, iLen=companies.length; i<iLen; i++) {
   							var dataOutput = '<div id="company-id-' + companies[i].companyid + '">';
   							dataOutput += '<div class="js--company-data-location">'+ companies[i].eventcity + ', ' + companies[i].eventstate + '</div>';
   							dataOutput += '<div class="js--company-data-coordinator">'+ companies[i].coordinatorfirstname + ' ' + companies[i].coordinatorlastname + '</div>';
   							dataOutput += '</div>';
   							$(dataOutput).appendTo('.js--company-data');
   			 		 }
     			 }
     		 });
    		}

        cd.getCompanyInfo = function(companyId){
          console.log('called company data' + companyId);
     		 Papa.parse(companyCSV, {
     		   header: true,
           download: true,
     		   complete: function(results) {
     		   console.log(results);

     				 var data = results.data;

     				 var company = cd.getCompanyByID(data, companyId);
             console.log('comany value: ' + company);
             if (company !== undefined) {
               var eventMapLink;
               console.log('company map url: ' + company.eventlocationmapurl);
       				 if (company.eventlocationmapurl !== undefined) {
       					 eventMapLink = company.eventlocationmapurl
       				 } else {
       					 eventMapLink = 'https://www.google.com/maps/place/' + company.eventaddress + ',' + company.eventcity + ',' + company.eventstate + ',' + company.eventzip;

       				 }

       				 var fieldDayDetails = '';
       				 fieldDayDetails += '<p>' + company.eventlocationname + '</p>';
       				 fieldDayDetails += '<p>' + company.eventcity + ', ' + company.eventstate + '</p>';
       				 $(fieldDayDetails).appendTo('.js--field-day-details');

       				 var companyLead = '<p><a aria-label="Email Company Lead ' + company.coordinatorfirstname + ' ' + company.coordinatorlastname +'" href="mailto:' + company.coordinatoremail +'">' + company.coordinatorfirstname + ' ' + company.coordinatorlastname + '</a></p>' ;
       				 $(companyLead).appendTo('.js--company-lead');

               var eventDateFormatted = moment(company.eventdate).format('MMMM D, YYYY');

       				 var  eventDate = '<p><strong>' + eventDateFormatted + '<br>' + company.eventtime + '</strong></p>';
       				 $(eventDate).appendTo('.js--event-date');

       				 var companyLocation = '<p>' + company.eventcity + ', ' + company.eventstate + '</p>'
       				 $(companyLocation).appendTo('.js--company-location');

               console.log(eventMapLink);

               if (eventMapLink !== undefined) {
                 var companyMap = '<a target="_blank" aria-title="Google map for '+ company.companyname +' location" href="' + eventMapLink + '">' + company.companyname + '</a>';
                 $('.js--company-link').html(companyMap);
               } else {
                 $('.js--company-link').remove();
               }

             }

     		   }
     		 });
     	 }

       cd.getCompanyLocation = function(companyId){
         console.log('called company data' + companyId);
        Papa.parse(companyCSV, {
          header: true,
          download: true,
          complete: function(results) {

            var data = results.data;
            var company = cd.getCompanyByID(data, companyId);

            if (company !== undefined) {
              var companyLocation = company.eventcity + ', ' + company.eventstate;

              $(companyLocation).appendTo('.js--company-location');
            }
          }
        });
      }

        // EXPANDABLE DONOR ROLL
        $('.js--honor-roll-expander').on('click', function (e) {
            if ($(this).children('i').hasClass('fa-chevron-down')) {
                $(this).children('i').removeClass('fa-chevron-down');
                $(this).children('i').addClass('fa-chevron-up');
                $(this).attr('aria-label', 'View less donors');
            } else {
                $(this).children('i').removeClass('fa-chevron-up');
                $(this).children('i').addClass('fa-chevron-down');
                $(this).attr('aria-label', 'View more donors');
            }

            $('.hidden-donor-row').slideToggle(200);
        });
        cd.reorderPageForMobile = function () {
            // Reorganize page for mobile views
            if (screenWidth <= 767) {

                $('.tr-page-info').insertAfter('.sidebar-hero');
                $('.fundraising-amounts').prepend($('.fundraising-amounts .col-12'));

                if ($('body').is('.pg_team')) {
                    $('.team-roster').insertBefore($('.donor-roll'));
                    $('.js--information-box').prependTo('.js--sidebar');
                    $('.information-box__content').removeClass('box-shadow');
                    $('.team-roster li .raised span').each(function (i, span) {
                        if ($(this).parent().prev('.donor-name').find('span.coach').length !== 0) {
                            $(this).insertAfter($(this).parent().prev('.donor-name').children('.coach'));
                        } else {
                            $(this).insertAfter($(this).parent().prev('.donor-name').children('a'));
                        }
                    });

                    $('.team-roster form .btn').html($('.team-roster form .btn i'));
                }

                if ($('body').is('.pg_company')) {
                    $('.js--information-box').prependTo('.sidebar-content');

                    $('.team-roster form .btn').html('<i class="fas fa-search"></i>');
                    $('#participant-roster td:nth-child(3) a').html('Donate');

                }

                if ($('body').is('.pg_personal')) {
                  $('.js--information-box').prependTo('.js--sidebar-content');
                  $('.information-box__content').removeClass('box-shadow');

                }
            }
        };

        cd.initializeTeamRosterTable = function () {
            window.cdTeamRosterTable = $('#team-roster').DataTable({
                "paging": false,
                "autoWidth": false,
                "order": [[1, 'desc']],
                "language": {
                    "search": "Search for a Team"
                }
            });
            $('#team-roster_info, #team-roster_filter').wrapAll('<div class="row"></div>');
            $('#team-roster_info').insertBefore($('#team-roster_filter')).wrap('<div class="col-lg-6 col-md-12 sorter pl-md-0"></div>');
            $('#team-roster_filter').wrap('<div class="col-lg-6 col-md-12"></div>');

            $('#team-roster_filter input[type="search"]').attr('id', 'team_search').wrap('<div class="input-group"></div>').addClass('form-control').after('<div class="input-group-append"><button tabindex="-1" aria-hidden="true"  class="btn btn-primary btn-outline-secondary" type="button"><i class="fas fa-search"></i></button></div>');

            $('#team-roster_filter label').attr('for', 'team_search');

            // Add general team donation total and link
            var genTeamDonAmt = $('.team-roster-participant-name:contains("Team Gifts")').next().text();
            $('.js--gen-team-don-total').text(genTeamDonAmt);

            $('#team-roster_wrapper .sorter').prepend($('.js--gen-team-don-container'));

            $('.js--gen-team-don-container').show();

        };

        cd.initializeParticipantRosterTable = function () {
            window.cdParticipantRosterTable = $('#participant-roster').DataTable({
                "paging": false,
                "autoWidth": false,
                "order": [[2, 'desc']],
                "language": {
                    "search": "Search for a Teammate"
                }
            });

            $('#participant-roster_info, #participant-roster_filter').wrapAll('<div class="row"></div>');
            $('#participant-roster_info').insertBefore($('#participant-roster_filter')).wrap('<div class="col-lg-6 col-md-12 sorter d-flex align-items-end"></div>');
            $('#participant-roster_filter').wrap('<div class="col-lg-6 col-md-12"></div>');

            $('#participant-roster_filter input[type="search"]').attr('id', 'participant_search').wrap('<div class="input-group"></div>').addClass('form-control').after('<div class="input-group-append"><button tabindex="-1" aria-hidden="true" class="btn btn-primary btn-outline-secondary" type="button"><i class="fas fa-search"></i></button></div>');

            $('#participant-roster_filter label').attr('for', 'participant_search');

        };

        cd.getTeamHonorRoll = function () {
            // populate donor honor roll
            if ($('.team-honor-list-row').length > 0) {
                // console.log('native honor row length:', $('.team-honor-list-row').length);
                $('.team-honor-list-row').each(function (i, donor) {
                    var donorName = $(this).find('.team-honor-list-name').text();
                    var donorAmt = $(this).find('.team-honor-list-value').text();
                    $('.js--donor-roll').append('<div ' + (i > 4 ? 'style="display:none;"' : '') + ' class="donor-row ' + (i > 4 ? 'hidden-donor-row' : '') + '"><span class="name">' + donorName + '</span><span class="amount">' + donorAmt + '</span></div>');
                    if (i === 5) {
                        $('.js--honor-roll-expander').addClass('d-block').removeClass('hidden');
                    }
                });
            }
        };

        cd.convertNumberToDollarAmount = function (number) {
            return (number + '').replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');
        };

        cd.setDonorRollHeight = function () {
            $('.donations-container div').each(function (i, div) {
                if (i > 4) {
                    $('.donations-container').css('height', '205px');
                }
            });
        };
        //if ($('body').is('.app_id_26') || $('body').is('.app_id_27')) {
        //run unslider anytime sponsor_slider is found
        if ($('.sponsor_slider .local_sponsors').length > 0) {
            $('.sponsor_slider .local_sponsors').unslider({
                selectors: {
                    container: 'div.tr_sponsorship_logos',
                    slides: 'div.tr_sponsorship_logo'
                },
                autoplay: true
            });
        }
        //}

        if ($('body').is('.pg_entry')) {
            // Greeting Page
            // populate greeting page content
            $('.js--greeting-text').html($('#fr_html_container').html());

            if (publicEventType === "Multi-Event") {
                // populate multi-event
                var multiEventPageId = (isProd === true ? '3571' : '1110');

                var multiEventApiRequest = "TR?fr_id=" + evID + "&pg=informational&sid=" + multiEventPageId + " #page_body_container";

                $('.js--multi-event-locations').load(multiEventApiRequest);
            }


            // Event info section mobile expand/collapse functionality
            $('.event-info-expand').click(function () {
                $(this).children('.event-info-collapse').toggleClass('d-sm-none');
                var icon = $(this).children('h3').children('span').children('i');

                if ($(icon).hasClass('fa-plus')) {
                    $(icon).removeClass('fa-plus').addClass('fa-minus');
                } else {
                    $(icon).removeClass('fa-minus').addClass('fa-plus');
                }
            });

            // show EMC link if logged in visitor is EMC for this event
            if ($('.event-management-link-container').length) {
                $('.custom-event-management-link-container').removeClass('hidden');
            }

            // Update placeholder text in mobile for top walker search
            if (screenWidth <= 1065) {
                $('#greeting-search-first-name').attr('placeholder', 'First Name');
                $('#greeting-search-last-name').attr('placeholder', 'Last Name');
            }

            // Launch thermometer
            var progress = $('#progress-amount').text();
            var goal = $('#goal-amount').text();
            cd.runThermometer(progress, goal);
            // Build roster on greeting page
            cd.getTopParticipants(evID);
            cd.getTopTeams(evID);
            cd.getCompanyList(evID);
            cd.getTopCompanies(evID);

            // Walker Search
            $('.js--greeting-participant-search-form').on('submit', function (e) {
                e.preventDefault();
                console.log('teammate search');
                var firstName = encodeURIComponent($('#greeting-search-first-name').val());
                var lastName = encodeURIComponent($('#greeting-search-last-name').val());
                window.location.href = luminateExtend.global.path.secure + 'SPageServer/?pagename=FieldDay_Search&search_type=participant&cross_event=false&fr_id=' + evID + (firstName ? '&first_name=' + firstName : '') +
                    (lastName ? '&last_name=' + lastName : '');
            });

            // Team Search
            $('.js--greeting-team-search-form').on('submit', function (e) {
                e.preventDefault();
                var teamName = encodeURIComponent($('#greeting-search-team').val());
                window.location.href = luminateExtend.global.path.secure + 'SPageServer/?pagename=FieldDay_Search&search_type=team&cross_event=false&fr_id=' + evID + '&team_name=' + teamName;
            });
        }

        if ($('.tr_sponsorship_logos').length > 0) {
            jQuery('.tr_sponsorship_logos a').on('click', function (e) {
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

            //mobile placement

            // populate custom personal page content
            $('.js--personal-text').html($('#fr_rich_text_container').html());

            // populate donor honor roll
            cd.getTeamHonorRoll();

            var companyIdParam = $('.js--sidebar-content').data('company');
            console.log('company id: ' + companyIdParam)

            //fill in company sidebar data
            cd.getCompanyInfo(companyIdParam);

            // Build personal donation form
            cd.getDonationFormInfo = function (options) {
                luminateExtend.api({
                    api: 'donation',
                    requestType: 'POST',
                    data: 'method=getDonationFormInfo&fr_id=' + evID + '&form_id=' + dfID,
                    requiresAuth: true,
                    callback: {
                        success: function (response) {
                            var i = 0,
                                donationLevels = luminateExtend.utils.ensureArray(response.getDonationFormInfoResponse.donationLevels.donationLevel);

                            $.each(donationLevels, function (i) {
                                var userSpecified = this.userSpecified,
                                    amountFormatted = this.amount.formatted.replace('.00', ''),
                                    levelID = this.level_id;

                                i++;

                                if (userSpecified == 'false') {
                                    // build pre-defined giving levels
                                    $('.donation-amounts').append('<label class="form-check-label donation-amount-btn btn mb-3" for="personalDonAmt' + i + '" data-level-id="' + levelID + '"> <input class="form-check-input" type="radio" name="personalDonAmt" id="personalDonAmt' + i + '" value="' + levelID + '"> ' + amountFormatted + '</label>');
                                } else {
                                    // build user-specified level
                                    $('.donation-amounts').append('<div class="custom-amount"> <input class="form-check-input other-amt-radio sr-only" type="radio" name="personalDonAmt" id="personalDonAmt' + i + '" value="' + levelID + '"> <label class="js--don-amt-other sr-only" for="personalDonAmt' + i + '" data-level-id="' + levelID + '">Enter your own amount</label> <label class="form-label d-inline-block" for="personalOtherAmt">Custom Amount:</label><br/> <input type="text" id="personalOtherAmt" class="form-control d-inline-block js--personal-amt-other" data-parsley-min="25" data-parsley-min-message="Donations of all amounts are greatly appreciated. Online donations have a $25 minimum." /> </div>');
                                }
                            });

                            $('.custom-amount').after('<span aria-atomic="true" role="alert" class="error-row" ></span>');


                            $('.js--personal-don-form').removeClass('hidden');
                            var defaultDonUrl = $('.js--personal-don-submit').data('don-url');
                            var finalDonUrl = null;
                            $('.js--personal-don-submit').attr('data-final-don-url', defaultDonUrl);

                            // define donation widget button behavior
                            $('.js--personal-don-form label').on('click', function () {
                                $('.js--personal-amt-other').val('');
                                $('.js--personal-don-form .donation-amount-btn').removeClass('active');
                                $('.paymentSelType').addClass('hidden');
                                $(this).addClass('active');
                                // $('.js--don-amt').text($(this).text());
                                finalDonUrl = defaultDonUrl + '&set.DonationLevel=' + $(this).data('level-id');
                                $('.js--personal-don-submit').attr('data-final-don-url', finalDonUrl);

                            });

                            $('.js--personal-amt-other').on('keyup', function (e) {
                                var keyCode = (e.keyCode ? e.keyCode : e.which);
                                // console.log('keyCode: ', keyCode);
                                $('.paymentSelType').addClass('hidden');
                                if (keyCode != 9) {
                                    $('.js--personal-don-form .donation-amount-btn').removeClass('active');
                                    $('.custom-amount input[name="personalDonAmt"]').prop('checked', true);

                                    var customAmt = parseInt($(this).val()) * 100;

                                    finalDonUrl = defaultDonUrl + '&set.DonationLevel=' + $('.js--don-amt-other').data('level-id') + (isNaN(customAmt) === true ? '' : '&set.Value=' + customAmt);
                                    $('.js--personal-don-submit').attr('data-final-don-url', finalDonUrl);
                                }
                            });

                            // Set default donation amount
                            $('input[name="personalDonAmt"]').eq(1).click().prop('checked', true).closest('.donation-amount-btn').addClass('active');
                            // $('.js--don-amt').text($('.form-check-label').eq(1).text().trim());

                            $('.other-amt-radio').focus(function(){
                              $('.js--personal-amt-other').focus();
                            });


                            // redirect is now managed in amazonpay.js
                            // $('.js--personal-don-form').on('submit', function(e){
                            //   e.preventDefault();
                            //   // redirect to personal donation form with preselected amount
                            //   window.location.href = finalDonUrl;
                            // });

                        },
                        error: function (response) {
                            // $('.field-error-text').text(response.errorResponse.message);
                            // $('.ErrorContainer').removeClass('hidden');
                        }
                    }
                });
            };
            cd.getDonationFormInfo();


            // Get events by name or state
            cd.getPersonalVideo = function (frId, consId) {
                luminateExtend.api({
                    api: 'teamraiser',
                    data: 'method=getPersonalVideoUrl' +
                        '&fr_id=' + frId +
                        '&cons_id=' + consId +
                        '&response_format=json',
                    callback: {
                        success: function (response) {
                            var videoEmbedHtml;
                            if (response.getPersonalVideoUrlResponse.videoUrl) {
                                var videoUrl = response.getPersonalVideoUrlResponse.videoUrl;

                                if (videoUrl && videoUrl.indexOf('vidyard') === -1) {
                                    videoUrl = videoUrl.replace('&amp;v=', '&v=');
                                    var videoId = '';
                                    var personalVideoEmbedUrl = '';

                                    if (videoUrl.indexOf('?v=') !== -1) {
                                        videoId = videoUrl.split('?v=')[1].split('&')[0];
                                    } else if (videoUrl.indexOf('&v=') !== -1) {
                                        videoId = videoUrl.split('&v=')[1].split('&')[0];
                                    } else if (videoUrl.indexOf('/embed/') !== -1) {
                                        videoId = videoUrl
                                            .split('/embed/')[1]
                                            .split('/')[0]
                                            .split('?')[0];
                                    } else if (videoUrl.indexOf('youtu.be/') !== -1) {
                                        videoId = videoUrl
                                            .split('youtu.be/')[1]
                                            .split('/')[0]
                                            .split('?')[0];
                                    }
                                    if (videoId !== '') {
                                        personalVideoEmbedUrl = 'https://www.youtube.com/embed/' + videoId + '?wmode=opaque&amp;rel=0&amp;showinfo=0';
                                    }
                                }
                                videoEmbedHtml = '<iframe cc_load_policy=1 class="embed-responsive-item" src="' + personalVideoEmbedUrl + '" title="American Heart Association Field Day Video" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>';
                            } else {
                                // TODO - show default video
                                videoEmbedHtml = '<iframe cc_load_policy=1 width="560" height="315" src="https://www.youtube.com/embed/LryhjU1bEC4" title="About American Heart Association Field Day" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>';
                            }
                            $('.js--personal-video-container').append(videoEmbedHtml);
                        },
                        error: function (response) {
                            // console.log('getPersonalVideo error: ' + response.errorResponse.message);
                        }
                    }
                });
            };
            var personalPageConsId = getURLParameter(currentUrl, 'px');
            cd.getPersonalVideo(evID, personalPageConsId);

            /*$(window).on('resize', function () {
              if (screenWidth <= 768) {
                $('.sidebar-content').insertAfter('.information-box__content').removeClass('box-shadow');
              } else {
                $('.sidebar-content').insertAfter('.sidebar img').addClass('box-shadow');
              }
            }).resize();*/
        }

        if ($('body').is('.pg_team')) {
            // Team Page
            var progress = $('#progress-amount').text();
            var goal = $('#goal-amount').text();
            cd.runThermometer(progress, goal);
            cd.setDonorRollHeight();
            cd.reorderPageForMobile();
            cd.getTeamCaptains();

            var companyIdParam = $('.js--sidebar-content').data('company');
            console.log('company id: ' + companyIdParam)

            //fill in company sidebar data
            cd.getCompanyInfo(companyIdParam);

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

                                    var participantRaised = (parseInt(participant.amountRaised) * 0.01).toFixed(2);
                                    var participantRaisedFormmatted = participantRaised.toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,").replace('.00', '');

                                    $('#team-roster tbody').append('<tr class="' + (i > 4 ? 'd-none' : '') + '"><td class="donor-name">' + (participant.aTeamCaptain === "true" ? ' <span class="coach"><i class="fal fa-megaphone" aria-hidden="true"></i> </span>' : '') + '<a href="' + participant.personalPageUrl + '">' +
                                        participant.name.first + ' ' + participant.name.last +
                                        '</a></td><td class="raised" data-sort="' + participantRaisedFormmatted + '"><span><strong>$' + participantRaisedFormmatted + '</strong></span></td><td><a href="' + participant.donationUrl + '">' + (screenWidth <= 480 ? 'Donate' : 'Donate to ' + participant.name.first) + '</a></td></tr>');
                                    if (participant.aTeamCaptain === 'true') {
                                        $('.js--team-captain-link').attr('href', participant.personalPageUrl).attr('aria-lablel', "Team Captain " + participant.name.first + ' ' + participant.name.last + "'s fundraising page'" + participant.name.last + ' ').text(participant.name.first + ' ' + participant.name.last);
                                    }
                                });

                                if (totalParticipants > 5) {
                                    $('.js--more-participant-results').removeAttr('hidden');
                                }
                                // cd.initializeTeamRosterTable();

                                //add call to hook donate button with payment type selections
                                addPaymentTypesOnSearch();
                                $('.js--more-participant-results').on('click', function (e) {
                                    e.preventDefault();
                                    $('#team-roster tr').removeClass('d-none');
                                    $(this).attr('hidden', true);
                                });
                            }
                        }
                    },
                    error: function (response) {
                        $('#error-participant').removeAttr('hidden').text(response.errorResponse.message);
                        // console.log('error response: ', response);
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
            var end_pos = pageTitle.indexOf('- Field Day', start_pos);
            var currentCompanyName = pageTitle.substring(start_pos, end_pos).trim();
            var currentCompanyId = getURLParameter(currentUrl, 'company_id');
            $('.js--company-name').text(currentCompanyName);
            // var isParentCompany = ($('#company_hierarchy_list_component .lc_Row1').length ? true : false)
            var isParentCompany = ($('.js--company-hierarchy-list-container .lc_Row1').length ? true : false);

            console.log('Parent company: ' + isParentCompany);

            var allCompanyData = [{
                id: currentCompanyId,
                name: currentCompanyName
            }];
            // allCompanyData.push({currentCompanyId, companyName});
            // get child company IDs
            if (isParentCompany) {

                $('.js--company-hierarchy-list-container .trr-td a').each(function () {
                    var childCompanyLink = $(this).attr('href');
                    var childCompanyName = $(this).text();
                    var childCompanyId = getURLParameter(childCompanyLink, 'company_id');
                    allCompanyData.push({id: childCompanyId, name: childCompanyName});
                    // allCompanyData.id
                });
            } else {

                $('.js--company-multiple-locations').hide();

                luminateExtend.api({
                    api: 'teamraiser',
                    data: 'method=getCompanyList&fr_id=' + evID +
                        '&include_all_companies=true&response_format=json',
                    callback: {
                        success: function (response) {
                            if (!$.isEmptyObject(response.getCompanyListResponse)) {
                                var companyItems = luminateExtend.utils.ensureArray(response.getCompanyListResponse.companyItem);

                                $(companyItems).each(function (i, company) {
                                    if (company.companyId === currentCompanyId) {
                                        var parentCompanyId = company.parentOrgEventId;

                                        luminateExtend.api({
                                            api: 'teamraiser',
                                            data: 'method=getCompaniesByInfo' +
                                                '&company_id=' + parentCompanyId +
                                                '&response_format=json',
                                            callback: {
                                                success: function (response) {
                                                    if (response.getCompaniesResponse.totalNumberResults !== '0') {
                                                        $('.js--company-name').before('<small><a href="' + response.getCompaniesResponse.company.companyURL + '">' + response.getCompaniesResponse.company.companyName + '</a></small>');
                                                    }
                                                },
                                                error: function (response) {
                                                    $('.js--company-results-container').removeAttr('hidden').text(response.errorResponse.message);
                                                }
                                            }
                                        });

                                    }
                                });
                            }
                        },
                        error: function (response) {
                            // console.log('getCompanyList error: ' + response.errorResponse.message);
                        }
                    }
                });
            }

            var raised = $('.indicator-title:contains("Company Fundraising Status")').parent().find('.amount-raised-value').text();

            if (raised) {
                $('#progress-amount').html(raised);
            }

            // Get company goal
            $('.indicator-title:contains("Company Fundraising")').closest('.tr-status-indicator-container').addClass('default-company-thermometer');
            // var companyoGoalText = $('.default-company-thermometer .total-goal-value').text();
            var companyoGoalText = $('.indicator-title:contains("Company Fundraising Status")').parent().find('.total-goal-value').text();


            var companyGoal = companyoGoalText.split('.');
            $('#goal-amount').html(companyGoal[0]);

            // populate custom personal page content
            $('.js--company-text').html($('#fr_rich_text_container').html());
            $('.js--company-logo').html($('#company_banner').html());

            var progress = $('#progress-amount').text();
            var goal = $('#goal-amount').text();
            if (parseInt(progress) > parseInt(goal) ) {
              $('.js--thermometer-trophy-goal').removeClass('d-none');
              $('.js--thermometer-trophy').addClass('d-none');
            }
            cd.runThermometer(progress, goal);
            cd.reorderPageForMobile();

            cd.getCompanyInfo(companyIdParam);
            console.log('called data');


            // Reset selected sort option
            $('.nav-tabs .nav-link').click(function () {
                $('.selected-sort-option').html('Amount Raised');
            });

            // Build company team roster
            // build team roster
            var numTeamRows = 0;

            cd.getCompanyTeams = function (companyId, companyName, numCompanies, companyIndex) {
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
                                $(teams).each(function (i, team) {
                                    var teamRaised = (parseInt(team.amountRaised) * 0.01).toFixed(2);
                                    var teamRaisedFormmatted = teamRaised.toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,").replace('.00', '');
                                    $('#team-roster tbody').append('<tr class="' + (numTeamRows > 4 ? 'd-none' : '') + '"> <td class="team-name"> <a href="' + team.teamPageURL + '" data-sort="' + team.name + '">' + team.name + '</a> </td><td class="donor-name"> <a href="TR/?px=' + team.captainConsId + '&pg=personal&fr_id=' + team.EventId + '" data-sort="' + team.captainFirstName + ' ' + team.captainLastName + '">' + team.captainFirstName + ' ' + team.captainLastName + '</a> </td><td class="company-name"> <a href="' + luminateExtend.global.path.secure + 'TR/?pg=company&company_id=' + team.companyId + '&fr_id=' + team.EventId + '" data-sort="' + companyName + '">' + companyName + '</a> </td><td class="raised" data-sort="' + teamRaisedFormmatted + '"> <span><strong>$' + teamRaisedFormmatted + '</strong></span> </td><td> <a href="' + team.joinTeamURL + '" aria-label="Join Team ' + team.name + '">' + (screenWidth <= 480 ? 'Join' : 'Join Team') + '</a> </td></tr>');
                                    numTeamRows++;
                                });

                                $('.js--more-team-results').on('click', function (e) {
                                    e.preventDefault();
                                    $('#team-roster tr').removeClass('d-none');
                                    $(this).attr('hidden', true);
                                });
                            }

                            if (companyIndex === numCompanies) {
                                setTimeout(function () {
                                    cd.initializeTeamRosterTable();
                                    var totalTeams = $('.team-name').length;
                                    var totalTeamsText = totalTeams > 1 ? ' Teams' : ' Team';
                                    $('.js--num-company-teams').text(totalTeams + totalTeamsText);
                                    if (totalTeams > 5) {
                                        $('.js--more-team-results').removeAttr('hidden');
                                    }
                                }, 250);
                            }
                        }
                    },
                    error: function (response) {
                        $('#error-participant').removeAttr('hidden').text(response.errorResponse.message);
                        // console.log('error response: ', response);
                    }
                });
            };

            cd.buildCompanyTeamRoster = function () {
                var numCompanies = allCompanyData.length;
                for (var i = 0, l = allCompanyData.length; i < l; i++) {
                    var company = allCompanyData[i];
                    var companyIndex = i + 1;
                    var companyId = company.id;
                    var companyName = company.name;
                    cd.getCompanyTeams(companyId, companyName, numCompanies, companyIndex);
                }
            }

            cd.buildCompanyTeamRoster();
            var numWalkerRows = 0;

            // build team roster
            cd.getCompanyParticipants = function () {
                var numCompanies = allCompanyData.length - 1;
                var company = allCompanyData[0];
                var companyIndex = 0;
                var companyId = company.id;
                var companyName = company.name;

                $('#participant-roster tbody').html('');
                var participants = [];

                cd.getAllParticipants = function (pgcnt) {
                    var deferred = $.Deferred();
                    var companyId = allCompanyData[companyIndex].id;
                    var companyName = allCompanyData[companyIndex].name;

                    $.ajax({
                        type: 'GET',
                        url: luminateExtend.global.path.secure + 'CRTeamraiserAPI',
                        data: {
                            method: 'getParticipants',
                            api_key: luminateExtend.global.apiKey,
                            v: '1.0',
                            team_name: '%%%',
                            fr_id: evID,
                            list_filter_column: 'team.company_id',
                            list_filter_text: companyId,
                            list_page_size: '499',
                            list_page_offset: pgcnt,
                            response_format: 'json',
                        },
                        dataType: 'json'
                    }).done(function (response) {
                        if (response.getParticipantsResponse.totalNumberResults === '0') {
                            if (allCompanyData[companyIndex + 1] != undefined) {
                                companyIndex = companyIndex + 1;
                                pgcnt = 0;
                                cd.getAllParticipants(pgcnt).done(function() {
                                    deferred.resolve();
                                });
                            } else {
                                deferred.resolve();
                            }
                        } else {
                            if (typeof (response.getParticipantsResponse.participant) == "undefined") {
                                if (allCompanyData[companyIndex + 1] != undefined) {
                                    companyIndex = companyIndex + 1;
                                    pgcnt = 0;
                                    cd.getAllParticipants(pgcnt).done(function() {
                                        deferred.resolve();
                                    });
                                } else {
                                    deferred.resolve();
                                }
                            } else {
                                pgcnt++;
                                var participantList = luminateExtend.utils.ensureArray(response.getParticipantsResponse.participant);
                                $(participantList).each(function (i, participant) {
                                    participantList[i].companyId = companyId;
                                    participantList[i].companyName = companyName;
                                });
                                participants = participants.concat(participantList);
                                cd.getAllParticipants(pgcnt).done(function() {
                                    deferred.resolve();
                                });
                            }
                        }
                    })
                    .fail(function (response) {
                        deferred.reject();
                        $('#error-participant').removeAttr('hidden').text(response.errorResponse.message);
                    });

                    return deferred.promise();
                }

                var numCompanies = allCompanyData.length - 1;
                var company = allCompanyData[0];
                var ipCompanyIndex = 0;
                var companyId = company.id;
                var companyName = company.name;
                var indivpgcnt = 0;

                cd.getCompanyIndividualParticipants = function (indivpgcnt) {
                    var deferred = $.Deferred();
                    var companyId = allCompanyData[ipCompanyIndex].id;
                    var companyName = allCompanyData[ipCompanyIndex].name;

                    $.ajax({
                        type: 'GET',
                        url: luminateExtend.global.path.secure + 'CRTeamraiserAPI',
                        data: {
                            method: 'getParticipants',
                            api_key: luminateExtend.global.apiKey,
                            v: '1.0',
                            first_name: '%%%',
                            fr_id: evID,
                            list_filter_column: 'reg.company_id',
                            list_filter_text: companyId,
                            list_page_size: '499',
                            list_page_offset: indivpgcnt,
                            response_format: 'json',
                        },
                        dataType: 'json'
                    }).done(function (indivResponse2) {
                        if (indivResponse2.getParticipantsResponse.totalNumberResults === '0') {
                            if (allCompanyData[ipCompanyIndex + 1] != undefined) {
                                ipCompanyIndex = ipCompanyIndex + 1;
                                indivpgcnt = 0;
                                cd.getCompanyIndividualParticipants(indivpgcnt).done(function() {
                                    deferred.resolve();
                                });
                            } else {
                                deferred.resolve();
                            }
                        } else {
                            if (typeof (indivResponse2.getParticipantsResponse.participant) == "undefined") {
                                if (allCompanyData[ipCompanyIndex + 1] != undefined) {
                                    ipCompanyIndex = ipCompanyIndex + 1;
                                    indivpgcnt = 0;
                                    cd.getCompanyIndividualParticipants(indivpgcnt).done(function() {
                                        deferred.resolve();
                                    });
                                } else {
                                    deferred.resolve();
                                }
                            } else {
                                indivpgcnt++;
                                var indivParticipantList2 = luminateExtend.utils.ensureArray(indivResponse2.getParticipantsResponse.participant);
                                $(indivParticipantList2).each(function (i, participant) {
                                    indivParticipantList2[i].companyId = companyId;
                                    indivParticipantList2[i].companyName = companyName;
                                });
                                participants = participants.concat(indivParticipantList2);
                                cd.getCompanyIndividualParticipants(indivpgcnt).done(function() {
                                    deferred.resolve();
                                });
                            }
                        }
                    })
                    .fail(function (indivResponse2) {
                        deferred.reject();
                        $('#error-participant').removeAttr('hidden').text(indivResponse2.errorResponse.message);
                    });

                    return deferred.promise();
                }

                $.when(cd.getCompanyIndividualParticipants(0), cd.getAllParticipants(0)).done(function (result) {
                    if (participants.length > 0) {
                        cd.buildParticipantList(participants);
                    } else {
                        // console.log('testing length of participants array - not greater than 0');
                    }
                });
            };

            cd.getCompanyParticipants();

            cd.buildParticipantList = function (participants) {
                $(participants).each(function (i, participant) {
                    var participantRaised = (parseInt(participant.amountRaised) * 0.01).toFixed(2);
                    var participantRaisedFormmatted = participantRaised.toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,").replace('.00', '');

                    $('#participant-roster tbody').append('<tr class="' + (numWalkerRows > 4 ? 'd-none' : '') + '"><td class="participant-name"><a href="' + participant.personalPageUrl + '">' +
                        participant.name.first + ' ' + participant.name.last +
                        '</a>' + (participant.aTeamCaptain === "true" ? ' <span class="coach">- Team Captain</span>' : '') + '</td><td class="company-name"> <a href="' + luminateExtend.global.path.secure + 'TR/?pg=company&company_id=' + participant.companyId + '&fr_id=' + participant.eventId + '" data-sort="' + participant.companyName + '">' + participant.companyName + '</a> </td><td class="raised" data-sort="' + participantRaisedFormmatted + '"><span><strong>$' + participantRaisedFormmatted + '</strong></span></td><td><a href="' + participant.donationUrl + '">' + (screenWidth <= 480 ? 'Donate' : 'Donate to ' + participant.name.first) + '</a></td></tr>');
                    numWalkerRows++;
                });

                $('.js--more-participant-results').on('click', function (e) {
                    e.preventDefault();
                    $('#participant-roster tr').removeClass('d-none');
                    $(this).attr('hidden', true);
                });

                setTimeout(function () {
                    cd.initializeParticipantRosterTable();
                    var totalParticipants = $('.participant-name').length;
                    var totalParticipantsText = totalParticipants > 1 ? ' Teammates' : ' Teammate';
                    $('.js--num-company-participants').text(totalParticipants + totalParticipantsText);
                    if (numWalkerRows > 5) {
                        $('.js--more-participant-results').removeAttr('hidden');
                    }
                }, 250);

                //add call to hook donate button with payment type selections
                $('a:contains(Donat)').on('click', function (e) {
                    e.preventDefault();
                    if (!$(this).hasClass('js--team-member-donate')) {
                        if ($(this).next('.paymentSelType').length > 0) {
                            $(this).next('.paymentSelType').remove();
                        } else {
                            var dlink = $(this).attr("href");
                            var fr_id = $.getCustomQuerystring(dlink, "FR_ID");
                            var px = $.getCustomQuerystring(dlink, "PROXY_ID");
                            var pt = $.getCustomQuerystring(dlink, "PROXY_TYPE");

                            var html = "<div aria-live='polite' class='paymentSelType text-center' style='padding-top:10px;'>" +
                                "<h2 class='h6'>How would you like to donate?</h2>" +
                                "<div class='payment-options-container'><a href='" + dlink + "'><img src='https://www2.heart.org/images/content/pagebuilder/credit-card-logos2.png' alt='Donate with Visa, MasterCard, American Express or Discover cards'/></a>" +
                                "<a href='" + default_path + "/site/SPageNavigator/fieldday_donate_amazon.html?FR_ID=" + fr_id + "&mfc_pref=T&PROXY_ID=" + px + "&PROXY_TYPE=" + pt + "' class='amazon'><img src='https://donatenow.heart.org/images/amazon-payments_inactive.png' alt='Donate with Amazon Pay'/></a>" +
                                "<a href='" + default_path + "/site/SPageNavigator/fieldday_donate_googlepay.html?FR_ID=" + fr_id + "&mfc_pref=T&PROXY_ID=" + px + "&PROXY_TYPE=" + pt + "' class='googlepay'><img src='https://www2.heart.org/donation-forms/donatenow/images/googlepay-button.png' alt='Donate with Google Pay'/></a>" +
                                "<a href='" + default_path + "/site/SPageNavigator/fieldday_donate_applepay.html?FR_ID=" + fr_id + "&mfc_pref=T&PROXY_ID=" + px + "&PROXY_TYPE=" + pt + "' class='applepay hidden-md hidden-lg'><img src='https://www2.heart.org/donation-forms-braintree/donatenow/images/DonateBlack_32pt_@2x.png' alt='ApplePay'/></a>" +
                                "<a href='" + default_path + "/site/SPageNavigator/fieldday_donate_venmo.html?FR_ID=" + fr_id + "&mfc_pref=T&PROXY_ID=" + px + "&PROXY_TYPE=" + pt + "' class='venmo hidden-md hidden-lg'><img src='https://www2.heart.org/donation-forms/donatenow/images/venmo-button.png' alt='Venmo'/></a>" +
                                "<a href='" + dlink + "&paypal=true'><img src='https://www2.heart.org/images/content/pagebuilder/PP_logo_h_100x26.png'/ alt='Donate with PayPal'></a></div>";
                            $(this).after(html);
                        }
                    }
                });

            }

        }



        if ($('body').is('.pg_informational')) {
            // Custom TR Page
        }


        if ($('body').is('.pg_FieldDay_Search')) {
            // FieldDay Search Page
            var clearSearchResults = function () {
                $('.js--event-results-container, .alert').attr('hidden', true);
                $('.js--event-results-rows').html('');
                $('.js--participant-results-container, .alert').attr('hidden', true);
                $('.js--participants-results-rows').html('');
                $('.js--team-results-container, .alert').attr('hidden', true);
                $('.js--team-results-rows').html('');
            }

            // Search by Company
            $('.js--company-search-form').on('submit', function (e) {
                e.preventDefault();
                clearSearchResults();
                var companySearched = encodeURIComponent($('#companyNameSearch').val());
                cd.getCompanies(companySearched, isCrossEventSearch === "true" ? true : false);
            });

            // Search by Event
            $('.js--zip-search-form').on('submit', function (e) {
                e.preventDefault();
                clearSearchResults();
                var zipSearched = encodeURIComponent($('#zipCodeSearch').val());
                cd.getEventsByDistance(zipSearched, isCrossEventSearch === "true" ? true : false);

            });
            $('#eventStateSearch').on('change', function () {
                clearSearchResults();
                var stateSearched = encodeURIComponent($('#eventStateSearch').val());
                cd.getEventsByState(stateSearched, isCrossEventSearch === "true" ? true : false);
            });

            $('.js--state-search-form').on('submit', function (e) {
                e.preventDefault();
                clearSearchResults();
                var stateSearched = encodeURIComponent($('#eventStateSearch').val());
                cd.getEventsByDistance(stateSearched, isCrossEventSearch === "true" ? true : false);
            });



            // Search page by Participant
            $('.js--participant-search-form').on('submit', function (e) {
                e.preventDefault();
                clearSearchResults();
                var firstName = encodeURIComponent($('#participantFirstName').val());
                var lastName = encodeURIComponent($('#participantLastName').val());

                cd.getParticipants(firstName, lastName, (isCrossEventSearch === "true" ? true : false));
            });

            // Search by Team
            $('.js--team-search-form').on('submit', function (e) {
                e.preventDefault();
                clearSearchResults();
                var teamName = encodeURIComponent($('#teamNameSearch').val());
                cd.getTeams(teamName, (isCrossEventSearch === "true" ? true : false));
            });


            if (searchType) {
                cd.autoSearchParticipant = function () {
                    var firstNameVal = getURLParameter(currentUrl, 'first_name') ? getURLParameter(currentUrl, 'first_name') : '';
                    var lastNameVal = getURLParameter(currentUrl, 'last_name') ? getURLParameter(currentUrl, 'last_name') : '';

                    if (!firstNameVal && !lastNameVal) {
                        // General participant search from greeting page. Show all walkers
                        cd.getParticipants('%25%25%25', '%25%25%25', (isCrossEventSearch === "true" ? true : false));
                    } else {
                        firstNameVal = decodeURIComponent(firstNameVal);
                        lastNameVal = decodeURIComponent(lastNameVal);

                        $('#participantFirstName').val(firstNameVal);
                        $('#participantLastName').val(lastNameVal);

                        cd.getParticipants(firstNameVal, lastNameVal, (isCrossEventSearch === "true" ? true : false));
                    }

                }

                cd.autoSearchTeam = function () {
                    var teamName = getURLParameter(currentUrl, 'team_name') ? getURLParameter(currentUrl, 'team_name') : '';
                    teamName = decodeURIComponent(teamName);
                    $('#teamNameSearch').val(teamName);

                    cd.getTeams(teamName, (isCrossEventSearch === "true" ? true : false));
                }

                cd.autoSearchCompany = function () {
                    var companyName = getURLParameter(currentUrl, 'company') ? getURLParameter(currentUrl, 'company') : '';
                    companyName = decodeURIComponent(companyName);
                    $('#companyNameSearch').val(companyName);
                    var crossEventSearch = (isCrossEventSearch === "true" ? true : false);
                    console.log(crossEventSearch);

                    cd.getCompanies(companyName, (isCrossEventSearch === "true" ? true : false));
                }

                cd.autoSearchZip = function () {
                    var searchZip = getURLParameter(currentUrl, 'zip') ? getURLParameter(currentUrl, 'zip') : '';
                    $('#zipCodeSearch').val(searchZip);
                    cd.getEventsByDistance(searchZip, (isCrossEventSearch === "true" ? true : false));
                }

                cd.autoSearchState = function () {
                    var searchState = getURLParameter(currentUrl, 'state') ? getURLParameter(currentUrl, 'state') : '';
                      $('#eventStateSearch').val(searchState);
                    cd.getEventsByState(searchState, (isCrossEventSearch === "true" ? true : false));
                }

                if (searchType === 'event') {
                    cd.autoSearchZip();
                } else if (searchType === 'participant') {
                    cd.autoSearchParticipant();
                    // Switch to walker tab
                    $('#searchParticipantTab').tab('show');
                } else if (searchType === 'team') {
                    cd.autoSearchTeam();
                    // Switch to team tab
                    $('#searchTeamTab').tab('show');
                } else if (searchType === 'zip') {
                    cd.autoSearchZip();
                    // Switch to team tab
                    $('#searchEventTab').tab('show');
                  } else if (searchType === 'state') {
                      cd.autoSearchState();
                      // Switch to team tab
                      $('#searchEventTab').tab('show');
                  } else if (searchType === 'company') {
                   cd.autoSearchCompany();
                   // Switch to company tab
                   $('#searchCompanyTab').tab('show');
                }
            }
        }

        //Landong Page

        if($('body').is('.pg_FieldDay_Landing_Page')) {
          //Search functionality

          $('#company-page-search, #participant-page-search').on('click', function(){
            $('.js--participant-search-results').html('');
            $('.js--participant-no-event-results').addClass('d-none');
            $('.js--participant-more-event-results').addAttr('hidden');
          });

          //State and Zip search
          $('.js--zip-search').on('submit', function (e) {
              e.preventDefault();
              $('.js--event-search-results').html('');
              var zipSearched = encodeURIComponent($('.js--zip-search-val').val());
              cd.getEventsByDistanceLanding(zipSearched);
          });
          $('.js--state-search-val').on('change', function () {
              $('.js--event-search-results').html('');
              var eventState = encodeURIComponent($('.js--state-search-val').val());
              cd.getEventsByStateLanding(eventState);
          });

          $('.js--state-search').on('submit', function (e) {
              e.preventDefault();
              $('.js--event-search-results').html('');
              var eventState = encodeURIComponent($('.js--state-search-val').val());
              cd.getEventsByStateLanding(eventState);
          });

          //Company and participant search
          $('.js--page-company-search').on('submit', function (e) {
              e.preventDefault();
              $('.js--participant-search-results').html('');
              var companyName = encodeURIComponent($('.js--page-company-search-val').val());
              cd.getCompaniesLanding(companyName);
          });
          $('.js--page-participant-search').on('submit', function (e) {
              e.preventDefault();
              $('.js--participant-search-results').html('');
              var firstName = encodeURIComponent($('.js--page-participant-search-first-val').val());
              var lastName = encodeURIComponent($('.js--page-participant-search-last-val').val());
              cd.getParticipantsLanding(firstName, lastName);
          });

          $('.js--card-content').each(function(){
            var highestBox = 0;

            if($(this).height() > highestBox) {
              highestBox = $(this).height();
            }

            $('.js--card-content').height(highestBox);
          });

         }
         //End Landing Page
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


var toggleMultiEventInfo = function (elem) {
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


//main menu hack
$('.nav-item--find a').on('click', function (event) {
    $(this).parent().toggleClass('open');
});

$('body').on('click, keydown', function (e) {
    if (!$('.nav-item--find').is(e.target)
        && $('.nav-item--find').has(e.target).length === 0
        && $('.open').has(e.target).length === 0
    ) {
        $('.nav-item--find').removeClass('open');
        $('.nav-item--find').removeClass('open');
    }
});


if ( $('body').is('.app_donation') || $('body').is('.app_tr_registration') || $('body').is('.pg_fieldday_register') ) {
  $('.nav-item--about').attr('aria-hidden', 'true');
  $('.nav-item--find').attr('aria-hidden', 'true');
}
