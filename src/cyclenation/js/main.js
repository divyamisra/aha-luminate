'use strict';

(function ($) {
  $(document).ready(function ($) {

    /*************/
    /* Namespace */
    /*************/
    window.cd = {};

    // BEGIN WRAPPER JS
    var screenWidth = $(window).innerWidth();

    // GREETING PAGE - HIDE CALENDAR IN IOS
    var iOS = false,
      p = navigator.platform;
    if (p === 'iPad' || p === 'iPhone' || p === 'iPod') {
      iOS = true;
    }
    if (iOS === false) {
      //show "ios-hide" items
    } else {
      $(".ios-hide").hide();
    }

    /***************/
    /* NAV SCRIPTS */
    /***************/
    $('.nav-toggle').on('click', function (e) {
      e.preventDefault();
    });
    if ($('body').is('.pg_cn_home') || $('body').is('.pg_entry')) {
      // Only apply sticky nav to landing and greeting pages
      // Sticky nav
      var stickyToggle = function (sticky, stickyWrapper, scrollElement) {
        var stickyHeight = sticky.outerHeight();
        // var stickyTop = stickyWrapper.offset().top;
        var stickyTop = stickyWrapper.offset().top + 300;
        if (scrollElement.scrollTop() >= stickyTop) {
          stickyWrapper.height(stickyHeight);
          sticky.addClass('is-sticky');
        } else {
          sticky.removeClass('is-sticky');
          stickyWrapper.height('auto');
        }
      };

      // Find all data-toggle="sticky-onscroll" elements
      $('[data-toggle="sticky-onscroll"]').each(function () {
        var sticky = $(this);
        var stickyWrapper = $('<div>').addClass('sticky-wrapper');
        sticky.before(stickyWrapper);
        sticky.addClass('sticky');

        // Scroll & resize events
        $(window).on('scroll.sticky-onscroll resize.sticky-onscroll', function () {
          stickyToggle(sticky, stickyWrapper, $(this));
        });

        // On page load
        stickyToggle(sticky, stickyWrapper, $(window));
      });

      // bind api survey
      luminateExtend.api.bind();
    }

    if ($('body').is('.pg_cn_home')) {
      $('.js__see-all-social').on('click', function(e){
        e.preventDefault();
        $(this).hide();
        $('.social-feed-container').css({
          "height": "auto",
          "overflow": "initial"
        })
      });
    }

    // Select all links with hashes
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
            if ($('body').is('.pg_cn_home') || $('body').is('.pg_entry')) {
              if($(document).scrollTop()>299){
                var scrollLocation = target.offset().top - 130;
              } else {
                var scrollLocation = target.offset().top - 250;
              }
            } else {
              var scrollLocation = target.offset().top;
            }
            $('html, body').animate({
              scrollTop: scrollLocation
            }, 1000, function () {});
          }
        });
    }
    addScrollLinks();



    // END WRAPPER JS


    // BEGIN LANDING PAGES
    /******************/
    /* SEARCH SCRIPTS */
    /******************/
    var eventType = 'CycleNation';
    var eventType2 = $('body').data('event-type2') ? $('body').data('event-type2') : null;
    var regType = $('body').data('reg-type') ? $('body').data('reg-type') : null;
    var publicEventType = $('body').data('public-event-type') ? $('body').data('public-event-type') : null;
    var isCrossEvent = $('body').is('.pg_cn_home') ? true : false;
    var viewportWidth = window.innerWidth || document.documentElement.clientWidth;


    var isProd = (luminateExtend.global.tablePrefix === 'heartdev' ? false : true);
    var eventName = luminateExtend.global.eventName;
    var srcCode = luminateExtend.global.srcCode;
    var subSrcCode = luminateExtend.global.subSrcCode;
    var evID = $('body').data('fr-id') ? $('body').data('fr-id') : null;
    var dfID = $('body').data('df-id') ? $('body').data('df-id') : null;
    var consID = $('body').data('cons-id') ? $('body').data('cons-id') : null;
    var eventDate = $('body').data('ev-date') ? new Date($('body').data('ev-date')) : null;
    if (eventDate != null) {
       eventDate.setDate(eventDate.getDate() + 15);
    }
    var currDate = $('body').data('curr-date') ? new Date($('body').data('curr-date')) : null;
    var fourWeek = $('body').data('ev-date') ? new Date($('body').data('ev-date')) : null;
    if (fourWeek != null) {
       fourWeek.setDate(fourWeek.getDate() - 30);
    }

    var motion_username = 'cyclenationapi';
    var motion_password = 'oNNuWown5A8MeJco';
    var motionDb = 'ahacycle';
    var motion_event = evID;
    var motion_urlPrefix = (isProd) ? 'loadprod' : 'load';

    function getURLParameter(url, name) {
      return (RegExp(name + '=' + '(.+?)(&|$)').exec(url) || [, null])[1];
    }
    var currentUrl = window.location.href;
    var searchType = getURLParameter(currentUrl, 'search_type');

    if (getURLParameter(currentUrl, 'demo') == "true") {
       //override to test bm
       motion_username = 'motionapi';
       motion_password = 'jPOHc5J4qMVVSj7P';
       motionDb = 'democdsb';
       motion_event = 1061;
    }

    function convertMinutes(mins) {
        mins = mins.replace(/,/g,'');
        var totalMinutes = parseFloat(mins);
        var hours = Math.floor(totalMinutes / 60);          
        var minutes = totalMinutes % 60;
        return hours + " hr " + minutes + " min";
    }
    
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
                  participant.eventName + '</a></td><td class="col-cta"><a href="' + participant.donationUrl + '" aria-label="Donate to ' + participant.name.first + ' ' + participant.name.last + '" class="btn-rounded btn-primary btn-block">Donate</a></td></tr>');

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
              $('.js__participant-results-container').removeAttr('hidden');
              addPaymentTypesOnSearch();

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
                  $('.list').append(
                    '<div class="search-result-details row py-3"><div class="col-md-5"><strong><a href="' + team.teamPageURL + '" class="team-name-label" title="' + team.name + '" target=_blank><span class="team-company-label sr-only">Team Name:</span> ' + team.name + '</a></strong><br><span class="team-captain-label">Team Captain:</span> <span class="team-captain-name">' + team.captainFirstName + ' ' + team.captainLastName + '</span></div><div class="col-md-5 mt-auto">' + ((team.companyName !== null && team.companyName !== undefined) ? '<span class="team-company-label">Company:</span> <span class="team-company-name">' + team.companyName + '</span>' : '') + '</div><div class="col-md-2"><a href="' + luminateExtend.global.path.secure + 'TRR/?fr_tjoin=' + team.id + '&pg=tfind&fr_id=' + evID + '&s_captainConsId=' + team.captainConsId + '&s_regType=joinTeam&skip_login_page=true" title="Join ' + team.name + '" aria-label="Join ' + team.name + '" class="btn-block btn-primary button team-join-btn">Join</a></div></div>');
                  $('.js__search-results-container').slideDown();
                  // $('.js__search-results-container').show();

                } else {
                  $('.js__team-results-rows')
                    .append('<tr' + (i > 10 ? ' class="d-none"' : '') + '><td><a href="' + team.teamPageURL + '">' +
                      team.name + '</a></td><td><a href="TR/?px=' + team.captainConsId + '&pg=personal&fr_id=' + team.EventId + '">' + team.captainFirstName + ' ' + team.captainLastName + '</a></td><td>' +
                      ((team.companyName !== null && team.companyName !== undefined) ? '<a href="TR?company_id=' + team.companyId + '&fr_id=' + team.EventId + '&pg=company">' + team.companyName + '</a>' : '') +
                      '</td><td><a href="TR/?fr_id=' + team.EventId + '&pg=entry">' + team.eventName + '</a></td><td class="col-cta"><a href="' + team.teamDonateURL + '" class="btn-rounded btn-primary btn-block" title="Donate to ' + team.name + '" aria-label="Donate to ' + team.name + '">Donate</a></td></tr>');
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
                  company.companyName + '</a></td><td class="col-cta"><a href="' + company.companyURL + '" aria-label="Visit page for ' + company.companyName + '" class="btn-rounded btn-primary btn-block">View</a></td></tr>');
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

    // FAQ SEARCH SCRIPTS
    if ($('body').is('.pg_internal.faq')) {
      // FAQ page scripts

      var faqCards = $('.js__faq-container li > .card ');
      // Use JS to add data attributes to make collapse functionality work. Otherwise, the WYSIWYG in LO will strip those from the hard coded HTML
      $(faqCards).each(function (i) {
        $(this).find('.card-header').attr('id', 'faq_header' + i);
        $(this).find('.faq-title').attr({
            'data-toggle': 'collapse',
            'data-target': '#faq_block_' + i,
            'aria-expanded': 'false',
            'aria-controls': 'faq_block_' + i
          })
          .append('<div class="accordion-icon icon-closed text-primary mr-2"><i class="fas fa-plus-circle"></i></div><div class="accordion-icon icon-open text-primary mr-2"><i class="fas fa-minus-circle"></i></div>');
        $(this).find('.collapse').attr({
          'id': 'faq_block_' + i,
          'aria-labelledby': 'faq_block_' + i,
          'data-parent': '#faqSearch'
        });
      });
      // add sorting for landing page
      var options = {
        valueNames: [
          'faq-title',
          'keywords'
        ]
      };
      var faqList = new List('faqSearch', options);

      faqList.on('updated', function (list) {
        var searchTextLength = $('.search').val().length;
        if (list.matchingItems.length == 0) {
          $('.js__no-faq-results').show();
        } else if (list.matchingItems.length == list.items.length) {
          $('.js__no-faq-results').hide();
        } else {
          $('.js__no-faq-results').hide();
        }
        if (searchTextLength > 0) {
          $('.js__clear-faq-search').show();
        } else {
          $('.js__clear-faq-search').hide();
        }
      });

      $('.js__faq-search-form').on('submit', function (e) {
        e.preventDefault();
        faqList.search();
      });
      // clear search on click
      $('.js__clear-faq-search').on('click', function (e) {
        e.preventDefault();
        $('.search').val('');
        faqList.search();
        $('.js__clear-faq-search').hide();
      });

    }


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

     // EXPANDABLE DONOR ROLL
     $('.js--honor-roll-expander').on('click', function (e) {
      if ($(this).children('i').hasClass('fa-chevron-down')) {
          $(this).children('i').removeClass('fa-chevron-down');
          $(this).children('i').addClass('fa-chevron-up');
      } else {
          $(this).children('i').removeClass('fa-chevron-up');
          $(this).children('i').addClass('fa-chevron-down');
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

              $('.team-roster form .btn').html('<i class="fas fa-search"></i>');
              $('#participant-roster td:nth-child(3) a').html('Donate');
          }
      }
    };

    cd.setDonorRollHeight = function () {
      $('.donations-container div').each(function (i, div) {
          if (i > 4) {
              $('.donations-container').css('height', '205px');
          }
      });
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

    // EXPANDABLE DONOR ROLL
    // $('.js--honor-roll-expander').on('click', function (e) {
    //   if ($(this).children('i').hasClass('fa-chevron-down')) {
    //     $(this).children('i').removeClass('fa-chevron-down');
    //     $(this).children('i').addClass('fa-chevron-up');
    //     $(this).attr('aria-label', 'View less donors');
    //   } else {
    //     $(this).children('i').removeClass('fa-chevron-up');
    //     $(this).children('i').addClass('fa-chevron-down');
    //     $(this).attr('aria-label', 'View more donors');
    //   }

    //   $('.hidden-donor-row').slideToggle(200);
    // });

    // GREETING PAGE
    if ($('body').is('.pg_entry')) {
      $('.js__toggle-calendar').on('click', function (e) {
        e.preventDefault();
        $('.js__calendar-menu').slideToggle();
      });

       // build greeting page social album
       if($('#social-feed').data('album-url')){
        var albumUrl = $('#social-feed').data('album-url');
        // var albumId = $('#social-feed').data('album-id');
        var albumId = '7584';
        // var albumImages = [];

        $.ajax({
          url: albumUrl,
          dataType: 'html',
          success: function (data) {
            var rawAlbumTable = $(data).find('table')[0];
            $('.js__raw-album-container').prepend(rawAlbumTable);

            $('.js__raw-album-container table').addClass('raw-photo-album');

            $('.raw-photo-album a').each(function(i){
              var imageId = $(this).attr('href');
              imageId = getURLParameter(imageId, 'PhotoID');
              var imageAltText = $(this).find('img').attr('alt');
              var imageSrc = '/images/content/photos/large_' + imageId + '.jpg';
              var finalAlbumImage = '<div class="grid-item"><a href="' + imageSrc + '"><img src="' + imageSrc + '" alt="' + imageAltText + '" data-modaal-desc="' + imageAltText + '" data-group="gallery" class="gallery" /></a></div>';

              $('.js__lo-album-container').prepend(finalAlbumImage);

            });

            var $grid = $('.js__lo-album-container').imagesLoaded( function() {
              console.log('launch masonry');
              // init Masonry after all images have loaded
              $grid.masonry({
                itemSelector: '.grid-item',
                percentPosition: true,
                columnWidth: '.grid-sizer'
              });

              // var simpleLightboxOptinos = {
              //   captions: true
              // }
              // var lightbox = $('.js__lo-album-container a').simpleLightbox();
              $('.gallery').modaal({
                type: 'image'
              });

            });

          },
          error: function (data) {
            // handle errors
          }
        });
      }

      //look for greeting page content
      if ( $('.js-greeting-intro').length > 0 ) {
        var greetingInfo = $('.js-greeting-intro').html();
        var greetingIntroContainer = '';
        greetingIntroContainer += '<div class="row">';
        greetingIntroContainer += '<div class="col-12 px-5 px-md-0 pb-5">';
        greetingIntroContainer += greetingInfo;
        greetingIntroContainer += '</div>';
        greetingIntroContainer += '</div>';

        $(greetingIntroContainer).insertAfter('.details-container');
      }

    }


    /******************************/
    /* CROSS EVENT ROSTER SCRIPTS */
    /******************************/
    var eventData = [];
    var compiledEventsData = [];
    var compiledParticipantsData = [];
    var compiledTeamsData = [];
    var compiledCompaniesData = [];

    var eventRosterReady = false;
    var participantRosterReady = false;
    var teamRosterReady = false;
    var companyRosterReady = false;

    cd.sort = function (prop, arr) {
      prop = prop.split('.');
      var len = prop.length;

      arr.sort(function (a, b) {
        var i = 0;
        while (i < len) {
          a = a[prop[i]];
          b = b[prop[i]];
          i++;
        }
        if (a > b) {
          return -1;
        } else if (a < b) {
          return 1;
        } else {
          return 0;
        }
      });
      return arr;
    };
    String.prototype.trunc = function (n) {
      return this.substr(0, n - 1) + (this.length > n ? '&hellip;' : '');
    };

    Number.prototype.formatMoney = function (c, d, t) {
      var n = this,
        c = isNaN(c = Math.abs(c)) ? 2 : c,
        d = d == undefined ? "." : d,
        t = t == undefined ? "," : t,
        s = n < 0 ? "-" : "",
        i = String(parseInt(n = Math.abs(Number(n) || 0).toFixed(c))),
        j = (j = i.length) > 3 ? j % 3 : 0;
      return s + (j ? i.substr(0, j) + t : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) + (c ? d +
        Math.abs(n - i).toFixed(c).slice(2) : "");
    };

    cd.getEvents = function (eventName, eventState, eventSort) {
      $('.js__loading').show();
      if ($('body').is('.pg_cn_home')) {
        var numEvents = 3;
      }
      $('.js__no-event-results').addClass('d-none');
      luminateExtend.api({
        api: 'teamraiser',
        data: 'method=getTeamraisersByInfo' +
          '&name=' + (eventState ? '%25%25' : eventName) +
          (eventState ? '&state=' + eventState : '') +
          '&event_type=' + eventType +
          '&response_format=json&list_page_size=499&list_page_offset=0&list_sort_column=' + (eventSort === 'city' ? 'city' : 'event_date') + '&list_ascending=true',
        callback: {
          success: function (response) {
            if (response.getTeamraisersResponse.totalNumberResults > '0') {
              $('.js__loading').hide();
              var events = luminateExtend.utils.ensureArray(response.getTeamraisersResponse.teamraiser);

              var todaysDate = new Date();
              todaysDate.setDate(todaysDate.getDate() - 1);
              var liveEventsDisplayed = 0;
              var pastEventsDisplayed = 0;

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
                var eventRow = '<li class="event-detail row col-12 col-lg-4 mb-4 fadein"><div class="event-detail-content col-10"><a class="js__event-name" href="' +
                  greetingUrl + '" aria-label="Visit ' + eventCity + ' ' + eventType + ' Event" onclick="_gaq.push([\'_trackEvent\', \'program homepage\', \'click\', \'search result name\']);"><span class="city">' +
                  eventCity + '</span>, <span class="fullstate">' +
                  eventStateAbbr + '</span></a><span class="eventtype d-block">' +
                  eventType + ' Event</span><span class="event-date d-block">' +
                  eventDate + '</span></div><a href="' +
                  greetingUrl + '" class="event-detail-button btn col-2" aria-label="Visit event page for CycleNation ' + eventCity + '" onclick="_gaq.push([\'_trackEvent\', \'program homepage\', \'click\', \'search result arrow\']);"><i class="fas fa-angle-right" aria-hidden="true" alt=""></i></a></li>';

                if (eventTimestamp > todaysDate && (eventStatus === '1' || eventStatus === '2' || eventStatus === '3')) {
                  if (numEvents) {
                    if (liveEventsDisplayed < numEvents) {
                      // numEvents exists. Restrict the number of results that are displayed
                      $('.js__event-search-results').append(eventRow);
                      liveEventsDisplayed++;
                    }
                  } else {
                    // numEvents does NOT exist. Display all results in list
                    $('.js__event-search-results').append(eventRow);
                  }
                } else if (eventStatus === '1' || eventStatus === '2' || eventStatus === '3') {
                  // display past events in a separate table
                  $('.js__past-event-search-results').append(eventRow);
                  $('.js__past-events-container').removeClass('d-none');
                }
              });

              if ($('body').is('.pg_cn_home') && liveEventsDisplayed === 0) {
                $('.js__no-event-results').removeClass('d-none');
              }

              $('.js__event-details').on('click', function () {
                _gaq.push(['t2._trackEvent', 'program-homepage', 'click', 'search-event-details-button']);
              });

              $('.js__event-register').on('click', function () {
                _gaq.push(['t2._trackEvent', 'program-homepage', 'click', 'search-event-register-button']);
              });

              $('.js__event-name').on('click', function () {
                _gaq.push(['t2._trackEvent', 'program-homepage', 'click', 'search-event-details-link']);
              });

            } else {
              $('.js__loading').hide();
              $('.js__no-event-results').removeClass('d-none');
            }
          },
          error: function (response) {
            $('.js__loading').hide();
            console.log('getEvents error: ' + response.errorResponse.message);
          }
        }
      });
    };
    // BEGIN getEventsByDistance

    cd.getEventsByDistance = function (zipCode) {
      $('.js__no-event-results').addClass('d-none');
      $('.js__loading').show();
      if ($('body').is('.pg_cn_home')) {
        var numEvents = 3;
      }
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
              $('.js__loading').hide();
              var events = luminateExtend.utils.ensureArray(response.getTeamraisersResponse.teamraiser);

              var todaysDate = new Date();
              todaysDate.setDate(todaysDate.getDate() - 1);
              var liveEventsDisplayed = 0;
              var pastEventsDisplayed = 0;

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

                var eventRow = '<li class="event-detail row col-12 col-lg-4 mb-4 fadein"><div class="event-detail-content col-10"><a class="js__event-name" href="' +
                  greetingUrl + '" aria-label="Visit ' + eventCity + ' ' + eventType + ' Event"><span class="city">' +
                  eventCity + '</span>, <span class="fullstate">' +
                  eventStateAbbr + '</span></a><span class="eventtype d-block">' +
                  eventType + ' Event</span><span class="event-date d-block">' +
                  eventDate + '</span></div><a href="' +
                  greetingUrl + '" class="event-detail-button btn col-2"  aria-label="Visit event page for CycleNation ' + eventCity + '"><i class="fas fa-angle-right" aria-hidden="true" alt=""></i></a></li>';
                if (eventTimestamp > todaysDate && (eventStatus === '1' || eventStatus === '2' || eventStatus === '3')) {
                  if (numEvents) {
                    if (liveEventsDisplayed < numEvents) {
                      // numEvents exists. Restrict the number of results that are displayed
                      $('.js__event-search-results').append(eventRow);
                      liveEventsDisplayed++;
                    }
                  } else {
                    // numEvents does NOT exist. Display all results in list
                    $('.js__event-search-results').append(eventRow);
                  }
                } else if (eventStatus === '1' || eventStatus === '2' || eventStatus === '3') {
                  // display past events in a separate table
                  $('.js__past-event-search-results').append(eventRow);
                }

              });

              // accessibility screen reader label for state search
              $("select#fr_event_state").on({
                "change": function () {
                  $(this).blur();
                },
                'focus': function () {
                  $('.js__state-search-submit').text('Select state combo box expanded');
                },
                "blur": function () {
                  $('.js__state-search-submit').text('Select state combo box collapsed');
                },
                "keyup": function (e) {
                  if (e.keyCode == 27)
                    $('.js__state-search-submit').text('Select state combo box collapsed');
                }
              });

              $('.js__event-details').on('click', function () {
                _gaq.push(['t2._trackEvent', 'program-homepage', 'click', 'search-event-details-button']);
              });

              $('.js__event-register').on('click', function () {
                _gaq.push(['t2._trackEvent', 'program-homepage', 'click', 'search-event-register-button']);
              });

              $('.js__event-name').on('click', function () {
                _gaq.push(['t2._trackEvent', 'program-homepage', 'click', 'search-event-details-link']);
              });
              addScrollLinks();

              // applyListFilter only on cn_home
              // applyListFilter();

            } else {
              $('.js__loading').hide();
              $('.js__no-event-results').removeClass('d-none');
            }
          },
          error: function (response) {
            $('.js__loading').hide();
            console.log('getEvents error: ' + response.errorResponse.message);
          }
        }
      });
    };
    // END getEventsByDistance

    // $('.js__show-more-events').on('click', function (e) {
    //   e.preventDefault();
    //   $(this).attr('hidden', true);
    //   $('.event-detail').removeAttr('hidden');
    //   $('.js__show-fewer-events').removeAttr('hidden');
    // });

    // $('.js__show-fewer-events').on('click', function (e) {
    //   e.preventDefault();
    //   $(this).attr('hidden', true);
    //   $('.event-detail').each(function (i) {
    //     if (i > 2) {
    //       $(this).attr('hidden', true);
    //     }
    //   });
    //   $('.js__show-more-events').removeAttr('hidden');
    // });


    // BEGIN TOP PARTICIPANTS
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
                var participantName = this.name.first + ' ' + this.name.last;
                var participantRaised = (parseInt(this.amountRaised) * 0.01);
                participantRaised = participantRaised.toFixed(0);
                var participantRaisedFormmatted = participantRaised.replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,");
                var participantId = this.consId;
                var participantPage = this.personalPageUrl;
                var isCaptain = this.aTeamCaptain;
                var topParticipantHtml = '<div class="top-list-entry row pb-2"><div class="badges col-2">' + (isCaptain === "true" ? '<svg version="1.1" class="team-captain-badge" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 110 110" style="enable-background:new 0 0 110 110;" xml:space="preserve" alt=""><circle class="st0" cx="55" cy="55" r="55"></circle><polygon class="st1" points="55,72.8 32.1,87.2 38.7,61 18,43.7 44.9,41.9 55,16.8 65.1,41.9 92,43.7 71.3,61 77.9,87.2 "></polygon></svg>' : '') + '</div><div class="names-amounts col-10 pl-0"><a class="participant-name" href="' + participantPage + '">' + participantName + ' <span class="hidden" aria-hidden="true">Participant</span></a><span class="amount-raised">$' + participantRaisedFormmatted + '</span></div></div>';

                $('.js__top-participants-list').append(topParticipantHtml);

              });
            }
          },
          error: function (response) {
            console.log('getTopParticipants error: ' + response.errorResponse.message);
          }
        }
      }); // end luminateExtend

    } // end getTopParticipants

    // END TOP PARTICIPANTS

    // BEGIN TOP TEAMS
    cd.getTopTeams = function (eventId) {
      luminateExtend.api({
        api: 'teamraiser',
        // data: 'method=getTopTeamsData&fr_id=' + eventId + '&response_format=json',
        data: 'method=getTeamsByInfo&fr_id=' + eventId + '&list_sort_column=total&list_ascending=false&list_page_size=5&response_format=json',
        callback: {
          success: function (response) {
            if (!$.isEmptyObject(response.getTeamSearchByInfoResponse)) {
              var teamData = luminateExtend.utils.ensureArray(response.getTeamSearchByInfoResponse.team);

              $(teamData).each(function (i) {
                var teamName = this.name;
                var teamRaised = (parseInt(this.amountRaised) * 0.01);
                teamRaised = teamRaised.toFixed(0);
                var teamRaisedFormmatted = teamRaised.replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,");
                var teamId = this.id;
                var badgeLevel = null;
                if (teamRaised >= 5000) {
                  badgeLevel = "5000";
                } else if (teamRaised >= 2500) {
                  badgeLevel = "2500";
                } else if (teamRaised >= 1000) {
                  badgeLevel = "1000";
                }
//                var topTeamRow = '<div class="top-list-entry row pb-2"><div class="badges col-2"> ' + (badgeLevel ? '<img src="http://' + window.location.host + '/aha-luminate/dist/cyclenation/image/badge_team_' + badgeLevel + '.svg" aria-hidden="true">' : '') + '</div><div class="names-amounts col-10 pl-0"> <a class="participant-name" href="TR/?team_id=' + teamId + '&amp;pg=team&amp;fr_id=' + evID + '">' + teamName + '</a> <span class="amount-raised">$' + teamRaisedFormmatted + '</span> </div></div>';
                var topTeamRow = '<div class="top-list-entry row pb-2"><div class="badges col-2"> ' + (badgeLevel ? '<img src="https://' + window.location.host + '/aha-luminate/dist/cyclenation/image/badge_team_' + badgeLevel + '.svg" aria-hidden="true" alt="">' : '') + '</div><div class="names-amounts col-10 pl-0"> <a class="participant-name" href="TR/?team_id=' + teamId + '&amp;pg=team&amp;fr_id=' + evID + '">' + teamName + ' <span class="hidden" aria-hidden="true">Team</span></a> <span class="amount-raised">$' + teamRaisedFormmatted + '</span> </div></div>';

                $('.js__top-teams-list').append(topTeamRow);
              });
            }
          },
          error: function (response) {
            console.log('getTopTeams error: ' + response.errorResponse.message);
          }
        }
      }); // end luminateExtend


    } // end getTopTeams

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

              $(topCompanies).each(function () {
                var companyName = this.companyName;
                var companyRaised = (parseInt(this.amountRaised) / 100);
                companyRaised = companyRaised.toFixed(0);
                var companyRaisedFormmatted = companyRaised.replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,");
                var topCompanyHtml = '<div class="top-list-entry row pb-2"> <div class="badges col-2"> </div><div class="names-amounts col-10 pl-0"> <a class="participant-name" href="TR?company_id=' + this.companyId + '&fr_id=' + evID + '&pg=company">' + companyName + ' <span class="hidden" aria-hidden="true">Company</span></a> <span class="amount-raised">$' + companyRaisedFormmatted + '</span> </div></div>';
                $('.js__top-companies-list').append(topCompanyHtml);
              });
            }
          },
          error: function (response) {
            console.log('getTopCompanies error: ' + response.errorResponse.message);
          }
        }
      }); // end luminateExtend
    } // end getTopCompanies

    cd.initializeTeamRosterTable = function () {
      window.cdTeamRosterTable = $('#team-roster').DataTable({
          // "paging": true,
          // "lengthMenu": [ [5, 10, 25, -1], [5, 10, 25, "All"] ],
          // "pageLength": 5,
          "paging": false,
          "autoWidth": false,
          "order": [[3, 'desc']],
          "language": {
              "search": "Search for a Team"
          }
      });
      $('#team-roster_info, #team-roster_filter').wrapAll('<div class="row"></div>');
      $('#team-roster_info').insertBefore($('#team-roster_filter')).wrap('<div class="col-md-6 col-sm-12 sorter pl-md-0"></div>');
      $('#team-roster_filter').wrap('<div class="col-md-6 col-sm-12"></div>');

      $('#team-roster_filter input[type="search"]').attr('id', 'team_search').wrap('<div class="input-group"></div>').addClass('form-control').after('<div class="input-group-append"><button class="btn btn-primary btn-outline-secondary" type="button">Search <i class="fas fa-search"></i></button></div>');

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
              "search": "Search for a Rider"
          }
      });

      $('#participant-roster_info, #participant-roster_filter').wrapAll('<div class="row"></div>');
      $('#participant-roster_info').insertBefore($('#participant-roster_filter')).wrap('<div class="col-md-6 col-sm-12 sorter d-flex align-items-end"></div>');
      $('#participant-roster_filter').wrap('<div class="col-md-6 col-sm-12"></div>');

      $('#participant-roster_filter input[type="search"]').attr('id', 'participant_search').wrap('<div class="input-group"></div>').addClass('form-control').after('<div class="input-group-append"><button class="btn btn-primary btn-outline-secondary" type="button">Search <i class="fas fa-search"></i></button></div>');

      $('#participant-roster_filter label').attr('for', 'participant_search');

  };

    /******************/
    /* MILES SCRIPTS */
    /******************/
    cd.getTopParticipantsMiles = function (eventId) {
        var motionApiUrl = 'https://' + motion_urlPrefix + '.boundlessfundraising.com/mobiles/' + motionDb + '/getMotionActivityRoster?event_id=' + motion_event + '&roster_type=participant&list_size=5';

        $.ajax({
            url: motionApiUrl,
            async: true,
            type:'GET',
            dataType: 'json',
            contentType: 'application/json',
            beforeSend: function(xhr) {
                xhr.setRequestHeader("Authorization", "Basic "+btoa(motion_username+':'+motion_password));
            },
            success: function(response){
                if (response.activities != undefined) {
                    $(response.activities).each(function(){
                        var participantName = this.name;
                        var miles = parseFloat(this.total).formatMoney(0);
                        var participantPage = "https://" + ((isProd) ? "www2" : "dev2") + ".heart.org/site/TR?px="+this.id+"&pg=personal&fr_id="+eventId;
                        var topParticipantHtml = '<div class="top-list-entry row pb-2"><div class="badges col-2"> </div><div class="names-amounts col-10 pl-0"><a class="participant-name" href="' + participantPage + '">' + participantName + ' <span class="hidden" aria-hidden="true">Participant Duration</span></a><span class="amount-raised">' + convertMinutes(miles) + '</span></div></div>';
                        $('.js__top-participants-miles').append(topParticipantHtml);
                    });
                }
            },
            error: function(err) {
                console.log('getMotionActivityRoster err', err);
            }
        });
    };
    // END TOP PARTICIPANTS MILES

    // BEGIN TOP TEAMS MILES
    cd.getTopTeamsMiles = function (eventId) {
        var motionApiUrl = 'https://' + motion_urlPrefix + '.boundlessfundraising.com/mobiles/' + motionDb + '/getMotionActivityRoster?event_id=' + motion_event + '&roster_type=team&list_size=5';

        $.ajax({
            url: motionApiUrl,
            async: true,
            type:'GET',
            dataType: 'json',
            contentType: 'application/json',
            beforeSend: function(xhr) {
                xhr.setRequestHeader("Authorization", "Basic "+btoa(motion_username+':'+motion_password));
            },
            success: function(response){
                if (response.activities != undefined) {
                    $(response.activities).each(function(){
                        var teamName = this.name;
                        var miles = parseFloat(this.total).formatMoney(0);
                        var topTeamRow = '<div class="top-list-entry row pb-2"><div class="badges col-2"> </div><div class="names-amounts col-10 pl-0"> <a class="team-name" href="TR/?team_id=' + this.id + '&amp;pg=team&amp;fr_id=' + evID + '">' + teamName + ' <span class="hidden" aria-hidden="true">Team Duration</span></a> <span class="amount-raised">' + convertMinutes(miles) + '</span> </div></div>';
                        $('.js__top-teams-miles').append(topTeamRow);
                    });
                }
            },
            error: function(err) {
                console.log('getMotionActivityRoster err', err);
            }
        });
    };

    // END TOP TEAMS MILES

    // BEGIN TOP COMPANIES MILES
    cd.getTopCompaniesMiles = function (eventId) {
        var motionApiUrl = 'https://' + motion_urlPrefix + '.boundlessfundraising.com/mobiles/' + motionDb + '/getMotionActivityRoster?event_id=' + motion_event + '&roster_type=company&list_size=5';

        $.ajax({
            url: motionApiUrl,
            async: true,
            type:'GET',
            dataType: 'json',
            contentType: 'application/json',
            beforeSend: function(xhr) {
                xhr.setRequestHeader("Authorization", "Basic "+btoa(motion_username+':'+motion_password));
            },
            success: function(response){
                if (response.activities != undefined) {
                    $(response.activities).each(function(){
                        var companyName = this.name;
                        var miles = parseFloat(this.total).formatMoney(0);
                        var topCompanyHtml = '<div class="top-list-entry row pb-2"> <div class="badges col-2"> </div><div class="names-amounts col-10 pl-0"> <a class="company-name" href="TR?company_id=' + this.id + '&fr_id=' + evID + '&pg=company">' + companyName + ' <span class="hidden" aria-hidden="true">Company Duration</span></a> <span class="amount-raised">' + convertMinutes(miles) + '</span> </div></div>';
                        $('.js__top-companies-miles').append(topCompanyHtml);
                    });
                }
            },
            error: function(err) {
                console.log('getMotionActivityRoster err', err);
            }
        });

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

    // BEGIN TOP EVENT MILES
    cd.getTopEventMiles = function () {
      var topEventHtml = '';
      var topEventList = [];
      var totalRaised = 0;
      var totalMiles = 0;
  	  $.getJSON("//tools.heart.org/cn_leaderboard/getTotals.php?isProd="+((isProd) ? 1 : 0)+"&callback=?",function(data){
        totalRaised = parseFloat(data.totalRaised);
        totalMiles = parseFloat(data.totalMiles);
        $('.therm-raised').html("$"+totalRaised.formatMoney(0));
        $('.therm-miles').html(totalMiles.formatMoney(0));
        var goalRaised = parseFloat($('#therm--progress').data("goal"));
        var goalMiles = parseFloat($('#therm2--progress').data("goal"));
        $('#therm--progress').css("width",((totalRaised/goalRaised) * 100).toFixed(2)+'%');
        $('#therm2--progress').css("width",((totalMiles/goalMiles) * 100).toFixed(2)+'%');
        topEventList = data.topEventList;
        if ($('body').is('.pg_cn_home')) {
          //sort totals highest to lowest
          topEventList.sort(function(a, b) {
            if (parseFloat(a.total) === parseFloat(b.total)) {return 0;}
            else {return (parseFloat(a.total) < parseFloat(b.total)) ? 1 : -1;}
          });
          //write out totals
          var cnt = 0;
          $.each(topEventList,function(){
            var event_id = this.event_id;
            var event_city = this.event_city;
            var event_state = this.event_state;
            var event_name = this.event_name;

            topEventHtml += '<div class="top-list-entry row pb-2">';
            topEventHtml += '  <div class="names-amounts col-8 pl-0">';
            topEventHtml += '    <a class="event-name" href="/site/TR?pg=entry&fr_id='+event_id+'"><span class="city">'+event_city+'</span>, <span class="fullstate">'+event_state+'</span></a>';
            topEventHtml += '  </div>';
            topEventHtml += '  <div class="names-amounts col-4 pl-0 text-right">';
            topEventHtml += '    <span class="distance">' + convertMinutes(this.total) + '</span>';
            topEventHtml += '  </div>';
            topEventHtml += '</div>';
            if (cnt >= 4) return false;
            cnt++;
          });
          $('.js__top-events-list').append(topEventHtml);
        }
      });
    };
    
    function getLocation() {
      var options = {
        enableHighAccuracy: true,
        timeout: 10000,
        maximumAge: 'infinity'
      };
      if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(showPosition, showGeolocationError, options);
      } else {
        console.log("Geolocation is not supported by this browser.");
      }
    }


    function showPosition(position) {
      var input = position.coords.latitude + "," + position.coords.longitude;
      var latlngStr = input.split(',', 2);
      var latlng = new google.maps.LatLng(latlngStr[0], latlngStr[1]);
      var geocoder = new google.maps.Geocoder();
      geocoder.geocode({
        'location': latlng
      }, function (results, status) {

        var postalCode;

        if (status == google.maps.GeocoderStatus.OK && results[0]) {
          $.each(results[0].address_components, function () {
            if ($.inArray('postal_code', this.types) >= 0) {
              postalCode = this.short_name;
            }
          });

          if (postalCode) {
            cd.getEventsByDistance(postalCode);
          } else {
            if (results[0].geometry && results[0].geometry.location) {
              // getZipForLatLng({
              //   lat: results[0].geometry.location.lat(),
              //   lng: results[0].geometry.location.lng(),
              //   callback: settings.callback
              // });
            } else {
              cd.getEventsByDistance(postalCode);
            }
          }
        } else {
          cd.getEventsByDistance(postalCode);
        }
      });

      // geocoder.geocode( { 'location': latlng }, function (result, status) {
      // console.log("Geocode result: ", result);
      // console.log("Geocode status: ", status);

      //   var zipCode = result[0]['address_components'][7]['short_name'];
      //   cd.getEventsByDistance(zipCode);

      // });
    }

    function showGeolocationError(error) {
      cd.getEvents('%25%25', null);
      switch (error.code) {
        case error.PERMISSION_DENIED:
          console.log("User denied the request for Geolocation.");
          break;
        case error.POSITION_UNAVAILABLE:
          console.log("Location information is currently unavailable.");
          break;
        case error.TIMEOUT:
          console.log("The request to get location timed out.  Please refresh the page to use this feature.");
          break;
        case error.UNKNOWN_ERROR:
          console.log("An unknown error occurred.");
          break;
      }
    }
    // Call roster scripts based on page type
    if ($('body').is('.pg_cn_search')) {
      // TODO - add api calls here on tab
      $('#participant-search-tab').on('click', function (e) {
        e.preventDefault()
        $('.results-tab-pane').hide();
        $('#participantSearchResults').show();
      });
      $('#team-search-tab').on('click', function (e) {
        e.preventDefault()
        $('.results-tab-pane').hide();
        $('#teamSearchResults').show();
      });
      $('#company-search-tab').on('click', function (e) {
        e.preventDefault()
        $('.results-tab-pane').hide();
        $('#companySearchResults').show();
      });

      var clearSearchForms = function () {
        $('#participantFirstName, #participantLastName, #teamName, #companyName').val('');
      }

      var clearSearchResults = function () {
        $('.js__participant-results-container, .alert').attr('hidden', true);
        $('.js__participants-results-rows').html('');
        $('.js__team-results-container, .alert').attr('hidden', true);
        $('.js__team-results-rows').html('');
        $('.js__company-results-container, .alert').attr('hidden', true);
        $('.js__company-results-rows').html('');
      }

      // Search by Participant
      $('.js__participant-search-form').on('submit', function (e) {
        e.preventDefault();
        clearSearchResults();
        var firstName = encodeURI($('#participantFirstName').val());
        var lastName = encodeURI($('#participantLastName').val());

        // console.log('searchType: ', searchType);
        // var searchAllEvents = true;
        // if(searchType && searchType === "individual"){
        //   searchAllEvents = false;
        // }

        cd.getParticipants(firstName, lastName, (searchType === "singleEvent" ? false : true));
      });

      // Search by Team
      $('.js__team-search-form').on('submit', function (e) {
        e.preventDefault();
        clearSearchResults();
        var teamName = encodeURI($('#teamName').val());
        cd.getTeams(teamName, null, (searchType === "singleEvent" ? false : true));
      });

      // Search by Company
      $('.js__company-search-form').on('submit', function (e) {
        e.preventDefault();
        clearSearchResults();
        var companyName = encodeURI($('#companyName').val());
        cd.getCompanies(companyName, (searchType === "singleEvent" ? false : true));
      });

      // auto search functionality based on URL params

      if (searchType) {
        var firstSearchTerm = getURLParameter(currentUrl, 'first_term') ? getURLParameter(currentUrl, 'first_term') : '';
        var lastSearchTerm = getURLParameter(currentUrl, 'second_term') ? getURLParameter(currentUrl, 'second_term') : '';

        firstSearchTerm = decodeURI(firstSearchTerm);
        lastSearchTerm = decodeURI(lastSearchTerm);

        cd.autoSearchParticipant = function () {
          $('#participantFirstName').val(firstSearchTerm);
          $('#participantLastName').val(lastSearchTerm);

          cd.getParticipants(firstSearchTerm, lastSearchTerm, (searchType === "singleEvent" ? false : true));
        }

        cd.autoSearchTeam = function () {
          var teamName = firstSearchTerm + (lastSearchTerm.length ? ' ' + lastSearchTerm : '');
          $('#teamName').val(teamName);
          cd.getTeams(teamName, null, (searchType === "crossEvent" ? true : false));
        }

        cd.autoSearchCompany = function () {
          var companyName = firstSearchTerm + (lastSearchTerm.length ? ' ' + lastSearchTerm : '');
          $('#companyName').val(companyName);
          cd.getCompanies(companyName, (searchType === "crossEvent" ? true : false));
        }

        cd.autoSearchParticipant();
        cd.autoSearchTeam();
        cd.autoSearchCompany();
      }

    }

    if ($('body').is('.pg_cn_home') || $('body').is('.pg_cn_events')) {

      if ($('body').is('.pg_cn_home')) {
        $('.js__loading').show();
        getLocation();
      } else {
        cd.getEvents('%25%25', null, 'city');
      }

      var clearEventSearchResults = function () {
        $('.js__event-search-results').html('');
        $('.js__past-event-search-results').html('');
        $('.js__past-events-container').addClass('d-none');
      }
      $('.js__state-search select').on('change', function (e) {
        e.preventDefault();
        $('#zip').val('');
        clearEventSearchResults();
        var stateSearched = $(this).children('option:selected').val();

        if (stateSearched === 'Select State') {
          cd.getEvents('%25%25', null);
        } else {
          cd.getEvents(null, stateSearched);
        }
        e.preventDefault();
      });

      $('.js__state-search').on('submit', function (e) {
        e.preventDefault();
        $('#zip').val('');
        clearEventSearchResults();
        var stateSearched = $(this).children('option:selected').val();
        if (stateSearched === 'Select State') {
          cd.getEvents('%25%25', null);
        } else {
          cd.getEvents(null, stateSearched);
        }
        e.preventDefault();
      });
      $('.js__zip-search').on('submit', function (e) {
        $('#fr_event_state').val($('#fr_event_state option:first').val());
        $('.js__event-search-results').html('');
        clearEventSearchResults();
        var zipSearched = $('#zip').val();
        if (zipSearched.length) {
          cd.getEventsByDistance(zipSearched);
        } else {
          cd.getEvents('%25%25', null);
        }

        e.preventDefault();
      });
      
    } else if ($('body').is('.pg_entry')) {
      cd.getTopParticipants(evID);
      cd.getTopTeams(evID);
      cd.getTopCompanies(evID);
      if (currDate >= fourWeek && currDate <= eventDate) {
          //build steps leaderboard
          cd.getTopParticipantsMiles(evID);
          cd.getTopTeamsMiles(evID);
          cd.getTopCompaniesMiles(evID);
      } else {
          $('#fundraiserMiles').hide();
      }
    }

    //Get boundless motion totals if therm exists
    if ($('.headerTherm').length > 0) {
      cd.getTopEventMiles();
    }

    // TODO - rename to make clear that this is a redirect search form with single field
    $('.js__rider-search').on('submit', function (e) {
      e.preventDefault();
      var fullName = $('#rider_name').val();
      var isMultiWordSearch = fullName.trim().indexOf(' ');
      var firstTerm, lastTerm, searchParams;

      if (isMultiWordSearch === -1) {
        searchParams = '&first_term=' + fullName;
      } else {
        // First Name is the first word of a multi word search. If there are more than two words, first name will include all of the words except the last word
        firstTerm = fullName.split(' ').slice(0, -1).join(' ');
        // Last Name is the last whole word in a multi word search
        lastTerm = fullName.split(' ').slice(-1).join(' ');
        searchParams = '&first_term=' + firstTerm + '&second_term=' + lastTerm;

      }

      if ($('body').is('.pg_cn_home')) {
        window.location.href = luminateExtend.global.path.secure + 'SPageServer/?pagename=cn_search&search_type=crossEvent' + searchParams;
      } else {
        window.location.href = luminateExtend.global.path.secure + 'SPageServer/?pagename=cn_search&search_type=singleEvent' + searchParams + '&fr_id=' + evID;
      }

    });


    // END LANDING PAGE ONLY

    /******************************************************************/
    /* Get Captain ID - auto select ptype time for those joining team */
    /******************************************************************/

    cd.getTeamCaptainId = function (evID, teamId, trPage) {
      luminateExtend.api({
        api: 'teamraiser',
        data: 'method=getTeamCaptains&response_format=json&fr_id=' + evID + '&team_id=' + teamId,
        callback: {
          success: function (response) {
            var captainArray = luminateExtend.utils.ensureArray(response.getTeamCaptainsResponse.captain);
            var captainConsId = captainArray[0].consId;

            if (trPage === 'personal') {
              var origJoinTeamUrl = $('#personal_page_join_team_button').attr('href');
              var modJoinTeamUrl = origJoinTeamUrl + '&s_regType=joinTeam&s_captainConsId=' + captainConsId;
              $('#personal_page_join_team_button').attr('href', modJoinTeamUrl);
            } else if (trPage === 'team') {
              var origJoinTeamUrl = $('#join_team_button').attr('href');
              var modJoinTeamUrl = origJoinTeamUrl + '&s_regType=joinTeam&s_captainConsId=' + captainConsId;
              $('#join_team_button').attr('href', modJoinTeamUrl);
            }
          },
          error: function (response) {

          }
        }
      });
    };

    // Top Participants Roster
    if ($('body').is('.pg_cn_top_participants')) {

      luminateExtend.api({
        api: 'teamraiser',
        data: 'method=getParticipants' +
          '&first_name=%25%25%25' +
          '&last_name=%25%25%25' +
          '&fr_id=' + evID +
          '&list_page_size=499' +
          '&list_page_offset=0',
        // '&response_format=json' +
        // '&list_sort_column=raised' +
        // '&list_ascending=false',
        callback: {
          success: function (response) {
            if (response.getParticipantsResponse.totalNumberResults === '0') {
              // no search results
            } else {
              var participants = luminateExtend.utils.ensureArray(response.getParticipantsResponse.participant);

              var topParticipantsData = [];

              $(participants).each(function (i, participant) {
                topParticipantsData.push({
                  "consName": participant.name.first + ' ' + participant.name.last,
                  "consTeamName": participant.teamName,
                  "consTeamUrl": participant.teamPageUrl,
                  "consTotal": participant.amountRaised,
                  "consId": participant.consId,
                  "consEventId": participant.eventId,
                  "consEventLocation": participant.eventName
                });
              });

              var sortedTopParticipantsData = cd.sort('consTotal', topParticipantsData);

              for (var i = 0, len = sortedTopParticipantsData.length; i < len; i++) {
                var participantData = '<tr><td><a href="' + luminateExtend.global.path.secure + 'TR/?fr_id=' +
                  sortedTopParticipantsData[i].consEventId + '&pg=personal&px=' + sortedTopParticipantsData[i].consId +
                  '">' + sortedTopParticipantsData[i].consName + '</a>' +
                  ((sortedTopParticipantsData[i].consTeamUrl) ? ', ' + '<a href="' + sortedTopParticipantsData[i].consTeamUrl +
                    '">' + sortedTopParticipantsData[i].consTeamName + '</a>' : '') + '</td><td class="text-right"><span class="pull-right">$' +
                  (sortedTopParticipantsData[i].consTotal / 100).toFixed(2).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",") + '</span></td></tr>';

                $('.js__top-participants-roster').append(participantData);
              }
              //add call to hook donate button with payment type selections
              // $('#participant_results').removeAttr('hidden');
            }
          },
          error: function (response) {
            // $('#error-participant').removeAttr('hidden').text(response.errorResponse.message);
            console.log('getParticipants Error: ', response);

          }
        }
      });
    }
    // Top Teams Roster
    if ($('body').is('.pg_teamlist')) {
      $('.tr-page-header h2').replaceWith(function () {
        return '<h1>' + $(this).html() + '</h1>';
      });
    }

    // Top Companies Roster
    if ($('body').is('.pg_complist')) {
      $('.tr-page-header h2').replaceWith(function () {
        return '<h1>' + $(this).html() + '</h1>';
      });
      $('.tr-page-header').append('<h2>Top Companies</h2>');
    }
    /****************/
    /* REGISTRATION */
    /****************/

    // interaction logic
    if ($('#user_type_page').length > 0 || $('#team_find_page').length > 0) {
      var trLoginSourceCode = (srcCode.length ? srcCode : 'trReg');
      var trSignupSourceCode = (srcCode.length ? srcCode : 'trReg');
      var trSocialSourceCode = (srcCode.length ? srcCode : 'trReg');

      var trLoginSubSourceCode = (subSrcCode.length ? subSrcCode : eventName + '_' + evID);
      var trSignupSubSourceCode = (subSrcCode.length ? subSrcCode : eventName + '_' + evID);
      var trSocialSubSourceCode = (subSrcCode.length ? subSrcCode : eventName + '_' + evID);

      var trRegInteractionID = (isProd === true ? '1031' : '1022');
      var trLoginInteractionID = (isProd === true ? '1030' : '1021');
      var trSocialInteractionID = (isProd === true ? '1032' : '1023');
      var trLoggedInInteractionID = (isProd === true ? '1040' : '1031');

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

    }

    if ($('#user_type_page').length > 0) {


      // UTYPE step



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
      $('.js__show-retrieve-login').on('click', function (e) {
        e.preventDefault();
        cd.resetValidation();
        $('.js__login-container').addClass('d-none');
        $('.js__retrieve-login-container').removeClass('d-none');
      });

      // show login form
      $('.js__show-login').on('click', function (e) {
        e.preventDefault();
        cd.resetValidation();
        $('.js__retrieve-login-container').addClass('d-none');
        $('.js__signup-container').addClass('d-none');
        $('.js__login-container').removeClass('d-none');
      });
      // show signup form
      $('.js__show-signup').on('click', function (e) {
        e.preventDefault();
        cd.resetValidation();
        $('.js__retrieve-login-container').addClass('d-none');
        $('.js__login-container').addClass('d-none');
        $('.js__signup-container').removeClass('d-none');
      });

      $('.js__existing-record').on('click', function (e) {
        // existing record. show log in form
        $('.js__have-we-met-container').addClass('d-none');
        $('.js__login-container').removeClass('d-none');
      });
      $('.js__show-have-we-met').on('click', function (e) {
        // existing record. show log in form
        e.preventDefault();
        $('.js__login-container').addClass('d-none');
        $('.js__have-we-met-container').removeClass('d-none');
      });
      $('.js__new-record').on('click', function (e) {
        // new participant. continue to tfind step
        $('#f2fRegPartType #next_step').click();
      });



      $('.janrainEngage').html('<div class="btn-social-login btn-facebook"><i class="fab fa-facebook-f mr-2"></i> Create with Facebook</div><div class="btn-social-login btn-amazon"><i class="fab fa-amazon mr-2"></i> Create with Amazon</div>');

    }

    // BEGIN TFIND

    if ($('#team_find_page').length > 0 || $('body').is('.pg_cn_register')) {
      // BEGIN tfind customizations
      $('form[name=FriendraiserFind]').attr('hidden', true);

      if (regType === 'startTeam') {
        if (eventType2 === 'Road' || eventType2 === 'Executive Challenge' || eventType2 === 'StationaryV2') {
          $('form[name=FriendraiserFind]').removeAttr('hidden');
          $('#team_find_section_body, #team_find_section_header').show();
        }
        var trCompanyCount = $('#fr_co_list > option').length;
        if (trCompanyCount < 2) {
          // no companies associated with this TR yet. Hide the team_find_new_team_company column
          $('#team_find_new_team_company').hide();
          // $('#team_find_new_team_attributes').addClass('no-companies');
          // $('#team_find_new_team_name, #team_find_new_fundraising_goal').addClass('col-md-6');
        }
      } else if (regType === 'joinTeam') {
        if ($('#team_find_existing').length > 0) {

          // BEGIN new team find form
          // $('.js__join-team-container').html($('.js__reg-team-search-form'));
          $('.js__reg-team-search-form').on('submit', function (e) {
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

          });

          cd.getCompanyList = function (frId, companyId) {
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
                success: function (response) {
                  // $('.js__loading').hide();


                  var companyList = '',
                    nationals = (response.getCompanyListResponse.nationalItem ? luminateExtend.utils.ensureArray(response.getCompanyListResponse.nationalItem) : []),
                    regionals = (response.getCompanyListResponse.regionalItem ? luminateExtend.utils.ensureArray(response.getCompanyListResponse.regionalItem) : []),
                    companies = (response.getCompanyListResponse.companyItem ? luminateExtend.utils.ensureArray(response.getCompanyListResponse.companyItem) : []);

                  var sortCompanies = function (a, b) {
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
                  $.each(nationals, function () {
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
                  $.each(regionals, function () {
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
                  $.each(companies, function () {
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
                error: function (response) {
                  // $('.js__loading').hide();
                  $('.js__error-team-search').text(response.errorResponse.message).show();
                }
              }
            });
          };

          cd.getCompanyList(evID);
          // END new team find form


          // $('#team_find_search_team_name_required').remove();
          // On JOIN TEAM step - rename label
          $('#team_label_container').text('Squad name:');
          $('#team_find_existing').prepend('<div class="text-center w-100"><p>Enter squad name and/or pick company from drop down</p></div>');
          $('#company_label_container').text('Search by company:');
          $('form[name=FriendraiserFind]').removeAttr('hidden');

          // append cons ID to the join team button
          if ($('#team_find_search_results_container').length > 0) {

            var teamRows = $('.list-component-row');
            $.each(teamRows, function (i, teamRow) {
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
      var goalPerBike = 1000;
      var defaultNumBikeText = 'Number of Bikes';
      var numBikeSelector = $('.js__numbike-selector');
      var dynTeamGoal = $('.js__generated-team-goal');
      var currentTeamGoal, currentTeamGoalFormatted, minTeamGoalMsg;
      var loTeamGoal = $('#fr_team_goal');
      var promoCode = ($('body').data('promocode') !== undefined ? $('body').data('promocode') : "");

      // tfind

      $('#fr_team_goal').attr("placeholder", "$");

      // begin StationaryV2 event conditional
      if (eventType2 === 'StationaryV2') {
        var loDefaultGoal = $('#fr_team_goal').val();
        if (loDefaultGoal) {
          goalPerBike = Number(loDefaultGoal.replace(/[^0-9\.-]+/g, ""));
        }

        // check to see if Start a Team and Breakaway ptypes are available

        // if Start a Team and Breakaway ptypes are not available, remove those registration options and display a sponsor code field on the reg options step



        cd.getParticipationTypes = function (promo) {
          $('.js__reg-type-container .alert').addClass('hidden');
          var isStartTeamAvailable = false;
          var isBreakawayAvailable = false;
          var validPromo = false;
          var promoCodePtypesAvailable = false;

          luminateExtend.api({
            api: 'teamraiser',
            data: 'method=getParticipationTypes' +
              '&fr_id=' + evID +
              ((promo !== undefined) ? '&promotion_code=' + promo : '') +
              '&response_format=json',
            callback: {
              success: function (response) {

                if (response.getParticipationTypesResponse.participationType.length) {
                  // no search results
                  var participationTypes = luminateExtend.utils.ensureArray(response.getParticipationTypesResponse.participationType);
                  // var promoPtypeLoaded = false;
                  $(participationTypes).each(function (i, ptype) {
                    // There is no promo code in session
                    if (ptype.participationTypeRegistrationLimit && ptype.participationTypeRegistrationLimit.limitReached === 'false') {
                      // Publicly available ptypes are available
                      // ptype has a limit and it has NOT been reached
                      if (ptype.name.indexOf('Start a Team') > -1) {
                        if (ptype.participationTypeRegistrationLimit.limitReached === 'false') {
                          isStartTeamAvailable = true;
                        }
                      } else if (ptype.name.indexOf('Breakaway') > -1) {
                        if (ptype.participationTypeRegistrationLimit.limitReached === 'false') {
                          isBreakawayAvailable = true;
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
                      } else if (ptype.name.indexOf('Breakaway') > -1) {
                        if (ptype.participationTypeRegistrationLimit.limitReached === 'false') {
                          isBreakawayAvailable = true;
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
                  if (isBreakawayAvailable === true) {
                    $('.breakaway-container').removeClass('hidden');
                  }

                  if (promoCodePtypesAvailable) {
                    console.log('promoCode ptypes are available and loaded');
                    // add promo code to reg options links in case they are entering it for the first time on this step
                    var regOptionLinks = $('.js__reg-type-form .step-button');

                    $(regOptionLinks).each(function () {
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
              error: function (response) {
                console.log(response.errorResponse.message);
              }
            }
          });
        };

        if (promoCode) {
          cd.getParticipationTypes(promoCode);
        } else {
          cd.getParticipationTypes();
        }

        // manage manual submission of promo codes on reg options step
        $('.js__reg-options-promo-form').on('submit', function (e) {
          e.preventDefault();
          var manualPromoCode = $('#sponsorCode').val();
          cd.getParticipationTypes(manualPromoCode);
        });

      } // end StationaryV2 event conditional

      // only show the VIP code field if a promo code is not already in session
      if (!promoCode) {
        $('#team_find_new_company_selection_container').append('<div id="team_sponsor_code" class="input-container"><div class="form-group"><label for="sponsorCode">Do you have a VIP Code?</label><input name="s_promoCode"type="text"id="sponsorCode"class="form-control" value=""></div></div>');
      }

      var numTeamResults = $('#team_find_search_results_container .list-component-row').length;

      if (numTeamResults < 20) {
        $('.list-component-paginator').hide();
      }

      $('#friend_potion_next')
        .wrap('<div class="order-1 order-sm-2 col-sm-4 offset-md-6 col-md-3 col-8 offset-2 mb-3"/>');
      if(regType === 'startTeam') {
      $('#team_find_section_footer')
        .prepend('<div class="order-2 order-sm-1 col-sm-4 col-md-3 col-8 offset-2 offset-sm-0"><a href="TRR/?pg=tfind&amp;fr_id=' + evID + '&fr_tm_opt=new" class="button btn-secondary btn-block">Back</a></div>');
      } else {
        $('#team_find_section_footer')
        .prepend('<div class="order-2 order-sm-1 col-sm-4 col-md-3 col-8 offset-2 offset-sm-0"><a href="TRR/?pg=tfind&amp;fr_id=' + evID + '" class="button btn-secondary btn-block">Back</a></div>');
      }

      // Style LOs team goal input
      if (eventType2 === 'StationaryV2') {
        $(loTeamGoal)
        .wrap('<div class="input-group" />');
      }


      $('#team_find_new_fundraising_goal_input_hint').before('<div class="team-goal-error"></div>');

      $('.js__show-team-bikes').on('click', function (e) {
        e.preventDefault();
        // display team captain page where bike numbers are calculated
        $('.js__reg-type-container').addClass('d-none');
        $('.js__team-bikes-container').removeClass('d-none');
      });

      $('.js__show-reg-type').on('click', function (e) {
        e.preventDefault();
        $('.js__team-bikes-container').addClass('d-none');
        $('.js__reg-type-container').removeClass('d-none');
      });


      var teamFindParsleyConfig = {
        errorsContainer: function (pEle) {
          var $err = pEle.$element.parent().parent().find('.team-goal-error');
          return $err;
        }
      }

      $('.js__show-team-details').on('click', function (e) {
        e.preventDefault();
        $('.js__team-bikes-container').attr('hidden', true);
        $('form[name=FriendraiserFind]').removeAttr('hidden');
        cd.calculateRegProgress();
      });

      // if team name submission fails, show system default error messages instead of going back to the bike number selector
      if ($('.ErrorMessage').length > 0) {
        $('.js__team-bikes-container').attr('hidden', true);
        $('form[name=FriendraiserFind]').removeAttr('hidden');
      }

      if (eventType2 === 'Road' || eventType2 === 'Executive Challenge' || eventType2 === 'StationaryV2') {
        $('#team_find_page > form').parsley(teamFindParsleyConfig);
      }

      // append session variable setting hidden input to track number of bikes selected so same value can be automatically selected in reg info step
      $('form[name="FriendraiserFind"]').prepend('<input type="hidden" class="js__numbikes" name="s_numBikes" value="">');

      if ($('body').data('numbikes')) {
        // If a session variable for number of bikes has already been set, prepopulate the js__numbikes input with that value so it isn't cleared out if the team create form errors out
        $('.js__numbikes').val($('body').data('numbikes'));
      }

      $('.dropdown-item').on('click', function (e) {
        e.preventDefault();
        var bikesSelected = $(this).data('numbikes');
        var bikesSelectedText = $(this).html();
        currentTeamGoal = bikesSelected * goalPerBike;
        currentTeamGoalFormatted = '$' + currentTeamGoal.formatMoney(0);
        minTeamGoalMsg = 'Your goal must be at least ' + currentTeamGoalFormatted;
        $(numBikeSelector).html(bikesSelectedText);
        $(dynTeamGoal).val(currentTeamGoalFormatted);
        $('.js__numbikes').val(bikesSelected);
        //removing min goal calc from eventType2
        if (eventType2 !== 'StationaryV2') {
          $('#fr_team_goal').val(currentTeamGoal);
        }
        $('.js__show-team-details').prop('disabled', false);
      });

      if ($('.field-error-text').length > 0 && $('.field-error-text:contains("There is already a team registered with that name")').length > 0) {
        // append "join team" link in error message with s_regType=joinTeam session var
        var joinTeamLink = $('.field-error-text a');
        var updatedJoinTeamLink = $(joinTeamLink).attr('href') + '&s_regType=joinTeam';
        $(joinTeamLink).attr('href', updatedJoinTeamLink);
      }

      if (eventType2 === 'StationaryV2') {
        $('#team_find_new_fundraising_goal_input_hint').text('');
      } else {
        $('#team_find_new_fundraising_goal_input_hint').text('You can increase your team\'s goal, but the amount shown above is your required fundraising minimum based off of the number of reserved bikes you selected.');
      }
      $('#previous_step span').text('Back');

    }

    // BEGIN PTYPE CUSTOMIZATIONS
    if ($('#F2fRegPartType').length > 0) {
      // add reg full class to ptype container
      var ptypeBlocks = $('.part-type-decoration-messages');

      if ($('.part-type-container').length === 1) {
        $('.part-type-decoration-messages > label').attr('tabindex', '0');
      }

      $(ptypeBlocks).each(function () {
        if ($(this).hasClass('part-type-full')) {
          $(this).parent().removeClass('selected').addClass('ptype-full').find('input[type=radio]').remove();
          var disabledLabel = $(this).find('label');
          $(disabledLabel).replaceWith('<div>' + $(disabledLabel).html() + '</div>');
          $(this).remove();
        }
        if (eventType2 === 'StationaryV2') {
          var ptypeName = $(this).find('.part-type-name').text();
          console.log(ptypeName);
          var newPtypeName = ptypeName.replace("Start a Team - ", "").replace("Join a Team - ", "").replace("Breakaway - ", "").replace("VIP", "").replace(", ", " from ");
          console.log(newPtypeName);
          // Hide and disable participation types that don't apply to this particular registration path
          $(this).parent().find('input[type=radio]').attr('aria-hidden', 'true').prop('checked', false).prop('disabled', true);

          if (ptypeName.indexOf('VIP') > -1) {
            $(this).closest('.part-type-container').addClass('vip-ptype-container');
          } else if (ptypeName.indexOf('Breakaway') > -1) {
            $(this).closest('.part-type-container').addClass('breakaway-ptype-container');
          } else if (ptypeName.indexOf('Start a Team') > -1) {
            $(this).closest('.part-type-container').addClass('start-team-ptype-container');

          } else if (ptypeName.indexOf('Join a Team') > -1) {
            $(this).closest('.part-type-container').addClass('join-team-ptype-container');
            var coachPtype = $('.captain-ptype').text();

            // NOTE - participation type names and times must always be split by " - "
            if (coachPtype) {
              var coachTime = coachPtype.split('-')[1];
              if (ptypeName.indexOf(coachTime) > -1) {
                // add special class to the join team ptype that matches the coach's ptype time
                $(this).closest('.part-type-container').addClass('join-team-ptype-time');
              }
            }
          }

          // Remove ptype prefixes from public-facing reg options
          $(this).find('.part-type-name').text(newPtypeName);
        }
      });



      // begin StationaryV2 event conditional
      if (eventType2 === 'StationaryV2') {
        if (regType === 'joinTeam') {
          $('#sel_type_container').text('What time do you want to ride?');
          if ($('.join-team-ptype-container').hasClass('join-team-ptype-time')) {
            // $('.join-team-ptype-container').addClass('d-inline-block col-md-6');
            // ensure the relevant ptypes are visiable and accessible from keyboard navigation
            $('.join-team-ptype-time').find('input[name=fr_part_radio]').attr('aria-hidden', 'false').prop('disabled', false).eq(0).prop('checked', true);
            // only display the ptype that matches the coach's ptype
            $('.join-team-ptype-time').show();
          } else {
            // ensure the relevant ptypes are visiable and accessible from keyboard navigation
            $('.join-team-ptype-container').find('input[name=fr_part_radio]').attr('aria-hidden', 'false').prop('disabled', false).eq(0).prop('checked', true);
            // show all join team ptypes as coach's ptype time was not found
            $('.join-team-ptype-container').addClass('d-inline-block col-md-6');
          }
        } else if (regType === 'startTeam') {
          if ($('.vip-ptype-container').length) {
            // ensure the relevant ptypes are visiable and accessible from keyboard navigation
            $('.vip-ptype-container').find('input[name=fr_part_radio]').attr('aria-hidden', 'false').prop('disabled', false).eq(0).prop('checked', true);
            // if promo code based ptype is available on page, only show that ptype option
            $('.vip-ptype-container').addClass('d-inline-block col-md-6');
          } else {
            // ensure the relevant ptypes are visiable and accessible from keyboard navigation
            $('.start-team-ptype-container').find('input[name=fr_part_radio]').attr('aria-hidden', 'false').prop('disabled', false).eq(0).prop('checked', true);
            // otherwise, show publicly available ptypes that match selected reg option
            $('.start-team-ptype-container').addClass('d-inline-block col-md-6');
          }
        } else if (regType === 'individual') {
          if ($('.vip-ptype-container').length) {
            // ensure the relevant ptypes are visiable and accessible from keyboard navigation
            $('.vip-ptype-container').find('input[name=fr_part_radio]').attr('aria-hidden', 'false').prop('disabled', false).eq(0).prop('checked', true);
            // if promo code based ptype is available on page, only show that ptype option
            $('.vip-ptype-container').addClass('d-inline-block col-md-6');
          } else {
            // ensure the relevant ptypes are visiable and accessible from keyboard navigation
            $('.breakaway-ptype-container').find('input[name=fr_part_radio]').attr('aria-hidden', 'false').prop('disabled', false).eq(0).prop('checked', true);
            // otherwise, show publicly available ptypes that match selected reg option
            $('.breakaway-ptype-container').addClass('d-inline-block col-md-6');
          }
        } else {
          // ensure the relevant ptypes are visiable and accessible from keyboard navigation
          $('.part-type-container').find('input[name=fr_part_radio]').attr('aria-hidden', 'false').prop('disabled', false).eq(0).prop('checked', true);
          // show all participation types in the case that a session variable has not been set for regType
          $('.part-type-container').addClass('d-inline-block col-md-6');
        }
      }

      var minFundraisingGoal = ($('input[name="fr_part_radio"]:checked').parent().find('.goal').val() ? $('input[name="fr_part_radio"]:checked').parent().find('.goal').val().replace('.00', '') : null);
      if (!minFundraisingGoal || minFundraisingGoal === "$0") {
        minFundraisingGoal = $('#fr_goal').val().replace('.00', '');
      }
      $('#fr_goal').val(minFundraisingGoal);
      // $('#part_type_fundraising_goal_container .form-content').append('<p class="small">All riders commit to fundraising <span class="min-fundraising-goal">' + minFundraisingGoal + '</span>. You can increase your fundraising goal, but the amount shown above is your required fundraising minimum.</p>');

      if (eventType2 === 'Stationary' || eventType2 === 'StationaryV2') {
        var numPtypesShown = $('.part-type-container:visible').length;
        if (numPtypesShown === 1 && (regType === 'startTeam' || regType === 'joinTeam')) {
          $('#part_type_selection_container .field-required').hide();
          if (regType === 'startTeam' && $('.vip-ptype-container').length) {
            $('#sel_type_container').text('Your team is riding with:');
          } else {
            $('#sel_type_container').text('Your team is riding from:');
          }

        } else {
          $('#sel_type_container').text('What time do you want to ride?');
        }
        $('.part-type-container').on('click focus', function (e) {
          $('.part-type-container').removeClass('selected');
          $(this).addClass('selected');
          $(this).find('input[type="radio"]').prop('checked', true);
        });

        // add accessibility events for keyboard navigation
        $('input[name="fr_part_radio"]').on('click focus', function (e) {
          $('.part-type-container').removeClass('selected');
          var selectedPtypeMin = $(this).parent().find('.goal').val().replace('.00', '');
          if (selectedPtypeMin === "$0") {
            selectedPtypeMin = minFundraisingGoal;
          }
          $('.min-fundraising-goal').text(selectedPtypeMin);
          $('#fr_goal').val(selectedPtypeMin);
          $(this).closest('.part-type-container').addClass('selected');
        });

      } else {
        $('#sel_type_container').text('How would you like to participate?');
        // Hide and disable participation types that don't apply to this particular registration path
        if (regType === 'virtual') {
          // $('.part-type-name:contains("Virtual")').closest('.part-type-container').addClass('d-inline-block col-md-6');
          $('.part-type-name').closest('.part-type-container').addClass('d-inline-block col-md-6');
        } else {
          $('.part-type-name').closest('.part-type-container').addClass('d-inline-block col-md-6');
          $('.part-type-name:contains("Virtual")').closest('.part-type-container').removeClass('d-inline-block');

        }
        $('.part-type-container.selected input').prop('checked', false).removeClass('selected');

        $('.part-type-container.selected').removeClass('selected');

        $('#next_step').addClass('disabled');

        $('#next_step').on('click', function () {
          if ($('.part-type-container input[type="radio"]').length && !$('.part-type-container input[type="radio"]').is(':checked')) {
            $('.js__ptype-errors').remove();
            $('#sel_type_container').after('<div class="js__ptype-errors"><div class="alert alert-danger" role="alert">Please select a participation type and agree to the Self-Pledge.</div></div>');
            $('html, body').animate({
              scrollTop: $("#part_type_selection_container").offset().top
            }, 1000);

            return false;
          }
        });

        $('.part-type-container').on('click', function (e) {
          $('.part-type-container').removeClass('selected');
          $(this).addClass('selected');
          $(this).find('input[type="radio"]').prop('checked', true);
          var ptypeMin = $(this).parent().find('.goal').val().replace('.00', '');
          if (ptypeMin === "$0") {
            ptypeMin = minFundraisingGoal;
          }
          $('.min-fundraising-goal').text(ptypeMin);
          $('#fr_goal').val(ptypeMin);
          $('#next_step').removeClass('disabled');
          $('#dspPledge').modal({
            backdrop: 'static',
            keyboard: false
          }).modal('show');
        });

        $('.part-type-container').on('keypress', function (e) {
          var key = e.which;
          if (key == 13) {
            $('.part-type-container').removeClass('selected');
            $(this).addClass('selected');
            var ptypeMin = $(this).parent().find('.goal').val().replace('.00', '');
            if (ptypeMin === "$0") {
              ptypeMin = minFundraisingGoal;
            }
            $('.min-fundraising-goal').text(ptypeMin);
            $('#fr_goal').val(ptypeMin);
            $(this).find('input[type="radio"]').prop('checked', true);
            $('#next_step').removeClass('disabled');
            $('#dspPledge').modal({
              backdrop: 'static',
              keyboard: false
            }).modal('show');
            return false;
          }
        });


        // remove on click event if has class .ptype-full
        $('.ptype-full').off();

      }



      $('#fund_goal_container').prepend('<span class="field-required"></span>&nbsp;');

      $('#fund_goal_container').after('How much will you fundraise for CycleNation?');



      $('.donation-level-amount-text').closest('.donation-level-row-container').addClass('don-level-btn');
      $('.donation-level-container .input-container').parent().addClass('other-amount-row-container');

      $('.other-amount-row-container .donation-level-row-label').text('Enter your own amount:');

      $('.donation-level-row-label-no-gift').text("No thanks. I don\'t want to make a donation towards my goal at the moment").closest('.donation-level-row-container').addClass('don-no-gift');
      $('.don-no-gift, #part_type_anonymous_input_container, #part_type_show_public_input_container').wrap('<div class="form-check"/>');

      // add donor recognition label
      console.log('donor recognition 01');
      $('<legend>Donor Recognition:</legend>').insertBefore('#tr_recognition_nameanonymous_row #tr_recognition_nameanonymousname');
      console.log('donor recognition 02');

      // hide anon and gift display options
      $('label[for="fr_anonymous_gift"], label[for="fr_show_public_gift"]').closest('.form-check').hide();

      // modify button behavior at bottom
      $('#next_step').wrap('<div class="order-1 order-sm-2 col-sm-4 offset-md-4 col-8 offset-2 mb-3"></div>');
      $('.donation-level-amount-text').each(function (i) {
        $(this).text($(this).text().replace('.00', ''));
        $(this).text($(this).text().replace(',', ''));
      });
      $('.donation-level-row-label').on('click', function (e) {
        $('.donation-level-row-label').removeClass('active');
        $('.other-amount-row-container input[type="text"]').val('');
        $(this).addClass('active');
      });
      // add label to other amount text input
      $('.other-amount-row-container input[type=text]').addClass('other-amount')

      var otherFieldLabel = $('.other-amount').attr('id');
      $('<label for="' + otherFieldLabel + '" class="sr-only">Enter other amount</label>').insertBefore($('.other-amount'));

      $('.other-amount')
        .prop('onclick', null).off('click')
        .prop('onkeyup', null).off('keyup')
        .prop('onchange', null).off('change')
        .prop('onfocus', null).off('focus');

      $('.other-amount').on('keyup', function (e) {
        if ($(this).val() > 0) {
          $('.donation-level-row-label').removeClass('active');
          $(this).parent().find('input[type="radio"]').prop('checked', true);
        } else {
          $(this).parent().find('input[type="radio"]').prop('checked', false);
        }
      });

      $('.other-amount-row-container input[type="radio"]').on('click, focus', function (e) {
        $('.donation-level-row-label').removeClass('active');
        $(this).closest('input[type=radio]').prop('checked', true);
      });

      $('.don-no-gift').on('click', function (e) {
        $('.donation-level-row-label').removeClass('active');
      });

      $('.donation-level-row-label-no-gift').on('click', function (e) {
        $('.donation-level-row-label').removeClass('active');
        $('.other-amount-row-container input[type="text"]').val('');
      });
      $('.don-level-btn').each(function () {
        var donRadio = $(this).find('input[type="radio"]');
        var donLabel = $(this).find('.donation-level-row-label');

        $(donLabel).append($(donRadio));
      });

      if (regType === 'virtual' || regType === 'individual') {
        $('#part_type_section_footer').append('<div class="order-2 order-sm-1 col-sm-4 col-8 offset-2 offset-sm-0"><a href="SPageServer/?pagename=cn_register&fr_id=' + evID + '&s_regType=" class="button btn-secondary btn-block">Back</a></div>');
      } else if (regType === 'startTeam') {
        $('#previous_step').replaceWith('<div class="order-2 order-sm-1 col-sm-4 col-8 offset-2 offset-sm-0"><a href="TRR/?pg=tfind&amp;fr_id=' + evID + '&fr_tm_opt=new&skip_login_page=true" class="button btn-secondary btn-block">Back</a></div>');
      } else if (regType === 'joinTeam') {
        $('#previous_step').replaceWith('<div class="order-2 order-sm-1 col-sm-4 col-8 offset-2 offset-sm-0"><a href="TRR/?pg=tfind&amp;fr_id=' + evID + '&amp;fr_tm_opt=existing&amp;skip_login_page=true" class="button btn-secondary btn-block">Back</a></div>');
      } else {
        $('#previous_step').replaceWith('<div class="order-2 order-sm-1 col-sm-4 col-8 offset-2 offset-sm-0"><a href="SPageServer/?pagename=cn_register&fr_id=' + evID + '&s_regType=" class="button btn-secondary btn-block">Back</a></div>');
      }

    }

    // BEGIN REG INFO CUSTOMIZATIONS
    if ($('#F2fRegContact').length > 0) {
      // begin 2019 test updates
      $('#emergency_contact_title_container span').text('Just in case, we need your ICE (in case of emergency)');
      $('#cons_city').closest('.cons-info-question-container').addClass('address-details col-md-6');
      $('#cons_state').closest('.cons-full-address-container').addClass('address-details col-md-2');
      $('#cons_zip_code').closest('.cons-full-address-container').addClass('address-details col-md-4');
      $('.address-details').wrapAll('<div class="row" />');
      $('.cons-full-name-container').wrapAll('<div class="row" />');

      $('.input-label:contains("Mobile")').closest('.survey-question-container').addClass('mobile-question-container two-col');
      $('.input-label:contains("I am a")').closest('.survey-question-container').addClass('survivor-question-container');
      $('.input-label:contains("jersey size")').closest('.survey-question-container').addClass('jersey-question-container');
      $('.input-label:contains("Route Distance")').closest('.survey-question-container').addClass('route-question-container');
      $('#cons_email').closest('.form-content').addClass('email-question-container two-col');
      $('#cons_email_format').before('<legend id="consEmailFormat" class="sr-only">Email Format</legend>');
      $('#cons_email_format').attr('aria-labelledby', 'consEmailFormat');

      $('#cons_info_dob')
        .after($('.jersey-question-container'))
        .after($('.route-question-container'))
        .after($('.survivor-question-container'))
        .after($('#gift_notice_optin'))
        .after($('.email-question-container'))
        .after($('.mobile-question-container'));

      $('.two-col').wrapAll('<div class="row" />');

      if (regType === 'startTeam') {
        $('#cons_info_component_contact_info_section .sub-section-header').after('<p>As a team lead, we\'ll need your address so we can show you some love and send you swag to help inspire your squad and help you hit those fundraising milestones!</p>');
        $('#cons_info_dob').show();
        $('#contact_info_section_one .form-content').addClass('required').prepend('<span class="field-required"></span>');
        $('.cons-address-street-full-container .form-content').eq(1).removeClass('required').find('.field-required').remove();
        $('#cons_info_component_contact_info_section').show();
      } else if (regType === 'individual') {
        $('#cons_info_dob').show();
        $('#contact_info_section_one .form-content').addClass('required').prepend('<span class="field-required"></span>');
        $('.cons-address-street-full-container .form-content').eq(1).removeClass('required').find('.field-required').remove();
        $('#cons_info_component_contact_info_section').show();
      } else if (regType === 'joinTeam') {
        var pFirstName = $('body').data('first-name') ? $('body').data('first-name') : null;
        var pLastName = $('body').data('last-name') ? $('body').data('last-name') : null;
        var pEmail = $('body').data('email') ? $('body').data('email') : null;
        if (pFirstName && pLastName && pEmail) {
          $('#cons_first_name').val(pFirstName);
          $('#cons_last_name').val(pLastName);
          $('#cons_email').val(pEmail);
        }
      }
      $('.input-label.cons_city_town').text('City:');
      $('.input-label.cons_state').text('State:');

      // $('.input-label:contains("Mobile")').closest('.survey-question-container').addClass('mobile-question-container');

      $('.cons_dob').text('Birthday:');
      // $('.mobile-question-container').after($('#cons_info_dob'));
      // $('.cons-dob-label label').attr('for', 'cons_info_dob');
      // $('.cons-zip-label label').attr('for', 'cons_zip_code');

      $('.cons-dob-label label').remove();
      $('.cons-email-label label').remove();
      $('.cons-zip-label label').remove();
      $('.cons-full-address-label label').remove();
      $('.cons-city-town-label label').remove();
      $('.cons-state-label label').remove();
      $('.cons-country-label label').remove();

      $('#password_component_container > div:nth-child(1)').addClass('col-md-6');
      $('#password_component_container > div:nth-child(2)').addClass('col-md-6').css('clear', 'left');
      $('#password_component_container > div:nth-child(3)').addClass('col-md-6');



      cd.setBirthMonth = function () {
        var birthDay = $('#cons_birth_date_DAY').val();
        var birthMonth = $('#cons_birth_date_MONTH').val();
        var birthYear = $('#cons_birth_date_YEAR').val();
        if (birthDay !== '0' && birthMonth !== '0') {
          $('#cons_birth_date_YEAR').val('1901');
        } else {
          $('#cons_birth_date_YEAR').val('0');
        }
      }
      cd.setBirthMonth();

      $('#cons_birth_date_DAY, #cons_birth_date_MONTH').on('change', function (e) {
        cd.setBirthMonth();
      });

      $('#cons_birth_date_DAY').wrap('<div class="col-md-6" />').before('<label class="sr-only" for="cons_birth_date_DAY">Birth Day</label>');
      $('#cons_birth_date_DAY').before('<label class="sr-only" for="cons_birth_date_DAY">Birth Day</label>');
      $('#cons_birth_date_MONTH').wrap('<div class="col-md-6" />').before('<label class="sr-only" for="cons_birth_date_MONTH">Birth Month</label>');
      $('#cons_birth_date_MONTH').before('<label class="sr-only" for="cons_birth_date_MONTH">Birth Month</label>');
      $('#cons_birth_date_YEAR').before('<label class="sr-only" for="cons_birth_date_YEAR">Birth Year</label>');


      $('#cons_info_dob .form-content').append('<p class="small">We love birthdays and want to make sure we put your special day in our calendar so we don\'t forget.</p>');


      $('.mobile-question-container .input-label').append('&nbsp;<span class="mobile-phone-tooltip" data-toggle="tooltip" data-placement="top" title="We require your cell/mobile phone number in case last minute or emergency situations happen with the event and we need to communicate important details to you. We respect your privacy and will not sell or divulge your cell phone number to third parties, without your consent."><i class="fas fa-question-circle"></i></span>');

      $('.mobile-phone-tooltip').tooltip();
      // $('.mobile-question-container .form-content').append('<p class="small"><i class="fas fa-question-circle"></i> We require your cell/mobile phone number in case last minute or emergency situations happen with the event and we need to communicate important details to you. We respect your privacy and will not sell or divulge your cell phone number to third parties, without your consent.</p>');

      if (eventType2 === 'Stationary') {
        // autoselect number of bikes based on tfind responses and/or ptype
        var bikeQuestion = $('.input-label:contains("How many bikes")');
        $(bikeQuestion).closest('.survey-question-container').attr('hidden', true);
        if (regType === 'individual') {
          $(bikeQuestion).closest('.input-container').find('select').val('1');
        } else if (regType === 'startTeam') {
          var numBikesSelected = $('body').data('numbikes');
          $(bikeQuestion).closest('.input-container').find('select').val(numBikesSelected);
        } else if (regType === 'joinTeam') {
          $(bikeQuestion).closest('.input-container').find('select').val('0');
        }
      }

      var termsHtml = $('.input-container label:contains("Terms and Conditions")').html();
      if (termsHtml != undefined) {
         termsHtml = termsHtml.replace(/Terms and Conditions/ig, '<a href="javascript:void(0)" onclick="window.open(\'https://www.heart.org/en/about-us/statements-and-policies/terms-of-service\',\'_blank\',\'location=yes,height=570,width=520,scrollbars=yes,status=yes\');">Terms and Conditions</a>');
         termsHtml = termsHtml.replace(/Privacy Policy/ig, '<a href="javascript:void(0)" onclick="window.open(\'https://www.heart.org/en/about-us/statements-and-policies/privacy-statement\',\'_blank\',\'location=yes,height=570,width=520,scrollbars=yes,status=yes\');">Privacy Policy</a>');
         $('.input-container label:contains("Terms and Conditions")').html(termsHtml);
      }

      var releaseHtml = $('.input-container label:contains("Release with Publicity Consent")').html();
      if (releaseHtml != undefined) {
         releaseHtml = releaseHtml.replace(/Release with Publicity Consent/ig, '<a href="#" class="js__terms-conditions">Release with Publicity Consent</a>');
         $('.input-container label:contains("Release with Publicity Consent")').html(releaseHtml);
      }

      $('.js__terms-conditions').on('click', function (e) {
        e.preventDefault();
        $('#termsModal').modal();
      });

      // disable next step button unless terms have been checked
      $('#next_step')
        .attr('disabled', true)
        .wrap('<div class="order-1 order-sm-2 col-sm-4 offset-md-4 col-8 offset-2 mb-3"/>');
      $('#previous_step').text('Back')
        .wrap('<div class="order-2 order-sm-1 col-sm-4 col-8 offset-2 offset-sm-0" />');

      var addressComplete = (regType === 'startTeam' ? false : true);

      var waiverCheckbox = $('.input-container label:contains("Release with Publicity")').prev('input[type=checkbox]');

      cd.regInfoVerification = function () {
        if ($(waiverCheckbox).is(':checked') === true && addressComplete === true) {
          $('#next_step').attr('disabled', false);
        } else {
          $('#next_step').attr('disabled', true);
        }
      }
      cd.addressVerification = function () {
        if (regType === 'startTeam') {
          if ($('input#cons_street1').val() == "" || $('input#cons_city').val() == "" || $('input#cons_zip_code').val() == "" || $('select#cons_state option:selected').val() == "" || $('select#cons_country option:selected').val() == "") {
            addressComplete = false;
            cd.regInfoVerification();
          } else {
            addressComplete = true;
            cd.regInfoVerification();
          }
        } else {
          cd.regInfoVerification();
        }
      }
      cd.addressVerification();


      $('#contact_info_section_one input, #contact_info_section_one select').on('keyup keypress blur change mouseout', function (e) {
        cd.addressVerification();

      });



      $(waiverCheckbox).on('click', function (e) {
        cd.regInfoVerification();
      });
      // if ($(waiverCheckbox).is(':checked') === true && addressComplete === true) {
      //   $('#next_step').attr('disabled', false);
      // }

    }

    if ($('#FriendraiserUserWaiver').length > 0) {
      // reg summary step
      $('.reg-summary-reg-info').prepend('<p>Click the <strong>"Complete Registration"</strong> button below to finish your registration.</p><p>Click on <strong>"Edit"</strong> below to revise your registration details</p>');
      if (regType === 'startTeam') {
        $('.contact-info-address').show();
      }
      $('.additional-gift-label').text('Personal Donation:');
      $('.total-label').text('Your registration total:');

      $('#reg_summary_body_container').before('<div class="row"><div class="reg-text my-3 col-md-10 offset-md-1 text-center"><p>To complete your registration, please review your information below and then click "Complete Registration."</p></div></div><div class="row"><div class="col-md-4 offset-md-4"><a href="#" class="button btn-primary btn-block js__submit-registration" id="submit-button">Complete Registration</a></div></div>');
      $('.action-button-container').addClass('col-md-4 offset-md-4')
      $('.js__submit-registration').on('click', function (e) {
        e.preventDefault();
        $('#next_button').click();
      });

    }
    // payment step of reg
    if ($('#fr_payment_form').length > 0) {
      $('label[for="responsive_payment_typecc_exp_date_MONTH"], #responsive_payment_typecc_exp_date_MONTH').wrapAll('<div class="col-6 col-md-4"></div>');
      $('label[for="responsive_payment_typecc_exp_date_YEAR"], #responsive_payment_typecc_exp_date_YEAR').wrapAll('<div class="col-6 col-md-4"></div>');
      $('.date-input-container').insertBefore($('#responsive_payment_typecc_exp_date_row'));

      $('#btn_next').text('Submit')
        .wrap('<div class="order-1 order-sm-2 col-sm-4 offset-md-4 col-8 offset-2 mb-3"/>');
      $('#btn_prev').text('Back')
        .wrap('<div class="order-2 order-sm-1 col-sm-4 col-8 offset-2 offset-sm-0" />');

    }


    if ($('body').is('.app_id_27') || $('body').is('.pg_cn_register')) {
      // remove side nav from tabindex for registration
      $('.navbar-toggler').attr('tabindex', -1);
    }
    if ($('body').is('.app_id_27')) {
      // BEGIN THERMO LOGIC
      cd.updateRegProgress = function (stepsComplete, stepsPossible) {
        var percentComplete = Math.round((stepsComplete / stepsPossible) * 100);
        $('.js__reg-progress')
          .attr('aria-valuenow', percentComplete)
          .css('width', percentComplete + '%')
          .text(percentComplete + '%');
      }

      cd.calculateRegProgress = function () {
        var requiresPayment;
        if ($('.progress-bar-step-text-container:contains("Make Payment")').length) {
          requiresPayment = true;
        } else {
          requiresPayment = false;
        }

        // Utype Step
        if ($('#user_type_page').length > 0) {
          // assuming max number of steps at beginning. As decisions are made in registration, will remove steps if necessary, i.e. if they do NOT create a team or have a payment step
          $('.existing-account-tooltip').tooltip();

          if (eventType2 === 'Stationary') {
            cd.updateRegProgress(1, 9);
          } else {
            cd.updateRegProgress(1, 8);
          }
        }
        // Tfind Step
        if ($('#team_find_page').length > 0) {
          if (eventType2 === 'Stationary') {
            // stationary logic
            if (regType === 'startTeam') {
              // regtype selection has not been made yet
              if ($('.js__numbikes').val() > 0) {
                // On "Team Details" step
                cd.updateRegProgress(4, 9);
              } else {
                // On "Hello Team Captain" step
                cd.updateRegProgress(3, 9);
              }
            } else if (regType === 'joinTeam') {
              cd.updateRegProgress(4, 9);
            } else if (regType === 'individual' || regType === 'virtual') {
              // if individual or virtual has been selected, they will no longer be on the tfind page
            } else {
              // On "I want to" step. regType selection has not been made yet
              cd.updateRegProgress(2, 9);
            }
          } else {
            // road logic
            if (regType === 'startTeam') {
              // On "Team Details" step
              cd.updateRegProgress(3, 8);
            } else if (regType === 'joinTeam') {
              cd.updateRegProgress(3, 8);
            } else if (regType === 'individual' || regType === 'virtual') {
              // if individual or virtual has been selected, they will no longer be on the tfind page
            } else {
              // On "I want to" step. regType selection has not been made yet
              cd.updateRegProgress(2, 8);
            }
          }

        }


        // Ptype Step
        if ($('#F2fRegPartType').length > 0) {

          if (eventType2 === 'Stationary') {
            // stationary logic
            if (regType === 'startTeam') {
              cd.updateRegProgress(5, 9);
            } else if (regType === 'joinTeam') {
              cd.updateRegProgress(4, 8);
            } else if (regType === 'individual' || regType === 'virtual') {
              cd.updateRegProgress(3, 7);
            }
          } else {
            // road logic
            // override default Bootstrap modal tab behavior

            $('#dspPledge').on('keyup', function (e) {
              var focusedElement = document.activeElement.id
              if (document.activeElement.id === 'dspPledge') {
                // Focus on outer lightbox container. Change focus to close button.
                $('#dspPledge .close').focus();
              }
            });
            if (regType === 'startTeam' || regType === 'joinTeam') {
              cd.updateRegProgress(4, 8);
            } else if (regType === 'individual' || regType === 'virtual') {
              cd.updateRegProgress(3, 7);
            }
          }
        }

        // Reg Info Step
        if ($('#F2fRegContact').length > 0) {
          if (eventType2 === 'Stationary') {
            // stationary logic
            if (regType === 'startTeam') {
              cd.updateRegProgress(6, (requiresPayment === true ? 9 : 8));
            } else if (regType === 'joinTeam') {
              cd.updateRegProgress(5, (requiresPayment === true ? 8 : 7));
            } else if (regType === 'individual' || regType === 'virtual') {
              cd.updateRegProgress(4, (requiresPayment === true ? 7 : 6));
            }
          } else {
            // road logic
            if (regType === 'startTeam' || regType === 'joinTeam') {
              cd.updateRegProgress(5, (requiresPayment === true ? 8 : 7));
            } else if (regType === 'individual' || regType === 'virtual') {
              cd.updateRegProgress(4, (requiresPayment === true ? 7 : 6));
            }
          }

        }

        // Review Step
        if ($('#FriendraiserUserWaiver').length > 0) {
          if (eventType2 === 'Stationary') {
            // stationary logic
            if (regType === 'startTeam') {
              cd.updateRegProgress(7, (requiresPayment === true ? 9 : 8));
            } else if (regType === 'joinTeam') {
              cd.updateRegProgress(6, (requiresPayment === true ? 8 : 7));
            } else if (regType === 'individual' || regType === 'virtual') {
              cd.updateRegProgress(5, (requiresPayment === true ? 7 : 6));
            }
          } else {
            // road logic
            if (regType === 'startTeam' || regType === 'joinTeam') {
              cd.updateRegProgress(6, (requiresPayment === true ? 8 : 7));
            } else if (regType === 'individual' || regType === 'virtual') {
              cd.updateRegProgress(5, (requiresPayment === true ? 7 : 6));
            }
          }
        }

        // Payment Step
        if ($('#fr_payment_form').length > 0) {
          if (eventType2 === 'Stationary') {
            // stationary logic
            if (regType === 'startTeam') {
              cd.updateRegProgress(8, 9);
            } else if (regType === 'joinTeam') {
              cd.updateRegProgress(7, 8);
            } else if (regType === 'individual' || regType === 'virtual') {
              cd.updateRegProgress(6, 7);
            }
          } else {
            // road logic
            if (regType === 'startTeam' || regType === 'joinTeam') {
              cd.updateRegProgress(7, 8);
            } else if (regType === 'individual' || regType === 'virtual') {
              cd.updateRegProgress(6, 7);
            }
          }
        }
      }

      cd.calculateRegProgress();
    }

    $('#part_type_selection_container .manageable-content, #fund_goal_container').prepend('<span class="aural-only">Field Is Required</span>');

    // Add 2017 Marathon Accessibility Updates

    // Issue #92 make edit link more clear -->
    $('.reg-summary-edit-link a').text('Edit Details');
    // End Issue #92 -->

    // Issue #a3 make labels more clear -->
    $('.input-label.cons_first_name').text('First Name');
    $('.input-label.cons_last_name').text('Last Name');
    // End Issue #a3 -->

    // Issue #a10 unhide legend for screenreaders -->
    $('#responsive_payment_typecc_type_row legend').addClass('aural-only');
    // End Issue #a10 -->

    // Add aria-required to donation form inputs -->
    $('#billing_first_namename,#billing_last_namename,#billing_addr_street1name,#billing_addr_street1name,#billing_addr_state,#billing_addr_cityname,#billing_addr_zipname,#donor_email_addressname,#responsive_payment_typecc_numbername,#responsive_payment_typecc_exp_date_MONTH,#responsive_payment_typecc_exp_date_YEAR,#responsive_payment_typecc_cvvname').attr('aria-required', 'true');
    // End add donation form required inputs -->

    // tr-05-utype-login-or-register
    $("#janrainModal img[src='https://docj27ko03fnu.cloudfront.net/rel/img/17c96fc4b9c8464d1c95cd785dd3120b.png']").attr('alt', 'Close button');
    //// This won't run because the JanRain scripts are at very bottom of body tag.
    $('#janrain-amazon, #janrain-facebook').removeAttr('role');

    $('.list-component-sort-select-text').attr('id', 'team_sort_label');
    $('.list-component-sort-select').attr('aria-labelledby', 'team_sort_label');
    // tr-06-join-or-form-a-team
    $('#team_find_new_team_company label.input-label').attr('for', 'fr_co_list');

    $('#team_find_new_team_recruiting_goal label.input-label').attr('for', 'fr_team_member_goal');

    $('#team_find_new_fundraising_goal input')
      .attr('data-parsley-required', '')
      .attr('data-parsley-required-message', 'Fundraising goal is required');


    var recruitGoalMax = $('body').data("reg-recruit-max");
    
    if (recruitGoalMax == '') {
      recruitGoalMax = '8';
    }

    console.log('Recruitment goal max', recruitGoalMax)

    setTimeout(function() { 
      // $('#team_find_new_team_recruiting_goal').children().prepend('<div class="regError"></div><span class="field-required" id="team_find_new_team_recruiting_goal_required"></span>');
      $('#team_find_new_team_recruiting_goal').children().prepend('<span class="field-required" id="team_find_new_team_recruiting_goal_required"></span>');
      $('#team_find_new_fundraising_goal').children().prepend('<span class="field-required" id="team_find_new_fundraising_goal_required"></span>');
      $('#team_find_new_team_recruiting_goal input').parent().append('<div class="recruit-description">You must have at least 2 but no more than '+recruitGoalMax+' people on your team</div>');
      $('#team_find_new_fundraising_goal .form-content').parent().append('<div class="recruit-description">Suggested $1,000 minimum goal</div>');
      $('#team_find_new_team_recruiting_goal label').text('Team Recruitment Goal');
      if($('#team_find_new_team_recruiting_goal input').val() !== '') {
        $('#team_find_new_team_recruiting_goal input')
        .attr('data-parsley-required', '')
        .attr('data-parsley-required-message', 'Recruitment goal is required')
        .attr('data-parsley-range', '[2, '+recruitGoalMax+']')
        .attr('data-parsley-range-message', 'Error: Please enter a number from 2 to '+recruitGoalMax);
        // .attr('data-parsley-errors-container', '.regError')
      } else {
        $('#team_find_new_team_recruiting_goal input')
        .val(6)
        .attr('data-parsley-required', '')
        .attr('data-parsley-required-message', 'Recruitment goal is required')
        .attr('data-parsley-range', '[2, '+recruitGoalMax+']')
        .attr('data-parsley-range-message', 'Error: Please enter a number from 2 to '+recruitGoalMax);
        // .attr('data-parsley-errors-container', '.regError')
      }
    }, 500);
    //Hardcoding value to test recruitment goal settings 
    // $('#team_find_new_team_recruiting_goal').find('input').val('3');

    // ptype
    // $('#part_type_selection_container').wrapInner('<fieldset role="radiogroup" class="ptype-selection"/>');

    $('#part_type_selection_container').wrapInner('<fieldset role="radiogroup" class="ptype-selection" id="ptype_fieldset" aria-labelledby="sel_type_container"/>');
    $('#ptype_fieldset').prepend('<legend class="sr-only">What time do you want to ride?</legend>');

    // $('input[name=fr_part_radio]').attr('aria-labelledby', 'sel_type_container');

    $('#fr_part_co_list').attr('aria-labelledby', 'individual_company_hdr_container');

    // $('.donation-levels').before('<legend id="reg_donation_array_label" class="sr-only">Make a donation</legend>');
    $('#part_type_additional_gift_section_header').prepend('<div class="bold-label" id="regDonationLabel">Donate Towards Your Goal Now</div>Want to donate above and beyond the registration fee to jump start your fundraising? Kick your fundraising into high gear with a personal donation:');

    $('#part_type_donation_level_input_container').wrapInner('<fieldset role="radiogroup" class="donation-form-fields" />');
    // $('#part_type_donation_level_input_container').wrapInner('<fieldset role="radiogroup" class="donation-form-fields" aria-labelledby="regDonationLabel"/>');
    $('.donation-form-fields').prepend('<legend class="sr-only">Donate Towards Your Goal Now</legend>');
    // $('.donation-form-fields input[type="radio"]').attr('aria-labelledby', 'regDonationLabel');
    // donation_level_form_


    // associate ptype label with input
    $('.part-type-container label').each(function (i) {
      var ptypeOptionId = $(this).attr('for');
      $(this).closest('.part-type-container').find('input[name="fr_part_radio"]').attr('id', ptypeOptionId);
    });
    // replace all h3 tags with h2
    $('#reg_payment_body_container h3').replaceWith(function () {
      return "<h2>" + $(this).html() + "</h2>";
    });
    $('label[for="responsive_payment_typecc_exp_date_MONTH"] .label-text').text('Month:');
    $('label[for="responsive_payment_typecc_exp_date_MONTH"]').insertBefore($('#responsive_payment_typecc_exp_date_MONTH'));

    $('label[for="responsive_payment_typecc_exp_date_YEAR"]').append('<span class="label-text">Year: </span>');
    $('label[for="responsive_payment_typecc_exp_date_YEAR"]').insertBefore($('#responsive_payment_typecc_exp_date_YEAR'));

    $('#responsive_payment_typecc_exp_date_row .field-required').remove();
    $('fieldset.cardExpGroup').prepend('<legend class="cc-legend">Credit Card Expires</legend>')
    $('.cc-legend').prepend('<span class="field-required"></span>&nbsp;');

    $('.internal-payment .payment-type-label').prepend('<span class="sr-only">Pay by Credit Card</span>');
    $('.external-payment .payment-type-label').prepend('<span class="sr-only">Pay with PayPal</span>');

    $('#responsive_payment_typecc_cvv_row .HelpLink').attr({
      "aria-hidden": "true",
      "tabindex": "-1"
    });
    // Reg
    $('label[for="cons_first_name"]').eq(0).remove();
    // $('#cons_birth_date_MONTH, #cons_birth_date_DAY, #cons_birth_date_YEAR').attr('aria-labelledby', 'enterAmtLabel');
    $('#cons_birth_date_YEAR').attr('aria-hidden', true);

    // paymentForm
    $('#responsive_payment_typepay_typeradio_payment_types').wrap('<fieldset />').prepend('<legend class="sr-only">Payment method:</legend>');



    $('#find_hdr_container').replaceWith(function () {
      return '<h2 class="' + $(this).attr('class') + '" id="' + $(this).attr('id') + '">' + $(this).html() + '</h2>';
    });
    $('.section-header-text').replaceWith(function () {
      return '<h1 class="h3 ' + $(this).attr('class') + '" id="' + $(this).attr('id') + '">' + $(this).html() + '</h1>';
    });

    $('#title_container').replaceWith(function () {
      return '<h1 class="h3 ' + $(this).attr('class') + '" id="' + $(this).attr('id') + '">' + $(this).html() + '</h1>';
    });

    // Update help link to not be redundant
    $('#responsive_payment_typecc_cvv_row .HelpLink').attr('title', 'Opens in new window');


    // END REGISTRATION

    if ($('body').is('.pg_entry')) {
      // $('.js__greeting-intro-text').html($('.js__chapter-intro-text'));


      $('.js__chapter-intro-images img').each(function (i) {
        $('.js__carousel-indicators').append('<li data-target="#carouselIndicators" data-slide-to="' + i + '"' + (i === 0 ? 'class="active"' : '') + '></li>');

        $('.js__carousel-inner').append('<div class="carousel-item ' + (i === 0 ? 'active' : '') + '"><img src="' + $(this).attr('src') + '" alt="' + $(this).attr('alt') + '"></div>');
      });
      $('.carousel').carousel({
        interval: 4000
      });

      if (viewportWidth < 640) {
        $('#rider_name').attr('placeholder', 'Search');
      }

      // BEGIN custom sponsor script

      if ($('.tr_sponsorship_logos').length) {
        $('.tr_sponsorship_logos:first .tr_sponsorship_logo').each(function (i, sponsor) {
          var sponsorAlt = $(this).find('img').attr('alt');
          var sponsorImg = $(this).find('img').attr('src');
          var sponsorUrl = $(this).find('a').attr('href');
          var sponsorLevel = sponsorAlt.split(' | ')[0];
          var sponsorName = sponsorAlt.split(' | ')[1];

          // TODO - add logic to show levels when a sponsor is added
          switch (sponsorLevel) {
            case "life":
              $('.js__life-sponsor-logos').append('<a href="TR?fr_id=' + evID + '&amp;pg=informational&amp;sid=2014"><img src="' + sponsorImg + '" alt="' + sponsorName + '"></a>');
              $('.js__life-sponsor-container').fadeIn();
              break;
            case "platform":
              $('.js__platform-sponsor-logos').append('<a href="TR?fr_id=' + evID + '&amp;pg=informational&amp;sid=2014"><img src="' + sponsorImg + '" alt="' + sponsorName + '"></a>');
              $('.js__platform-sponsor-container').fadeIn();
              break;
            case "signature":
              $('.js__signature-sponsor-logos').append('<a href="TR?fr_id=' + evID + '&amp;pg=informational&amp;sid=2014"><img src="' + sponsorImg + '" alt="' + sponsorName + '"></a>');
              $('.js__signature-sponsor-container').fadeIn();
              break;
            case "level1":
              $('.js__level1-sponsor-logos').append('<a href="TR?fr_id=' + evID + '&amp;pg=informational&amp;sid=2014"><img src="' + sponsorImg + '" alt="' + sponsorName + '"></a>');
              $('.js__level1-sponsor-container').fadeIn();
              break;
            case "level2":
              $('.js__level2-sponsor-logos').append('<a href="TR?fr_id=' + evID + '&amp;pg=informational&amp;sid=2014"><img src="' + sponsorImg + '" alt="' + sponsorName + '"></a>');
              $('.js__level2-sponsor-container').fadeIn();
              break;
            case "level3":
              $('.js__level3-sponsor-logos').append('<a href="TR?fr_id=' + evID + '&amp;pg=informational&amp;sid=2014">' + sponsorName + '</a><br>');
              $('.js__level3-sponsor-container').fadeIn();
              break;
            case "level4":
              $('.js__level4-sponsor-logos').append('<a href="TR?fr_id=' + evID + '&amp;pg=informational&amp;sid=2014">' + sponsorName + '</a><br>');
              $('.js__level4-sponsor-container').fadeIn();

              break;
          }

          // var sponsorToPush = { };
          // sponsorToPush["sponsorName"] = sponsorName;
          // sponsorToPush["sponsorLevel"] = sponsorLevel;
          // sponsorToPush["sponsorImg"] = sponsorImg;
          // sponsorToPush["sponsorLevel"] = sponsorLevel;
          // sponsorToPush["sponsorUrl"] = sponsorUrl;
          // sponsorsArray.push(sponsorToPush);

        });

      }
    }
    if ($('body').is('.pg_personal')) {
      console.log('image src', $('.sidebar-hero').attr('src'));
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
       cd.getDonationFormInfo = function (options) {
           luminateExtend.api({
               api: 'donation',
               requestType: 'POST',
               data: 'method=getDonationFormInfo&fr_id=' + evID + '&form_id=' + dfID,
               requiresAuth: true,
               callback: {
                   success: function (response) {
                     console.log('donation from api response', response)
                       var i = 0,
                           donationLevels = luminateExtend.utils.ensureArray(response.getDonationFormInfoResponse.donationLevels.donationLevel);
                           console.log('donation levels', donationLevels)

                       $.each(donationLevels, function (i) {
                           var userSpecified = this.userSpecified,
                               amountFormatted = this.amount.formatted.replace('.00', ''),
                               levelID = this.level_id;

                           i++;

                           console.log('user specified', userSpecified)

                           if (userSpecified == 'false') {
                               // build pre-defined giving levels
                               $('.donation-amounts').append('<label class="form-check-label donation-amount-btn btn mb-3" for="personalDonAmt' + i + '" data-level-id="' + levelID + '"> <input class="form-check-input" type="radio" name="personalDonAmt" id="personalDonAmt' + i + '" value="' + levelID + '"> ' + amountFormatted + '</label>');
                           } else {
                               // build user-specified level
                               $('.donation-amounts').append('<div class="custom-amount"> <input class="form-check-input other-amt-radio sr-only" type="radio" name="personalDonAmt" id="personalDonAmt' + i + '" value="' + levelID + '"> <label class="js--don-amt-other sr-only" for="personalDonAmt' + i + '" data-level-id="' + levelID + '">Enter your own amount</label> <label class="form-label d-inline-block" for="personalOtherAmt">Custom Amount:</label><br/> <input type="text" id="personalOtherAmt" class="form-control d-inline-block js--personal-amt-other" data-parsley-min="25" data-parsley-min-message="Donations of all amounts are greatly appreciated. Online donations have a $25 minimum."/> </div>');
                           }
                       });

                       $('.custom-amount').after('<span class="error-row"></span>');


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


                       // redirect is now managed in amazonpay.js
                       // $('.js--personal-don-form').on('submit', function(e){
                       //   e.preventDefault();
                       //   // redirect to personal donation form with preselected amount
                       //   window.location.href = finalDonUrl;
                       // });

                   },
                   error: function (response) {
                       console.log('donarion error response', response)
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
                           videoEmbedHtml = '<iframe class="embed-responsive-item" src="' + personalVideoEmbedUrl + '" title="American Heart Association Heart Walk Video" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>';
                       } else {
                           // TODO - show default video
                           if (isProd) {
                             if (evID === 5612 || evID === 4854 || evID === 5731) {
                               videoEmbedHtml = '<iframe class="embed-responsive-item" src="https://www.youtube.com/embed/TnjvKjkANPI?wmode=opaque&amp;rel=0&amp;showinfo=0" title="American Heart Association Heart Walk Video" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>';
                             }
                             else {
                               videoEmbedHtml = '<iframe class="embed-responsive-item" src="https://www.youtube.com/embed/b3K5LcaPzvE?wmode=opaque&amp;rel=0&amp;showinfo=0" title="American Heart Association Heart Walk Video" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>';
                             }
                           }
                           else {
                             if (evID === 4412 || evID === 4413 || evID === 4414) {
                               videoEmbedHtml = '<iframe class="embed-responsive-item" src="https://www.youtube.com/embed/TnjvKjkANPI?wmode=opaque&amp;rel=0&amp;showinfo=0" title="American Heart Association Heart Walk Video" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>';
                             }
                             else {
                               videoEmbedHtml = '<iframe class="embed-responsive-item" src="https://www.youtube.com/embed/b3K5LcaPzvE?wmode=opaque&amp;rel=0&amp;showinfo=0" title="American Heart Association Heart Walk Video" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>';
                             }
                           }                                
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
      //  TODO - commented out video code until CN delivers new video
      //  cd.getPersonalVideo(evID, personalPageConsId);
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

                        var participantRaised = (parseInt(participant.amountRaised) * 0.01).toFixed(2);
                        var participantRaisedFormmatted = participantRaised.toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,").replace('.00', '');
                        
                        if (participant.name.first != null) {
                            $('#team-roster tbody').append('<tr class="' + (i > 4 ? 'd-none' : '') + '"><td class="donor-name"><a href="' + participant.personalPageUrl + '">' +
                                participant.name.first + ' ' + participant.name.last +
                                '</a>' + (participant.aTeamCaptain === "true" ? ' <span class="coach">- Team Captain</span>' : '') + '</td><td class="raised" data-sort="' + participantRaisedFormmatted + '"><span><strong>$' + participantRaisedFormmatted + '</strong></span></td><td><a href="' + participant.donationUrl + '">' + (screenWidth <= 480 ? 'Donate' : 'Donate to ' + participant.name.first) + '</a></td></tr>');
                            if (participant.aTeamCaptain === 'true') {
                                $('.js--team-captain-link').attr('href', participant.personalPageUrl).text(participant.name.first + ' ' + participant.name.last);
                            }
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

  if($('.achievements .achievement-badge').length == 0) {
    $('.achievements').parent().hide();
  }
  var teamId = getURLParameter(currentUrl, 'team_id');
  luminateExtend.api({
    api: 'teamraiser',
    data: 'method=getTeamCaptains&response_format=json&fr_id=' + evID + '&team_id=' + teamId,
    callback: {
      success: function success(response) {
        var captainArray = luminateExtend.utils.ensureArray(response.getTeamCaptainsResponse.captain);
        var captainConsId = captainArray[0].consId;
        console.log('this is captainID', captainConsId)
        console.log('TRR/?fr_tjoin='+teamId+'&pg=tfind&fr_id='+evID+'&s_regType=joinTeam&s_captainConsId='+captainConsId)
        $('.team-page-join-link').attr("href", 'TRR/?fr_tjoin='+teamId+'&pg=tfind&fr_id='+evID+'&s_regType=joinTeam&s_captainConsId='+captainConsId);
      },
      error: function error(response) {}
    }
  });
}
    if ($('body').is('.pg_company')) {
 // Company Page

            // Populate company name from page title
            var pageTitle = jQuery('head title').text().trim();
            var start_pos = pageTitle.indexOf(':') + 1;
            var end_pos = pageTitle.indexOf('- Heart Walk', start_pos);
            var currentCompanyName = pageTitle.substring(start_pos, end_pos).trim();
            var currentCompanyId = getURLParameter(currentUrl, 'company_id');
            // var isParentCompany = ($('#company_hierarchy_list_component .lc_Row1').length ? true : false)
            var isParentCompany = ($('.js--company-hierarchy-list-container .lc_Row1').length ? true : false)

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
                                                        $('.tr-page-info h1').before('<small><a href="' + response.getCompaniesResponse.company.companyURL + '">' + response.getCompaniesResponse.company.companyName + '</a></small>');
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

            cd.getCompaniesGoal = function (companyId) {
              console.log('company name', companyId)
              luminateExtend.api({
                api: 'teamraiser',
                data: 'method=getCompaniesByInfo' +
                  '&company_id=' + companyId +
                  '&event_type=' + eventType +
                  '&include_cross_event=true' +
                  '&response_format=json',
                callback: {
                  success: function (response) {
                    console.log('company goal success:', response)

                    $('.js--company-name').text(response.getCompaniesResponse.company.companyName);

                    if($(".js--company-name:contains(&amp;)")) {
                      console.log('contains &')
                      var ampersand = response.getCompaniesResponse.company.companyName;
                      var newAmpersand = ampersand.replace(/&amp;/g, "&");
                      $('.js--company-name').text(newAmpersand);
                    }

                    var raised = numberWithCommas(response.getCompaniesResponse.company.amountRaised / 100);

                    if (raised) {
                        $('#progress-amount').html('$' + raised);
                    }

                    // Get company goal
                    var companyGoal = numberWithCommas(response.getCompaniesResponse.company.goal / 100);
                    $('#goal-amount').html('$' + companyGoal);

                    // populate custom personal page content
                    $('.js--company-text').html($('#fr_rich_text_container').html());

                    var progress = $('#progress-amount').text();
                    var goal = $('#goal-amount').text();
                    cd.runThermometer(progress, goal);
                    cd.reorderPageForMobile();

                    function numberWithCommas(x) {
                      return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
                    }
                  },
                  error: function (response) {
                    console.log('company goal fail', response)
                  }
                }
              });
            }
            var getCompanyId = getURLParameter(currentUrl, 'company_id');
            console.log(getCompanyId)
            cd.getCompaniesGoal(getCompanyId);

            // Reset selected sort option
            $('.nav-tabs .nav-link').click(function () {
                $('.selected-sort-option').html('Amount Raised');
            });

            // Build company team roster
            // build team roster
            var numTeamRows = 0;

            cd.getCompanyTeams = function (companyId, companyName, numCompanies, companyIndex) {
              console.log("wwwwww");
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
                                    //$('#team-roster tbody').append('<tr class="' + (numTeamRows > 4 ? 'd-none' : '') + '"> <td class="team-name"> <a href="' + team.teamPageURL + '" data-sort="' + team.name + '">' + team.name + '</a> </td><td class="donor-name"> <a href="TR/?px=' + team.captainConsId + '&pg=personal&fr_id=' + team.EventId + '" data-sort="' + team.captainFirstName + ' ' + team.captainLastName + '">' + team.captainFirstName + ' ' + team.captainLastName + '</a> </td><td class="company-name"> <a href="' + luminateExtend.global.path.secure + 'TR/?pg=company&company_id=' + team.companyId + '&fr_id=' + team.EventId + '" data-sort="' + team.companyName + '">' + team.companyName + '</a> </td><td class="raised" data-sort="' + teamRaisedFormmatted + '"> <span><strong>$' + teamRaisedFormmatted + '</strong></span> </td><td> <a href="' + team.joinTeamURL + '">' + (screenWidth <= 480 ? 'Join' : 'Join Team') + '</a> </td></tr>');
                                    $('#team-roster tbody').append('<tr> <td class="team-name"> <a href="' + team.teamPageURL + '" data-sort="' + team.name + '">' + team.name + '</a> </td><td class="donor-name"> <a href="TR/?px=' + team.captainConsId + '&pg=personal&fr_id=' + team.EventId + '" data-sort="' + team.captainFirstName + ' ' + team.captainLastName + '">' + team.captainFirstName + ' ' + team.captainLastName + '</a> </td><td class="company-name"> <a href="' + luminateExtend.global.path.secure + 'TR/?pg=company&company_id=' + team.companyId + '&fr_id=' + team.EventId + '" data-sort="' + team.companyName + '">' + team.companyName + '</a> </td><td class="raised" data-sort="' + teamRaisedFormmatted + '"> <span><strong>$' + teamRaisedFormmatted + '</strong></span> </td><td> <a href="' + team.joinTeamURL + '">' + (screenWidth <= 480 ? 'Join' : 'Join Team') + '</a> </td></tr>');
                                    numTeamRows++;
                                    console.log('company name', team.companyName);
                                    var companyNameInsert = $('.js--company-name').text();
                                    $('.company-name a').text(companyNameInsert);
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
                   console.log('particiant: ', participant)
                    var participantRaised = (parseInt(participant.amountRaised) * 0.01).toFixed(2);
                    var participantRaisedFormmatted = participantRaised.toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,").replace('.00', '');

                    // $('#participant-roster tbody').append('<tr class="' + (numWalkerRows > 4 ? 'd-none' : '') + '"><td class="participant-name"><a href="' + participant.personalPageUrl + '">' +
                    $('#participant-roster tbody').append('<tr><td class="participant-name"><a href="' + participant.personalPageUrl + '">' +
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
                    var totalParticipantsText = totalParticipants > 1 ? ' Participants' : ' Participant';
                    $('.js--num-company-participants').text(totalParticipants + totalParticipantsText);
                    if (numWalkerRows > 5) {
                        $('.js--more-participant-results').removeAttr('hidden');
                    }
                }, 250);
                //removing team donat button call
                //add call to hook donate button with payment type selections
                // $('a:contains(Donat)').on('click', function (e) {
                //     e.preventDefault();
                //     if (!$(this).hasClass('js--team-member-donate')) {
                //         if ($(this).next('.paymentSelType').length > 0) {
                //             $(this).next('.paymentSelType').remove();
                //         } else {
                //             var dlink = $(this).attr("href");
                //             var fr_id = $.getCustomQuerystring(dlink, "FR_ID");
                //             var px = $.getCustomQuerystring(dlink, "PROXY_ID");
                //             var pt = $.getCustomQuerystring(dlink, "PROXY_TYPE");

                //             var html = "<div class='paymentSelType text-center' style='padding-top:10px;'>" +
                //                 "<h2 class='h6'>How would you like to donate?</h2>" +
                //                 "<div class='payment-options-container'><a href='" + dlink + "'><img src='https://www2.heart.org/images/content/pagebuilder/credit-card-logos2.png' alt='Donate with Visa, MasterCard, American Express or Discover cards'/></a>" +
                //                 "<a href='" + default_path + "/site/SPageNavigator/cyclenation_donate_amazon.html?FR_ID=" + fr_id + "&mfc_pref=T&PROXY_ID=" + px + "&PROXY_TYPE=" + pt + "' class='amazon'><img src='https://www2.heart.org/images/content/pagebuilder/amazon-payments.png' alt='Donate with Amazon Pay'/></a>" +
                //                 "<a href='" + default_path + "/site/SPageNavigator/cyclenation_donate_googlepay.html?FR_ID=" + fr_id + "&mfc_pref=T&PROXY_ID=" + px + "&PROXY_TYPE=" + pt + "' class='googlepay'><img src='https://www2.heart.org/donation-forms/donatenow/images/googlepay-button.png' alt='Donate with Google Pay'/></a>" +
                //                 "<a href='" + default_path + "/site/SPageNavigator/cyclenation_donate_applepay.html?FR_ID=" + fr_id + "&mfc_pref=T&PROXY_ID=" + px + "&PROXY_TYPE=" + pt + "' class='applepay hidden-md hidden-lg'><img src='https://www2.heart.org/donation-forms-braintree/donatenow/images/DonateBlack_32pt_@2x.png' alt='ApplePay'/></a>" +
                //                 "<a href='" + default_path + "/site/SPageNavigator/cyclenation_donate_venmo.html?FR_ID=" + fr_id + "&mfc_pref=T&PROXY_ID=" + px + "&PROXY_TYPE=" + pt + "' class='venmo hidden-md hidden-lg'><img src='https://www2.heart.org/donation-forms/donatenow/images/venmo-button.png' alt='Venmo'/></a>" +
                //                 "<a href='" + dlink + "&paypal=true'><img src='https://www2.heart.org/images/content/pagebuilder/PP_logo_h_100x26.png'/ alt='Donate with PayPal'></a></div>";
                //             $(this).after(html);
                //         }
                //     }
                // });

            }
            cd.getCompanyName = function (companyId) {
              console.log('company name our participants', companyId)
              luminateExtend.api({
                api: 'teamraiser',
                data: 'method=getCompaniesByInfo' +
                  '&company_id=' + companyId +
                  '&event_type=' + eventType +
                  '&include_cross_event=true' +
                  '&response_format=json',
                callback: {
                  success: function (response) {
                    console.log('company participant name success:', response)
                    var companyNameStr = response.getCompaniesResponse.company.companyName;
                    var companyNameStrReplace = companyNameStr.replace("&amp;", "&");
                    $('#participant-roster .company-name a').text(companyNameStrReplace);
                  },
                  error: function (response) {
                    console.log('company name fail', response)
                  }
                }
              });
            }
            // var getCompanyId = getURLParameter(currentUrl, 'company_id');
            // console.log(getCompanyId)
            setTimeout(function () {
              cd.getCompanyName(getCompanyId);
            }, 1000);
    }
    if ($('body').is('.app_donation')) {
      /* 2019 DF UPDATES */

      // donation levels
      $('.donation-level-container').addClass('level');
      $('.donation-level-container:last-child').addClass('otherAmount').removeClass('level');
      $('.donation-level-container.level .donation-level-amount-container').prop('tabindex', '0');

      $('.donation-level-user-entered input[type="text"]').prop('placeholder', 'Other');
      $('.otherAmount .donation-level-label-container').remove();
      $('.donation-level-user-entered > label').prepend('<span class="text-muted"><em>($25 minimum)</em></span>');
      $('.otherAmount label .aural-only').text('Other amount edit');

      $('.otherAmount .form-input > label').prepend('<span class="text-muted">Enter an amount</span>');

      $('.donation-level-user-entered input[type="text"]').removeAttr('onfocus');

      var askMessageHtml = '<div class="ask-message">Donors who give $5,000 or more each year join our <a target="_blank" href="https://www.heart.org/en/get-involved/ways-to-give/cor-vitae-society">Cor Vitae Giving Society</a>.</div>';
      $(askMessageHtml).insertAfter('.don-standard-levels');

      $('.donation-level-amount-container').click(function() {
        $('.donation-level-amount-container.active, .donation-level-user-entered input').removeClass('active');
        $(this).addClass('active');
      });

      $('.donation-level-user-entered').click(function() {
        $('.donation-level-amount-container.active, .donation-level-user-entered input').removeClass('active');
        $(this).find('input').addClass('active');
        $('.otherAmount .donation-level-label-input-container input[type="radio"]').click();
      });

      $('.donation-level-amount-container').keydown(function(e) {
        var code = e.which
        if ((code === 13) || (code === 32)) {
          e.preventDefault();
          $(this).click();
        }
      });
      $('.donation-level-user-entered input').keyup(function(e) {
        var code = e.which
        var click = code === 9 || code === 39 || code === 40 || code === 37 || code === 38 ? false : true;
        if (click) {
          $('.donation-level-user-entered').click();
        }
      });

      $('.donation-level-amount-container').focus(function(e) {
        $(this).keyup(function(e){
          var code = e.which
          if ((code === 39) || (code === 40)) {
            var nextElem = $(this).parent().parent().parent().parent()[0].nextElementSibling;
            if($(nextElem).hasClass('otherAmount')) {
              $('.donation-level-user-entered input[type="text"]').focus();
            } else {
              $(nextElem).find('.donation-level-amount-container').focus();
            }
          }
          if ((code === 37) || (code === 38)) {
            var prevElem = $(this).parent().parent().parent().parent()[0].previousElementSibling;
            $(prevElem).find('.donation-level-amount-container').focus();
          }
        });
      });

      // add donor recognition label
      $('<legend>Donor Recognition:</legend>').insertBefore('#tr_recognition_nameanonymous_row #tr_recognition_nameanonymousname');

      // update anonymous checkbox text
      $('label[for=tr_recognition_nameanonymousname]').text('Do not display my name on any donor lists or pages on this site.');

      // Add text above matching company label
      // removed code

      // wrap billing fields into container
      $('#billing_first_name_row, #billing_last_name_row, #donor_email_address_row, .custom-field-container:contains("Cell or Phone Number"), #billing_addr_street1_row, #billing_addr_street2_row, #billing_addr_city_row, #billing_addr_state_row, #billing_addr_zip_row, #billing_addr_country_row').wrapAll('<div class="billing-fields-container"></div>');

      // change paypal logo
      $('#responsive_payment_typepay_typeradio_payment_types .external-payment img').attr('src', 'http://heartdev.convio.net/images/content/pagebuilder/aha_cn_donation_form_paypal_logo.png');

      // change cc logos
      $('#responsive_payment_typecc_type_Visa').attr('src', 'http://heartdev.convio.net/images/content/pagebuilder/aha_cn_donation_form_credit_cards_visa.png');
      $('#responsive_payment_typecc_type_Discover').attr('src', 'http://heartdev.convio.net/images/content/pagebuilder/aha_cn_donation_form_credit_cards_discover.png');
      $('#responsive_payment_typecc_type_American_Express').attr('src', 'http://heartdev.convio.net/images/content/pagebuilder/aha_cn_donation_form_credit_cards_amex.png');
      $('#responsive_payment_typecc_type_MasterCard').attr('src', 'http://heartdev.convio.net/images/content/pagebuilder/aha_cn_donation_form_credit_cards_mastercard.png');

      // wrap cc fields into container
      $('#responsive_payment_typecc_number_row, #responsive_payment_typecc_exp_date_row').wrapAll('<div class="cc-fields-container"></div>');

      // wrap cc expiration dates into separate containers
      $('label[for=responsive_payment_typecc_exp_date_MONTH], select#responsive_payment_typecc_exp_date_MONTH').wrapAll('<div class="cc-expiration-date-month-container expiration-date-fields"></div>');
      $('label[for=responsive_payment_typecc_exp_date_YEAR], select#responsive_payment_typecc_exp_date_YEAR').wrapAll('<div class="cc-expiration-date-year-container expiration-date-fields"></div>');

      // apply button styles classes
      $('#pstep_finish').addClass('btn-rounded btn-primary')
      /* END 2019 DF UPDATES */

      // replace duplicate ID
      $('#level_flexible_row.form-row.form-donation-level').attr('id', 'level_flexible_row2');

      $('#level_flexible_row2').wrapInner('<fieldset></fieldset>');
      $('#level_flexible_row2 fieldset').prepend('<legend class="aural-only">Select Gift Amount</legend>');

      $('#responsive_payment_typepay_typeradio_payment_types').wrapInner('<fieldset></fieldset>');
      $('#responsive_payment_typepay_typeradio_payment_types fieldset').prepend('<legend class="aural-only">Payment options</legend>');

      $('h5.transaction-summary-header').replaceWith(function () {
        return '<h1 class="transaction-summary-header summary-section-header dividerHeading" class="section-header-text">' + $(this).html() + '</h1>';
      });

      $('#responsive_payment_typecc_numbername, #responsive_payment_typecc_cvvname, #billing_first_namename, #billing_last_namename, #billing_addr_street1name, #billing_addr_cityname, #billing_addr_zipname, #donor_email_addressname, #responsive_payment_typecc_exp_date_MONTH, #responsive_payment_typecc_exp_date_YEAR, #billing_addr_state, #billing_addr_country').attr('aria-required', 'true');

      if ($('.errorMessageContainer .ErrorMessage.page-error .field-error-text').length > 0) {
        $('.errorMessageContainer .ErrorMessage.page-error .field-error-text').attr('role', 'alert');
      }
      $('#responsive_payment_typecc_numbername').attr('placeholder', 'XXXXXXXXXXXXXXXX');
      $('#level_flexible_row').before('<div class="required-indicator-legend d-block w-100"><span class="field-required"></span><span class="required-indicator-legend-text">&nbsp;Indicates Required</span></div>');

      $('label[for="responsive_payment_typepay_typeradiocredit"] a').attr('aria-label', 'PAYMENT BY CREDIT CARD');
      $('label[for="responsive_payment_typepay_typeradiopaypal"] a').attr('aria-label', 'Pay with PayPal');

      // Selecting empty value from the Gift Duration drop-down when the One-time Gift box is checked
      $('#level_flexiblegift_type1').click(function () {
        $('#level_flexibleduration').val("");
      });

      // Limiting number of characters in credit card field
      $('#responsive_payment_typecc_numbername').attr('maxlength', '16');
      $('#responsive_payment_typecc_cvvname').attr('minlength', '3').attr('maxlength', '4');


      // Change order of help link for tabbing
      $('.HelpLink').insertAfter('#responsive_payment_typecc_cvvname');

      $('#billing_addr_state option[value="None"]').remove();

      /*Thank You Page access edits */
      if ($('.transaction-summary-info').length > 0) {
        $('.transaction-summary-entry .entry-label').attr('tabindex', '0');
        $('.transaction-summary-entry .entry-value').each(function () {
          if ($(this).text().length > 0) {
            $(this).attr('tabindex', '0');
          } else {
            $(this).attr('tabindex', '1');
          }
        });
        $('.entry-label:contains("Total Gift Amount:")').attr('aria-label', 'Total Gift Amount');
      }


      $('#cell_or_phone_number_input').attr('placeholder', 'ex. 555-555-5555');

      $('.donation-levels').before('<span id="donation-errors"></span>');

      $('input[name="level_flexibleexpanded"]')
        .attr('data-parsley-required', '')
        .attr('data-parsley-required-message', 'Donation Amount is required')
        .attr('data-parsley-errors-container', '#donation-errors');

      $('#billing_first_namename')
        .attr('data-parsley-required', '')
        .attr('data-parsley-required-message', 'First Name is required');

      $('#billing_last_namename')
        .attr('data-parsley-required', '')
        .attr('data-parsley-required-message', 'Last Name is required');

      $('#donor_email_addressname')
        .attr('data-parsley-required', '')
        .attr('data-parsley-required-message', 'Email Address is required')
        .attr('data-parsley-type', 'email')
        .attr('data-parsley-type-message', 'Please enter a valid email address');

      $('#billing_addr_state')
        .attr('data-parsley-required', '')
        .attr('data-parsley-required-message', 'State is required');

      $('#billing_addr_cityname')
        .attr('data-parsley-required', '')
        .attr('data-parsley-required-message', 'City is required');

      $('#billing_addr_street1name')
        .attr('data-parsley-required', '')
        .attr('data-parsley-required-message', 'Billing Street is required');

      $('#billing_addr_zipname')
        .attr('data-parsley-required', '')
        .attr('data-parsley-required-message', 'Zip Code is required')
        .attr('data-parsley-maxlength', '10')
        .attr('data-parsley-maxlength-message', 'Zip Code cannot be more than 10 characters');

      $('#responsive_payment_typecc_numbername')
        .attr('data-parsley-required', '')
        .attr('data-parsley-required-message', 'Credit Card Number is required')
        .attr('data-parsley-type', 'number')
        .attr('data-parsley-type-message', 'Credit Card must be a number')
        .attr('data-parsley-maxlength', '16')
        .attr('data-parsley-maxlength-message', 'Credit Card cannot be more than 16 characters');

      $('#responsive_payment_typecc_cvvname')
        .attr('data-parsley-required', '')
        .attr('data-parsley-required-message', 'CVV is required')
        .attr('data-parsley-type', 'number')
        .attr('data-parsley-type-message', 'CVV must be a number')
        .attr('data-parsley-minlength', '3')
        .attr('data-parsley-maxlength-message', 'CVV must be at least 3 characters')
        .attr('data-parsley-maxlength', '4')
        .attr('data-parsley-maxlength-message', 'CVV cannot be more than 4 characters');

      var parsleyDonDefaults = {
        uiEnabled: true,
        priorityEnabled: true,
        errorsWrapper: '<div class="help-block with-errors"></div>',
        errorTemplate: '<span class="text-danger"></span>'
      }

      $('#ProcessForm').parsley(parsleyDonDefaults);

      $('.internal-payment').on('click', function (e) {
        $('#responsive_payment_typecc_numbername').attr('data-parsley-required', '');
        $('#responsive_payment_typecc_cvvname').attr('data-parsley-required', '');
      });
      $('.external-payment').on('click', function (e) {
        $('#responsive_payment_typecc_numbername').removeAttr('data-parsley-required');
        $('#responsive_payment_typecc_cvvname').removeAttr('data-parsley-required');
      });

      $('.donation-level-container input').each(function() {
        if($(this).prop("checked") == true){
          $(this).parent().parent().find('.donation-level-amount-container').addClass('active');
        }
      });

      $('#pstep_finish').on('click', function (e) {
        var r = /((?:\d{4}[ -]?){3}\d{3,4})/gm;
        $('[type=text]:not(#responsive_payment_typecc_numbername)').each(function () {
          jQuery(this).val(jQuery(this).val().replace(r, ""));
        });
        var rawPhoneNumber = $('#cell_or_phone_number_input').val();
        var cleanPhoneNumber = rawPhoneNumber.replace(/[()-]/g, "");
        cleanPhoneNumber = cleanPhoneNumber.replace(/\s/g, "");
        $('#cell_or_phone_number_input').val(cleanPhoneNumber);
      });

    }
  });
}(jQuery));
