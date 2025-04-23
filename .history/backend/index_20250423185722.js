const express = require('express');
const { createClient } = require('@supabase/supabase-js');
const jwt = require('jsonwebtoken');
const dotenv = require('dotenv');

dotenv.config();

const app = express();
app.use(express.json());

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_KEY);

// Your Supabase JWT public key from Supabase Dashboard
const SUPABASE_JWT_PUBLIC_KEY = process.env.SUPABASE_JWT_PUBLIC_KEY || 'your-supabase-jwt-public-key';

// Middleware to verify Supabase JWT token
async function verifyToken(req, res, next) {
  const token = req.headers.authorization?.split('Bearer ')[1];
  if (!token) return res.status(401).json({ error: 'No token provided' });

  try {
    // Verify Supabase JWT
    const decodedToken = jwt.verify(token, SUPABASE_JWT_PUBLIC_KEY, {
      algorithms: ['HS256'],
    });
    req.user = { uid: decodedToken.sub, email: decodedToken.email };
    console.log('Verified user:', decodedToken.sub, decodedToken.email);

    // Check if user exists in Supabase
    const { data: user, error } = await supabase
      .from('users')
      .select('user_id')
      .eq('user_id', decodedToken.sub)
      .maybeSingle();

    if (error) {
      console.error('User check error:', error);
      return res.status(500).json({ error: 'Server error', details: error.message });
    }

    if (!user) {
      console.log('Creating new user:', decodedToken.sub, decodedToken.email);
      const { error: insertError } = await supabase
        .from('users')
        .insert([{ user_id: decodedToken.sub, email: decodedToken.email || null }]);
      if (insertError) {
        console.error('User creation error:', insertError);
        return res.status(500).json({ error: 'Failed to create user', details: insertError.message });
      }
      console.log('User created successfully');
    }

    next();
  } catch (error) {
    console.error('Token verification error:', error);
    res.status(401).json({ error: 'Invalid token' });
  }
}

// Root route
app.get('/', (req, res) => {
  res.send('GlycoSnap Backend: Use /api/meals for API endpoints');
});

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
  console.log('Received payload:', req.body);
  const { food_name, glycemic_load, meal_type } = req.body;

  // Check for undefined or null, allow 0 for glycemic_load
  if (
    food_name === undefined || food_name === null || food_name === '' ||
    glycemic_load === undefined || glycemic_load === null ||
    meal_type === undefined || meal_type === null || meal_type === ''
  ) {
    return res.status(400).json({ error: 'Missing required fields' });
  }

  try {
    const { data, error } = await supabase
      .from('meals')
      .insert([
        {
          user_id: req.user.uid,
          name: food_name,
          glycemic_load: Number(glycemic_load),
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