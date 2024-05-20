import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> uploadInitialData() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> mancharData = [
    {'name': 'Amit Gorakshanath Bhagat', 'position': 'Sr. Manager', 'location': 'Manchar'},
    {'name': 'Hiralal Sampatrao Sonwalkar', 'position': 'BM', 'location': 'Manchar'},
    {'name': 'Manik Kalyan Mangale', 'position': 'ABM', 'location': 'Manchar'},
    {'name': 'Pradip Arun Pawar', 'position': 'LS', 'location': 'Manchar'},
    {'name': 'Suraj Sambhaji Pagare', 'position': 'LS', 'location': 'Manchar'},
    {'name': 'Sandip Mangaldas Wavhal', 'position': 'LS', 'location': 'Manchar'},
    {'name': 'Sachin Babasaheb Waman', 'position': 'WS', 'location': 'Manchar'},
    {'name': 'Vishal Rajendra Shinde', 'position': 'BA', 'location': 'Manchar'},
    {'name': 'Shrikant Baliram Shelke', 'position': 'Tr. LS', 'location': 'Manchar'},
    {'name': 'Anil Kisan Kagne', 'position': 'WS', 'location': 'Manchar'},
  ];

  List<Map<String, dynamic>> shirurData = [
    {'name': 'Manish Kumar Singh', 'position': 'Sr. Manager', 'location': 'Shirur'},
    {'name': 'Mahindra Shivaji Thakre', 'position': 'BM', 'location': 'Shirur'},
    {'name': 'Prathmesh Balasaheb Magar', 'position': 'ABM', 'location': 'Shirur'},
    {'name': 'Ajinkya Nanasaheb Dhokale', 'position': 'LS', 'location': 'Shirur'},
    {'name': 'Hamid Rajikhan Pathan', 'position': 'LS', 'location': 'Shirur'},
    {'name': 'Hrishikesh Vitthal Najan', 'position': 'LS', 'location': 'Shirur'},
    {'name': 'Maruti Sonyabapu Dongare', 'position': 'WS', 'location': 'Shirur'},
    {'name': 'Ramdas Gangadhar Hinge', 'position': 'LS', 'location': 'Shirur'},
    {'name': 'Prashant Vijay More', 'position': 'WS', 'location': 'Shirur'},
    {'name': 'Akshay Ramkrushna Patil', 'position': 'LS', 'location': 'Shirur'},
    {'name': 'Sanjay Gorakh Rakh', 'position': 'LS', 'location': 'Shirur'},
    {'name': 'Sunil Pandit Rathod', 'position': 'LS', 'location': 'Shirur'},
  ];

  List<Map<String, dynamic>> nirgudsarData = [
    {'name': 'Nivrutti Dilip Sonawane', 'position': 'BM', 'location': 'Nirgudsar'},
    {'name': 'Jagadish Bhanudas Nakade', 'position': 'ABM', 'location': 'Nirgudsar'},
    {'name': 'Rutik Sharad Hinge', 'position': 'LS', 'location': 'Nirgudsar'},
    {'name': 'Akshay Manohar Jadhav', 'position': 'LS', 'location': 'Nirgudsar'},
    {'name': 'Subhash Prakash Arote', 'position': 'LS', 'location': 'Nirgudsar'},
    {'name': 'Vaibhav Ganpat Kokane', 'position': 'LS', 'location': 'Nirgudsar'},
    {'name': 'Omkar Sunil Mali', 'position': 'WS', 'location': 'Nirgudsar'},
    {'name': 'Amit Balu Jadhav', 'position': 'WS', 'location': 'Nirgudsar'},
  ];

  List<Map<String, dynamic>> urulikanchanData = [
    {'name': 'Kalyan Balu Gangawane', 'position': 'Sr. Manager', 'location': 'Urulikanchan'},
    {'name': 'Akshay Anandrao Mane', 'position': 'BM', 'location': 'Urulikanchan'},
    {'name': 'Swapnil Bhauso Kamble', 'position': 'BA', 'location': 'Urulikanchan'},
    {'name': 'Rohan Wable', 'position': 'LS', 'location': 'Urulikanchan'},
    {'name': 'Ganesh Yogesh More', 'position': 'LS', 'location': 'Urulikanchan'},
    {'name': 'Sagar Ashok Shelar', 'position': 'LS', 'location': 'Urulikanchan'},
    {'name': 'Shankar Gopal Waghe', 'position': 'LS', 'location': 'Urulikanchan'},
    {'name': 'Shubham Ganesh Mane', 'position': 'LS', 'location': 'Urulikanchan'},
    {'name': 'Mahesh Bhanudas Awade', 'position': 'LS', 'location': 'Urulikanchan'},
    {'name': 'Rahul Baban Dhaware', 'position': 'LS', 'location': 'Urulikanchan'},
    {'name': 'Aniket Suresh Kamble', 'position': 'LS', 'location': 'Urulikanchan'},
    {'name': 'Manohar Shivaji Dede', 'position': 'LS', 'location': 'Urulikanchan'},
    {'name': 'Swapnil Tukaram Rade', 'position': 'LS', 'location': 'Urulikanchan'},
    {'name': 'Shivaji Anand Kamble', 'position': 'LS', 'location': 'Urulikanchan'},
    {'name': 'Atish Sanjay Kamble', 'position': 'LS', 'location': 'Urulikanchan'},
    {'name': 'Mayur Prakash Nawale', 'position': 'LS', 'location': 'Urulikanchan'},
    {'name': 'Navnath Pandekar', 'position': 'LS', 'location': 'Urulikanchan'},
    {'name': 'Anil Kagne', 'position': 'WS', 'location': 'Urulikanchan'},
  ];

  List<Map<String, dynamic>> sangamnerData = [
    {'name': 'Samsu Sultan Tamboli', 'position': 'BM', 'location': 'Sangamner'},
    {'name': 'Sudheer Sakharam Sonawane', 'position': 'LS', 'location': 'Sangamner'},
    {'name': 'Ganesh Appasaheb Pawar', 'position': 'LS', 'location': 'Sangamner'},
    {'name': 'Rohit Sanjay Dhanrao', 'position': 'WS', 'location': 'Sangamner'},
  ];

  List<Map<String, dynamic>> alephataData = [
    {'name': 'Shivaji Dattatray Tambe', 'position': 'BM', 'location': 'Alephata'},
    {'name': 'Somnath Radhakisan Yadav', 'position': 'ABM', 'location': 'Alephata'},
    {'name': 'Santosh Pandurang Kale', 'position': 'ABM', 'location': 'Alephata'},
    {'name': 'Janardhan Sharad Shingote', 'position': 'BA', 'location': 'Alephata'},
    {'name': 'Nitin Subhash Dhamale', 'position': 'LS', 'location': 'Alephata'},
    {'name': 'Datta Ramesh Lad', 'position': 'Sr. LS', 'location': 'Alephata'},
    {'name': 'Shubham Sitaram Aher', 'position': 'LS', 'location': 'Alephata'},
    {'name': 'Pramod Sampat Shinde', 'position': 'WS', 'location': 'Alephata'},
    {'name': 'Ajay Raju Shelar', 'position': 'WS', 'location': 'Alephata'},
    {'name': 'Pradip Rohidas Shinde', 'position': 'LS', 'location': 'Alephata'},
    {'name': 'Rahul Baban Datir', 'position': 'LS', 'location': 'Alephata'},
  ];

  // Uploading data to Firestore
  for (var person in mancharData) {
    await firestore.collection('Manchar').add(person);
  }

  for (var person in shirurData) {
    await firestore.collection('Shirur').add(person);
  }

  for (var person in nirgudsarData) {
    await firestore.collection('Nirgudsar').add(person);
  }

  for (var person in urulikanchanData) {
    await firestore.collection('Urulikanchan').add(person);
  }

  for (var person in sangamnerData) {
    await firestore.collection('Sangamner').add(person);
  }

  for (var person in alephataData) {
    await firestore.collection('Alephata').add(person);
  }
}
