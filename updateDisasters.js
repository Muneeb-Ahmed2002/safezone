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

async function processGDACS(users) {
  const url = 'https://www.gdacs.org/gdacsapi/api/events/geteventlist/MAP?alertlevel=red,orange&eventtype=FL,TC';
  const res = await axios.get(url);
  const events = res.data.results;

  for (const event of events) {
    const lat = parseFloat(event.latitude);
    const lon = parseFloat(event.longitude);
    const type = event.eventtype === 'FL' ? 'floods' : 'cyclones';

    for (const user of users) {
      const dist = getDistanceFromLatLonInKm(lat, lon, user.latitude, user.longitude);
      if (dist < RADIUS_KM) {
        await pushToFirebase(type, {
          user: user.userName,
          location: event.country,
          title: event.eventname,
          time: new Date().toISOString(),
          userLat: user.latitude,
          userLon: user.longitude
        });
      }
    }
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
    await processEarthquakes(users);
    await processGDACS(users);
    await processHeatwaves(users);
    console.log('✅ Disaster data successfully pushed.');
  } catch (err) {
    console.error('Error:', err);
    process.exit(1);
  }
}

main();
