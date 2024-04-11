import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_listtile.dart';
import 'package:luvpark/custom_widget/custom_text.dart';

class MyWidget extends StatefulWidget {
  final List numbersList;
  final Function onTap;
  const MyWidget({super.key, required this.numbersList, required this.onTap});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        color: Colors.white,
      ),
      width: Variables.screenSize.width * 0.80, // Set the desired width
      height: Variables.screenSize.height * 0.50, // Set the desired height
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: CustomDisplayText(
                    label: "Select Duration",
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: CircleAvatar(
                    radius: 13,
                    backgroundColor: Colors.grey.shade200,
                    child: const Icon(
                      Icons.close,
                      size: 15,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 20),
              itemCount: widget.numbersList.length,
              itemBuilder: (context, index) {
                return CustomListtile(
                  title:
                      "${widget.numbersList[index]} ${widget.numbersList[index] > 1 ? "Hours" : "Hour"}",
                  subTitle: "",
                  leading: CupertinoIcons.clock_fill,
                  trailing: Icons.arrow_drop_down,
                  onTap: () {
                    Navigator.of(context).pop();
                    widget.onTap(widget.numbersList[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
