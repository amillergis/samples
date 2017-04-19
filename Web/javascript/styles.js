define([],function() {
  function getFeatureStyle(layer,feature) {
    switch(layer) {
      case "stops": return [
        new ol.style.Style({
          image: new ol.style.Icon({
            scale: 0.2,
            rotation: Math.radians(feature.get('azimuth')),
            src: 'images/GreenArrow.svg'
            }),
          text: new ol.style.Text({
            offsetY: 15,
            font: '12px helvetica,sans-serif',
            text: String(feature.get('stopid')),
            fill: new ol.style.Fill({
              color: '#000'
              }),
            stroke: new ol.style.Stroke({
              color: '#fff',
              width: 3
              })
            })
          })
        ]
      }
    }
  }
  )
