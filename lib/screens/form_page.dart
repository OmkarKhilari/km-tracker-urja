import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:file_picker/file_picker.dart';

class FormPage extends StatefulWidget {
  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  List<EmployeeData> _employeeData = [];

  @override
  void initState() {
    super.initState();
    _employeeData = [
      ...parseEmployeeData(branch: 'Manchar', data: mancharData),
      ...parseEmployeeData(branch: 'Shirur', data: shirurData),
      ...parseEmployeeData(branch: 'Nirgudsar', data: nirgudsarData),
      ...parseEmployeeData(branch: 'Urulikanchan', data: urulikanchanData),
      ...parseEmployeeData(branch: 'Sangamner', data: sangamnerData),
      ...parseEmployeeData(branch: 'Alephata', data: alephataData),
    ];
  }

  List<EmployeeData> parseEmployeeData(
      {required String branch, required List<List<String>> data}) {
    return data
        .map((entry) => EmployeeData(
              name: entry[1],
              designation: entry[2],
              branch: branch,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KM Tracker',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(
        employeeData: _employeeData,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final List<EmployeeData> employeeData;

  const HomePage({Key? key, required this.employeeData}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormBuilderState>();
  PlatformFile? _openingKmFile, _closingKmFile;
  final TextEditingController _openingKmController = TextEditingController();
  final TextEditingController _closingKmController = TextEditingController();
  final TextEditingController _differenceController = TextEditingController();
  double kmTravelled = 0;

  List<String>? _names;
  String? _selectedShift = 'Day';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("KM Tracker"),
      ),
      body: FormBuilder(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              FormBuilderDropdown(
                name: 'branch',
                decoration: InputDecoration(
                  labelText: 'Select Branch',
                  hintText: 'Select Branch',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _formKey.currentState!.fields['branch']!.reset();
                      setState(() {
                        _names = null;
                      });
                    },
                  ),
                ),
                items: [
                  'Manchar',
                  'Alephata',
                  'Urulikanchan',
                  'Shirur',
                  'Sangamner',
                  'Nirgudsar'
                ]
                    .map((branch) => DropdownMenuItem(
                          value: branch,
                          child: Text(branch),
                        ))
                    .toList(),
              ),
              SizedBox(height: 20),
              FormBuilderDropdown(
                name: 'position',
                decoration: InputDecoration(
                  labelText: 'Select Position',
                  hintText: 'Select Position',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _formKey.currentState!.fields['position']!.reset();
                      setState(() {
                        _names = null;
                      });
                    },
                  ),
                ),
                items: ['Sr. Manager', 'BM', 'ABM', 'LS', 'WS']
                    .map((position) => DropdownMenuItem(
                          value: position,
                          child: Text(position),
                        ))
                    .toList(),
                onChanged: (String? newPosition) {
                  _formKey.currentState!.fields['name']!.didChange(null);
                  _updateNames();
                },
              ),
              SizedBox(height: 20),
              FormBuilderDropdown(
                name: 'name',
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                items: _names?.map((name) => DropdownMenuItem(
                      value: name,
                      child: Text(name),
                    )).toList() ?? [],
                enabled: _names != null,
              ),
              SizedBox(height: 20),
              FormBuilderTextField(
                name: 'phone',
                decoration: InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _openingKmController,
                decoration: InputDecoration(
                  labelText: 'Opening KM',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _calculateDifference();
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _closingKmController,
                decoration: InputDecoration(
                  labelText: 'Closing KM',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _calculateDifference();
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _differenceController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'KM Travelled Today',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              DropdownButton<String>(
                value: _selectedShift,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedShift = newValue;
                  });
                },
                items: <String>['Day', 'Night']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();
                  if (result != null) {
                    setState(() {
                      _openingKmFile = result.files.first;
                    });
                  }
                },
                child: Text('Opening KM PROOF (Select File)'),
              ),
              SizedBox(height: 10),
              Text(_openingKmFile?.name ?? 'No file selected'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();
                  if (result != null) {
                    setState(() {
                      _closingKmFile = result.files.first;
                    });
                  }
                },
                child: Text('Closing KM PROOF (Select File)'),
              ),
              SizedBox(height: 10),
              Text(_closingKmFile?.name ?? 'No file selected'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.saveAndValidate()) {
                    print(_formKey.currentState!.value);
                    _calculateTotalIncome();
                  }
                },
                child: Text('Submit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.yellow,
                ),
              ),
               SizedBox(height: 20),
              Text(
                'Today\'s Allowance: \$${_todaysAllowance.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _todaysAllowance = 0.0;


  void _calculateDifference() {
    final openingKm = double.tryParse(_openingKmController.text) ?? 0.0;
    final closingKm = double.tryParse(_closingKmController.text) ?? 0.0;
    final difference = closingKm - openingKm;
    kmTravelled = difference;
    _differenceController.text = difference.toString();
  }

  void _updateNames() {
    final branch = _formKey.currentState?.fields['branch']?.value;
    final position = _formKey.currentState?.fields['position']?.value;
    if (branch != null && position != null) {
      setState(() {
        _names = widget.employeeData
            .where((data) =>
                data.branch == branch && data.designation == position)
            .map((data) => data.name)
            .toList();
      });
    }
  }

  void _calculateTotalIncome() {
    final name = _formKey.currentState?.fields['name']?.value;
    final position = _formKey.currentState?.fields['position']?.value;
    final shift = _selectedShift ?? 'Day';
    final isSunday = DateTime.now().weekday == DateTime.sunday;
    
    if (name != null && position != null) {
      final employee = widget.employeeData.firstWhere(
          (data) => data.name == name && data.designation == position);
      final dailyAllowance = employee.calculateDailyAllowance(shift, isSunday, kmTravelled);
      setState(() {
        _todaysAllowance = dailyAllowance;
      });
      print('Total income for $name: \$${dailyAllowance.toStringAsFixed(2)}');
    }
  }
}

