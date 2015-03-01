timeTracker.controller 'IssueCtrl', ($scope, $window, Account, Redmine, Ticket, Project, Message, State, Resource, Analytics, IssueEditState) ->

  # list data
  $scope.accounts = []
  $scope.projects = []
  $scope.queries  = []
  $scope.issues   = []

  # selected
  $scope.selectedAccount = {}
  $scope.selectedProject = {}
  $scope.selectedQuery   = {}

  # typeahead data
  $scope.accountData = null
  $scope.projectData = null
  $scope.queryData   = null

  $scope.searchField = text: ''
  $scope.tooltipPlace = 'top'
  $scope.totalItems = 0
  $scope.state = State

  # typeahead options
  $scope.inputOptions =
    highlight: true
    minLength: 0



  ###
   Initialize.
  ###
  init = () ->
    Account.getAccounts (accounts) ->
      $scope.accounts.set(accounts)
      $scope.selectedAccount = $scope.accounts[0]
      initializeSearchform()
    $scope.editState = new IssueEditState($scope)


  ###
   Initialize .
  ###
  initializeSearchform = () ->

    # account
    $scope.accountData =
      displayKey: 'url'
      source: substringMatcher($scope.accounts, 'url')

    # projects
    $scope.projectData =
      displayKey: 'text'
      source: substringMatcher($scope.projects, 'text')

    # query
    $scope.queryData =
      displayKey: 'name'
      source: substringMatcher($scope.queries, 'name')


  substringMatcher = (objects, key) ->
    return findMatches = (query, cb) ->
      matches = []
      substrRegexs = []
      queries = []
      for q in query.split(' ') when not q.isBlank()
        queries.push q
        substrRegexs.push new RegExp(q, 'i')

      for obj in objects
        isAllMatch = true
        for r in substrRegexs
          isAllMatch = isAllMatch and r.test(obj[key])

        matches.push(obj) if isAllMatch

      cb(matches, queries)


   remove project and issues.
  ###
  $scope.$on 'accountRemoved', (e, url) ->
    # remove a account
    if $scope.selectedAccount?.url is url
      $scope.selectedAccount = $scope.accounts[0]
    # remove projects
    newPrjs = (p for p in $scope.projects when p.url isnt url)
    $scope.projects.set(newPrjs)
    # update selected project if remoed.
    if $scope.selectedProject?.url is url
      $scope.selectedProject = $scope.projects[0]


  ###
   on change projects, update selected project.
   - if projects is empty.
   - if project not selected.
   - if selected project is not included current projects.
  ###
  $scope.$watch('projects', () ->
    if $scope.projects.length is 0
      $scope.selectedProject = null
      return

    selected = $scope.selectedProject
    if not selected?
      $scope.selectedProject = $scope.projects[0]
      return

    found = $scope.projects.some (ele) -> ele.equals(selected)
    if not found
      $scope.selectedProject = $scope.projects[0]

  , true)


    $scope.editState.currentPage = 1
    $scope.editState.load()


  ###
   on change state.currentPage, start loading.
  ###
  $scope.$watch 'editState.currentPage', ->
    Analytics.sendEvent 'user', 'clicked', 'pagination'
    $scope.editState.load()


  ###
   Start Initialize.
  ###
  init()
