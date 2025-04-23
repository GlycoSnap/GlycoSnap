const express = require('express');
const { createClient } = require('@supabase/supabase-js');
const admin = require('firebase-admin');
const dotenv = require('dotenv');

dotenv.config();

const app = express();
app.use(express.json());

admin.initializeApp({
  credential: admin.credential.cert('./firebase-credentials.json'),
});

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_KEY);

// Middleware to verify Firebase token
async function verifyToken(req, res, next) {
  const token = req.headers.authorization?.split('Bearer ')[1];
  if (!token) return res.status(401).json({ error: 'No token provided' });

  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    req.user = decodedToken;

    // Check if user exists in Supabase, create if not
    const { data: user, error } = await supabase
      .from('users')
      .select('user_id')
      .eq('user_id', decodedToken.uid)
      .single();

    if (error && error.code === 'PGRST116') { // User not found
      const { error: insertError } = await supabase
        .from('users')
        .insert([{ user_id: decodedToken.uid, email: decodedToken.email }]);
      if (insertError) {
        console.error('Error creating user:', insertError);
        return res.status(500).json({ error: 'Failed to create user' });
      }
    } else if (error) {
      console.error('Error checking user:', error);
      return res.status(500).json({ error: 'Server error' });
    }

    next();
  } catch (error) {
    console.error('Token verification error:', error);
    res.status(401).json({ error: 'Invalid token' });
  }
}

// GET /api/meals
app.get('/api/meals', verifyToken, async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('meals')
      .select('*')
      .eq('user_id', req.user.uid);
    if (error) throw error;
    res.json(data);
  } catch (error) {
    console.error('Error fetching meals:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// POST /api/meals
app.post('/api/meals', verifyToken, async (req, res) => {
  const { food_name, glycemic_load, meal_type } = req.body;
  if (!food_name || !glycemic_load || !meal_type) {
    return res.status(400).json({ error: 'Missing required fields' });
  }

  try {
    const { data, error } = await supabase
      .from('meals')
      .insert([
        {
          user_id: req.user.uid,
          food_name,
          glycemic_load,
          meal_type,
          created_at: new Date().toISOString(),
        },
      ])
      .select();
    if (error) throw error;
    res.status(201).json(data[0]);
  } catch (error) {
    console.error('Error adding meal:', error);
    res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));