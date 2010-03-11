/**
 * @constructor
 * @extends google.maps.Marker
 */
function DataMarker(options) {
  this.extend(DataMarker, google.maps.Marker);
  google.maps.Marker.apply(this, arguments); 
}

/**
 * Extends a objects prototype by anothers.
 *
 * @param {Object} obj1 The object to be extended.
 * @param {Object} obj2 The object to extend with.
 * @return {Object} The new extended object.
 * @ignore
 */
DataMarker.prototype.extend = function(obj1, obj2) {
  return (function(object) {
    for (property in object.prototype) {
      this.prototype[property] = object.prototype[property];
    }
    return this;
  }).apply(obj1, [obj2]);
};

DataMarker.prototype.setData = function(data) {
  this._data = data;
}

DataMarker.prototype.getData = function(data) {
  return this._data;
}
