require('./main.css');

var Elm = require('./Main.elm');

var root = document.getElementById('root');
var app = Elm.Main.embed(root);
var observer = new MutationObserver(triggerDigest);
var compile = false;
var listenForRouteChanges = true;
var ignoreNextPushState = false;
var activeScope = null;

var ps = window.history.pushState;
window.history.pushState = function() {
    if(ignoreNextPushState) {
        ignoreNextPushState = false;
        return;
    }
    ps.apply(window.history, arguments);
}

app.ports.watchDom.subscribe(obs);
function obs(c) {
    console.log('starting to observe the dom');
    compile = c;
    listenForRouteChanges = false;
    observer.observe(root, { childList: true, subtree: true });
}

obs();

//let's do some angular stuff in here ...
angular.module('MyApp', [])
    .component('pageOne', {
    template:'<div><button ng-click="cm.pageFour()">Go to page four</button> And <a href="pagefour/3456">Go to page four a different way</a></div>',
    controllerAs: 'cm',    
    controller: function PageOneController ($location) {
        this.pageFour = function() {
            $location.path('pagefour/5678');
        }
        console.log('We are in page one now at ' + $location.absUrl());
    }
}).component('homePage', {
    template: '<h1>Home Page (angular)</h1>',
    controller: function HomePageController ($location) {
        console.log('We are in the home page now at ' + $location.absUrl());
    }
}).component('pageFour', {
    template: '<h1>Page Four with id: {{$ctrl.customId}} (angular)</h1>',
    controller: function ($location) {
        console.log('We are in page four now at ' + $location.absUrl());
    },
    bindings: {
        customId: '<'
    }
}).config(function($locationProvider, $provide) {
    $locationProvider.html5Mode(true);   
}).run(function($rootScope, $location) {
    //if we use $locationChangeSuccess angular will already have added an entry to the history
    $rootScope.$on('$locationChangeSuccess', function(e, newUrl, oldUrl){
        if(!listenForRouteChanges) {
            return;
        }
        app.ports.newUrl.send(newUrl);
        //at this point angular will have added a history state
        //already so we should ignore the next one
        ignoreNextPushState = true;
        console.log('location change from angular ' + newUrl);
    });
});

function triggerDigest() {
    if(activeScope) {
        activeScope.$destroy();
    }

    if(!compile) {
        console.log('no need to compile this route');
        return;
    }
    var $body = angular.element(document.body);            
    var $rootScope = $body.injector().get('$rootScope');  
    var $location = $body.injector().get('$location');  
    var $compile = $body.injector().get('$compile');

    activeScope = $rootScope.$new();

    $location.$$parseLinkUrl(window.location.href);
    console.log('triggering a digest loop. We are at ' + window.location.href + ' angular thinks we are at ' + $location.path());
    activeScope.$apply(function() {
        $compile($body)(activeScope);
    });
    observer.disconnect();
    listenForRouteChanges = true;
}


