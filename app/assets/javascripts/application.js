// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require foundation
//= require remotewind
//= require jquery.flot.min
//= require jquery.flot.fillbetween
//= require markerclusterer_compiled
//= require_tree .

// This lets us call console even in crap browsers.
window.console = window.console||{
    log : function(){},
    info: function(){},
    error: function(){}
};

// Init foundation.js (UI toolkit)


// dependencies loaded with Google loader
google.load("maps", "3", { other_params: "sensor=true", callback : function(){
    $(document).trigger('google.maps.apiloaded');
}});

$(document).ready(function(){

  $(document).foundation();
});