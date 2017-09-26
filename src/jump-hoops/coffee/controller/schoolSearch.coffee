angular.module 'ahaLuminateControllers'
  .controller 'SchoolSearchCtrl', [
    '$rootScope'
    '$scope'
    '$filter'
    'SchoolLookupService'
    ($rootScope, $scope, $filter, SchoolLookupService) ->
      $scope.schoolList =
        searchSubmitted: false
        searchPending: false
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
      $scope.schoolDataMap = {}
      $scope.schoolSuggestionCache = {}
      
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
      
      setSchools = (companies) ->
        schools = []
        angular.forEach companies, (company) ->
          if company.coordinatorId and company.coordinatorId isnt '0'
            schools.push
              FR_ID: company.eventId
              COMPANY_ID: company.companyId
              SCHOOL_NAME: company.companyName
        schools
      
      $scope.getSchoolSuggestions = (newValue) ->
        newValue = newValue or ''
        if newValue isnt '' and $scope.schoolSuggestionCache[newValue] and $scope.schoolSuggestionCache[newValue] isnt 'pending'
          $filter('filter') $scope.schoolSuggestionCache[newValue].schools, SCHOOL_NAME: newValue
        else
          firstThreeCharacters = newValue.substring 0, 3
          if $scope.schoolSuggestionCache[firstThreeCharacters] and $scope.schoolSuggestionCache[firstThreeCharacters] isnt 'pending' and (newValue.length < 5 or $scope.schoolSuggestionCache[firstThreeCharacters].totalNumberResults < 500)
            $filter('filter') $scope.schoolSuggestionCache[firstThreeCharacters].schools, SCHOOL_NAME: newValue
          else
            firstFiveCharacters = newValue.substring 0, 5
            if $scope.schoolSuggestionCache[firstFiveCharacters] and $scope.schoolSuggestionCache[firstFiveCharacters] isnt 'pending' and (newValue.length < 7 or $scope.schoolSuggestionCache[firstFiveCharacters].totalNumberResults < 500)
              $filter('filter') $scope.schoolSuggestionCache[firstFiveCharacters].schools, SCHOOL_NAME: newValue
            else
              firstSevenCharacters = newValue.substring 0, 7
              if $scope.schoolSuggestionCache[firstSevenCharacters] and $scope.schoolSuggestionCache[firstSevenCharacters] isnt 'pending' and (newValue.length < 9 or $scope.schoolSuggestionCache[firstSevenCharacters].totalNumberResults < 500)
                $filter('filter') $scope.schoolSuggestionCache[firstSevenCharacters].schools, SCHOOL_NAME: newValue
              else
                firstNineCharacters = newValue.substring 0, 9
                if $scope.schoolSuggestionCache[firstNineCharacters] and $scope.schoolSuggestionCache[firstNineCharacters] isnt 'pending' and (newValue.length is 9 or $scope.schoolSuggestionCache[firstNineCharacters].totalNumberResults < 500)
                  $filter('filter') $scope.schoolSuggestionCache[firstNineCharacters].schools, SCHOOL_NAME: newValue
                else
                  searchCharacters = ''
                  if newValue isnt ''
                    searchCharacters = firstThreeCharacters
                    if newValue.length > 4
                      searchCharacters = firstFiveCharacters
                    if newValue.length > 6
                      searchCharacters = firstSevenCharacters
                    if newValue.length is 9
                      searchCharacters = firstNineCharacters
                    if newValue.length > 9
                      searchCharacters = newValue
                  $scope.schoolSuggestionCache[searchCharacters] = 'pending'
                  SchoolLookupService.getSchoolCompanies 'company_name=' + encodeURIComponent(searchCharacters) + '&list_sort_column=company_name&list_page_size=500'
                    .then (response) ->
                      companies = response.data.getCompaniesResponse?.company
                      totalNumberResults = response.data.getCompaniesResponse?.totalNumberResults or '0'
                      totalNumberResults = Number totalNumberResults
                      schools = []
                      if companies
                        companies = [companies] if not angular.isArray companies
                        schools = setSchools companies
                        schools = $filter('unique') schools, 'SCHOOL_NAME'
                      if searchCharacters isnt ''
                        $scope.schoolSuggestionCache[searchCharacters] =
                          schools: schools
                          totalNumberResults: totalNumberResults
                      $filter('filter') schools, SCHOOL_NAME: newValue
      
      $scope.submitSchoolSearch = ->
        $scope.schoolList.searchSubmitted = true
        $scope.schoolList.nameFilter = $scope.schoolList.ng_nameFilter
        $scope.schoolList.stateFilter = ''
        $scope.getSchoolSearchResults()
      
      setSchoolsData = (schools) ->
        angular.forEach schools, (school, schoolIndex) ->
          schoolData = $scope.schoolDataMap['id' + school.COMPANY_ID]
          if schoolData
            schools[schoolIndex].SCHOOL_CITY = schoolData.SCHOOL_CITY
            schools[schoolIndex].SCHOOL_STATE = schoolData.SCHOOL_STATE
            schools[schoolIndex].COORDINATOR_FIRST_NAME = schoolData.COORDINATOR_FIRST_NAME
            schools[schoolIndex].COORDINATOR_LAST_NAME = schoolData.COORDINATOR_LAST_NAME
        schools
      
      $scope.getSchoolSearchResults = ->
        delete $scope.schoolList.schools
        $scope.schoolList.searchPending = true
        nameFilter = $scope.schoolList.nameFilter
        SchoolLookupService.getSchoolCompanies 'company_name=' + encodeURIComponent(nameFilter) + '&list_sort_column=company_name&list_page_size=500'
          .then (response) ->
            companies = response.data.getCompaniesResponse?.company
            totalNumberResults = response.data.getCompaniesResponse?.totalNumberResults or '0'
            totalNumberResults = Number totalNumberResults
            $scope.schoolList.totalNumberResults = totalNumberResults
            schools = []
            if companies
              companies = [companies] if not angular.isArray companies
              if companies.length > 0
                schools = setSchools companies
                schools = setSchoolsData schools
                if $scope.schoolList.stateFilter isnt ''
                  schools = $filter('filter') schools, SCHOOL_STATE: $scope.schoolList.stateFilter
            if totalNumberResults <= 500
              $scope.schoolList.totalItems = schools.length
              $scope.schoolList.schools = schools
              $scope.orderSchools $scope.schoolList.sortProp, true
              delete $scope.schoolList.searchPending
            else
              additionalPages = []
              angular.forEach [1, 2, 3, 4], (additionalPage) ->
                if totalNumberResults > additionalPage * 500
                  additionalPages.push additionalPage
              additionalPagesComplete = 0
              angular.forEach additionalPages, (additionalPage) ->
                SchoolLookupService.getSchoolCompanies 'company_name=' + encodeURIComponent(nameFilter) + '&list_sort_column=company_name&list_page_size=500&list_page_offset=' + additionalPage
                  .then (response) ->
                    moreCompanies = response.data.getCompaniesResponse?.company
                    moreSchools = []
                    if moreCompanies
                      moreCompanies = [moreCompanies] if not angular.isArray moreCompanies
                      if moreCompanies.length > 0
                        moreSchools = setSchools moreCompanies
                        moreSchools = setSchoolsData moreSchools
                        if $scope.schoolList.stateFilter isnt ''
                          moreSchools = $filter('filter') moreSchools, SCHOOL_STATE: $scope.schoolList.stateFilter
                    schools = schools.concat moreSchools
                    additionalPagesComplete++
                    if additionalPagesComplete is additionalPages.length
                      $scope.schoolList.totalItems = schools.length
                      $scope.schoolList.schools = schools
                      $scope.orderSchools $scope.schoolList.sortProp, true
                      delete $scope.schoolList.searchPending
      
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
        
      $scope.noschoolRedirect = ->
        if $scope.selectedItem
          window.location.href = $scope.selectedItem
]
