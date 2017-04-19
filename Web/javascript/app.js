define([
  'jquery',
  'openlayers'
  ], 
  function(
    $, 
    ol
  ){
    var loadBaseMap = function(){
      // CREATE BASEMAP
      var map = new ol.Map({
      target: 'map',
      layers: [
        new ol.layer.Tile({
          source: new ol.source.XYZ({
            url: ''
            })
          })
        ],
        view: new ol.View({
          center: ol.proj.transform([-123,51], 'EPSG:4326', 'EPSG:3857'),
          zoom: 7
          })
      })
      return map
    };

    var loadBusStops = function(map) {
      //////////////////////////////////////
      // function onMouseMove(browserEvent) {
      //   var coordinate = browserEvent.coordinate;
      //   var pixel = map.getPixelFromCoordinate(coordinate);
      //   var el = document.getElementById('name');
      //   el.innerHTML = '';
      //   map.forEachFeatureAtPixel(pixel, function(feature) {
      //     el.innerHTML += feature.get('name') + '<br>';
      //   });
      // }
      // map.on('pointermove', onMouseMove);
      //////////////////////////////////////

      /////////////////////////////////////////

      function getStyle(feature) {
        var textAnchor = [50,50];
        var azimuth = feature.get("azimuth") + 90;
        if (azimuth > 360) {
          azimuth -= 360
        }
        if (azimuth >= 0 && azimuth < 45) {
          textAnchor = [30,0];
        } else if (azimuth >=45 && azimuth < 90) {
          textAnchor = [0,15];
        } else if (azimuth >=90 && azimuth < 135) {
          textAnchor = [0,15];
        } else if (azimuth >=135 && azimuth < 180) {
          textAnchor = [-30,0];
        } else if (azimuth >=180 && azimuth < 225) {
          textAnchor = [-30,0];
        } else if (azimuth >=225 && azimuth < 270) {
          textAnchor = [0,-15];
        } else if (azimuth >=270 && azimuth < 315) {
          textAnchor = [0,-15];
        } else if (azimuth >=315 && azimuth <= 360) {
          textAnchor = [30,0];
        }

        var icon = ''

        switch(feature.get("status")){
          case 'Exists':
            icon = 'images/GreenArrow.svg';
            break;
          case 'Decommissioned':
            icon ='images/RedArrow.svg';
            break;
          default:
            icon = 'images/PurpleArrow.svg';
        }
        return [
          new ol.style.Style({
            image: new ol.style.Icon({
              scale: 0.2,
              rotation: Math.radians(feature.get('azimuth')),
              src: icon
            }),
            text: new ol.style.Text({
              offsetX: textAnchor[0],
              offsetY: textAnchor[1],
              font: 'bold 11px Arial, Verdana, Helvetica, sans-serif',
              text: String(feature.get("stopid")),
              fill: new ol.style.Fill({
                color: '#fff'
              }),
              stroke: new ol.style.Stroke({
                color: '#000',
                width: 3
              })
            })
          })
        ]
      }

      $SearchText = $('.SearchText')
      $SearchButton = $('.SearchButton')
      $SearchButton.click(function(){zoomToStopLocation($SearchText.val())})

      function zoomToStopLocation(stopid) {
        view = map.getView();
        map.getLayers().item(1).getSource().forEachFeature(function(feature) {
          if (feature.get('stopid') == stopid) {
            stopLocation = ol.proj.fromLonLat([feature.get('longitude'), feature.get('latitude')]);
            view.setCenter(stopLocation);
            view.setZoom(16)
            return true;
          };
        });
      }
      

      Math.radians = function(degrees) {
        return degrees * Math.PI / 180;
      };
      $(document).bind('ajaxStart', function(){
      $('.loader').show();
      }).bind('ajaxStop', function(){
      $('.loader').hide();
      });
      // LOAD BUS STOPS
      var url = "";
      $.ajax({
        jsonp: false,
        jsonpCallback: 'getJson',
        type: 'GET',
        url: url,
        async: false,
        dataType: 'jsonp',
        success: function(data) {
          var vectorSource = new ol.source.Vector({
            features: (new ol.format.GeoJSON()).readFeatures(data)
          });
          var vectorLayer = new ol.layer.Vector({
            source: vectorSource,
            style: function(feature) {
              if (map.getView().getZoom() >= 15) {
                return getStyle(feature);
              } 
            }
          });
          map.addLayer(vectorLayer);
        }
      });
      //////////////////////////////////////////////////////
      function pickRandomProperty() {
        var prefix = ['bottom', 'center', 'top'];
        var randPrefix = prefix[Math.floor(Math.random() * prefix.length)];
        var suffix = ['left', 'center', 'right'];
        var randSuffix = suffix[Math.floor(Math.random() * suffix.length)];
        return randPrefix + '-' + randSuffix;
      }
      var popup = new ol.Overlay({
        element: document.getElementById('popup')
      });
      map.addOverlay(popup)
      var container = document.getElementById('popup');
      
      var displayClickInfo = function(pixel, coordinate) {
        $CloseDetails = $('#CloseDetails')
        $CloseDetails.click(function(){document.getElementById('details').style.display = "none";})
        var features = [];
        map.forEachFeatureAtPixel(pixel, function(feature, layer) {
          features.push(feature);
        });
        if (features.length > 0) {
          document.getElementById('details').style.display = "block";
          var details = $('#detailsContent')[0];
          details.innerHTML = "<b>Stop Number</b>: " + features[0].get('stopid') + "<br/>";
          details.innerHTML += "<b>BC Transit System</b>: " + features[0].get('bctsystem') + "<br/>";
          details.innerHTML += "<b>BC Transit Region</b>: " + features[0].get('bctregion') + "<br/>";
          details.innerHTML += "<b>Regional District</b>: " + features[0].get('regdist') + "<br/>";
          details.innerHTML += "<b>Stop Name</b>: " + features[0].get('stopname') + "<br/>";
          details.innerHTML += "<b>City</b>: " + features[0].get('city') + "<br/>";
          details.innerHTML += "<b>Stop Owner</b>: " + features[0].get('stopowner') + "<br/>";
          details.innerHTML += "<b>Stop Responsible Party</b>: " + features[0].get('stopresp') + "<br/>";
          details.innerHTML += "<b>Shelter/Bench Owner</b>: " + features[0].get('sbowner') + "<br/>";
          details.innerHTML += "<b>Shelter Responsible Party</b>: " + features[0].get('sbresp') + "<br/>";
          details.innerHTML += "<b>Sign Type</b>: " + features[0].get('bssignage') + "<br/>";
          details.innerHTML += "<b>Curb Site Design</b>: "+ features[0].get('csd') +"<br/>";
          details.innerHTML += "<b>Status</b>: " + features[0].get('status') + "<br/>";
          details.innerHTML += "<b>Comments</b>: " + features[0].get('comments') + "<br/>";
          details.innerHTML += "<br/><b>Amenities</b><ul>";
          if (features[0].get('shelter') == 'Yes')
            details.innerHTML += "<li>Sheltered</li>";
          if (features[0].get('bench') == 'Yes')
            details.innerHTML += "<li>Bench</li>";
          if (features[0].get('accessible') == 'Accessible Design and Connection')
            details.innerHTML += "<li>Wheelchair Accessible</li>";
          if (features[0].get('sidewalk') == 'Yes')
            details.innerHTML += "<li>Sidewalk</li>";
          if (features[0].get('rtid') == 'Yes')
            details.innerHTML += "<li>Real-time Display</li>";
          if (features[0].get('heating') == 'Yes')
            details.innerHTML += "<li>Heating Unit</li>"; 
          if (features[0].get('tgsi') == 'Yes')
            details.innerHTML += "<li>Tactile Ground Surface Indicators</li>";
          if (features[0].get('cpla') == 'Yes')
            details.innerHTML += "<li>Concrete Pad / Landing Area</li>";
          if (features[0].get('lighting') == 'Yes')
            details.innerHTML += "<li>Lighting</li>";
          if (features[0].get('shade') == 'Yes')
            details.innerHTML += "<li>Shade</li>";
          if (features[0].get('garbage') == 'Yes')
            details.innerHTML += "<li>Garbage Bins</li>";
          if (features[0].get('schedhold') == 'Yes')
            details.innerHTML += "<li>Schedule Holder</li>";
          if (features[0].get('advert') == 'Yes')
            details.innerHTML += "<li>Advertisements</li>";
          if (features[0].get('stopiddis') == 'Yes')
            details.innerHTML += "<li>Stop Number Displayed</li>";  
          details.innerHTML += "</ul><br/>";
      //    details.innerHTML += "<br/><b>Photographs</b><br/>";
      //     var info = [];
      //     for (var i = 0, ii = features.length; i < ii; ++i) {
      //       info.push(features[i].get('bctsystem')+'this is a click popup');
      //     }
      //     container.innerHTML = info.join(', ') || '(unknown)';
      //     popup.setPositioning('top-right');
      //     popup.setPosition(coordinate);
        } else {
          container.innerHTML = '&nbsp;';
          document.getElementById('details').style.display = "none";
        }
      }

      

      var displayHoverInfo = function(pixel, coordinate) {
        var features = [];
        map.forEachFeatureAtPixel(pixel, function(feature, layer) {
          features.push(feature);
        });
        if (features.length > 0) {
          var info = [];
          for (var i = 0, ii = features.length; i < ii; ++i) {
            info.push(features[i].get('stopname')+' (#'+features[i].get('stopid')+')');
          }
          container.innerHTML = info.join(', ') || '(unknown)';
          popup.setPositioning('bottom-left');
          popup.setPosition(coordinate);
        } else {
          container.innerHTML = '&nbsp;';
        }
      };
      // map.on('pointermove', function(evt) {
      //   var coordinate = evt.coordinate;
      //   displayClickInfo(evt.pixel, coordinate);
      // });

      map.on('click', function(evt) {
        var coordinate = evt.coordinate;
        displayClickInfo(evt.pixel, coordinate);
      });
    }

  return {
    loadBaseMap: loadBaseMap,
    loadBusStops: loadBusStops
  };
  
  // What we return here will be used by other modules
});
