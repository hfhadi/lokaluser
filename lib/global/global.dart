import 'package:firebase_auth/firebase_auth.dart';

import '../models/direction_details_info.dart';
import '../models/user_model.dart';

final FirebaseAuth gFirebaseAuth = FirebaseAuth.instance;
User? gCurrentFirebaseUser;
UserModel? gUserModelCurrentInfo;
List gSortedDriverList = []; //online-active drivers Information List
DirectionDetailsInfo? gTripDirectionDetailsInfo;
String? gChosenDriverId = "";
String gCloudMessagingServerToken =
    "key=AAAAOING-Is:APA91bHbsB6xKiIf1u18UQaPU_M_e4ZKm2XRl0h0QpIkXzEWbKH6OJfzr4-k5lTlpfuvU5Lzdxu0TtxgZnEC7tpFlYtLHtqejzpJ6B1ecpVN0bO4a8Opx6-Zkt_TDjxfte1dJbIuxEav";
String gUserDropOffAddress = "";
String gDriverCarDetails = "";
String gDriverName = "";
String gDriverPhone = "";
double gCountRatingStars = 0.0;
String titleStarsRating = "";
