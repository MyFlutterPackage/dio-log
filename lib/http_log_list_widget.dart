import 'dart:collection';

import 'package:flutter/material.dart';

import 'bean/net_options.dart';
import 'dio_log.dart';
import 'page/log_widget.dart';
import 'theme/style.dart';

///网络请求日志列表
class HttpLogListWidget extends StatefulWidget {
  @override
  _HttpLogListWidgetState createState() => _HttpLogListWidgetState();
}

class _HttpLogListWidgetState extends State<HttpLogListWidget> {
  LinkedHashMap<String, NetOptions> logMap;
  List<String> keys;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dismissDebugBtn();

    logMap = LogPoolManager.getInstance().logMap;
    keys = LogPoolManager.getInstance().keys;
    return WillPopScope(
      onWillPop: () async {
        showDebugBtn(context, isDelay: false);

        // You can do some work here.
        // Returning true allows the pop to happen, returning false prevents it.
        return true;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          setState(() {});

          return;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              '',
              style: TextStyle(
                fontSize: 14.0,
                color: Color(0xFF4a4a4a),
                fontWeight: FontWeight.normal,
              ),
            ),
            backgroundColor: Colors.white,
            brightness: Brightness.light,
            centerTitle: true,
            elevation: 1.0,
            iconTheme: IconThemeData(color: Color(0xFF555555)),
            actions: <Widget>[
              InkWell(
                onTap: () {
                  LogPoolManager.getInstance().clear();
                  setState(() {});
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Align(
                    child: Text(
                      'Clear',
                      style: Style.defTextBold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: logMap.length < 1
              ? Center(
                  child: Text('no request log'),
                )
              : ListView.builder(
                  reverse: false,
                  itemCount: keys.length,
                  itemBuilder: (BuildContext context, int index) {
                    NetOptions item = logMap[keys[index]];
                    return _buildItem(item);
                  },
                ),
        ), // Your Scaffold goes here.
      ), // Your Scaffold goes here.
    );
  }

  Widget _buildItem(NetOptions item) {
    var resOpt = item.resOptions;
    var reqOpt = item.reqOptions;

    ///格式化请求时间
    var requestTime = getTimeStr1(reqOpt.requestTime);

    return Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(width: .6, color: Colors.grey.withOpacity(.2)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return LogWidget(item);
          }));
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${reqOpt.method}',
                    style: TextStyle(
                      color: _requestMethodColor(reqOpt.method),
                    ),
                  ),
                  if (item.errOptions?.errorMsg != null) ...[
                    Text(
                      'ERROR',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ] else if (resOpt == null) ...[
                    Text(
                      'WAITING',
                      style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold),
                    ),
                  ] else ...[
                    Text(
                      '${resOpt?.statusCode}',
                      style: TextStyle(
                          color: resOpt?.statusCode == 200
                              ? Colors.green
                              : Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ],
              ),
              Divider(height: 6),
              Text(
                'Url: ${reqOpt.url.replaceAll('%5B', '[').replaceAll('%5D', ']')}',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              Divider(height: 2),
              Text(
                'requestTime: $requestTime    duration: ${resOpt?.duration ?? 0}ms',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _requestMethodColor(String method) {
    Color color = Colors.green;

    switch (method) {
      case 'PUT':
        color = Colors.blueAccent;
        break;

      case 'DELETE':
        color = Colors.red;
        break;

      case 'POST':
        color = Colors.orange;
        break;
    }
    return color;
  }
}