class EmployeeData {
  final String name;
  final String designation;
  final String branch;

  EmployeeData({
    required this.name,
    required this.designation,
    required this.branch,
  });

  double calculateDailyAllowance(String shift, bool isSunday, double kmTravelled) { 
    double dailyAllowance = 3.2 * kmTravelled; 

    switch (designation) {
      case 'BM':
        dailyAllowance += shift == 'Day' ? 90 : 120;
        break;
      case 'ABM':
        dailyAllowance += shift == 'Day' ? 75 : 120;
        break;
      case 'LS':
        dailyAllowance += shift == 'Day' ? 60 : 120;
        break;
      case 'WS':
        dailyAllowance += shift == 'Day' ? 100 : 60;
        if (isSunday) dailyAllowance += 100;
        break;
      default:
        break;
    }

    return dailyAllowance;
  }
}

final List<List<String>> mancharData = [
  ['1', 'Amit Gorakshanath Bhagat', 'Sr. Manager', 'Manchar'],
  ['2', 'Hiralal Sampatrao Sonwalkar', 'BM', 'Manchar'],
  ['3', 'Manik Kalyan Mangale', 'ABM', 'Manchar'],
  ['4', 'Pradip Arun Pawar', 'LS', 'Manchar'],
  ['5', 'Suraj Sambhaji Pagare', 'LS', 'Manchar'],
  ['6', 'Sandip Mangaldas Wavhal', 'LS', 'Manchar'],
  ['7', 'Sachin Babasaheb Waman', 'WS', 'Manchar'],
  ['8', 'Vishal Rajendra Shinde', 'BA', 'Manchar'],
  ['9', 'Shrikant Baliram Shelke', 'Tr. LS', 'Manchar'],
  ['10', 'Anil Kisan Kagne', 'WS', 'Manchar'],
];

final List<List<String>> shirurData = [
  ['1', 'Manish Kumar Singh', 'Sr. Manager', 'Shirur'],
  ['2', 'Mahindra Shivaji Thakre', 'BM', 'Shirur'],
  ['3', 'Prathmesh Balasaheb Magar', 'ABM', 'Shirur'],
  ['4', 'Ajinkya Nanasaheb Dhokale', 'LS', 'Shirur'],
  ['5', 'Hamid Rajikhan Pathan', 'LS', 'Shirur'],
  ['6', 'Hrishikesh Vitthal Najan', 'LS', 'Shirur'],
  ['7', 'Maruti Sonyabapu Dongare', 'WS', 'Shirur'],
  ['8', 'Ramdas Gangadhar Hinge', 'LS', 'Shirur'],
  ['9', 'Prashant Vijay More', 'WS', 'Shirur'],
  ['10', 'Akshay Ramkrushna Patil', 'LS', 'Shirur'],
  ['11', 'Sanjay Gorakh Rakh', 'LS', 'Shirur'],
  ['12', 'Sunil Pandit Rathod', 'LS', 'Shirur'],
];

