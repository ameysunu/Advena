class GeoHash {
  String _base32 = '0123456789bcdefghjkmnpqrstuvwxyz';
  List<int> _bits = [16, 8, 4, 2, 1];

  String encodeGeohash(double latitude, double longitude, {int precision = 9}) {
    String geohash = '';
    bool isEven = true;
    int bit = 0;
    int ch = 0;

    List<double> latRange = [-90.0, 90.0];
    List<double> lonRange = [-180.0, 180.0];

    while (geohash.length < precision) {
      if (isEven) {
        double mid = (lonRange[0] + lonRange[1]) / 2;
        if (longitude > mid) {
          ch |= _bits[bit];
          lonRange[0] = mid;
        } else {
          lonRange[1] = mid;
        }
      } else {
        double mid = (latRange[0] + latRange[1]) / 2;
        if (latitude > mid) {
          ch |= _bits[bit];
          latRange[0] = mid;
        } else {
          latRange[1] = mid;
        }
      }

      isEven = !isEven;

      if (bit < 4) {
        bit++;
      } else {
        geohash += _base32[ch];
        bit = 0;
        ch = 0;
      }
    }

    return geohash;
  }
}
