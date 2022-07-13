importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
   apiKey: "AIzaSyDbkI8uwv1xVSlIVV3I2dILxs9-foMdNgY",
            authDomain: "geetaxi-15c74.firebaseapp.com",
            databaseURL: "https://geetaxi-15c74.firebaseio.com",
            projectId: "geetaxi-15c74",
            storageBucket: "geetaxi-15c74.appspot.com",
            messagingSenderId: "242720635019",
            appId: "1:242720635019:web:c2781e12c5e3b516363c8e",
});
// Necessary to receive background messages:
const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((m) => {
  console.log("onBackgroundMessage", m);
});
