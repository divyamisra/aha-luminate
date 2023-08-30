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



  //   <div id="top_participant_list_container" class="lc_Table">
  //   <div class="lc_Row1 list-row top-participant-list-row clearfix">
  //     <div class="top-participant-list-name">
  //       <a href="https://dev2.heart.org/site/TR/OSE/FDA-FoundersAffiliate?px=8866676&amp;pg=personal&amp;fr_id=4736">Jean-test Vestal</a>
  //     </div>
  //     <div class="top-participant-list-amount-container">
  //       <div class="top-participant-list-amount-label">Raised:</div>
  //       <div class="top-participant-list-amount">$200.00</div>
  //     </div>
  //     <div class="top-participant-list-team">
  //       <a href="https://dev2.heart.org/site/TR/OSE/FDA-FoundersAffiliate?team_id=4571&amp;pg=team&amp;fr_id=4736">Team Blackbaud</a>
  //     </div>
  //   </div>
  // </div>

  //   div#top_participant_list_container {
  //     background: #fafafa;
  //     border-top: 3px solid #e2e2e2;
  //     border-bottom: 1px solid #e2e2e2;
  //     border-left: 1px solid #e2e2e2;
  //     border-right: 1px solid #e2e2e2;
  //     padding: 16px 10px;
  //     margin: 0px;
  //   }
        

    if ($('body').is('.pg_topparticipantlist')) {
      // Top Participant page JS goes here
      $('#top_participant_list_container').hide();
      $('#top_participant_list_container').after('<div id="all_participant_list_container" class="lc_Table"></div>')


      // get all Participants
      var allParticipantPromise = new Promise(function(resolve, reject) {
        luminateExtend.api({
          api: 'teamraiser',
          data: 'method=getParticipants&fr_id=' + evID + '&response_format=json&first_name=%25&last_name=%25%25%25&list_sort_column=total&list_ascending=false&list_page_size=5',
          callback: {
            success: function (response) {
              if (!$.isEmptyObject(response.getParticipantsResponse)) {
                var participantData = luminateExtend.utils.ensureArray(response.getParticipantsResponse.teamraiserData);
                if (participantData.length > 0) {
                  var sortedParticipantsData = participantData.slice(0, 5);
                  console.log('sortedParticipantsData ' + sortedParticipantsData)
                  for (var i = 0, len = sortedParticipantsData.length; i < len; i++) {
                    sortedParticipantsData[i].total = Number(sortedParticipantsData[i].total.replace('$', '').replace(',', ''));
                    console.log('total: ' + sortedParticipantsData[i].total)
                    if (sortedParticipantsData[i].total > 0) {
                      // var participantDataOutput = '<tr><td><a href="' + luminateExtend.global.path.nonsecure + 'TR/?fr_id=' + evID + '&pg=personal&px=' +    
                      //   + 'sortedParticipantsData[i].id'
                      //   + '">' 
                      //   + 'sortedParticipantsData[i].name'
                      //   + '</a></td><td><span class="pull-right">$'
                      //   + 'sortedParticipantsData[i].total.formatMoney(0)'
                      //   + '</span></td></tr>';
                      var teamData = ''
                      if (sortedParticipantsData[i].teamName.length > 0) {
                        teamData = '<a href="' + luminateExtend.global.path.secure + 'TR?team_id=' + sortedParticipantsData[i].teamId + '&pg=team&fr_id=' + evID + '">'+sortedParticipantsData[i].teamName+'</a>';
                      }

                      var participantDataOutput = '<div class="lc_Row1 list-row top-participant-list-row clearfix">'
                        + '<div class="top-participant-list-name">'
                          + '<a href="' + luminateExtend.global.path.secure + 'TR/?fr_id=' + evID + '&pg=personal&px=' + sortedParticipantsData[i].id
                          +  '">'+sortedParticipantsData[i].name
                        + '</div>'
                        + '<div class="top-participant-list-amount-container">'
                          + '<div class="top-participant-list-amount-label">Raised:</div>'
                          + '<div class="top-participant-list-amount">'+sortedParticipantsData[i].total.formatMoney(0)
                          +'</div>'
                        + '</div>'
                        + '<div class="top-participant-list-team">'
                          + teamData
                        + '</div>'
                      + '</div>';

                      $('#all_participant_list_container').append(participantDataOutput);
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

      allParticipantPromise.then(function() {
        console.log("allParticipantPromise then function?")
        // if( !$.trim( $('.insert_top-participants-list').html() ).length ) {
        //   partP = false;
        //   $('.top-participants-list').hide();
        // }
        // else {
        //   partP = true;
        //   $('#top_lists').show();
        //   $('.top-participants-list').show();
        // }
      }, function(err) {
        console.log(err);
      });

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




    if ($('body').is('.pg_teamlist')) {
      // Top team page JS goes here

      // get all teams
      var allTeamsPromise = new Promise(function(resolve, reject) {
        luminateExtend.api({
          api: 'teamraiser',
          data: 'method=getTeamsByInfo&fr_id=' + evID + '&response_format=json&list_sort_column=total&list_ascending=false&list_page_size=5',
          callback: {
            success: function (response) {
              console.log('allTeamsPromise success function')
              // if (!$.isEmptyObject(response.getTopTeamsDataResponse)) {
              //   var teamData = luminateExtend.utils.ensureArray(response.getTopTeamsDataResponse.teamraiserData);
              //   if (teamData.length > 0) {
              //     var sortedTeamsData = teamData.slice(0, 5);
              //     for (var i = 0, len = sortedTeamsData.length; i < len; i++) {
              //       sortedTeamsData[i].total = Number(sortedTeamsData[i].total.replace('$', '').replace(',', ''));
              //       if (sortedTeamsData[i].total > 0) {
              //         var teamsData = '<tr><td><a href="' + luminateExtend.global.path.nonsecure + 'TR/?pg=team&team_id=' + sortedTeamsData[i].id + '&fr_id=' + evID + '">' + sortedTeamsData[i].name + '</a></td><td><span class="pull-right">$' + sortedTeamsData[i].total.formatMoney(0) + '</span></td></tr>';
              //         $('.insert_top-teams-list').append(teamsData);
              //       }
              //     }
              //   }
              // }
              resolve();
            },
            error: function (response) {
              console.log('getTopTeams error: ' + response.errorResponse.message);
              reject(Error());
            }
          }
        });
      });

      allTeamsPromise.then(function() {
        console.log('all teams promise then')
      }, function(err) {
        console.log(err);
      });

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




  });
}(jQuery));
