import 'package:dio_log/bean/net_options.dart';
import 'package:dio_log/dio_log.dart';
import 'package:dio_log/widget/json_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_json_view/flutter_json_view.dart';

class LogResponseWidget extends StatefulWidget {
  final NetOptions netOptions;

  LogResponseWidget(this.netOptions);

  @override
  _LogResponseWidgetState createState() => _LogResponseWidgetState();
}

class _LogResponseWidgetState extends State<LogResponseWidget>
    with AutomaticKeepAliveClientMixin {
  bool isShowAll = false;
  double fontSize = 14;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    var response = widget.netOptions.resOptions;
    var json = response?.data ?? 'no response';
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          copyClipboard(context, toJson(json));
        },
        child: const Icon(Icons.copy),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              SizedBox(width: 10),
              Text(isShowAll ? 'shrink all' : 'expand all'),
              Checkbox(
                value: isShowAll,
                onChanged: (check) {
                  isShowAll = check;
                  setState(() {});
                },
              ),
              Expanded(
                child: Slider(
                  value: fontSize,
                  max: 30,
                  min: 1,
                  onChanged: (v) {
                    fontSize = v;
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
          // JsonView.map(json),
          JsonViews(
            json: json,
            isShowAll: isShowAll,
            fontSize: fontSize,
          ),
        ],
      )),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
