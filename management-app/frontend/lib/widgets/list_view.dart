import 'package:conglobo_app/api/api.dart';
import 'package:conglobo_app/model/services.dart';
import 'package:conglobo_app/widgets/toggle_button.dart';
import 'package:flutter/material.dart';

class MyListView extends StatefulWidget {
  const MyListView({Key? key}) : super(key: key);

  @override
  _MyListViewState createState() => _MyListViewState();
}

class _MyListViewState extends State<MyListView> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Services>(
        future: getServices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final servicesObj = snapshot.data;
            print("THIS IS THE SERVICE OBJECT $servicesObj");
            return ListView.builder(
              itemCount: servicesObj!.services.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildListItem(index, servicesObj);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildListItem(int index, Services servicesObj) {
    final bool _isExpanded = index == _selectedIndex;
    final serviceName = servicesObj.services.keys.toList()[index];
    final serviceInfo = servicesObj.services.values.toList()[index];

    return Card(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = _isExpanded ? null : index;
          });
        },
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text(serviceName),
              subtitle: Text(serviceInfo.description),
              leading: _isExpanded
                  ? const Icon(Icons.arrow_drop_up)
                  : const Icon(Icons.arrow_drop_down),
              trailing: MyToggleButton(
                chosenService: serviceName,
              ),
            ),
            _isExpanded ? _buildExpandedDetails() : Container(),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedDetails() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'This is the expanded details section. '
            'It could contain more information about the selected item.',
          ),
          IconButton(onPressed: () {}, icon: Icon(Icons.delete))
        ],
      ),
    );
  }
}
