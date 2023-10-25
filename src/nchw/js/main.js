'use strict';
(function ($) {
  $(document).ready(function ($) {
    // New NCHW JS goes here...
    // Example of retrieving data attribute (fr_id) from the body tag
    var evID = $('body').data('fr-id') ? $('body').data('fr-id') : null;

    //mobile nav
    jQuery('#mobileNav .sub-nav-toggle-link').click(function () {
      //slide up all the link lists
      jQuery('.sub-nav').slideUp();
      jQuery(this).removeClass('sub-nav-open').parent().removeClass('sub-active');
      //slide down the link list below the h3 clicked - only if its closed
      if (!jQuery(this).next().is(':visible')) {
        jQuery(this).next().slideDown();
        jQuery(this).removeClass('sub-nav-open').parent().removeClass('sub-active');
        jQuery(this).addClass('sub-nav-open').parent().addClass('sub-active');
      }
    });

    //sponsor slider
    jQuery('.sponsor_slider .local_sponsors').unslider({
      selectors: {
        container: 'div.tr_sponsorship_logos',
        slides: 'div.tr_sponsorship_logo'
      },
      autoplay: true
    });

    if ($('body').is('.pg_entry')) {
      // Greeting page-specific JS goes here
      $('#insert_ele_welcome').appendTo('#welcome .row');
      $('#insert_ele_contact').appendTo('#contact .row');

      if(!$('#insert_ele_subtitle:empty').length) {
        $('#insert_ele_subtitle').insertAfter('.greeting_hero_inner h1');
      }

      $('.social_icons a').each(function () {
        if ($(this).attr('href').length > 0) {
          $(this).parent().addClass('show_icon');
        }
      });
      $('#top_lists').hide();

      // getTopParticipantsData
      var participantPromise = new Promise(function(resolve, reject) {
        luminateExtend.api({
          api: 'teamraiser',
          data: 'method=getTopParticipantsData&fr_id=' + evID + '&response_format=json',
          callback: {
            success: function (response) {
              if (!$.isEmptyObject(response.getTopParticipantsDataResponse)) {
                var participantData = luminateExtend.utils.ensureArray(response.getTopParticipantsDataResponse.teamraiserData);
                if (participantData.length > 0) {
                  var sortedParticipantsData = participantData.slice(0, 5);
                  for (var i = 0, len = sortedParticipantsData.length; i < len; i++) {
                    sortedParticipantsData[i].total = Number(sortedParticipantsData[i].total.replace('$', '').replace(',', ''));
                    if (sortedParticipantsData[i].total > 0) {
                      var participantDataOutput = '<tr><td><a href="' + luminateExtend.global.path.nonsecure + 'TR/?fr_id=' + evID + '&pg=personal&px=' + sortedParticipantsData[i].id + '">' + sortedParticipantsData[i].name + '</a></td><td><span class="pull-right">$' + sortedParticipantsData[i].total.formatMoney(0) + '</span></td></tr>';
                      $('.insert_top-participants-list').append(participantDataOutput);

                    }
                  }
                }
              }
              resolve();
            },
            error: function (response) {
              console.log('getTopParticipants error: ' + response.errorResponse.message);
              reject(Error());
            }
          }
        });
      });


      // getTopTeamsData
      var teamPromise = new Promise(function(resolve, reject) {
        luminateExtend.api({
          api: 'teamraiser',
          data: 'method=getTopTeamsData&fr_id=' + evID + '&response_format=json',
          callback: {
            success: function (response) {
              if (!$.isEmptyObject(response.getTopTeamsDataResponse)) {
                var teamData = luminateExtend.utils.ensureArray(response.getTopTeamsDataResponse.teamraiserData);
                if (teamData.length > 0) {
                  var sortedTeamsData = teamData.slice(0, 5);
                  for (var i = 0, len = sortedTeamsData.length; i < len; i++) {
                    sortedTeamsData[i].total = Number(sortedTeamsData[i].total.replace('$', '').replace(',', ''));
                    if (sortedTeamsData[i].total > 0) {
                      var teamsData = '<tr><td><a href="' + luminateExtend.global.path.nonsecure + 'TR/?pg=team&team_id=' + sortedTeamsData[i].id + '&fr_id=' + evID + '">' + sortedTeamsData[i].name + '</a></td><td><span class="pull-right">$' + sortedTeamsData[i].total.formatMoney(0) + '</span></td></tr>';
                      $('.insert_top-teams-list').append(teamsData);
                    }
                  }
                }
              }
              resolve();
            },
            error: function (response) {
              console.log('getTopTeams error: ' + response.errorResponse.message);
              reject(Error());
            }
          }
        });
      });

      // getTopCompaniesByInfo
      var companyPromise = new Promise(function(resolve, reject) {
        luminateExtend.api({
          api: 'teamraiser',
          data: 'method=getCompaniesByInfo&fr_id=' + evID + '&list_sort_column=total&list_ascending=false&response_format=json',
          callback: {
            success: function (response) {
              if (!$.isEmptyObject(response.getCompaniesResponse)) {
                var companyData = luminateExtend.utils.ensureArray(response.getCompaniesResponse.company);
                if (companyData.length > 0) {
                  var sortedCompaniesData = companyData.slice(0, 5);
                  // build company roster here
                  for (var i = 0, len = sortedCompaniesData.length; i < len; i++) {
                    if (sortedCompaniesData[i].amountRaised > 0) {
                      var companyData = '<tr><td><a href="' + sortedCompaniesData[i].companyURL + '">' + sortedCompaniesData[i].companyName + '</a></td><td><span class="pull-right">$' + (sortedCompaniesData[i].amountRaised / 100).formatMoney(0) + '</span></td></tr>';
                      $('.insert_top-companies-list').append(companyData);
                    }
                  }
                }
              }
              resolve();
            },
            error: function (response) {
              console.log('getTopCompanies error: ' + response.errorResponse.message);
              reject(Error());
            }
          }
        });
      });
      var partP;
      var teamP;
      var compP;
      participantPromise.then(function() {
        if( !$.trim( $('.insert_top-participants-list').html() ).length ) {
          partP = false;
          $('.top-participants-list').hide();
        }
        else {
          partP = true;
          $('#top_lists').show();
          $('.top-participants-list').show();
        }
      }, function(err) {
        console.log(err);
      });

      teamPromise.then(function() {
        if( !$.trim( $('.insert_top-teams-list').html() ).length ) {
          teamP = false;
          $('.top-teams-list').hide();
        }
        else {
          teamP = true;
          $('#top_lists').show();
          $('.top-teams-list').show();
        }
      }, function(err) {
        console.log(err);
      });

      companyPromise.then(function() {
        if( !$.trim( $('.insert_top-companies-list').html() ).length ) {
          compP = false;
          $('.top-companies-list').hide();
        }
        else {
          compP = true;
          $('#top_lists').show();
          $('.top-companies-list').show();
        }
      }, function(err) {
        console.log(err);
      });

      setTimeout(function(){
        if ( partP == false) {
            if ( teamP == false) {
                // No part list and no team list
                if ( compP == false) {
                    // No lists are showing
                    // No adjustments necessary
                } else {
                    // Only company list is showing
                    $('.top-companies-list').addClass('col-md-offset-2 col-md-8');
                    $('.top-companies-list').removeClass('col-md-offset-0 col-md-4');
                }
            } else {
                // No part list but yes team list
                if ( compP == false) {
                    // Only team list is showing
                    $('.top-teams-list').addClass('col-md-offset-2 col-md-8');
                    $('.top-teams-list').removeClass('col-md-offset-0 col-md-4');
                } else {
                    // Team list and company list
                    $('.top-companies-list').addClass('col-md-6');
                    $('.top-companies-list').removeClass('col-md-4');
                    $('.top-teams-list').addClass('col-md-6');
                    $('.top-teams-list').removeClass('col-md-4');
                }
            }
        } else {
            if ( teamP == false) {
                // Yes part list and no team list
                if ( compP == false) {
                    // Only part list is showing
                    $('.top-participants-list').addClass('col-md-offset-2 col-md-8');
                    $('.top-participants-list').removeClass('col-md-offset-0 col-md-4');
                } else {
                    // Part list and company list are showing
                    $('.top-companies-list').addClass('col-md-6');
                    $('.top-companies-list').removeClass('col-md-4');
                    $('.top-participants-list').addClass('col-md-6');
                    $('.top-participants-list').removeClass('col-md-4');
                }
            } else {
                // Part list and team list
                if ( compP == false) {
                    // Part list and team list
                    $('.top-participants-list').addClass('col-md-6');
                    $('.top-participants-list').removeClass('col-md-4');
                    $('.top-teams-list').addClass('col-md-6');
                    $('.top-teams-list').removeClass('col-md-4');
                } else {
                    // Part list and team list and comp list
                    // No adjustments necessary
                }
            }
        }
      }, 1000);

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
    }

    if ($('body').is('.pg_topparticipantlist')) {
      // Top Participant page JS goes here
      $('#top_participant_list_container').hide();
      //$('#top_participant_list_container').after('<div id="all_participant_list_container" class="lc_Table"></div>')
      $('#top_participant_list_container').after('<div class="mb-5">'
        + '<div class="row">'
          + '<div class="col-md-8 offset-md-2">'
            + '<form class="js--walker-search-form mt-3">'
              + '<p>Search by First and / or Last Name</p>'
              + '<div class="input-group input-group-lg">'
                + '<label for="participantFirstName" class="sr-only">First Name</label>'
                + '<input id="participantFirstName" type="text" name="first-name" class="form-control" />'
                + '<label for="participantLastName"  class="sr-only">Last Name</label>'
                +'<input id="participantLastName" type="text" name="last-name" class="form-control" />'
                +'<div class="input-group-append">'
                  +'<button type="submit" class="btn btn-primary">Search <i class="fas fa-search aria-hidden="true"></i></button>'
                +'</div>'
              +'</div>'
            +'</form>'
          +'</div>'
        +'</div>'
        +'<div class="row">'
          +'<div class="results-tab-pane col-12" id="participantSearchResults">'
            +'<div id="error-participant" class="alert alert-danger text-center" hidden>'
              +'Participant not found. Please try different search terms.</div>'
              +'<div class="js--participant-results-container col-md-12" hidden>'
                +'<div class="d-block d-md-none font-italic mobile-results-count">'
                  +'<span class="js--num-participant-results"></span>'
                +'</div>'
                +'<table id="participantResultsTable" class="js--participants-results-table table mt-4" width="100%">'
                  +'<thead>'
                    +'<tr>'
                      +'<th class="th-sm">Full Name'
                      +'</th>'
                      +'<th class="th-sm">Team Name'
                      +'</th>'
                      +'<th class="th-sm">Amount Raised'
                      +'</th>'
                      +'<th class="th-sm" data-orderable="false"><span class="js--num-participant-results"></span>'
                      +'</th>'
                    +'</tr>'
                  +'</thead>'
                  +'<tbody class="js--participants-results-rows"></tbody>'
                +'</table>'
                +'<div class="text-center pt-4">'
                  +'<p class="font-italic js--more-participant-results" hidden><a href="#">See More Results <i class="fas fa-arrow-down"></i></a></p>'
                  +'<p class="font-italic js--end-participant-list" hidden>You&rsquo;ve reached the end of the list'
                  +'</p>'
                +'</div>'
              +'</div>'
            +'</div>'
          +'</div>'
        +'</div>'
      );

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

      // get all Participants
      var screenWidth = $(window).innerWidth();
      console.log('screenWidth ' + screenWidth)

      if (!evID) {
        var url = window.location.href;
        url = url.split('fr_id=')[1];
        url = url.split('&')[0];
        evID = url;
      }

      var pageOffset = 0;
      var participantCount = 0;
      var allParticipants = [];
      
      function getAllParticipants(firstName, lastName){
        //console.log('getAllParticipants');

        if (firstName) {
          firstName = firstName;
        }
        else {
          firstName = '%25'
        }
        if (lastName) {
          lastName = lastName;
        }
        else {
          lastName = '%25%25%25'
        }

        luminateExtend.api({
          api: 'teamraiser',
          data: 'method=getParticipants&fr_id=' + evID + '&response_format=json&first_name='+firstName+'&last_name='+lastName+'&list_sort_column=total&list_ascending=false&list_page_size=500&list_page_offset='+pageOffset,
          callback: {
            success: function (response) {
              if (response.getParticipantsResponse.totalNumberResults === '0') {
                // no search results
                $('#error-participant').removeAttr('hidden').text('Participant not found. Please try different search terms.');
              } 
              else {
                  var totalParticipants = Number(response.getParticipantsResponse.totalNumberResults);
                  
                  var participants = luminateExtend.utils.ensureArray(response.getParticipantsResponse.participant);

                  var numParticipants = participants.length;
                  participantCount = participantCount + numParticipants;

                  $(participants).each(function (i, participant) {
                    allParticipants.push(participant);
                  });

                  if (participantCount === totalParticipants) {

                    participantCount = 0;

                    if ($.fn.DataTable) {
                      if ($.fn.DataTable.isDataTable('#participantResultsTable')) {
                        $('#participantResultsTable').DataTable().destroy();
                      }
                    }
  
                    $('#participantResultsTable tbody').empty();
                    $('.js--num-participant-results').text((totalParticipants === 1 ? '1 Result' : totalParticipants + ' Results'));
                    
                    function compare( a, b ) {

                      if ( Number(a.amountRaised) < Number(b.amountRaised) ){
                        return -1;
                      }
                      if ( Number(a.amountRaised) > Number(b.amountRaised) ){
                        return 1;
                      }
                      //return 0;
                      if ( a.name.last < b.name.last ){
                        return -1;
                      }
                      if ( a.name.last > b.name.last ){
                        return 1;
                      }
                    }
                    
                    allParticipants.sort( compare );
                    allParticipants.reverse();

                    $.each(allParticipants,function(i, participant){

                      var formattedAmountRaised = new Intl.NumberFormat("en-US", { style: "currency",currency: "USD"}).format(participant.amountRaised / 100);

                      if (screenWidth >= 768) {
                        $('.js--participants-results-rows').append('<tr' + (i > 10 ? ' class="d-none"' : '') + '><td><a href="' + participant.personalPageUrl + '">' +
                            participant.name.first + ' ' + participant.name.last +
                            '</a></td><td>' +
                            ((participant.teamName !== null && participant.teamName !== undefined) ? '<a href="' + participant.teamPageUrl + '">' + participant.teamName + '</a>' : '') + '</td><td>' + formattedAmountRaised + '</td><td class="col-cta"><a href="' + participant.donationUrl + '" aria-label="Donate to ' + participant.name.first + ' ' + participant.name.last + '" class="btn btn-primary btn-block btn-rounded">Donate</a></td></tr>');
                      } else {
                          $('#participantResultsTable thead').remove();
                          $('.js--participants-results-rows').addClass('mobile').append('<tr' + (i > 10 ? ' class="d-none"' : '') + '><td><table><tr><td>Participant</td><td><a href="' + participant.personalPageUrl + '">' +
                              participant.name.first + ' ' + participant.name.last + '</a></td></tr>' +
                              ((participant.teamName !== null && participant.teamName !== undefined) ? '<tr><td>Team</td><td><a href="' + participant.teamPageUrl + '">' + participant.teamName + '</a>' : '') +
                              '</td></tr><tr><td>Amount Raised</td><td>' + formattedAmountRaised + '</td></tr><tr><td colspan="2" class="text-center"><a href="' + participant.donationUrl + '" class="btn btn-primary btn-block btn-rounded" title="Donate to ' + participant.name.first + ' ' + participant.name.last + '" aria-label="Donate to ' + participant.name.first + ' ' + participant.name.last + '">Donate</a></td></tr></table></td></tr>');
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
                          "autoWidth": false,
                          "order": [[2, 'desc']]
                      });
                    }
                    $('.dataTables_length').addClass('bs-select');

                    $('.js--participant-results-container').removeAttr('hidden');
            
                    //$('.js--more-participant-results').on('click', function (e) {
                    $('.js--more-participant-results').click(function (e) {
                        e.preventDefault();
                        $('.js--participants-results-rows tr').removeClass('d-none');
                        $(this).attr('hidden', true);
                        $('.js--end-participant-list').removeAttr('hidden');
                    });

                    //allParticipants.length = 0
                    allParticipants.splice(0,allParticipants.length);
                    participantCount = 0;
                    pageOffset = 0;

                  }
                  else {
                    console.log('run it again');
                    pageOffset ++;
                    getAllParticipants(firstName,lastName);
                  }
              }
            },
            error: function (response) {
                $('#error-participant').removeAttr('hidden').text(response.errorResponse.message);
            }

          }
        });
      }
      getAllParticipants();


      var clearSearchResults = function () {
        $('.js--participant-results-container, .alert').attr('hidden', true);
        $('.js--participants-results-rows').html('');
        $('.js--end-participant-list').attr('hidden', true);
      }

      // Search page by Participant
      $('.js--walker-search-form').on('submit', function (e) {
        e.preventDefault();
        clearSearchResults();
        var firstName = encodeURIComponent($('#participantFirstName').val());
        var lastName = encodeURIComponent($('#participantLastName').val());

        //cd.getParticipants(firstName, lastName);
        getAllParticipants(firstName, lastName)
        
      });
    
    }

    
    if ($('body').is('.pg_teamlist')) {
      // Top team page JS goes here

      $('#top_team_list_container').hide();
      $('#top_team_list_container').after('<div class="row">'
          + '<div class="col-md-6 offset-md-3">'
            + '<form class="js--team-search-form mt-3">'
              + '<label for="teamNameSearch">Search by Team Name</label>'
              + '<div class="input-group input-group-lg">'
                + '<input id="teamNameSearch" type="text" class="form-control" name="team-search" />'
                + '<div class="input-group-append">'
                  + '<button type="submit" class="btn btn-primary">Search <i class="fas fa-search" aria-hidden="true"></i></button>'
                + '</div>'
              + '</div>'
            + '</form>'
          + '</div>'
        + '</div>'
        + '<div class="row">'
          + '<div class="results-tab-pane col-12" id="teamSearchResults">'
            + '<div id="error-team" class="alert alert-danger text-center" hidden>'
              + 'Team not found. Please try different search terms.</div>'
            + '<div class="js--team-results-container col-md-12" hidden>'
              + '<div class="d-block d-md-none font-italic mobile-results-count"><span class="js--num-team-results"></span>'
            + '</div>'
            + '<table id="teamResultsTable" class="table mt-4" width="100%">'
              + '<thead>'
                + '<tr>'
                  + '<th class="th-sm">Team'
                  + '</th>'
                  + '<th class="th-sm">Team Coach'
                  + '</th>'
                  + '<th class="th-sm">Participants'
                  + '</th>'
                  + '<th class="th-sm">Amount Raised'
                  + '</th>'
                  + '<th class="th-sm" data-orderable="false"><span class="js--num-team-results"></span>'
                  + '</th>'
                + '</tr>'
              + '</thead>'
              + '<tbody class="js--team-results-rows"></tbody>'
            + '</table>'
            + '<div class="text-center pt-4">'
              + '<p class="font-italic js--more-team-results" hidden><a href="#">See More Results <iclass="fas fa-arrow-down"></i></a></p>'
              + '<p class="font-italic js--end-team-list" hidden>You&rsquo;ve reached the end of the list</p>'
            + '</div>'
          + '</div>'
        + '</div>'
      + '</div>');

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

      // get all Teams for teamlist

      var allTeams = [];
      var teamCount = 0;
      var screenWidth = $(window).innerWidth();

      if (!evID) {
        var url = window.location.href;
        url = url.split('fr_id=')[1];
        url = url.split('&')[0];
        evID = url;
      }

      var pageOffset = 0;
      var teamCount = 0;
      var allTeams = [];

      function getAllTeams(teamname){

        if (teamname) {
          teamname = teamname;
        }
        else {
          teamname = '%25%25%25'
        }

        luminateExtend.api({
          api: 'teamraiser',
          data: 'method=getTeamsByInfo&fr_id=' + evID + '&response_format=json&team_name='+teamname+'&list_sort_column=total&list_ascending=false&list_page_size=500&list&list_page_offset='+pageOffset,
          callback: {
            success: function (response) {
              if (response.getTeamSearchByInfoResponse.totalNumberResults === '0') {
                // no search results
                $('#error-team').removeAttr('hidden').text('Team not found. Please try different search terms.');
              } 

              else {

                var totalTeams = Number(response.getTeamSearchByInfoResponse.totalNumberResults);
                
                var teams = luminateExtend.utils.ensureArray(response.getTeamSearchByInfoResponse.team);

                var numTeams = teams.length;
                teamCount = teamCount + numTeams;

                $(teams).each(function (i, team) {
                  allTeams.push(team);
                });

                if (teamCount === totalTeams) {
                  teamCount = 0;

                  if ($.fn.DataTable) {
                    if ($.fn.DataTable.isDataTable('#teamResultsTable')) {
                      $('#teamResultsTable').DataTable().destroy();
                    }
                  }

                  $('#teamResultsTable tbody').empty();
                  $('.js--num-team-results').text((totalTeams === 1 ? '1 Result' : totalTeams + ' Results'));
                  
                  function compare( a, b ) {

                    if ( Number(a.amountRaised) < Number(b.amountRaised) ){
                      return -1;
                    }
                    if ( Number(a.amountRaised) > Number(b.amountRaised) ){
                      return 1;
                    }
                    //return 0;
                    if ( a.name < b.name ){
                      return -1;
                    }
                    if ( a.name > b.name ){
                      return 1;
                    }
                  }
                  
                  allTeams.sort( compare );
                  allTeams.reverse();   numMembers

                  $.each(allTeams,function(i, team){
                    
                    var formattedAmountRaised = new Intl.NumberFormat("en-US", { style: "currency",currency: "USD"}).format(team.amountRaised / 100);

                    if (screenWidth >= 768) {
                      $('.js--team-results-rows')
                          .append('<tr' + (i > 10 ? ' class="d-none"' : '') + '><td><a href="' + team.teamPageURL + '">' +
                              team.name + '</a></td><td><a href="TR/?px=' + team.captainConsId + '&pg=personal&fr_id=' + team.EventId + '">' + team.captainFirstName + ' ' + team.captainLastName + '</a></td>' +
                              '<td>'+team.numMembers+'</td>' +
                              '<td>' + formattedAmountRaised + '</td><td class="col-cta"><a href="' + team.teamDonateURL + '" class="btn btn-primary btn-block btn-rounded" title="Donate to ' + team.name + '" aria-label="Donate to ' + team.name + '">Donate</a></td></tr>');
                    } else {
                      $('#teamResultsTable thead').remove();
                      $('.js--team-results-rows')
                          .addClass('mobile')
                          .append('<tr><td><table><tr' + (i > 10 ? ' class="d-none"' : '') + '><td>Team</td><td><a href="' + team.teamPageURL + '">' +
                              team.name + '</a></td></tr><tr><td>Team Captain</td><td><a href="TR/?px=' + team.captainConsId + '&pg=personal&fr_id=' + team.EventId + '">' + team.captainFirstName + ' ' + team.captainLastName + '</a></td></tr>' +
                              '</tr>' + 
                              '<tr><td>Participants</td><td>'+team.numMembers+'</td></tr>' +
                              '<tr><td>Amount Raised</td><td>' + formattedAmountRaised + '</td></tr><tr><td colspan="2" class="text-center"><a href="' + team.teamDonateURL + '" class="btn btn-primary btn-block btn-rounded" title="Donate to ' + team.name + '" aria-label="Donate to ' + team.name + '">Donate</a></td></tr></table></td></tr>');
                    }
                  });

                  if (totalTeams > 10) {
                    $('.js--more-team-results').removeAttr('hidden');
                  }
          
                  if (screenWidth >= 768) {
                    $('#teamResultsTable').DataTable({
                        "paging": false,
                        "searching": false,
                        "info": false,
                        "autoWidth": false,
                        "order": [[2, 'desc']]
                    });
                  }
                  $('.dataTables_length').addClass('bs-select');

                  $('.js--team-results-container').removeAttr('hidden');
          
                  //$('.js--more-participant-results').on('click', function (e) {
                  $('.js--more-team-results').click(function (e) {
                      e.preventDefault();
                      $('.js--team-results-rows tr').removeClass('d-none');
                      $(this).attr('hidden', true);
                      $('.js--end-team-list').removeAttr('hidden');
                  });

                  //allParticipants.length = 0
                  allTeams.splice(0,allTeams.length);
                  teamCount = 0;
                  pageOffset = 0;

                }
                else {
                  pageOffset ++;
                  console.log('pageOffset ' + pageOffset);
                  console.log('run it again with team name: ' + teamName)
                  getAllteams(teamName);
                }

              }
              
            },
            error: function (response) {
              $('#error-team').removeAttr('hidden').text(response.errorResponse.message);
            }
          }
        });
      }
      getAllTeams();

      var clearSearchResults = function () {
        $('.js--team-results-container, .alert').attr('hidden', true);
        $('.js--team-results-rows').html('');
        $('.js--end-team-list').attr('hidden', true);
      }

      // Search page by Team
      $('.js--team-search-form').on('submit', function (e) {
        e.preventDefault();
        clearSearchResults();
        var teamName = encodeURIComponent($('#teamNameSearch').val());

        getAllTeams(teamName);
      });
    }

  });
}(jQuery));
