require('./main.css');

var Elm = require('./Main.elm');

var root = document.getElementById('root');
var app = Elm.Main.embed(root);
var observer = new MutationObserver(triggerDigest);
var compile = false;
var listenForRouteChanges = true;

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
    }
}).component('homePage', {
    template: '<h1>Home Page (angular)</h1>',
    controller: function HomePageController () {
        console.log('We are in the home page now');
    }
}).component('pageFour', {
    template: '<h1>Page Four with id: {{$ctrl.customId}} (angular)</h1>',
    controller: function () {
        console.log('We are in page four now');
    },
    bindings: {
        customId: '<'
    }
}).config(function($locationProvider, $provide) {
    $locationProvider.html5Mode(true);   
}).run(function($rootScope) {
    $rootScope.$on('$locationChangeStart', function(e, newUrl, oldUrl){
        if(!listenForRouteChanges) {
            return;
        }
        app.ports.newUrl.send(newUrl);
        console.log('location change from angular ' + newUrl);
    });
});

function triggerDigest() {
    if(!compile) {
        console.log('no need to compile this route');
        return;
    }
    console.log('triggering a digest loop');
    var $body = angular.element(document.body);            
    var $rootScope = $body.injector().get('$rootScope');  
    var $compile = $body.injector().get('$compile');
    $rootScope.$apply(function() {
        $compile($body)($rootScope);
    });
    observer.disconnect();
    listenForRouteChanges = true;
}


