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




    if ($('body').is('.pg_nchw_search')) {
      
      // NCHW Search Page

      var isTeamList = getURLParameter(currentUrl, 'team_list');

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

      if (!isTeamList) { 


      }

      if (isTeamList) {
        // get all Teams

        var allTeams = [];
        var teamCount = 0;

        if (!evID) {
          var url = window.location.href;
          url = url.split('fr_id=')[1];
          url = url.split('&')[0];
          evID = url;
        }

        var pageOffset = 0;

        var getAllTeams = function(teamName){
          if (teamName) {
            teamName = teamName;
          }
          else {
            teamName = '%25'
          }
          console.log('getAllTeams function')
          console.log('pageOffset ' + pageOffset);
          luminateExtend.api({
            api: 'teamraiser',
            data: 'method=getTeamsByInfo&fr_id=' + evID + '&response_format=json&team_name='+teamName+'&list_sort_column=total&list_ascending=false&list_page_size=500&list&list_page_offset='+pageOffset,
            callback: {
              success: function (response) {
                if (!$.isEmptyObject(response.getTeamSearchByInfoResponse)) {
                  var totalTeams = Number(response.getTeamSearchByInfoResponse.totalNumberResults);
                  console.log('totalTeams ' + totalTeams)
                  
                  var teamData = luminateExtend.utils.ensureArray(response.getTeamSearchByInfoResponse.team);
                  if (teamData.length > 0) {
                    
                    for (var i = 0, len = teamData.length; i < len; i++) {
                      teamCount ++;
                      var amountRaised = Number(teamData[i].amountRaised)/100;
                      amountRaised = amountRaised.formatMoney(0);

                      var team = {
                        teamId: teamData[i].id,
                        teamName: teamData[i].name,
                        captainFirstName: teamData[i].captainFirstName,
                        captainLastName: teamData[i].captainLastName,
                        captainConsId: teamData[i].captainConsId,
                        eventId: teamData[i].EventId,
                        teamSize: teamData[i].numMembers,
                        amountRaised: amountRaised,
                        teamPageURL: teamData[i].teamPageURL,
                        joinTeamUrl: teamData[i].joinTeamURL
                      }
                      allTeams.push(team);

                    }

                    if (teamCount === totalTeams) {
                      displayTeams();
                    }
                    else {
                      pageOffset ++;
                      getAllTeams();
                    }

                  }
                }
                
              },
              error: function (response) {
                console.log('getAllTeams error: ' + response.errorResponse.message);
              }
            }
          });
        }
        getAllTeams();

        var displayTeams = function() {
          var totalTeams = allTeams.length;
          console.log('displayTeams' + displayTeams);
          // $.each(allTeams,function(){
          //   var teamDataOutput = '<div class="lc_Row0 list-row team-list-row clearfix">'
          //     + '<div class="team-list-name">'
          //       + '<a href="' + luminateExtend.global.path.secure + 'TR/?fr_id=' + this.eventId + '&pg=team&team_id=' + this.teamId + '">'+this.teamName + '</a>'
          //     + '</div>'
          //     + '<div class="team-list-captain">Team Captain: ' + this.captainFirstName + ' ' + this.captainLastName +'</div>'
          //     + '<div class="team-list-participants">Members: ' + this.teamSize + '</div>'
          //     + '<div class="team-list-donations">Amount Raised: $' + this.amountRaised + '</div>'
          //     + '<div class="team-list-one-button-container">'
          //       + '<div class="team-list-join-container">'
          //         + '<a href=" ' + this.joinTeamUrl + ' " class="button">Join</a>'
          //       + '</div>'
          //     + '</div>'
          //   + '</div>';

          //   $('#all_team_list_container').append(teamDataOutput);

          // });
          $.each(allTeams, function (i, team) {
            if (screenWidth >= 768) {
                $('.js--team-results-rows')
                    .append('<tr' + (i > 10 ? ' class="d-none"' : '') + '><td><a href="' + team.teamPageURL + '">' +
                        team.name + '</a></td><td><a href="TR/?px=' + team.captainConsId + '&pg=personal&fr_id=' + team.eventId + '">' + team.captainFirstName + ' ' + team.captainLastName + '</a></td>' +
                        '<td>' + team.amountRaised + '</td><td class="col-cta"><a href="' + team.teamDonateURL + '" class="btn btn-primary btn-block btn-rounded" title="Donate to ' + team.name + '" aria-label="Donate to ' + team.name + '">Donate</a></td></tr>');
            } else {
                $('#teamResultsTable thead').remove();
                $('.js--team-results-rows')
                    .addClass('mobile')
                    .append('<tr><td><table><tr' + (i > 10 ? ' class="d-none"' : '') + '><td>Team</td><td><a href="' + team.teamPageURL + '">' +
                        team.name + '</a></td></tr><tr><td>Team Captain</td><td><a href="TR/?px=' + team.captainConsId + '&pg=personal&fr_id=' + team.eventId + '">' + team.captainFirstName + ' ' + team.captainLastName + '</a></td></tr>' +
                        '<tr><td>Amount Raised</td><td>' + team.amountRaised + '</td></tr><tr><td colspan="2" class="text-center"><a href="' + team.teamDonateURL + '" class="btn btn-primary btn-block btn-rounded" title="Donate to ' + team.name + '" aria-label="Donate to ' + team.name + '">Donate</a></td></tr></table></td></tr>');
            }
          });

          //var totalTeams = parseInt(response.getTeamSearchByInfoResponse.totalNumberResults);

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
          //addPaymentTypesOnSearch();
          $('.js--team-results-container').removeAttr('hidden');

        };
      }

      // NCHW Search Page
      var clearSearchResults = function () {
          $('.js--participant-results-container, .alert').attr('hidden', true);
          $('.js--participants-results-rows').html('');
          $('.js--team-results-container, .alert').attr('hidden', true);
          $('.js--team-results-rows').html('');
      }

      // Search page by Participant
      $('.js--walker-search-form').on('submit', function (e) {
          e.preventDefault();
          clearSearchResults();
          var firstName = encodeURIComponent($('#walkerFirstName').val());
          var lastName = encodeURIComponent($('#walkerLastName').val());

          //cd.getParticipants(firstName, lastName);
          getAllParticipants(firstName, lastName)

      });

      // Search by Team
      $('.js--team-search-form').on('submit', function (e) {
          e.preventDefault();
          clearSearchResults();
          var teamName = encodeURIComponent($('#teamNameSearch').val());
          //cd.getTeams(teamName, null);
          getAllTeams(teamName)
      });


      // if (searchType) {
      //     cd.autoSearchParticipant = function () {
      //         var firstNameVal = getURLParameter(currentUrl, 'first_name') ? getURLParameter(currentUrl, 'first_name') : '';
      //         var lastNameVal = getURLParameter(currentUrl, 'last_name') ? getURLParameter(currentUrl, 'last_name') : '';

      //         if (!firstNameVal && !lastNameVal) {
      //             // General participant search from greeting page. Show all walkers
      //             cd.getParticipants('%25%25%25', '%25%25%25', (isCrossEventSearch === "true" ? true : false));
      //         } else {
      //             firstNameVal = decodeURIComponent(firstNameVal);
      //             lastNameVal = decodeURIComponent(lastNameVal);

      //             $('#walkerFirstName').val(firstNameVal);
      //             $('#walkerLastName').val(lastNameVal);

      //             cd.getParticipants(firstNameVal, lastNameVal, (isCrossEventSearch === "true" ? true : false));
      //         }

      //     }

      //     cd.autoSearchTeam = function () {
      //         var teamName = getURLParameter(currentUrl, 'team_name') ? getURLParameter(currentUrl, 'team_name') : '';
      //         teamName = decodeURIComponent(teamName);
      //         $('#teamNameSearch').val(teamName);

      //         cd.getTeams(teamName, null, (isCrossEventSearch === "true" ? true : false));
      //     }

      //     cd.autoSearchEvents = function () {
      //         var searchZip = getURLParameter(currentUrl, 'zip') ? getURLParameter(currentUrl, 'zip') : '';
      //         $('#zipCodeSearch').val(searchZip);

      //         cd.getEventsByDistance(searchZip);
      //     }

      //     if (searchType === 'event') {
      //         cd.autoSearchEvents();
      //     } else if (searchType === 'walker') {
      //         cd.autoSearchParticipant();
      //         // Switch to walker tab
      //         $('#searchWalkerTab').tab('show');
      //     } else if (searchType === 'team') {
      //         cd.autoSearchTeam();
      //         // Switch to team tab
      //         $('#searchTeamTab').tab('show');
      //     }
      // }



    //   cd.getParticipants = function (firstName, lastName, isCrossEvent) {
    //     luminateExtend.api({
    //         api: 'teamraiser',
    //         data: 'method=getParticipants' +
    //             ((firstName !== undefined) ? '&first_name=' + firstName : '') +
    //             ((lastName !== undefined) ? '&last_name=' + lastName : '') +
    //             (isCrossEvent === true ? '&event_type=' + eventType : '&fr_id=' + evID) +
    //             '&list_page_size=499' +
    //             '&list_page_offset=0' +
    //             '&response_format=json' +
    //             '&list_sort_column=first_name' +
    //             '&list_ascending=true',
    //         callback: {
    //             success: function (response) {
    //                 if (response.getParticipantsResponse.totalNumberResults === '0') {
    //                     // no search results
    //                     $('#error-participant').removeAttr('hidden').text('Participant not found. Please try different search terms.');
    //                 } else {
    //                     var participants = luminateExtend.utils.ensureArray(response.getParticipantsResponse.participant);
    //                     var totalParticipants = parseInt(response.getParticipantsResponse.totalNumberResults);

    //                     if ($.fn.DataTable) {
    //                         if ($.fn.DataTable.isDataTable('#participantResultsTable')) {
    //                             $('#participantResultsTable').DataTable().destroy();
    //                         }
    //                     }
    //                     $('#participantResultsTable tbody').empty();

    //                     $('.js--num-participant-results').text((totalParticipants === 1 ? '1 Result' : totalParticipants + ' Results'));

    //                     $(participants).each(function (i, participant) {
    //                         if (screenWidth >= 768) {
    //                             $('.js--participants-results-rows').append('<tr' + (i > 10 ? ' class="d-none"' : '') + '><td><a href="' + participant.personalPageUrl + '">' +
    //                                 participant.name.first + ' ' + participant.name.last +
    //                                 '</a></td><td>' +
    //                                 ((participant.teamName !== null && participant.teamName !== undefined) ? '<a href="' + participant.teamPageUrl + '">' + participant.teamName + '</a>' : '') + '</td><td><a href="TR/?fr_id=' + participant.eventId + '&pg=entry">' +
    //                                 participant.eventName + '</a></td><td class="col-cta"><a href="' + participant.donationUrl + '" aria-label="Donate to ' + participant.name.first + ' ' + participant.name.last + '" class="btn btn-primary btn-block btn-rounded">Donate</a></td></tr>');
    //                         } else {
    //                             $('#participantResultsTable thead').remove();
    //                             $('.js--participants-results-rows').addClass('mobile').append('<tr><td><table><tr' + (i > 10 ? ' class="d-none"' : '') + '><td>Walker</td><td><a href="' + participant.personalPageUrl + '">' +
    //                                 participant.name.first + ' ' + participant.name.last + '</a></td></tr>' +
    //                                 ((participant.teamName !== null && participant.teamName !== undefined) ? '<tr><td>Team</td><td><a href="' + participant.teamPageUrl + '">' + participant.teamName + '</a>' : '') +
    //                                 '</td></tr><tr><td>Event Name</td><td><a href="TR/?fr_id=' + participant.eventId + '&pg=entry">' + participant.eventName + '</a></td></tr><tr><td colspan="2" class="text-center"><a href="' + participant.donationUrl + '" class="btn btn-primary btn-block btn-rounded" title="Donate to ' + participant.name.first + ' ' + participant.name.last + '" aria-label="Donate to ' + participant.name.first + ' ' + participant.name.last + '">Donate</a></td></tr></table></td></tr>');
    //                         }
    //                     });

    //                     if (totalParticipants > 10) {
    //                         $('.js--more-participant-results').removeAttr('hidden');
    //                     }

    //                     if (screenWidth >= 768) {
    //                         $('#participantResultsTable').DataTable({
    //                             "paging": false,
    //                             "searching": false,
    //                             "info": false,
    //                             "autoWidth": false
    //                         });
    //                     }
    //                     $('.dataTables_length').addClass('bs-select');
    //                     //add call to hook donate button with payment type selections
    //                     addPaymentTypesOnSearch();
    //                     $('.js--participant-results-container').removeAttr('hidden');

    //                     $('.js--more-participant-results').on('click', function (e) {
    //                         e.preventDefault();
    //                         $('.js--participants-results-rows tr').removeClass('d-none');
    //                         $(this).attr('hidden', true);
    //                         $('.js--end-participant-list').removeAttr('hidden');
    //                     });

    //                 }
    //             },
    //             error: function (response) {
    //                 $('#error-participant').removeAttr('hidden').text(response.errorResponse.message);
    //             }
    //         }
    //     });
    // };

    // cd.getTeams = function (teamName, isCrossEvent, firstName, lastName, companyId) {
    //     $('.js__team-results-rows').html('');
    //     luminateExtend.api({
    //         api: 'teamraiser',
    //         data: 'method=getTeamsByInfo' +
    //             '&team_name=' + teamName +
    //             (isCrossEvent === true ? '&event_type=' + eventType : '&fr_id=' + evID) +
    //             (firstName ? '&first_name=' + firstName : '') +
    //             (lastName ? '&last_name=' + lastName : '') +
    //             (companyId ? '&team_company_id=' + companyId : '') +
    //             '&list_page_size=499' +
    //             '&list_page_offset=0' +
    //             '&response_format=json' +
    //             '&list_sort_column=name' +
    //             '&list_ascending=true',
    //         callback: {
    //             success: function (response) {

    //                 if ($.fn.DataTable) {
    //                     if ($.fn.DataTable.isDataTable('#teamResultsTable')) {
    //                         $('#teamResultsTable').DataTable().destroy();
    //                     }
    //                 }
    //                 $('#teamResultsTable tbody').empty();

    //                 if (response.getTeamSearchByInfoResponse.totalNumberResults === '0') {
    //                     // no search results
    //                     $('#error-team').removeAttr('hidden').text('Team not found. Please try different search terms.');
    //                     $('.js--error-team-search').show();
    //                 } else {
    //                     var teams = luminateExtend.utils.ensureArray(response.getTeamSearchByInfoResponse.team);

    //                     $(teams).each(function (i, team) {
    //                         if (screenWidth >= 768) {
    //                             $('.js--team-results-rows')
    //                                 .append('<tr' + (i > 10 ? ' class="d-none"' : '') + '><td><a href="' + team.teamPageURL + '">' +
    //                                     team.name + '</a></td><td><a href="TR/?px=' + team.captainConsId + '&pg=personal&fr_id=' + team.EventId + '">' + team.captainFirstName + ' ' + team.captainLastName + '</a></td><td>' +
    //                                     ((team.companyName !== null && team.companyName !== undefined) ? '<a href="TR?company_id=' + team.companyId + '&fr_id=' + team.EventId + '&pg=company">' + team.companyName + '</a>' : '') +
    //                                     '</td><td><a href="TR/?fr_id=' + team.EventId + '&pg=entry">' + team.eventName + '</a></td><td class="col-cta"><a href="' + team.teamDonateURL + '" class="btn btn-primary btn-block btn-rounded" title="Donate to ' + team.name + '" aria-label="Donate to ' + team.name + '">Donate</a></td></tr>');
    //                         } else {
    //                             $('#teamResultsTable thead').remove();
    //                             $('.js--team-results-rows')
    //                                 .addClass('mobile')
    //                                 .append('<tr><td><table><tr' + (i > 10 ? ' class="d-none"' : '') + '><td>Team</td><td><a href="' + team.teamPageURL + '">' +
    //                                     team.name + '</a></td></tr><tr><td>Team Captain</td><td><a href="TR/?px=' + team.captainConsId + '&pg=personal&fr_id=' + team.EventId + '">' + team.captainFirstName + ' ' + team.captainLastName + '</a></td></tr>' +
    //                                     ((team.companyName !== null && team.companyName !== undefined) ? '<tr><td>Company</td><td><a href="TR?company_id=' + team.companyId + '&fr_id=' + team.EventId + '&pg=company">' + team.companyName + '</a>' : '') +
    //                                     '</td></tr><tr><td>Event Name</td><td><a href="TR/?fr_id=' + team.EventId + '&pg=entry">' + team.eventName + '</a></td></tr><tr><td colspan="2" class="text-center"><a href="' + team.teamDonateURL + '" class="btn btn-primary btn-block btn-rounded" title="Donate to ' + team.name + '" aria-label="Donate to ' + team.name + '">Donate</a></td></tr></table></td></tr>');
    //                         }
    //                     });

    //                     var totalTeams = parseInt(response.getTeamSearchByInfoResponse.totalNumberResults);

    //                     $('.js--num-team-results').text((totalTeams === 1 ? '1 Result' : totalTeams + ' Results'));

    //                     if (totalTeams > 10) {
    //                         $('.js--more-team-results').removeAttr('hidden');
    //                     }

    //                     $('.js--team-results-container').removeAttr('hidden');

    //                     $('.js--more-team-results').on('click', function (e) {
    //                         e.preventDefault();
    //                         $('.js--team-results-rows tr').removeClass('d-none');
    //                         $(this).attr('hidden', true);
    //                         $('.js--end-team-list').removeAttr('hidden');
    //                     });
    //                     if (screenWidth >= 768) {
    //                         $('#teamResultsTable').DataTable({
    //                             "paging": false,
    //                             "searching": false,
    //                             "info": false
    //                         });
    //                     }
    //                     $('.dataTables_length').addClass('bs-select');
    //                     //add call to hook donate button with payment type selections
    //                     addPaymentTypesOnSearch();
    //                     $('.js--team-results-container').removeAttr('hidden');

    //                 }
    //             },
    //             error: function (response) {
    //                 $('#error-team').removeAttr('hidden').text(response.errorResponse.message);
    //                 $('.js--search-results').show();
    //                 $('.js--search-results-container').show();
    //             }
    //         }
    //     });
    // };


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
                + '<label for="walkerFirstName">First Name</label>'
                + '<input id="walkerFirstName" type="text" name="first-name" class="form-control" />'
                + '<label for="walkerLastName">Last Name</label>'
                +'<input id="walkerLastName" type="text" name="last-name" class="form-control" />'
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
      console.log('initial participantCount '  + participantCount);
      var allParticipants = [];
      
      function getAllParticipants(firstName, lastName){
        console.log('getAllParticipants');

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
        console.log('lastName  ' + lastName);

        luminateExtend.api({
          api: 'teamraiser',
          data: 'method=getParticipants&fr_id=' + evID + '&response_format=json&first_name='+firstName+'&last_name='+lastName+'&list_sort_column=total&list_ascending=false&list_page_size=3&list&list_page_offset='+pageOffset,
          callback: {
            success: function (response) {
              if (response.getParticipantsResponse.totalNumberResults === '0') {
                // no search results
                $('#error-participant').removeAttr('hidden').text('Participant not found. Please try different search terms.');
              } 
              else {
                  console.log('participantCount in else ' + participantCount);
                  var totalParticipants = Number(response.getParticipantsResponse.totalNumberResults);
                  console.log('totalParticipants ' + totalParticipants + typeof totalParticipants);
                  
                  //var participantData = luminateExtend.utils.ensureArray(response.getParticipantsResponse.participant);
                  var participants = luminateExtend.utils.ensureArray(response.getParticipantsResponse.participant);

                  var numParticipants = participants.length;
                  console.log('numParticipants ' + numParticipants + typeof numParticipants);
                  participantCount = participantCount + numParticipants;
                  console.log('participantCount' + participantCount);

                  $(participants).each(function (i, participant) {
                    allParticipants.push('participant');
                    console.log('allParticipants length ' + allParticipants.length);
                  });

                  if (participantCount === totalParticipants) {
                    console.log('got them all ');
                    participantCount = 0;

                    if ($.fn.DataTable) {
                      if ($.fn.DataTable.isDataTable('#participantResultsTable')) {
                        console.log('destroying the table')
                        $('#participantResultsTable').DataTable().destroy();
                      }
                    }
  
                    $('#participantResultsTable tbody').empty();
                    $('.js--num-participant-results').text((totalParticipants === 1 ? '1 Result' : totalParticipants + ' Results'));
  

                    $.each(allParticipants,function(i, participant){

                      if (screenWidth >= 768) {
                        $('.js--participants-results-rows').append('<tr' + (i > 10 ? ' class="d-none"' : '') + '><td><a href="' + participant.personalPageUrl + '">' +
                            participant.name.first + ' ' + participant.name.last +
                            '</a></td><td>' +
                            ((participant.teamName !== null && participant.teamName !== undefined) ? '<a href="' + participant.teamPageUrl + '">' + participant.teamName + '</a>' : '') + '</td><td>' + participant.amountRaised + '</td><td class="col-cta"><a href="' + participant.donationUrl + '" aria-label="Donate to ' + participant.name.first + ' ' + participant.name.lasat + '" class="btn btn-primary btn-block btn-rounded">Donate</a></td></tr>');
                      } else {
                          $('#participantResultsTable thead').remove();
                          $('.js--participants-results-rows').addClass('mobile').append('<tr><td><table><tr' + (i > 10 ? ' class="d-none"' : '') + '><td>Participant</td><td><a href="' + participant.personalPageUrl + '">' +
                              participant.firstName + ' ' + participant.lastName + '</a></td></tr>' +
                              ((participant.teamName !== null && participant.teamName !== undefined) ? '<tr><td>Team</td><td><a href="' + participant.teamPageUrl + '">' + participant.teamName + '</a>' : '') +
                              '</td></tr><tr><td>Amount Raised</td><td>' + participant.amountRaised + '</td></tr><tr><td colspan="2" class="text-center"><a href="' + participant.donationUrl + '" class="btn btn-primary btn-block btn-rounded" title="Donate to ' + participant.name.first + ' ' + participant.name.last + '" aria-label="Donate to ' + participant.name.first + ' ' + participant.name.last + '">Donate</a></td></tr></table></td></tr>');
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
                    //addPaymentTypesOnSearch();
                    $('.js--participant-results-container').removeAttr('hidden');
            
                    //$('.js--more-participant-results').on('click', function (e) {
                    $('.js--more-participant-results').click(function (e) {
                        e.preventDefault();
                        $('.js--participants-results-rows tr').removeClass('d-none');
                        $(this).attr('hidden', true);
                        $('.js--end-participant-list').removeAttr('hidden');
                    });


                  }
                  else {
                    console.log('run it again');
                    getAllParticipants();
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
        console.log('clearSearchResults')
        $('.js--event-results-container, .alert').attr('hidden', true);
        $('.js--event-results-rows').html('');
        $('.js--participant-results-container, .alert').attr('hidden', true);
        $('.js--participants-results-rows').html('');
        $('.js--team-results-container, .alert').attr('hidden', true);
        $('.js--team-results-rows').html('');
      }

      // Search page by Participant
      $('.js--walker-search-form').on('submit', function (e) {
        e.preventDefault();
        console.log('submit function')
        clearSearchResults();
        var firstName = encodeURIComponent($('#walkerFirstName').val());
        var lastName = encodeURIComponent($('#walkerLastName').val());

        //cd.getParticipants(firstName, lastName);
        getAllParticipants(firstName, lastName)
        
      });

    

    }

    

    if ($('body').is('.pg_teamlist')) {
      // Top team page JS goes here

      $('#top_team_list_container').hide();
      $('#top_team_list_container').after('<div id="all_team_list_container" class="lc_Table team-list-table"></div>')

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

      // get all Teams

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

      getAllTeams = function(teamname){
        console.log('getAllTeams function')
        console.log('pageOffset ' + pageOffset);
        luminateExtend.api({
          api: 'teamraiser',
          data: 'method=getTeamsByInfo&fr_id=' + evID + '&response_format=json&list_sort_column=total&list_ascending=false&list_page_size=500&list&list_page_offset='+pageOffset,
          callback: {
            success: function (response) {
              if (!$.isEmptyObject(response.getTeamSearchByInfoResponse)) {
                var totalTeams = Number(response.getTeamSearchByInfoResponse.totalNumberResults);
                console.log('totalTeams ' + totalTeams)
                
                var teamData = luminateExtend.utils.ensureArray(response.getTeamSearchByInfoResponse.team);
                if (teamData.length > 0) {
                  
                  for (var i = 0, len = teamData.length; i < len; i++) {
                    teamCount ++;
                    var amountRaised = Number(teamData[i].amountRaised)/100;
                    amountRaised = amountRaised.formatMoney(0);

                    var team = {
                      teamId: teamData[i].id,
                      teamName: teamData[i].name,
                      captainFirstName: teamData[i].captainFirstName,
                      captainLastName: teamData[i].captainLastName,
                      eventId: teamData[i].EventId,
                      teamSize: teamData[i].numMembers,
                      amountRaised: amountRaised,
                      joinTeamUrl: teamData[i].joinTeamURL
                    }
                    allTeams.push(team);

                  }

                  if (teamCount === totalTeams) {
                    displayTeams();
                  }
                  else {
                    pageOffset ++;
                    getAllTeams();
                  }

                }
              }
              
            },
            error: function (response) {
              console.log('getAllTeams error: ' + response.errorResponse.message);
            }
          }
        });
      }
      getAllTeams();

      var displayTeams = function() {
        $.each(allTeams,function(){
          var teamDataOutput = '<div class="lc_Row0 list-row team-list-row clearfix">'
            + '<div class="team-list-name">'
              + '<a href="' + luminateExtend.global.path.secure + 'TR/?fr_id=' + this.eventId + '&pg=team&team_id=' + this.teamId + '">'+this.teamName + '</a>'
            + '</div>'
            + '<div class="team-list-captain">Team Captain: ' + this.captainFirstName + ' ' + this.captainLastName +'</div>'
            + '<div class="team-list-participants">Members: ' + this.teamSize + '</div>'
            + '<div class="team-list-donations">Amount Raised: $' + this.amountRaised + '</div>'
            + '<div class="team-list-one-button-container">'
              + '<div class="team-list-join-container">'
                + '<a href=" ' + this.joinTeamUrl + ' " class="button">Join</a>'
              + '</div>'
            + '</div>'
          + '</div>';

          $('#all_team_list_container').append(teamDataOutput);

        });
      };

    }


  });
}(jQuery));
