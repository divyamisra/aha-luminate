angular.module 'trPageEditControllers'
  .controller 'NgPageEditMainCtrl', [
    '$rootScope'
    '$scope'
    '$location'
    '$compile'
    '$sce'
    '$uibModal'
    'APP_INFO'
    'TeamraiserRegistrationService'
    'TeamraiserParticipantPageService'
    'TeamraiserTeamPageService'
    'TeamraiserCompanyPageService'
    'TeamraiserSurveyResponseService'
    ($rootScope, $scope, $location, $compile, $sce, $uibModal, APP_INFO, TeamraiserRegistrationService, TeamraiserParticipantPageService, TeamraiserTeamPageService, TeamraiserCompanyPageService, TeamraiserSurveyResponseService) ->
      luminateExtend.api.getAuth()

      $embedRoot = angular.element '[data-embed-root]'
      editPage = $embedRoot.data 'edit-page'

      $scope.teamraiserAPIPath = $sce.trustAsResourceUrl $scope.securePath + 'CRTeamraiserAPI'

      $scope.textEditorToolbar = [
        [
          'h1'
          'h2'
          'h3'
          'p'
          'bold'
          'italics'
          'underline'
        ]
        [
          'ul'
          'ol'
          'justifyLeft'
          'justifyCenter'
          'justifyRight'
          'justifyFull'
          'indent'
          'outdent'
        ]
        [
          'insertImage'
          'insertLink'
          'undo'
          'redo'
        ]
      ]

      if editPage is 'personal'
        $scope.regSurvey = {}
        $scope.regSurveyString = ''
        TeamraiserSurveyResponseService.getSurveyResponses
          error: ->
            # TODO
          success: (response) ->
            surveyResponses = response.getSurveyResponsesResponse?.responses
            if not surveyResponses
              # TODO
            else
              surveyResponses = [surveyResponses] if not angular.isArray surveyResponses
              angular.forEach surveyResponses, (surveyResponse) ->
                if not surveyResponse.responseValue or surveyResponse.responseValue is 'User Provided No Response' or not angular.isString surveyResponse.responseValue
                  surveyResponse.responseValue = ''
                if surveyResponse.key and surveyResponse.key is 'what_is_why' or surveyResponse.key is 'clear_hw_id'
                  # TODO
                else
                  $scope.regSurveyString += '&question_' + surveyResponse.questionId + '=' + surveyResponse.responseValue
              $scope.regSurvey = surveyResponses

        TeamraiserRegistrationService.getRegistration
          error: ->
            # TODO
          success: (response) ->
            $scope.registration = response.getRegistrationResponse?.registration

        $personalPhoto2 = angular.element '.kd-user-cover__bg'

        # make cover photo dynamic
        $scope.setPersonalPhoto2Url = (photoUrl) ->
          defaultPhotoUrl = angular.element('.kd-user-cover__bg').attr('data-defaultphoto') or ''
          $scope.personalPhoto2Url = photoUrl or defaultPhotoUrl
          if defaultPhotoUrl isnt ''
            $scope.personalPhoto2IsDefault = $scope.personalPhoto2Url.indexOf(defaultPhotoUrl.replace('..', '')) isnt -1
          if not $scope.$$phase
            $scope.$apply()
        if $personalPhoto2.css('background-image') and $personalPhoto2.css('background-image').indexOf('(') isnt -1
          $scope.setPersonalPhoto2Url $personalPhoto2.css('background-image').split('(')[1].split(')')[0]
          $personalPhoto2.replaceWith $compile($personalPhoto2.clone().attr('ng-style', "{'background-image': 'url(' + personalPhoto2Url + ')'}"))($scope)
          $personalPhoto2 = angular.element '.kd-user-cover__bg'

        # insert cover photo edit button
        $scope.editPersonalPhoto2 = ->
          $scope.editPersonalPhoto2Modal = $uibModal.open
            scope: $scope
            templateUrl: APP_INFO.rootPath + 'dist/heart-walk/html/page-edit/modal/editPersonalPhoto2.html'
        $scope.closePersonalPhoto2Modal = ->
          if $scope.editPersonalPhoto2Modal
            $scope.editPersonalPhoto2Modal.close()
          $scope.setPersonalPhoto2Error()
          if not $scope.$$phase
            $scope.$apply()
        $scope.deletePersonalPhoto2 = ($event) ->
          if $event
            $event.preventDefault()
          angular.element('.js--delete-personal-photo-2-form').submit()
          false
        $scope.cancelEditPersonalPhoto2 = ->
          $scope.closePersonalPhoto2Modal()
        $scope.setPersonalPhoto2Error = (errorMessage) ->
          if not errorMessage and $scope.updatePersonalPhoto2Error
            delete $scope.updatePersonalPhoto2Error
          $scope.updatePersonalPhoto2Error =
            message: errorMessage
          if not $scope.$$phase
            $scope.$apply()
        $personalPhoto2.append $compile('<button type="button" class="btn btn-primary-inverted btn-raised" ng-click="editPersonalPhoto2()"><span class="glyphicon glyphicon-camera"></span> Edit Cover Photo</button>')($scope)

        $personalPhoto1 = angular.element '.heart-user-image-wrap--personal'

        # make photo dynamic
        $scope.setPersonalPhoto1Url = (photoUrl) ->
          $scope.personalPhoto1Url = photoUrl
          if not $scope.$$phase
            $scope.$apply()
        angular.forEach $personalPhoto1, (photoContainer) ->
          $personalPhoto = angular.element(photoContainer).find('img')
          $personalPhotoSrc = $personalPhoto.attr 'src'
          if $personalPhotoSrc and $personalPhotoSrc isnt ''
            $scope.setPersonalPhoto1Url $personalPhotoSrc
          $personalPhoto.replaceWith $compile($personalPhoto.clone().attr('ng-src', '{{personalPhoto1Url}}'))($scope)

        # insert photo edit button
        $scope.editPersonalPhoto1 = ->
          $scope.editPersonalPhoto1Modal = $uibModal.open
            scope: $scope
            templateUrl: APP_INFO.rootPath + 'dist/heart-walk/html/page-edit/modal/editPersonalPhoto1.html'
        $scope.closePersonalPhoto1Modal = ->
          if $scope.editPersonalPhoto1Modal
            $scope.editPersonalPhoto1Modal.close()
          $scope.setPersonalPhoto1Error();
          if not $scope.$$phase
            $scope.$apply()
        $scope.deletePersonalPhoto1 = ($event) ->
          if $event
            $event.preventDefault()
          angular.element('.js--delete-personal-photo-1-form').submit()
          false
        $scope.cancelEditPersonalPhoto1 = ->
          $scope.closePersonalPhoto1Modal()
        $scope.setPersonalPhoto1Error = (errorMessage) ->
          if not errorMessage and $scope.updatePersonalPhoto1Error
            delete $scope.updatePersonalPhoto1Error
          $scope.updatePersonalPhoto1Error =
            message: errorMessage
          if not $scope.$$phase
            $scope.$apply()
        $personalPhoto1.find('.heart-user-image-wrap-inner').prepend $compile('<button type="button" class="btn btn-primary-inverted btn-raised" ng-click="editPersonalPhoto1()" id="edit_personal_photo"><span class="glyphicon glyphicon-camera"></span> Edit Photo</button>')($scope)

        $personalHeader = angular.element '.kd-user-story__headline'
        $personalHeadline = $personalHeader.find '> h2'

        # make headline dynamica
        $scope.personalHeadline = $personalHeadline.text()
        $personalHeadline.replaceWith $compile($personalHeadline.clone().attr('ng-class', '{"hidden": personalHeadlineOpen}').html('{{personalHeadline}}'))($scope)

        # insert headline edit button
        $scope.editPersonalHeadline = ->
          $scope.prevPersonalHeadline = $scope.personalHeadline
          $scope.personalHeadlineOpen = true
        $personalHeader.prepend $compile('<button type="button" class="btn btn-primary-inverted btn-raised" ng-class="{\'hidden\': personalHeadlineOpen}" ng-click="editPersonalHeadline()"><span class="glyphicon glyphicon-pencil"></span> Edit Headline</button>')($scope)

        # insert headline form
        closePersonalHeadline = ->
          $scope.personalHeadlineOpen = false
          if not $scope.$$phase
            $scope.$apply()
        $scope.cancelEditPersonalHeadline = ->
          $scope.personalHeadline = $scope.prevPersonalHeadline
          closePersonalHeadline()
        $scope.updatePersonalHeadline = ->
          TeamraiserParticipantPageService.updatePersonalPageInfo 'page_title=' + $scope.personalHeadline,
            error: (response) ->
              # TODO
            success: (response) ->
              closePersonalHeadline()
        $personalHeader.append $compile('<form method="POST" novalidate ng-class="{\'hidden\': !personalHeadlineOpen}" ng-submit="updatePersonalHeadline()"><button type="button" class="btn btn-primary-inverted btn-raised" ng-click="cancelEditPersonalHeadline()">Cancel</button> <button type="submit" class="btn btn-primary btn-raised">Save</button><h2><input type="text" class="form-control" ng-model="personalHeadline"></h2></form>')($scope)

        $personalVideo = angular.element '.heart-user-video--personal'
        $scope.fr_id = $rootScope.frId;
        # make video dynamic
        $scope.personalMedia = {}
        $scope.personalVideo = {}
        $scope.personalizedVideoObj = {}
        $scope.setPersonalVideoUrl = (videoUrl) ->
          angular.forEach $personalVideo, (videoContainer) ->
            $personalVideoIframe = angular.element(videoContainer).find('iframe')
            $personalVideoIframe.css('opacity','1')
            if $scope.personalVideoEmbedUrl isnt ''
              $personalVideoIframe.replaceWith $compile($personalVideoIframe.clone().attr('ng-src', '{{personalVideoEmbedUrl}}'))($scope)
          if videoUrl and videoUrl.indexOf('vidyard') is -1
            videoUrl = videoUrl.replace '&amp;v=', '&v='
            videoId = ''
            if videoUrl.indexOf('?v=') isnt -1
              videoId = videoUrl.split('?v=')[1].split('&')[0]
            else if videoUrl.indexOf('&v=') isnt -1
              videoId = videoUrl.split('&v=')[1].split('&')[0]
            else if videoUrl.indexOf('/embed/') isnt -1
              videoId = videoUrl.split('/embed/')[1].split('/')[0].split('?')[0]
            else if videoUrl.indexOf('youtu.be/') isnt -1
              videoId = videoUrl.split('youtu.be/')[1].split('/')[0].split('?')[0]
            if videoId isnt ''
              $scope.personalMedia.videoUrl = 'http://youtube.com/watch?v=' + videoId
              $scope.personalVideoEmbedUrl = $sce.trustAsResourceUrl '//www.youtube.com/embed/' + videoId + '?wmode=opaque&amp;rel=0&amp;showinfo=0'
          if not $scope.$$phase
            $scope.$apply()
        angular.forEach $personalVideo, (videoContainer) ->
          $personalVideoIframe = angular.element(videoContainer).find('iframe')
          $personalVideoSrc = $personalVideoIframe.attr 'src'
          $personalVideoIframe.css('opacity','1')
          if $personalVideoSrc and $personalVideoSrc isnt ''
            $scope.setPersonalVideoUrl $personalVideoSrc
          $personalVideoIframe.replaceWith $compile($personalVideoIframe.clone().attr('ng-src', '{{personalVideoEmbedUrl}}'))($scope)
        # insert edit video button
        $scope.editPersonalVideo = ->
          $scope.editPersonalVideoModal = $uibModal.open
            scope: $scope
            templateUrl: APP_INFO.rootPath + 'dist/heart-walk/html/page-edit/modal/editPersonalVideo.html'
        $scope.closePersonalVideoModal = ->
          if $scope.editPersonalVideoModal
            $scope.editPersonalVideoModal.close()
          $scope.setPersonalVideoError();
          if not $scope.$$phase
            $scope.$apply()
        $scope.cancelEditPersonalVideo = ->
          $scope.closePersonalVideoModal()
        $scope.setPersonalVideoError = (errorMessage) ->
          if not errorMessage and $scope.updatePersonalVideoError
            delete $scope.updatePersonalVideoError
          $scope.updatePersonalVideoError =
            message: errorMessage
        $scope.updatePersonalVideo = ->
          if $scope.personalVideo.type is 'youtube'
            angular.element('.js--remove-personalized-video-form').submit()
            TeamraiserParticipantPageService.updatePersonalVideoUrl 'video_url=' + $scope.personalMedia.videoUrl,
              error: (response) ->
                $scope.setPersonalVideoError response.errorResponse.message
              success: (response) ->
                videoUrl = response.updatePersonalVideoUrlResponse?.videoUrl
                $scope.setPersonalVideoUrl videoUrl
                $scope.closePersonalVideoModal()
          else if $scope.personalVideo.type is 'personalized'
            TeamraiserParticipantPageService.updatePersonalVideoUrl 'video_url=http://www.youtube.com/'
            formData = { auth_token: "Jep8QrDjpqwOnI5rpsAbJw", email: $rootScope.email, fields: {firstname: $rootScope.firstName, why: $scope.personalMedia.myWhy, cons_id: $rootScope.consId} }
            $scope.submitVidyardCallback = (data) ->
              jQuery.ajax 'http://hearttools.heart.org/vidyard/vy_pv_callback_to_bb.php',
                type: 'POST'
                data: JSON.stringify( { uuid: data.unit.uuid, cons_id: $rootScope.consId } ),
                contentType: 'application/json',
                dataType: 'json',
                success: (data) ->
                  # TODO
            $scope.submitVidyard = ->
              jQuery.ajax 'http://blender.vidyard.com/forms/pd5MsBtKJwfrReeWz7d8v4/submit.json',
                type: 'POST'
                data: JSON.stringify( { auth_token: "Jep8QrDjpqwOnI5rpsAbJw", email: $rootScope.email, fields: {firstname: $rootScope.firstName, why: $scope.personalMedia.myWhy, cons_id: '"' + $rootScope.consId + '"'} } ),
                contentType: 'application/json',
                dataType: 'json',
                success: (response) ->
                  $scope.submitVidyardCallback response
            $scope.submitVidyard()
            angular.element('.js--submit-personalized-video-LO-form').submit()
            setTimeout ( ->
              $scope.closePersonalVideoModal()
            ), 500

          else if $scope.personalVideo.type is 'default'
            angular.element('.js--remove-personalized-video-form').submit()
            TeamraiserParticipantPageService.updatePersonalVideoUrl 'video_url=http://www.youtube.com/'
            setTimeout ( ->
              $scope.closePersonalVideoModal()
              window.location.href = 'http://' + $location.$$host + '/site/TR?fr_id=' + $scope.frId + '&pg=personal&px=' + $rootScope.consId
            ), 500
        $personalVideo.find('.heart-user-video-inner').prepend $compile('<button type="button" class="btn btn-primary-inverted btn-raised" ng-click="editPersonalVideo()" id="edit_personal_video"><span class="glyphicon glyphicon-facetime-video"></span> Edit Video</button>')($scope)

        $personalTextContainer = angular.element '.heart-page-story--personal #fr_rich_text_container'

        # make content dynamic
        $scope.personalContent = $personalTextContainer.html()
        $scope.ng_personalContent = $personalTextContainer.html()
        $personalTextContainer.html $compile('<div ng-class="{\'hidden\': personalContentOpen}" ng-bind-html="personalContent"></div>')($scope)

        # insert content edit button
        $scope.editPersonalContent = ->
          $scope.prevPersonalContent = $scope.personalContent
          $scope.personalContentOpen = true
        $personalTextContainer.prepend $compile('<div class="form-group"><button type="button" class="btn btn-primary btn-raised" ng-class="{\'hidden\': personalContentOpen}" ng-click="editPersonalContent()" id="edit_personal_story"><span class="glyphicon glyphicon-pencil"></span> Edit Story</button></div>')($scope)

        # insert content form
        closePersonalContent = ->
          $scope.personalContentOpen = false
          if not $scope.$$phase
            $scope.$apply()
        $scope.cancelEditPersonalContent = ->
          $scope.personalContent = $scope.prevPersonalContent
          closePersonalContent()
          $scope.ng_personalContent = $scope.prevPersonalContent
        $scope.updatePersonalContent = ->
          richText = $scope.ng_personalContent
          $richText = jQuery '<div />',
            html: richText
          richText = $richText.html()
          richText = richText.replace /<\/?[A-Z]+.*?>/g, (m) ->
            m.toLowerCase()
          .replace(/<font>/g, '<span>').replace(/<font /g, '<span ').replace /<\/font>/g, '</span>'
          .replace(/<b>/g, '<strong>').replace(/<b /g, '<strong ').replace /<\/b>/g, '</strong>'
          .replace(/<i>/g, '<em>').replace(/<i /g, '<em ').replace /<\/i>/g, '</em>'
          .replace(/<u>/g, '<span style="text-decoration: underline;">').replace(/<u /g, '<span style="text-decoration: underline;" ').replace /<\/u>/g, '</span>'
          .replace /[\u00A0-\u9999\&]/gm, (i) ->
            '&#' + i.charCodeAt(0) + ';'
          .replace /&#38;/g, '&'
          .replace /<!--[\s\S]*?-->/g, ''
          TeamraiserParticipantPageService.updatePersonalPageInfo 'rich_text=' + encodeURIComponent(richText),
            error: (response) ->
              # TODO
            success: (response) ->
              success = response.updatePersonalPageResponse?.success
              if not success or success isnt 'true'
                # TODO
              else
                $scope.personalContent = richText
                closePersonalContent()
        $personalTextContainer.append $compile('<form method="POST" novalidate ng-class="{\'hidden\': !personalContentOpen}" ng-submit="updatePersonalContent()"><div class="form-group"><button type="button" class="btn btn-primary-inverted btn-raised" ng-click="cancelEditPersonalContent()">Cancel</button> <button type="submit" class="btn btn-primary btn-raised">Save</button></div><div class="form-group"><div text-angular ng-model="ng_personalContent" ta-toolbar="{{textEditorToolbar}}" ta-text-editor-class="border-around" ta-html-editor-class="border-around"></div></div></form>')($scope)

      else if editPage is 'team'
        $teamPhoto1 = angular.element '.heart-user-image-wrap--team'

        # make photo dynamic
        $scope.setTeamPhoto1Url = (photoUrl) ->
          $scope.teamPhoto1Url = photoUrl
          if not $scope.$$phase
            $scope.$apply()
        angular.forEach $teamPhoto1, (photoContainer) ->
          $teamPhoto = angular.element(photoContainer).find('img')
          $teamPhotoSrc = $teamPhoto.attr 'src'
          if $teamPhotoSrc and $teamPhotoSrc isnt ''
            $scope.setTeamPhoto1Url $teamPhotoSrc
          $teamPhoto.replaceWith $compile($teamPhoto.clone().attr('ng-src', '{{teamPhoto1Url}}'))($scope)

        # insert photo edit button
        $scope.editTeamPhoto1 = ->
          $scope.editTeamPhoto1Modal = $uibModal.open
            scope: $scope
            templateUrl: APP_INFO.rootPath + 'dist/heart-walk/html/page-edit/modal/editTeamPhoto1.html'
        $scope.closeTeamPhoto1Modal = ->
          if $scope.editTeamPhoto1Modal
            $scope.editTeamPhoto1Modal.close()
          $scope.setTeamPhoto1Error();
          if not $scope.$$phase
            $scope.$apply()
        $scope.deleteTeamPhoto1 = ($event) ->
          if $event
            $event.preventDefault()
          angular.element('.js--delete-team-photo-1-form').submit()
          false
        $scope.cancelEditTeamPhoto1 = ->
          $scope.closeTeamPhoto1Modal()
        $scope.setTeamPhoto1Error = (errorMessage) ->
          if not errorMessage and $scope.updateTeamPhoto1Error
            delete $scope.updateTeamPhoto1Error
          $scope.updateTeamPhoto1Error =
            message: errorMessage
          if not $scope.$$phase
            $scope.$apply()
        $teamPhoto1.find('.heart-user-image-wrap-inner').prepend $compile('<button type="button" class="btn btn-primary-inverted btn-raised" ng-click="editTeamPhoto1()" id="edit_team_photo"><span class="glyphicon glyphicon-camera"></span> Edit Photo</button>')($scope)

        $teamPageTextContainer = angular.element '.heart-page-story--team #fr_rich_text_container'

        # make content dynamic
        $scope.teamContent = $teamPageTextContainer.html()
        $scope.ng_teamContent = $teamPageTextContainer.html()
        $teamPageTextContainer.html $compile('<div ng-class="{\'hidden\': teamContentOpen}" ng-bind-html="teamContent"></div>')($scope)

        # insert content edit button
        $scope.editTeamContent = ->
          $scope.prevTeamContent = $scope.teamContent
          $scope.teamContentOpen = true
        $teamPageTextContainer.prepend $compile('<div class="form-group"><button type="button" class="btn btn-primary btn-raised" ng-class="{\'hidden\': teamContentOpen}" ng-click="editTeamContent()" id="edit_team_story"><span class="glyphicon glyphicon-pencil"></span> Edit Story</button></div>')($scope)

        # insert content form
        closeTeamContent = ->
          $scope.teamContentOpen = false
          if not $scope.$$phase
            $scope.$apply()
        $scope.cancelEditTeamContent = ->
          $scope.teamContent = $scope.prevTeamContent
          closeTeamContent()
          $scope.ng_teamContent = $scope.prevTeamContent
        $scope.updateTeamContent = ->
          richText = $scope.ng_teamContent
          $richText = jQuery '<div />',
            html: richText
          richText = $richText.html()
          richText = richText.replace /<\/?[A-Z]+.*?>/g, (m) ->
            m.toLowerCase()
          .replace(/<font>/g, '<span>').replace(/<font /g, '<span ').replace /<\/font>/g, '</span>'
          .replace(/<b>/g, '<strong>').replace(/<b /g, '<strong ').replace /<\/b>/g, '</strong>'
          .replace(/<i>/g, '<em>').replace(/<i /g, '<em ').replace /<\/i>/g, '</em>'
          .replace(/<u>/g, '<span style="text-decoration: underline;">').replace(/<u /g, '<span style="text-decoration: underline;" ').replace /<\/u>/g, '</span>'
          .replace /[\u00A0-\u9999\&]/gm, (i) ->
            '&#' + i.charCodeAt(0) + ';'
          .replace /&#38;/g, '&'
          .replace /<!--[\s\S]*?-->/g, ''
          TeamraiserTeamPageService.updateTeamPageInfo 'rich_text=' + encodeURIComponent(richText),
            error: (response) ->
              # TODO
            success: (response) ->
              success = response.updateTeamPageResponse?.success
              if not success or success isnt 'true'
                # TODO
              else
                $scope.teamContent = richText
                closeTeamContent()
        $teamPageTextContainer.append $compile('<form method="POST" novalidate ng-class="{\'hidden\': !teamContentOpen}" ng-submit="updateTeamContent()"><div class="form-group"><button type="button" class="btn btn-primary-inverted btn-raised" ng-click="cancelEditTeamContent()">Cancel</button> <button type="submit" class="btn btn-primary btn-raised">Save</button></div><div class="form-group"><div text-angular ng-model="ng_teamContent" ta-toolbar="{{textEditorToolbar}}" ta-text-editor-class="border-around" ta-html-editor-class="border-around"></div></div></form>')($scope)

      else if editPage is 'company'
        $scope.companyId = $location.absUrl().split('company_id=')[1].split('&')[0]

        TeamraiserRegistrationService.getRegistration
          error: ->
            # TODO
          success: (response) ->
            registration = response.getRegistrationResponse?.registration
            if registration
              companyInformation = registration?.companyInformation
              if companyInformation?.companyId is $scope.companyId and companyInformation?.isCompanyCoordinator is 'true'
                $companyPhoto1 = angular.element '.heart-user-image-wrap--company'

                # make photo dynamic
                $scope.setCompanyPhoto1Url = (photoUrl) ->
                  $scope.companyPhoto1Url = photoUrl
                  if not $scope.$$phase
                    $scope.$apply()
                angular.forEach $companyPhoto1, (photoContainer) ->
                  $companyPhoto = angular.element(photoContainer).find('img')
                  $companyPhotoSrc = $companyPhoto.attr 'src'
                  if $companyPhotoSrc and $companyPhotoSrc isnt ''
                    $scope.setCompanyPhoto1Url $companyPhotoSrc
                  $companyPhoto.replaceWith $compile($companyPhoto.clone().attr('ng-src', '{{companyPhoto1Url}}'))($scope)

                # insert photo edit button
                $scope.editCompanyPhoto1 = ->
                  $scope.editCompanyPhoto1Modal = $uibModal.open
                    scope: $scope
                    templateUrl: APP_INFO.rootPath + 'dist/heart-walk/html/page-edit/modal/editCompanyPhoto1.html'
                $scope.closeCompanyPhoto1Modal = ->
                  if $scope.editCompanyPhoto1Modal
                    $scope.editCompanyPhoto1Modal.close()
                  $scope.setCompanyPhoto1Error();
                  if not $scope.$$phase
                    $scope.$apply()
                $scope.deleteCompanyPhoto1 = ($event) ->
                  if $event
                    $event.preventDefault()
                  angular.element('.js--delete-company-photo-1-form').submit()
                  false
                $scope.cancelEditCompanyPhoto1 = ->
                  $scope.closeCompanyPhoto1Modal()
                $scope.setCompanyPhoto1Error = (errorMessage) ->
                  if not errorMessage and $scope.updateCompanyPhoto1Error
                    delete $scope.updateCompanyPhoto1Error
                  $scope.updateCompanyPhoto1Error =
                    message: errorMessage
                  if not $scope.$$phase
                    $scope.$apply()
                $companyPhoto1.find('.heart-user-image-wrap-inner').prepend $compile('<button type="button" class="btn btn-primary-inverted btn-raised" ng-click="editCompanyPhoto1()" id="edit_company_photo"><span class="glyphicon glyphicon-camera"></span> Edit Photo</button>')($scope)

                $companyPageTextContainer = angular.element '.heart-page-story--company #fr_rich_text_container'

                # make content dynamic
                $scope.companyContent = $companyPageTextContainer.html()
                $scope.ng_companyContent = $companyPageTextContainer.html()
                $companyPageTextContainer.html $compile('<div ng-class="{\'hidden\': companyContentOpen}" ng-bind-html="companyContent"></div>')($scope)

                # insert content edit button
                $scope.editCompanyContent = ->
                  $scope.prevCompanyContent = $scope.companyContent
                  $scope.companyContentOpen = true
                $companyPageTextContainer.prepend $compile('<div class="form-group"><button type="button" class="btn btn-primary btn-raised" ng-class="{\'hidden\': companyContentOpen}" ng-click="editCompanyContent()" id="edit_company_story"><span class="glyphicon glyphicon-pencil"></span> Edit Story</button></div>')($scope)

                # insert content form
                closeCompanyContent = ->
                  $scope.companyContentOpen = false
                  if not $scope.$$phase
                    $scope.$apply()
                $scope.cancelEditCompanyContent = ->
                  $scope.companyContent = $scope.prevCompanyContent
                  closeCompanyContent()
                  $scope.ng_companyContent = $scope.prevCompanyContent
                $scope.updateCompanyContent = ->
                  richText = $scope.ng_companyContent
                  $richText = jQuery '<div />',
                    html: richText
                  richText = $richText.html()
                  richText = richText.replace /<\/?[A-Z]+.*?>/g, (m) ->
                    m.toLowerCase()
                  .replace(/<font>/g, '<span>').replace(/<font /g, '<span ').replace /<\/font>/g, '</span>'
                  .replace(/<b>/g, '<strong>').replace(/<b /g, '<strong ').replace /<\/b>/g, '</strong>'
                  .replace(/<i>/g, '<em>').replace(/<i /g, '<em ').replace /<\/i>/g, '</em>'
                  .replace(/<u>/g, '<span style="text-decoration: underline;">').replace(/<u /g, '<span style="text-decoration: underline;" ').replace /<\/u>/g, '</span>'
                  .replace /[\u00A0-\u9999\&]/gm, (i) ->
                    '&#' + i.charCodeAt(0) + ';'
                  .replace /&#38;/g, '&'
                  .replace /<!--[\s\S]*?-->/g, ''
                  TeamraiserCompanyPageService.updateCompanyPageInfo 'rich_text=' + encodeURIComponent(richText),
                    error: (response) ->
                      # TODO
                    success: (response) ->
                      success = response.updateCompanyPageResponse?.success
                      if not success or success isnt 'true'
                        # TODO
                      else
                        $scope.companyContent = richText
                        closeCompanyContent()
                $companyPageTextContainer.append $compile('<form method="POST" novalidate ng-class="{\'hidden\': !companyContentOpen}" ng-submit="updateCompanyContent()"><div class="form-group"><button type="button" class="btn btn-primary-inverted btn-raised" ng-click="cancelEditCompanyContent()">Cancel</button> <button type="submit" class="btn btn-primary btn-raised">Save</button></div><div class="form-group"><div text-angular ng-model="ng_companyContent" ta-toolbar="{{textEditorToolbar}}" ta-text-editor-class="border-around" ta-html-editor-class="border-around"></div></div></form>')($scope)

      window.trPageEdit =
        uploadPhotoError: (response) ->
          errorResponse = response.errorResponse
          photoType = errorResponse.photoType
          photoNumber = errorResponse.photoNumber
          errorCode = errorResponse.code
          errorMessage = errorResponse.message

          if photoType is 'personal'
            if photoNumber is '1'
              $scope.setPersonalPhoto1Error errorMessage
            else if photoNumber is '2'
              $scope.setPersonalPhoto2Error errorMessage

          else if photoType is 'team'
            if photoNumber is '1'
              $scope.setTeamPhoto1Error errorMessage

          else if photoType is 'company'
            if photoNumber is '1'
              $scope.setCompanyPhoto1Error errorMessage
        uploadPhotoSuccess: (response) ->
          successResponse = response.successResponse
          photoType = successResponse.photoType
          photoNumber = successResponse.photoNumber

          if photoType is 'personal'
            TeamraiserParticipantPageService.getPersonalPhotos
              error: (response) ->
                # TODO
              success: (response) ->
                photoItems = response.getPersonalPhotosResponse?.photoItem
                if photoItems
                  photoItems = [photoItems] if not angular.isArray photoItems
                  angular.forEach photoItems, (photoItem) ->
                    photoUrl = photoItem.customUrl
                    if photoItem.id is '1'
                      $scope.setPersonalPhoto1Url photoUrl
                    else if photoItem.id is '2'
                      $scope.setPersonalPhoto2Url photoUrl
                $scope.closePersonalPhoto1Modal()
                $scope.closePersonalVideoModal()
                $scope.closePersonalPhoto2Modal()

          else if photoType is 'team'
            TeamraiserTeamPageService.getTeamPhoto
              error: (response) ->
                # TODO
              success: (response) ->
                photoItems = response.getTeamPhotoResponse?.photoItem
                if photoItems
                  photoItems = [photoItems] if not angular.isArray photoItems
                  angular.forEach photoItems, (photoItem) ->
                    photoUrl = photoItem.customUrl
                    if photoItem.id is '1'
                      $scope.setTeamPhoto1Url photoUrl
                $scope.closeTeamPhoto1Modal()

          else if photoType is 'company'
            TeamraiserCompanyPageService.getCompanyPhoto
              error: (response) ->
                # TODO
              success: (response) ->
                photoItems = response.getCompanyPhotoResponse?.photoItem
                if photoItems
                  photoItems = [photoItems] if not angular.isArray photoItems
                  angular.forEach photoItems, (photoItem) ->
                    photoUrl = photoItem.customUrl
                    if photoItem.id is '1'
                      $scope.setCompanyPhoto1Url photoUrl
                $scope.closeCompanyPhoto1Modal()

      getParameterByName = (name, url) ->
        if !url
          url = $location.absUrl()
        name = name.replace(/[\[\]]/g, '\\$&')
        regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)')
        results = regex.exec(url)
        if !results
          return null
        if !results[2]
          return ''
        decodeURIComponent results[2].replace(/\+/g, ' ')
      videoWhy = getParameterByName('videoWhy');
      if videoWhy is 'true'
        $scope.editPersonalVideo()
  ]
