
<div style="text-align:center; font-size:80pt;"><img src="https://cernbox.cern.ch/index.php/s/iavcnlnKD41GpAf/download" style="width:250px; "/></div>

# CRAVER 

https://gitlab.cern.ch/lhcb-online/craver

## Project

Your phone -> App (Craver) -> Our server -> Select sources (Prometheus/DIM/LbLogbook)

## App

Main.dart
https://gitlab.cern.ch/lhcb-online/craver/-/blob/main/craver_flutter_project/lib/main.dart

Pages are managed from bottom_nav, which also updates the header from a setting variable.
##### Tools
1. VSC
2. https://docs.flutter.dev/get-started/install
3. Flutter dev tools extension

#### How to install / set up project
1. Install flutter
2. Run ```git clone https://gitlab.cern.ch/lhcb-online/craver.git```
3. Run ```flutter pub get``` (*VSCode will promt you to do this for you*)
4. Now you should be ready to develop and test. Follow steps 5-7 for publishing.
5. Get access to the ```craverKeystore.jks``` and the ```key.properties``` used for the app (Try asking Aristeidis Fkiaras), or make your own. See [how to create keys](#create_keys).
6. Put the ```key.properties``` in the ```andorid folder```
7. Put the ```craverKeystore.jks``` in the ```android/app``` folder


#### Links
*   [How to install VSCode and extention](https://docs.flutter.dev/development/tools/vs-code)
*   [How to install Flutter](https://docs.flutter.dev/get-started/install)
*   How to set up dev mode on your phone ([Android](https://developer.android.com/studio/debug/dev-options)/[iOS](https://developer.apple.com/documentation/xcode/enabling-developer-mode-on-a-device))
*   How to instal emulators of phones ([Android](https://docs.flutter.dev/get-started/install/windows#set-up-the-android-emulator)/[iOS](https://docs.flutter.dev/get-started/install/macos#set-up-the-ios-simulator))
*   <a id="create_keys">[How to create keys](https://docs.flutter.dev/deployment/android#signing-the-app)</a>

##### How to build (To android)
```bash
flutter build apk
```

##### How to add a new Page
1. Clone one of the existing pages (pages dir)
2. Add a button on the bot nav
3. Import the page
4. Add the name in the ```Enum Pages```
5. Add the main method of the page it self in ```_pages``` 


UI is controlled from inside the dart code

#### How to add a new DIM variable
Each DIM value is of the class ```ControlValue``` (As they are curently only used in the *control* panel). To create a new variable, go to ```ControlValues``` and create a ```static final``` variable of type ```ControlValue``` specifying the DIM path, a short name and an optional long name. Next add this variable to the ```allValues``` list at the end of the ```ControlValues``` class. Next you need to add this DIM path to the server whitelist. In the ```controlPanelInterface.py``` file, you must add the DIM path to the ```allowed_states``` list. If you want to do big changes, they can be exported from the ```ControlValues``` class in the flutter project.


#### Settings
Many settings are platform specific and need to be set seperately in the android/ios folders. For example, to change the name of the app on android platforms, you need to go to android\app\src\main\AndroidManifest.xml

#### Usefull flutter commands
Sometimes doing ```flutter clean``` followed by ```flutter build``` will help. 

#### Pulishing to playstore
You need to aquire the keystore that I have used. It is not included in the respository and so needs to be aquired through other means. Try asking Aristeidis Fkiaras. When creating a new version to publish, change the ```version``` in the ```pubspec.yaml``` file, and run ```flutter build appbundle```. Remember to increment the number after the ```+``` by 1, even if you want to keep the version name the same. 

#### Development notes
When creating a new page, some of the problems i found the most frustrating to deal with were futures and sizeconstraints of ui widgets. Futures are used when a variable will store data from an asyncronous source, ie. it will store data in the *future*. This is useful when you build your widget, but you don't want the build function to wait for the server. You would then use a Future builder that automatically updates your widget once the future is resolved. I initially used this in the Instances and Logbook pages, but decided to use simpler notification values instead. 

You will get [deprication warnings](https://github.com/mogol/flutter_secure_storage/issues/162), but that is the fault of the library we use, not our code. Future work could look into finding an alternative library or seeing if the current library (flutter_secure_storage) has finally fixed the issue. 

The second problem you might encounter is flutter complaining that a widgets size is unconstrained. This often happens inside rows or columns, and I honestly don't understand it well enough to give any usefull tips. That was at least true until now! I belive that if this happens, you should set the mainAxizSize to MainAxisSize.min. There are many places in this project where this should be done, but I don't have time to fix it. 

The third issue I'd like to point out is that the app uses a constant context for displaying messages. This was okay when there only was pages from the main bottom navigator view, but now that there is a login page, a preferences page and a help page, the app can crash if messages are displayed on those pages. This should be done differently, but as an inexperienced flutter developer, I wasn't sure how. 

## Server
The server handles get requests from the applications by forwarding requests to various sources. These sources are specified by environment variables ```LBLOGBOOK_SOURCE```, ```CONTROL_PANEL_SOURCE``` and ```PROMETHEUS_SOURCE```. The server does not store any data except automatically caching data. The prometheus and logbook results update every 20 seconds, while the control panel updates every second.

#### Deployment
For deployment, some environment variables need to be set. In the ```docker_server``` directory, create a ```env_vars.env``` file and find values for these values

    LBLOGBOOK_SOURCE=
    CONTROL_PANEL_SOURCE=
    PROMETHEUS_SOURCE=
    CSRF_SESSION_KEY=
    SECRET_KEY=

Try asking Aristeidis Fkiaras. Then run ```./deployServer```.

Make sure that the ```server``` variable in ```lib/support/data_getter.dart``` is set to the deployment location of your server. The value as of 01.09.22 is ```http://lbcraver.cern.ch:80```.

#### Security
The important server functions are token protected. An unprotected page is the curent server version: http://lbcraver.cern.ch/version. Whereas a protected page will be inaccecable unless you also have a valid token in the header: http://lbcraver.cern.ch/control_panel?state=lbWeb/LHCb|LHCb_fsm_currentState.

In addition to the token security, the api of the server is very restrictive. The arguments in the get requests for prometheus and DIM are whitelisted. The lblogbook handler accepts any integer (page) number between 0 and 999 and is therefore also very restrictive.

The sources that the server communicates with are all inaccecable from outside the CERN network, so even if the apk of the app was decompiled and the adresses of the sources were extracted, it would be useless unless they already were inside the CERN network. 

#### Development notes
If there are network issues, try to 

	export http_proxy=http://lbproxy01:8080
	export https_proxy=http://lbproxy01:8080
	export HTTP_PROXY=http://lbproxy01:8080
	export HTTPS_PROXY=http://lbproxy01:8080
    
## Sources
These are usually small scripts that give us access to the data we want. Try asking Aristeidis Fkiaras.