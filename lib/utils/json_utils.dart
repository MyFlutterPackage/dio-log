import 'dart:convert';

toJson(dynamic data) {
  var je = JsonEncoder.withIndent('  ');
  var json = je.convert(data);
  return json;
}

String map2Json(Map map) {
  if (map == null) {
    return '';
  }
  StringBuffer sb = StringBuffer();
  sb.writeln('{');
  map.forEach((key, value) => sb.writeln('$key:$value'));
  sb.write('}');
  return sb.toString();
}
