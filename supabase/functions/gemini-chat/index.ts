// =============================================================================
// SUPABASE EDGE FUNCTION: gemini-chat
// =============================================================================
// Server-side proxy for Google Gemini API.
// Keeps the GEMINI_API_KEY secure in Supabase Server Environment Secrets.
// Never exposes the API key to the client APK or HTTP response.
// =============================================================================

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';

const GEMINI_API_KEY = Deno.env.get('GEMINI_API_KEY');
const GEMINI_ENDPOINT = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    if (!GEMINI_API_KEY) {
      return new Response(
        JSON.stringify({ error: 'Server configuration error: Gemini API key is missing on backend.' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const { prompt, context } = await req.json();

    if (!prompt || typeof prompt !== 'string' || prompt.trim().length === 0) {
      return new Response(
        JSON.stringify({ error: 'Invalid prompt provided.' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Truncate oversized prompts (Max 2000 characters for rate limit safety)
    const sanitizedPrompt = prompt.trim().substring(0, 2000);
    const sanitizedContext = (context || '').substring(0, 1000);

    const fullText = sanitizedContext
      ? `System Context: ${sanitizedContext}\n\nUser Prompt: ${sanitizedPrompt}`
      : sanitizedPrompt;

    // Call Google Gemini REST API server-side
    const geminiRes = await fetch(`${GEMINI_ENDPOINT}?key=${GEMINI_API_KEY}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [
          {
            parts: [{ text: fullText }],
          },
        ],
        generationConfig: {
          temperature: 0.7,
          maxOutputTokens: 500,
        },
      }),
    });

    if (!geminiRes.ok) {
      const errText = await geminiRes.text();
      console.error('[GEMINI SERVER ERROR]', errText);
      return new Response(
        JSON.stringify({ error: 'Gemini service temporarily unavailable. Please try again.' }),
        { status: 502, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const data = await geminiRes.json();
    const candidateText = data?.candidates?.[0]?.content?.parts?.[0]?.text || 'No response generated.';

    return new Response(
      JSON.stringify({ reply: candidateText }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  } catch (error) {
    console.error('[EDGE FUNCTION EXCEPTION]', error);
    return new Response(
      JSON.stringify({ error: 'Server error processing request.' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
});
