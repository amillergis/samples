require.config({
  paths: {
    //'openlayers' : 'http://openlayers.org/en/v3.9.0/build/ol',
    'openlayers' : 'https://cdnjs.cloudflare.com/ajax/libs/ol3/3.9.0/ol-debug',
    'jquery': 'jquery-2.1.4.min'
  }
});

requirejs(['app'], function(App) {
  map = App.loadBaseMap();
  App.loadBusStops(map);
});

