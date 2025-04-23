const express = require('express');
const { createClient } = require('@supabase/supabase-js');
const admin = require('firebase-admin');
const dotenv = require('dotenv');

dotenv.config();
const app = express();
app.use(express.json());

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert('./firebase-credentials.json'),
});

// Initialize Supabase
const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_KEY);

// Middleware to verify Firebase token
const verifyToken = async (req, res, next) => {
  const token = req.headers.authorization?.split('Bearer ')[1];
  if (!token) return res.status(401).send('Unauthorized');
  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    req.user = decodedToken;
    next();
  } catch (error) {
    res.status(401).send('Invalid token');
  }
};

// API to add a meal
app.post('/api/meals', verifyToken, async (req, res) => {
  const { food_name, glycemic_load, meal_type } = req.body;
  try {
    const { data, error } = await supabase
      .from('meals')
      .insert([{ user_id: req.user.uid, food_name, glycemic_load, meal_type }])
      .select();
    if (error) throw error;
    res.status(201).json(data[0]);
  } catch (error) {
    res.status(500).send(error.message);
  }
});

// API to get user meals
app.get('/api/meals', verifyToken, async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('meals')
      .select('*')
      .eq('user_id', req.user.uid)
      .order('created_at', { ascending: false });
    if (error) throw error;
    res.json(data);
  } catch (error) {
    res.status(500).send(error.message);
  }
});

app.listen(process.env.PORT, () => {
  console.log(`Server running on port ${process.env.PORT}`);
});