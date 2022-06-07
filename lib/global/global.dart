import 'package:firebase_auth/firebase_auth.dart';

import '../models/direction_details_info.dart';
import '../models/user_model.dart';

final FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
UserModel? userModelCurrentInfo;
List dList = []; //online-active drivers Information List
DirectionDetailsInfo? tripDirectionDetailsInfo;
String? chosenDriverId = "";
String cloudMessagingServerToken =
    "key=AAAAOING-Is:APA91bHbsB6xKiIf1u18UQaPU_M_e4ZKm2XRl0h0QpIkXzEWbKH6OJfzr4-k5lTlpfuvU5Lzdxu0TtxgZnEC7tpFlYtLHtqejzpJ6B1ecpVN0bO4a8Opx6-Zkt_TDjxfte1dJbIuxEav";
String userDropOffAddress = "";
String driverCarDetails = "";
String driverName = "";
String driverPhone = "";
double countRatingStars = 0.0;
String titleStarsRating = "";
