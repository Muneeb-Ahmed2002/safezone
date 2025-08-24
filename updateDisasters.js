const axios = require("axios");
const admin = require("firebase-admin");
const fs = require("fs");

// Initialize Firebase
admin.initializeApp({
  credential: admin.credential.cert("./serviceAccountKey.json"),
});
const db = admin.firestore();
const USERS_COLLECTION = "users";

// Haversine formula to calculate distance (km)
function getDistanceFromLatLonInKm(lat1, lon1, lat2, lon2) {
  const R = 6371;
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLon = ((lon2 - lon1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLon / 2) ** 2;
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

// Get users from Firestore
async function getUsers() {
  const usersSnapshot = await db.collection(USERS_COLLECTION).get();
  return usersSnapshot.docs.map((doc) => doc.data());
}

// Push to Firestore with optional custom doc ID
async function pushToFirebase(collection, data, id = null) {
  const ref = id
    ? db.collection(collection).doc(id)
    : db.collection(collection).doc();
  await ref.set(data, { merge: true });
}

// Send push notification via FCM
async function sendNotification(user, title, body) {
  if (!user.fcmToken) return;
  const message = {
    token: user.fcmToken,
    notification: {
      title,
      body,
    },
  };
  try {
    await admin.messaging().send(message);
    console.log(`Notification sent to ${user.userName}`);
  } catch (err) {
    console.error("Error sending notification:", err);
  }
}

/**
 * Process USGS Earthquakes (last hour feed only)
 */
async function processEarthquakes(users) {
  const url =
    "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_hour.geojson";
  const res = await axios.get(url);
  const earthquakes = res.data.features || [];

  for (const eq of earthquakes) {
    const [lon, lat, depth] = eq.geometry.coordinates;
    const data = {
      magnitude: eq.properties.mag,
      location: eq.properties.place,
      time: new Date(eq.properties.time).toISOString(),
      url: eq.properties.url,
      type: eq.properties.type,
      depth,
      lat,
      lon,
      timestamp: new Date().toISOString(),
    };

    // Prevent duplicates using event ID
    await pushToFirebase("earthquakes", data, eq.id);

    // Notify users within 400 km if magnitude >= 4.5
    if (data.magnitude >= 4.5) {
      for (const user of users) {
        const distance = getDistanceFromLatLonInKm(
          user.latitude,
          user.longitude,
          lat,
          lon
        );
        if (distance <= 400) {
          await sendNotification(
            user,
            `Earthquake Alert (M${data.magnitude})`,
            `${data.location} at ${data.time}`
          );
        }
      }
    }
  }
}

/**
 * Process GDACS (filtered to last 24h events only)
 */
async function processGDACS(users) {
  const url = "https://www.gdacs.org/gdacsapi/api/events/geteventlist/MAP";
  const res = await axios.get(url);
  const events = Array.isArray(res.data?.features) ? res.data.features : [];

  const now = new Date();
  const oneDayAgo = new Date(now.getTime() - 24 * 60 * 60 * 1000);

  for (const event of events) {
    const props = event.properties;
    const coords = event.geometry.coordinates;

    const fromDate = new Date(props.fromdate);
    const toDate = props.todate ? new Date(props.todate) : null;

    // Skip events that ended more than a day ago
    if (fromDate < oneDayAgo && (!toDate || toDate < oneDayAgo)) {
      continue;
    }

    const data = {
      type: props.eventtype,
      country: props.country,
      description: props.description,
      alertLevel: props.alertlevel,
      fromDate: props.fromdate,
      toDate: props.todate,
      latitude: coords[1],
      longitude: coords[0],
      url: props.url?.details || null,
      timestamp: new Date().toISOString(),
    };

    await pushToFirebase(
      `disasters_${props.eventtype.toLowerCase()}`,
      data,
      props.eventid.toString()
    );

    // Send notifications for high alert events within 400 km
    if (["Orange", "Red"].includes(props.alertlevel)) {
      for (const user of users) {
        const distance = getDistanceFromLatLonInKm(
          user.latitude,
          user.longitude,
          data.latitude,
          data.longitude
        );
        if (distance <= 400) {
          await sendNotification(
            user,
            `${props.eventtype} Alert (${props.alertlevel})`,
            `${props.description} in ${props.country}`
          );
        }
      }
    }
  }
}

/**
 * Process Weather for each user
 */
async function processWeather(users) {
  for (const user of users) {
    if (!user.latitude || !user.longitude) continue;

    const url = `https://api.openweathermap.org/data/2.5/weather?lat=${user.latitude}&lon=${user.longitude}&appid=${process.env.OPENWEATHER_API_KEY}&units=metric`;
    const res = await axios.get(url);
    const temp = res.data.main.temp;

    const data = {
      user: user.userName,
      location: res.data.name,
      temperature: temp,
      time: new Date().toISOString(),
      userLat: user.latitude,
      userLon: user.longitude,
    };

    await pushToFirebase(
      "weather",
      data,
      `${user.userName}_${Date.now()}`
    );
  }
}

/**
 * Main Orchestrator
 */
async function main() {
  try {
    const users = await getUsers();

    try {
      await processGDACS(users);
      console.log("GDACS data pushed.");
    } catch (err) {
      console.error("Error in GDACS:", err);
    }

    try {
      await processEarthquakes(users);
      console.log("Earthquake data pushed.");
    } catch (err) {
      console.error("Error in Earthquakes:", err);
    }

    try {
      await processWeather(users);
      console.log("Weather data pushed.");
    } catch (err) {
      console.error("Error in Weather:", err);
    }

    console.log("All disaster data successfully pushed.");
  } catch (err) {
    console.error("Fatal Error:", err);
  }
}

main();
