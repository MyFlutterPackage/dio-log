import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///
/// Created by rich on 2019-07-17
///

class JsonViews extends StatefulWidget {
  ///要展示的json数据
  final dynamic json;

  ///是否展开全部json
  final bool isShowAll;

  final double fontSize;
  JsonViews({
    this.json,
    this.isShowAll = false,
    this.fontSize = 14,
  });

  @override
  _JsonViewsState createState() => _JsonViewsState();
}

class _JsonViewsState extends State<JsonViews> {
  Map<String, bool> showMap = Map();

  ///当前节点编号
  int currentIndex = 0;

  @override
  void didUpdateWidget(JsonViews oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isShowAll != widget.isShowAll) {
      _flexAll(widget.isShowAll);
    }
  }

  @override
  Widget build(BuildContext context) {
    currentIndex = 0;
    Widget w;
    JsonType type = getType(widget.json);
    if (type == JsonType.object) {
      w = _buildObject(widget.json);
    } else if (type == JsonType.array) {
      List list = widget.json as List;
      w = _buildArray(list, '');
    } else {
      var je = JsonEncoder.withIndent('  ');
      var json = je.convert(widget.json);
      return _buildObject(jsonDecode(json));
      return _getDefText(json);
    }
    return w;
  }

  Color textColor(dynamic value) {
    Color color = Colors.black12;

    if (value.runtimeType == int ||
        value.runtimeType == double ||
        value.runtimeType == Float) {
      color = Colors.blue;
    } else if (value.runtimeType == String) {
      color = Color(0xffC80000);
    }

    return color;
  }

  Widget rowJson(String key, dynamic value) {
    return Container(
      // width: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (key != null) ...[
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    key,
                    style: TextStyle(
                        fontSize: widget.fontSize, color: Colors.purple),
                  ),
                  Text(
                    ':',
                    style: TextStyle(fontSize: widget.fontSize),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(width: 2),
          Container(
            child: Text(
              value.toString(),
              overflow: TextOverflow.ellipsis,
              maxLines: 20,
              style:
                  TextStyle(fontSize: widget.fontSize, color: textColor(value)),
            ),
          ),
        ],
      ),
    );
  }

  ///构建object节点的展示
  Widget _buildObject(Map<String, dynamic> json, {String key}) {
    List<Widget> listW = [];

    ///增加一个节点
    currentIndex++;

    ///object节点
    Widget keyW;
    if (_isShow(currentIndex)) {
      keyW = rowJson(key, '{');
      //keyW = _getDefText('${key == null ? '{' : '$key:{'}');
    } else {
      keyW = rowJson(key, '{...},');
      // keyW =  _getDefText('${key == null ? '{...}' : '$key:{...}'}');
    }
    listW.add(_wrapFlex(currentIndex, keyW));

    ///object展示内容
    if (_isShow(currentIndex)) {
      List<Widget> listObj = [];
      json.forEach((k, v) {
        Widget w;
        JsonType type = getType(v);
        if (type == JsonType.object) {
          w = _buildObject(v, key: k);
        } else if (type == JsonType.array) {
          List list = v as List;
          w = _buildArray(list, k);
        } else {
          w = _buildKeyValue(v, k: k);
        }
        listObj.add(w);
      });

      listObj.add(rowJson(null, '},'));

      ///添加缩进
      listW.add(
        Padding(
          padding: EdgeInsets.only(left: 10),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: listObj,
            ),
          ),
        ),
      );
    }
    return Container(
        // width: 200,
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: listW,
    ));
  }

  ///构建array节点的展示
  Widget _buildArray(List listJ, String key) {
    List<Widget> listW = [];

    ///增加一个节点
    currentIndex++;

    ///添加key的展示
    Widget keyW;
    if (key.isEmpty) {
      keyW = rowJson(null, '['); //_getDefText('[');
    } else if (_isShow(currentIndex)) {
      keyW = rowJson(key, '['); //_getDefText('$key:[');
    } else {
      keyW = Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          rowJson(key, '[...],'),
          Text(
            ' length: ${listJ.length}',
            style: TextStyle(
                color: Colors.purple.withOpacity(.5),
                fontSize: widget.fontSize - 7),
          )
        ],
      ); //_getDefText('$key:[...]');
    }

    ///添加key的点击事件
    ///添加key的展示
    listW.add(_wrapFlex(currentIndex, keyW));

    if (_isShow(currentIndex)) {
      List<Widget> listArr = [];
      listJ.forEach((val) {
        var type = getType(val);
        Widget w;
        if (type == JsonType.object) {
          w = _buildObject(val);
        } else {
          w = _buildKeyValue(val);
        }
        listArr.add(w);
      });

      listArr.add(Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          rowJson(null, '],'),
          Text(
            ' length: ${listJ.length}',
            style: TextStyle(
                color: Colors.purple.withOpacity(.5),
                fontSize: widget.fontSize - 7),
          )
        ],
      ));

      ///添加缩进
      listW.add(
        Padding(
          padding: EdgeInsets.only(left: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: listArr,
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: listW,
    );
  }

  ///包裹展开按钮
  Widget _wrapFlex(int key, Widget keyW) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (key == 0) {
          _flexAll(!_isShow(key));
          setState(() {});
        }
        _flexSwitch(key.toString());
      },
      child: Row(
        children: <Widget>[
          Transform.rotate(
            angle: _isShow(key) ? 0 : 3.14 * 1.5,
            child: Icon(
              Icons.expand_more_outlined,
              size: widget.fontSize,
            ),
          ),
          keyW,
        ],
      ),
    );
  }

  ///构建子节点的展示
  Widget _buildKeyValue(v, {k}) {
    Widget w = Row(
      children: [
        SizedBox(
          width: 10,
        ),
        rowJson(k, v)
      ],
    );
    // _getDefText(
    //     '\t\t\t${k ?? ''}:${v is String ? ' "$v"' : v?.toString() ?? null},');
    if (k != null) {
      w = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onLongPress: () {
          _copy(v);
        },
        child: w,
      );
    }
    return w;
  }

  ///Whether the json node is displayed
  bool _isShow(int key) {
    ///Description is the root node
    if (key == 1) return true;
    if (widget.isShowAll) {
      return showMap[key.toString()] ?? true;
    } else {
      return showMap[key.toString()] ?? false;
    }
  }

  ///Expand closed switch
  _flexSwitch(String key) {
    showMap.putIfAbsent(key, () => false);
    showMap[key] = !showMap[key];
    setState(() {});
  }

  ///Expand and close all
  _flexAll(bool flex) {
    showMap.forEach((k, v) {
      showMap[k] = flex;
    });
  }

  ///判断value值的类型
  JsonType getType(dynamic json) {
    if (json is List) {
      return JsonType.array;
    } else if (json is Map<String, dynamic>) {
      return JsonType.object;
    } else {
      return JsonType.str;
    }
  }

  ///Default text size
  Text _getDefText(String str, [Color color = Colors.purple]) {
    return Text(
      str,
      style: TextStyle(fontSize: widget.fontSize, color: Colors.green),
    );
  }

  _copy(value) {
    var snackBar =
        SnackBar(content: Text('"$value"\n\n copy success to clipboard'));
    Scaffold.of(context).showSnackBar(snackBar);
    Clipboard.setData(ClipboardData(text: value?.toString()));
  }
}

enum JsonType {
  object,
  array,
  str,
}
