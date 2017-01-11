require('./main.css');

var Elm = require('./Main.elm');

var root = document.getElementById('root');
var app = Elm.Main.embed(root);
var observer = new MutationObserver(triggerDigest);
var compile = false;

app.ports.watchDom.subscribe(obs);
function obs(c) {
    console.log('starting to observe the dom');
    compile = c;
    observer.observe(root, { childList: true, subtree: true });
}

obs();

//let's do some angular stuff in here ...
angular.module('MyApp', [])
    .component('pageOne', {
    template:'<button ng-click="cm.pageFour()">Go to page four</button>',
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

    $provide.decorator('$location', ['$delegate', 
        function $locationDecorator($delegate) {
            var p = $delegate.path;
            $delegate.path = function(url) {
                app.ports.newUrl.send(url);
            }
            return $delegate;
        }]);
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
}


