library craver.globals;

bool DEVELOPMENT = true;
String VERSION = '0.5'; //This must match SERVER_VERSION on the server
String FULLVERSION = '$VERSION${DEVELOPMENT ? '-dev' : ''}';
