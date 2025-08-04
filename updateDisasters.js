const axios = require('axios');
const admin = require('firebase-admin');
const fs = require('fs');

// Initialize Firebase
admin.initializeApp({
  credential: admin.credential.cert('./serviceAccountKey.json')
});
const db = admin.firestore();

const USERS_COLLECTION = 'users';
const RADIUS_KM = 300; // distance to check in kilometers

// Haversine formula
function getDistanceFromLatLonInKm(lat1, lon1, lat2, lon2) {
  const R = 6371; // Radius of earth in km
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

async function getUsers() {
  const usersSnapshot = await db.collection(USERS_COLLECTION).get();
  return usersSnapshot.docs.map(doc => doc.data());
}

// Push to collection
async function pushToFirebase(collection, data) {
  const ref = db.collection(collection).doc();
  await ref.set(data);
}

async function processEarthquakes(users) {
  const url = 'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_hour.geojson';
  const res = await axios.get(url);
  const earthquakes = res.data.features;

  for (const eq of earthquakes) {
    const [lon, lat] = eq.geometry.coordinates;
    const time = new Date(eq.properties.time).toISOString();
    const magnitude = eq.properties.mag;
    const place = eq.properties.place;

    for (const user of users) {
      const dist = getDistanceFromLatLonInKm(lat, lon, user.latitude, user.longitude);
      if (dist < RADIUS_KM) {
        await pushToFirebase('earthquakes', {
          user: user.userName,
          location: place,
          magnitude,
          time,
          userLat: user.latitude,
          userLon: user.longitude
        });
      }
    }
  }
}

async function processGDACS() {
  const response = await fetch("https://www.gdacs.org/gdacsapi/api/events/geteventlist/MAP");
  const gdacsData = await response.json();

  const events = Array.isArray(gdacsData?.features) ? gdacsData.features : [];

  for (const event of events) {
    const props = event.properties;
    const coords = event.geometry.coordinates;

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
      timestamp: new Date().toISOString()
    };

    const docRef = doc(firestore, `disasters_${props.eventtype.toLowerCase()}`, `${props.eventid}`);
    await setDoc(docRef, data, { merge: true });
    console.log(`GDACS event stored: ${props.eventid}`);
  }
}

async function processHeatwaves(users) {
  for (const user of users) {
    const url = `https://api.openweathermap.org/data/2.5/weather?lat=${user.latitude}&lon=${user.longitude}&appid=${process.env.OPENWEATHER_API_KEY}&units=metric`;
    const res = await axios.get(url);
    const temp = res.data.main.temp;

    if (temp >= 40) {
      await pushToFirebase('heatwaves', {
        user: user.userName,
        location: res.data.name,
        temperature: temp,
        time: new Date().toISOString(),
        userLat: user.latitude,
        userLon: user.longitude
      });
    }
  }
}

async function main() {
  try {
    const users = await getUsers();
    try {
      await processGDACS();
    } catch (err) {
      console.error("Error in GDACS:", err);
    }
    try {
          await processEarthquakes(users);
        } catch (err) {
          console.error("Error in GDACS:", err);
        }
    try {
              await processHeatwaves(users);;
            } catch (err) {
              console.error("Error in GDACS:", err);
            }
    console.log('Disaster data successfully pushed.');
  } catch (err) {
    console.error('Error:', err);
  }
}

main();
