


  getMessager(int n)async{
  int f=0;
  print('waiting...');
   await Future.delayed( Duration(seconds: n), ()=> f=35);
  return f;
}

getPrinter(String name){
  print (name);
}


void main()async{
  getPrinter('hello');
 await getMessager(1).then((value) => print(value));
  getPrinter('world');


}