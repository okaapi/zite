//
//   google map supporting functions
//
function google_map_js( div, lat, long, zoom ) { 
  map = new GMap2(document.getElementById(div)); 
  var point = new GLatLng(long,lat);  
  map.setCenter(point,zoom); 
  map.addControl(new GSmallMapControl(),  
                     new GControlPosition(G_ANCHOR_BOTTOM_RIGHT, new GSize(10, 10)));  
  return map;
} 
function google_map_by_adr_js( div, address, zoom ) { 
  var map = new GMap2(document.getElementById(div));
  map.addControl(new GSmallMapControl(),
                 new GControlPosition(G_ANCHOR_BOTTOM_RIGHT, new GSize(10, 10)));
  var geocoder = new GClientGeocoder();        
  geocoder.getLatLng( address,
    function(pnt) { 
      if (!pnt) { alert( address + " not found" ); }
      else { map.setCenter(pnt,zoom); }
      } );  
  return map;  
} 
function google_map_icon_add_js( map, point, content, icn, shadow, thumb ) {
  var icon = new GIcon(); 
  if ( icn ) {
    icon.shadow = shadow;
    icon.iconAnchor = new GPoint(10, 10);
    icon.image = icn;
    icon.infoWindowAnchor = new GPoint(10, 10);
    icon.iconSize = new GSize(20, 20);
    icon.shadowSize = new GSize(50, 30);
    alert( icn );
  }
  else {       
    icon.shadow = 'http://www.google.com/intl/en_ALL/mapfiles/arrowshadow.png'; 
    icon.iconAnchor = new GPoint(10, 10); 
    icon.image = 'http://www.google.com/intl/en_ALL/mapfiles/arrow.png'; 
    icon.infoWindowAnchor = new GPoint(10, 10);	 
    icon.iconSize = new GSize(50, 30); 
    icon.shadowSize = new GSize(50, 30); 
  }
  var marker = new GMarker(point, icon);  
  if ( thumb )
  {
    GEvent.addListener(marker, "mouseover", function()
    { 
      var mp = map.getPane(G_MAP_MARKER_PANE);
      var pre = $("preview");
      if( pre ) { mp.removeChild(pre); }
      var pnt = map.fromLatLngToDivPixel(marker.getPoint());
      var img = document.createElement('img');
      img.src = thumb;
      img.id = "previewimg";
      img.style.position = 'relative';
      img.style.left = parseInt(pnt.x) + 10 + 'px';
      img.style.top = parseInt(pnt.y) + 10 + 'px';
      mp.appendChild( img );
      //thumbnail_resize(img,100);
      
      var txt = document.createElement('text');
      txt.innerHTML = "click!";
      txt.id = "previewtxt";   
      txt.style.position = 'relative';
      txt.style.left = parseInt(pnt.x) + 10 + 'px';
      txt.style.top = parseInt(pnt.y) + 'px' ;
      txt.style.color = 'blue';
      txt.style.backgroundColor = 'yellow';
      mp.appendChild( txt );
      

    });
  }
  GEvent.addListener(marker, "mouseout", function()
    { 
      var mp = map.getPane(G_MAP_MARKER_PANE);
      var pre = $("previewimg");
      if( pre ) { mp.removeChild(pre); }
      var pre = $("previewtxt");
      if( pre ) { mp.removeChild(pre); }
    });  
  if ( content ) GEvent.addListener(marker, "click", function() {
                     marker.openInfoWindowHtml(content); });
  map.addOverlay(marker);
}

function google_map_icon_js( map, lat, long, content, icon, shadow, thumb ) { 
  var point = new GLatLng(long,lat); 
  google_map_icon_add_js( map, point, content, icon, shadow, thumb );
}
function google_map_icon_by_adr_js( map, address, content, icon, shadow, thumb ) { 
  var geocoder = new GClientGeocoder();        
  geocoder.getLatLng( address,
    function(point) { 
      if (!point) { alert( address + " not found" ); }
      else { google_map_icon_add_js( map, point, content, icon, shadow, thumb  ); }
      } );    
}
function google_map_boundary_add_js( map, points ) {
  var pline = new GPolyline( points ); 
  map.addOverlay(pline);
}