final List<List<String>> nirgudsarData = [
  ['1', 'Nivrutti Dilip Sonawane', 'BM', 'Nirgudsar'],
  ['2', 'Jagadish Bhanudas Nakade', 'ABM', 'Nirgudsar'],
  ['3', 'Rutik Sharad Hinge', 'LS', 'Nirgudsar'],
  ['4', 'Akshay Manohar Jadhav', 'LS', 'Nirgudsar'],
  ['5', 'Subhash Prakash Arote', 'LS', 'Nirgudsar'],
  ['6', 'Vaibhav Ganpat Kokane', 'LS', 'Nirgudsar'],
  ['7', 'Omkar Sunil Mali', 'WS', 'Nirgudsar'],
  ['8', 'Amit Balu Jadhav', 'WS', 'Nirgudsar'],
];

final List<List<String>> urulikanchanData = [
  ['1', 'Kalyan Balu Gangawane', 'Sr. Manager', 'Urulikanchan'],
  ['2', 'Akshay Anandrao Mane', 'BM', 'Urulikanchan'],
  ['3', 'Swapnil Bhauso Kamble', 'BA', 'Urulikanchan'],
  ['4', 'Rohan Wable', 'LS', 'Urulikanchan'],
  ['5', 'Ganesh Yogesh More', 'LS', 'Urulikanchan'],
  ['6', 'Sagar Ashok Shelar', 'LS', 'Urulikanchan'],
  ['7', 'Shankar Gopal Waghe', 'LS', 'Urulikanchan'],
  ['8', 'Shubham Ganesh Mane', 'LS', 'Urulikanchan'],
  ['9', 'Mahesh Bhanudas Awade', 'LS', 'Urulikanchan'],
  ['10', 'Rahul Baban Dhaware', 'LS', 'Urulikanchan'],
  ['11', 'Aniket Suresh Kamble', 'LS', 'Urulikanchan'],
  ['12', 'Manohar Shivaji Dede', 'LS', 'Urulikanchan'],
  ['13', 'Swapnil Tukaram Rade', 'LS', 'Urulikanchan'],
  ['14', 'Shivaji Anand Kamble', 'LS', 'Urulikanchan'],
  ['15', 'Atish Sanjay kamble', 'LS', 'Urulikanchan'],
  ['16', 'Mayur Prakash Nawale', 'LS', 'Urulikanchan'],
  ['17', 'Navnath Pandekar', 'LS', 'Urulikanchan'],
  ['18', 'Anil Kagne', 'WS', 'Urulikanchan'],
];

final List<List<String>> sangamnerData = [
  ['1', 'Samsu Sultan Tamboli', 'BM', 'Sangamner'],
  ['2', 'Sudheer Sakharam Sonawane', 'LS', 'Sangamner'],
  ['3', 'Ganesh Appasaheb Pawar', 'LS', 'Sangamner'],
  ['4', 'Rohit Sanjay Dhanrao', 'WS', 'Sangamner'],
];

final List<List<String>> alephataData = [
  ['1', 'Shivaji Dattatray Tambe', 'BM', 'Alephata'],
  ['2', 'Somnath Radhakisan Yadav', 'ABM', 'Alephata'],
  ['3', 'Santosh Pandurang Kale', 'ABM', 'Alephata'],
  ['4', 'Janardhan Sharad Shingote', 'BA', 'Alephata'],
  ['5', 'Nitin Subhash Dhamale', 'LS', 'Alephata'],
  ['6', 'Datta Ramesh Lad', 'Sr. LS', 'Alephata'],
  ['7', 'Shubham Sitaram Aher', 'LS', 'Alephata'],
  ['8', 'Pramod Sampat Shinde', 'WS', 'Alephata'],
  ['9', 'Ajay Raju Shelar', 'WS', 'Alephata'],
  ['10', 'Pradip Rohidas Shinde', 'LS', 'Alephata'],
  ['11', 'Rahul Baban Datir', 'LS', 'Alephata'],
];
