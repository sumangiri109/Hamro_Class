# hamro_project
Getting Started

## Create dev branch and set as default, best practice:
 # Folder Structure:

1.  assets folder in main project file (not inside the lib   folder) , define the path in pubspec.yaml file.

2.  Inside lib folder : </br>

        a. constant (folder):
    - create files like: const.dart, images.dart, fonts.dart, string.dart etc. (you can add more files)  </br>

            b.i = core (folder):
    - create models folder : </br>
    inside models folder make files for models (eg: user_models.dart).

             b.ii =  create services (folder):
      - inside servies folder create services files : ( eg: user_services.dart  ).

            3. create presentation(folder):
       - inside presentation folder create: </br>

              3.1 auth (folder): 
        - which contains : login, signup, forgotpassword, changepassword, etc.. </br>

               3.2  permission_handler(folder):
       - where the files related with asking permission (eg: location permission, photos permission) should be handled  inside file name : permission.dart

              3.3  screens(folders):
      - which should contains the folder like (homepage,aboutus , contactus and all other folders): </br>  inside homepage folder there should be files related with homepage screen.

     ## Note:                                </br> Inside screens create widget folder where all the widgets should be stored or you can store each widgets in their individual screens . 


      
     




