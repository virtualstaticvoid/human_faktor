// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


// credit to http://stackoverflow.com/users/36537/phil-h for this one...

function rgbstringToTriplet(rgbstring)
{
  var commadelim = rgbstring.substring(4,rgbstring.length-1);
  var strings = commadelim.split(",");
  var numeric = [];
  for(var i=0; i<3; i++) { numeric[i] = parseInt(strings[i]); }
  return numeric;
}

function adjustColour(hexcolor)
{
  rgbstring = hexToRGB(hexcolor.substr(1, 6))
  var triplet = rgbstringToTriplet(rgbstring);
  var newtriplet = [];
  // black or white:
  var total = 0; for (var i=0; i<triplet.length; i++) { total += triplet[i]; } 
  if(total > (3*256/2)) {
    newtriplet = [0,0,0];
  } else {
    newtriplet = [255,255,255];
  }
  return "rgb("+newtriplet.join(",")+")";
}

function hexToRGB(color)
{
  if (color.length === 3)
    color = color.charAt(0) + color.charAt(0) + color.charAt(1) + color.charAt(1) + color.charAt(2) + color.charAt(2);
  else if (color.length !== 6)
    throw('Invalid hex color: ' + color);
  var rgb = [];
  for (var i = 0; i <= 2; i++)
    rgb[i] = parseInt(color.substr(i * 2, 2), 16);
  return "rgb(" + rgb.join(",") + ")";
}

