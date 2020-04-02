angular.module 'ahaLuminateApp'
  .factory 'SchoolSearchService', [
    '$filter'
    'TeamraiserCompanyService'
    'SchoolLookupService'
    ($filter, TeamraiserCompanyService, SchoolLookupService) ->
      init: ($scope, eventType, getLoc) ->
        $scope.schoolList =
          searchSubmitted: false
          searchPending: false
          searchByLocation: false
          geoLocationEnabled: false
          sortProp: 'SCHOOL_NAME'
          sortDesc: false
          totalItems: 0
          currentPage: 1
          paginationItemsPerPage: 5
          paginationMaxSize: 5
          nameFilter: ''
          ng_nameFilter: ''
          stateFilter: ''
          showHelp: false
        $scope.schoolListByState = {}
        $scope.schoolDataMap = {}
        $scope.schoolDataMapByState = {}
        $scope.searchError = false;
        
        #
        # New Geo Locate code for KHC
        filterGeoSchoolData = (e) ->
          SchoolLookupService.getStateByLocation e,
            failure: (response) ->
            success: (response) ->
              delete $scope.schoolList.schools
              $scope.schoolList.stateFilter = response.data.company.schoolData.state
              $scope.schoolList.searchPending = true
              $scope.schoolList.searchSubmitted = true
              $scope.schoolList.searchByLocation = true
              $scope.schoolList.geoLocationEnabled = true
              $scope.getSchoolSearchResults(true)
              #SchoolLookupService.getGeoSchoolData e,
              #  failure: (response) ->
              #  success: (response) ->
              #    showSchoolSearchResults(response)

        # gelocate call error
        showGEOError = (e) ->
          $scope.schoolList.searchPending = false
          switch e.code
            when e.PERMISSION_DENIED
              $scope.schoolList.searchErrorMessage = 'User denied the request for Geolocation or not in https. Try Again.'
            when e.POSITION_UNAVAILABLE
              $scope.schoolList.searchErrorMessage = 'Location information is currently unavailable. Try Again.'
            when e.TIMEOUT
              $scope.schoolList.searchErrorMessage = 'The request to get location timed out. Please refresh the page to use this feature.'
            when e.UNKNOWN_ERROR
              $scope.schoolList.searchErrorMessage = 'An unknown error occurred. Try Again.'
          return

        # ask or retrieve current lat/long
        $scope.getLocation = ->
          e = 
            enableHighAccuracy: !0
            timeout: 1e4
            maximumAge: 'infinity'
          if navigator.geolocation then navigator.geolocation.getCurrentPosition(filterGeoSchoolData, showGEOError, e) else console.log('Geolocation is not supported by this browser.')
          return

        # if getLoc is passed as true
        # ask for geolocation and load all schools within 10 miles of geolocation
        if getLoc is true
           $scope.schoolList.geoLocationEnabled = true
        #  $scope.getLocation()
        
        $scope.filterByLocation = ->
          nameFilter = jQuery.trim $scope.schoolList.ng_nameFilter
          $scope.schoolList.nameFilter = nameFilter
          if not nameFilter
            $scope.schoolList.searchErrorMessage = 'Please specify a search criteria before initiating a search.'
          else
            delete $scope.schoolList.searchErrorMessage
            $scope.schoolList.searchPending = true
            $scope.schoolList.searchSubmitted = true
            $scope.schoolList.searchByLocation = true
            getLocation()
        
        #get school data with getSchoolDataNew service call
        $scope.getSchoolSearchResultsNew = ->
          delete $scope.schoolList.schools
          $scope.schoolList.searchPending = true
          $scope.schoolList.currentPage = 1
          nameFilter = $scope.schoolList.nameFilter or '%'
          stateFilter = ''
          if $scope.schoolList.stateFilter isnt ''
            stateFilter = $scope.schoolList.stateFilter
          SchoolLookupService.getSchoolDataNew '&name=' + encodeURIComponent(nameFilter) + '&state=' + encodeURIComponent(stateFilter),
            failure: (response) ->
            success: (response) ->
              showSchoolSearchResults(response)

        #display school date retrieved
        showSchoolSearchResults = (response) ->
              totalNumberResults = 0
              schoolDataRows = response.data.company.schoolData
              schools = []
              angular.forEach schoolDataRows, (schoolDataRow, schoolDataRowIndex) ->
                totalNumberResults++
                schools.push
                  FR_ID: schoolDataRow['fr_id']
                  SCHOOL_NAME: schoolDataRow['name']
                  SCHOOL_ID: schoolDataRow['school_id']
                  COMPANY_ID: schoolDataRow['school_id']
                  SCHOOL_CITY: schoolDataRow['city']
                  SCHOOL_STATE: schoolDataRow['state']
                  COORDINATOR_FIRST_NAME: schoolDataRow['coord_first']
                  COORDINATOR_LAST_NAME: schoolDataRow['coord_last']
              $scope.schoolList.totalNumberResults = totalNumberResults
              $scope.schoolList.totalItems = totalNumberResults
              $scope.schoolList.schools = schools
              # setResults()
              $scope.schoolList.searchSubmitted = true
              delete $scope.schoolList.searchPending
              updateCompanyData()

        # run search when submit button clicked
        $scope.submitSchoolSearchNew = ->
          nameFilter = jQuery.trim $scope.schoolList.ng_nameFilter
          $scope.schoolList.nameFilter = nameFilter
          $scope.schoolList.stateFilter = ''
          $scope.schoolList.searchSubmitted = true
          $scope.schoolList.searchByLocation = false
          # if not nameFilter or nameFilter.length < 3
          if false
            $scope.schoolList.searchErrorMessage = 'Please enter at least 3 characters to search for.'
          else
            delete $scope.schoolList.searchErrorMessage
            $scope.getSchoolSearchResultsNew()
        # END new Geo locate code for KHC

        #
        # New Alt Geo Locate code for KHC to get state
        getSchoolState = (e) ->
          $scope.schoolList.geoLocationEnabled = true
          SchoolLookupService.getGeoState(e)
            .then (response) ->
              $scope.schoolList.stateFilter = stateFilter = response.data.results[0].address_components[4].short_name
              SchoolLookupService.getSchoolDataByState(stateFilter)
                .then (response) ->
                  schoolDataRows = response.data.getSchoolSearchDataResponse.schoolData
                  schoolDataHeaders = {}
                  schoolDataMapByState = {}
                  angular.forEach schoolDataRows[0], (schoolDataHeader, schoolDataHeaderIndex) ->
                    schoolDataHeaders[schoolDataHeader] = schoolDataHeaderIndex
                  angular.forEach schoolDataRows, (schoolDataRow, schoolDataRowIndex) ->
                    if schoolDataRowIndex > 0
                      schoolDataMapByState['id' + schoolDataRow[schoolDataHeaders.COMPANY_ID]] =
                        SCHOOL_CITY: schoolDataRow[schoolDataHeaders.SCHOOL_CITY]
                        SCHOOL_STATE: schoolDataRow[schoolDataHeaders.SCHOOL_STATE]
                        COORDINATOR_FIRST_NAME: schoolDataRow[schoolDataHeaders.COORDINATOR_FIRST_NAME]
                        COORDINATOR_LAST_NAME: schoolDataRow[schoolDataHeaders.COORDINATOR_LAST_NAME]
          
                  $scope.schoolDataMapByState = schoolDataMapByState
                  $scope.getSchoolSearchResults(true)

        # ask or retrieve current lat/long
        $scope.getLocationAlt = ->
          $scope.schoolList.searchSubmitted = true
          nameFilter = jQuery.trim $scope.schoolList.ng_nameFilter
          $scope.schoolList.nameFilter = nameFilter
          if not nameFilter
            $scope.schoolList.searchErrorMessage = 'Please specify a search criteria before initiating a search.'
          else
            delete $scope.schoolList.searchErrorMessage
            $scope.schoolList.searchPending = true
            $scope.schoolList.searchByLocation = true
            e = 
              enableHighAccuracy: !0
              timeout: 1e4
              maximumAge: 'infinity'
            if navigator.geolocation then navigator.geolocation.getCurrentPosition(filterGeoSchoolData, showGEOError, e) else console.log('Geolocation is not supported by this browser.')
            return

        SchoolLookupService.getSchoolData()
          .then (response) ->
            schoolDataRows = response.data.getSchoolSearchDataResponse.schoolData
            schoolDataHeaders = {}
            schoolDataMap = {}
            angular.forEach schoolDataRows[0], (schoolDataHeader, schoolDataHeaderIndex) ->
              schoolDataHeaders[schoolDataHeader] = schoolDataHeaderIndex
            angular.forEach schoolDataRows, (schoolDataRow, schoolDataRowIndex) ->
              if schoolDataRowIndex > 0
                schoolDataMap['id' + schoolDataRow[schoolDataHeaders.COMPANY_ID]] =
                  SCHOOL_CITY: schoolDataRow[schoolDataHeaders.SCHOOL_CITY]
                  SCHOOL_STATE: schoolDataRow[schoolDataHeaders.SCHOOL_STATE]
                  COORDINATOR_FIRST_NAME: schoolDataRow[schoolDataHeaders.COORDINATOR_FIRST_NAME]
                  COORDINATOR_LAST_NAME: schoolDataRow[schoolDataHeaders.COORDINATOR_LAST_NAME]
          
            $scope.schoolDataMap = schoolDataMap
            if $scope.schoolList.schools?.length > 0
              angular.forEach $scope.schoolList.schools, (school, schoolIndex) ->
                schoolData = $scope.schoolDataMap['id' + school.COMPANY_ID]
                if schoolData
                  school.SCHOOL_CITY = schoolData.SCHOOL_CITY
                  school.SCHOOL_STATE = schoolData.SCHOOL_STATE
                  school.COORDINATOR_FIRST_NAME = schoolData.COORDINATOR_FIRST_NAME
                  school.COORDINATOR_LAST_NAME = schoolData.COORDINATOR_LAST_NAME
                  $scope.schoolList.schools[schoolIndex] = school

        $scope.submitSchoolSearch = ->
          nameFilter = jQuery.trim $scope.schoolList.ng_nameFilter
          $scope.schoolList.nameFilter = nameFilter
          #$scope.schoolList.stateFilter = ''
          $scope.schoolList.searchSubmitted = true
          if not nameFilter
            $scope.schoolList.searchErrorMessage = 'Please specify a search criteria before initiating a search.'
          else
            delete $scope.schoolList.searchErrorMessage
            $scope.getSchoolSearchResults()
        
        $scope.orderSchools = (sortProp, keepSortOrder) ->
          schools = $scope.schoolList.schools
          if schools.length > 0
            if not keepSortOrder
              $scope.schoolList.sortDesc = !$scope.schoolList.sortDesc
            if $scope.schoolList.sortProp isnt sortProp
              $scope.schoolList.sortProp = sortProp
              $scope.schoolList.sortDesc = true
            schools = $filter('orderBy') schools, sortProp, $scope.schoolList.sortDesc
            $scope.schoolList.schools = schools
            $scope.schoolList.currentPage = 1
        
        $scope.paginate = (value) ->
          begin = ($scope.schoolList.currentPage - 1) * $scope.schoolList.paginationItemsPerPage
          end = begin + $scope.schoolList.paginationItemsPerPage
          index = $scope.schoolList.schools.indexOf value
          begin <= index and index < end
        
        setSchools = (companies) ->
          schools = []
          angular.forEach companies, (company) ->
            if company.coordinatorId and company.coordinatorId isnt '0'
              schools.push
                FR_ID: company.eventId
                COMPANY_ID: company.companyId
                SCHOOL_NAME: company.companyName
                COORDINATOR_ID: company.coordinatorId
          schools
        
        setSchoolsDataByState = (schools) ->
          angular.forEach schools, (school, schoolIndex) ->
            schoolData = $scope.schoolDataMapByState['id' + school.COMPANY_ID]
            if schoolData
              schools[schoolIndex].SCHOOL_CITY = schoolData.SCHOOL_CITY
              schools[schoolIndex].SCHOOL_STATE = schoolData.SCHOOL_STATE
              schools[schoolIndex].COORDINATOR_FIRST_NAME = schoolData.COORDINATOR_FIRST_NAME
              schools[schoolIndex].COORDINATOR_LAST_NAME = schoolData.COORDINATOR_LAST_NAME
          schools
        
        setSchoolsData = (schools) ->
          angular.forEach schools, (school, schoolIndex) ->
            schoolData = $scope.schoolDataMap['id' + school.COMPANY_ID]
            if schoolData
              schools[schoolIndex].SCHOOL_CITY = schoolData.SCHOOL_CITY
              schools[schoolIndex].SCHOOL_STATE = schoolData.SCHOOL_STATE
              schools[schoolIndex].COORDINATOR_FIRST_NAME = schoolData.COORDINATOR_FIRST_NAME
              schools[schoolIndex].COORDINATOR_LAST_NAME = schoolData.COORDINATOR_LAST_NAME
          schools
        
        searchOverridesMap = [
          {
            original: 'Saint', 
            overrides: ['St', 'St.']
          },
          {
            original: 'St', 
            overrides: ['Saint', 'St.']
          },
          {
            original: 'St.', 
            overrides: ['Saint', 'St']
          },
          {
            original: 'and',
            overrides: ['&']
          },
          {
            original: '&',
            overrides: ['and']
          },
          {
            original: 'Ft',
            overrides: ['Fort', 'Ft.']
          },
          {
            original: 'Ft.',
            overrides: ['Fort', 'Ft']
          },
          {
            original: 'Fort',
            overrides: ['Ft', 'Ft.']
          },
          {
            original: 'Mt',
            overrides: ['Mount', 'Mt.']
          },
          {
            original: 'Mt.',
            overrides: ['Mount', 'Mt']
          },
          {
            original: 'Mount',
            overrides: ['Mt', 'Mt.']
          }
        ]
        
        findOverrides = (param) ->
          searchOverridesMap.filter((i) ->
            if param.indexOf(i.original) is -1
              return false
            else
              return true
          )
        
        updateCompanyData = ->
          if not $scope.$$phase
            $scope.$apply()
        
        $scope.getSchoolSearchResults = (bystate) ->
          delete $scope.schoolList.schools
          $scope.schoolList.searchPending = true
          $scope.schoolList.currentPage = 1
          nameFilter = $scope.schoolList.nameFilter or '%'
          companies = []
          TeamraiserCompanyService.getCompanies 'event_type=' + encodeURIComponent(eventType) + '&company_name=' + encodeURIComponent(nameFilter) + '&list_sort_column=company_name&list_page_size=500', (response) ->
            if response.getCompaniesResponse?.company
              if response.getCompaniesResponse?.totalNumberResults is '1'
                companies.push response.getCompaniesResponse.company
              else
                companies = response.getCompaniesResponse.company
            
            totalNumberResults = response.getCompaniesResponse?.totalNumberResults or '0'
            totalNumberResults = Number totalNumberResults
            $scope.schoolList.totalNumberResults = totalNumberResults
            schools = []
            updateCompanyData()

            setResults = ->
              if companies.length > 0
                schools = setSchools companies
                #if bystate is true
                #  schools = setSchoolsDataByState schools
                #else
                schools = setSchoolsData schools
                $scope.schoolList.totalItems = schools.length
                $scope.schoolList.totalNumberResults = schools.length
                $scope.schoolList.schools = schools
                $scope.orderSchools $scope.schoolList.sortProp, true
                if nameFilter isnt 'zz'
                  # filter off zz schools
                  schools = $filter('filter')(schools, ((value) -> value.SCHOOL_NAME.toLowerCase().indexOf('zz') isnt 0), false)
                  $scope.schoolList.schools = schools
                  $scope.schoolList.totalItems = schools.length
                  $scope.schoolList.totalNumberResults = schools.length
                if $scope.schoolList.stateFilter isnt ''
                  schools = $filter('filter') schools, SCHOOL_STATE: $scope.schoolList.stateFilter
                  $scope.schoolList.schools = schools
                  $scope.schoolList.totalItems = schools.length
                  $scope.schoolList.totalNumberResults = schools.length
              else
                $scope.schoolList.schools = []
                $scope.schoolList.totalItems = 0
                $scope.schoolList.totalNumberResults = 0
            
            getAdditionalPages = (filter, totalNumber) ->
              additionalPages = []
              angular.forEach [1, 2, 3], (additionalPage) ->
                if totalNumber > additionalPage * 500
                  additionalPages.push additionalPage
              additionalPagesComplete = 0
              angular.forEach additionalPages, (additionalPage) ->
                TeamraiserCompanyService.getCompanies 'event_type=' + encodeURIComponent(eventType) + '&company_name=' + encodeURIComponent(filter) + '&list_sort_column=company_name&list_page_size=500&list_page_offset=' + additionalPage, (response) ->
                  moreCompanies = response.getCompaniesResponse?.company
                  moreSchools = []
                  if moreCompanies
                    moreCompanies = [moreCompanies] if not angular.isArray moreCompanies
                    if moreCompanies.length > 0
                      moreSchools = setSchools moreCompanies
                      if bystate is true
                        moreSchools = setSchoolsDataByState moreSchools
                      else
                        moreSchools = setSchoolsData moreSchools
                      if $scope.schoolList.stateFilter isnt ''
                        moreSchools = $filter('filter') moreSchools, SCHOOL_STATE: $scope.schoolList.stateFilter
                  schools = schools.concat moreSchools
                  additionalPagesComplete++
                  if additionalPagesComplete is additionalPages.length
                    setResults()
                    delete $scope.schoolList.searchPending
                    updateCompanyData()
            
            isOverride = findOverrides nameFilter
            if isOverride.length > 0
              setOverride = (response, nameFilterReplace) ->
                totalNumberOverrides = response.getCompaniesResponse?.totalNumberResults
                
                if response.getCompaniesResponse.totalNumberResults is '1'
                  companies.push response.getCompaniesResponse.company
                else
                  angular.forEach response.getCompaniesResponse?.company, (comp) ->
                    companies.push comp
                totalNumberResults += Number response.getCompaniesResponse?.totalNumberResults
                
                if totalNumberOverrides > 500
                  getAdditionalPages nameFilterReplace, totalNumberOverrides
                else
                  setResults()
                  delete $scope.schoolList.searchPending
                  updateCompanyData()
              
              angular.forEach isOverride, (override) ->
                angular.forEach override.overrides, (replace) ->
                  nameFilterReplace = nameFilter.replace override.original, replace
                  if nameFilterReplace.indexOf('..') is -1
                    TeamraiserCompanyService.getCompanies 'event_type=' + encodeURIComponent(eventType) + '&company_name=' + encodeURIComponent(nameFilterReplace) + '&list_sort_column=company_name&list_page_size=500', (response) ->
                      if response.errorResponse
                        # adding additional call due to occasional error returns
                        # SchoolLookupService.getSchoolCompanies 'company_name=' + encodeURIComponent(nameFilterReplace) + '&list_sort_column=company_name&list_page_size=500'
                          # .then (response) ->
                            # if response.data.errorResponse
                              # console.log 'error'
                            # else
                              # setOverride response, nameFilterReplace
                        angular.noop()
                      else
                        setOverride response, nameFilterReplace
            else
              if totalNumberResults > 500
                getAdditionalPages nameFilter, totalNumberResults
              else
                setResults()
                delete $scope.schoolList.searchPending
                updateCompanyData()
  ]
