import 'package:conglobo_app/widgets/toggle_button.dart';
import 'package:flutter/material.dart';

class MyListView extends StatefulWidget {
  const MyListView({Key? key}) : super(key: key);

  @override
  _MyListViewState createState() => _MyListViewState();
}

class _MyListViewState extends State<MyListView> {
  final List<String> _services = <String>[
    'Service 1',
    'Service 2',
    'Service 3',
  ];

  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _services.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildListItem(index);
        },
      ),
    );
  }

  Widget _buildListItem(int index) {
    final bool _isExpanded = index == _selectedIndex;

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
              title: Text(_services[index]),
              subtitle: Text('This is the subtitle'),
              leading: _isExpanded
                  ? Icon(Icons.arrow_drop_up)
                  : Icon(Icons.arrow_drop_down),
              trailing: MyToggleButton(
                chosenService: _services[index].toLowerCase(),
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
          Text(
            'This is the expanded details section. '
            'It could contain more information about the selected item.',
          ),
          IconButton(onPressed: () {}, icon: Icon(Icons.delete))
        ],
      ),
    );
  }
}
