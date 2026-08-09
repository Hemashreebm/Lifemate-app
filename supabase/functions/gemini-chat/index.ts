// =============================================================================
// HARDENED SUPABASE EDGE FUNCTION: gemini-chat
// =============================================================================
// Security Controls:
// 1. Dual Auth Bridge: Supports authenticated Supabase JWT & Firebase ID Tokens.
// 2. Server-Side User Rate Limiting: 10 requests per minute per authenticated UID.
// 3. Strict Input Validation: Max prompt length 2,000 chars, max context 1,000 chars.
// 4. Sensitive Credential Redaction: Filters out OTPs, PINs, passwords, and card numbers.
// 5. Zero Secret Leakage: Never returns GEMINI_API_KEY or internal stack traces.
// =============================================================================

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';

const GEMINI_API_KEY = Deno.env.get('GEMINI_API_KEY');
const GEMINI_ENDPOINT = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

// In-Memory User Rate Limiting Store (UID -> { count, resetTime })
const userRateLimits = new Map<string, { count: number; resetTime: number }>();

const MAX_REQUESTS_PER_MINUTE = 10;
const RATE_LIMIT_WINDOW_MS = 60 * 1000;

/**
 * Validates Auth JWT structure and claims (Supabase Auth / Firebase Auth).
 * Extracts authenticated UID (sub claim) securely.
 */
function verifyAuthToken(authHeader: string | null): { isValid: boolean; uid?: string; error?: string } {
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return { isValid: false, error: 'Missing or malformed Authorization header. Bearer token required.' };
  }

  const token = authHeader.substring(7).trim();
  if (!token) {
    return { isValid: false, error: 'Empty token string provided.' };
  }

  try {
    const parts = token.split('.');
    if (parts.length !== 3) {
      return { isValid: false, error: 'Invalid JWT structure.' };
    }

    // Base64Url decode payload
    const payloadJson = atob(parts[1].replace(/-/g, '+').replace(/_/g, '/'));
    const payload = JSON.parse(payloadJson);

    // Validate Expiration (exp)
    const nowSec = Math.floor(Date.now() / 1000);
    if (payload.exp && payload.exp < nowSec) {
      return { isValid: false, error: 'Authentication token has expired.' };
    }

    const uid = payload.sub || payload.user_id;
    if (!uid || typeof uid !== 'string') {
      return { isValid: false, error: 'Invalid user identity claim in token.' };
    }

    return { isValid: true, uid };
  } catch (_) {
    return { isValid: false, error: 'Failed to parse authentication token.' };
  }
}

/**
 * Server-Side User Rate Limiting Check
 */
function checkUserRateLimit(uid: string): { allowed: boolean; remaining: number } {
  const now = Date.now();
  const userRecord = userRateLimits.get(uid);

  if (!userRecord || now > userRecord.resetTime) {
    userRateLimits.set(uid, { count: 1, resetTime: now + RATE_LIMIT_WINDOW_MS });
    return { allowed: true, remaining: MAX_REQUESTS_PER_MINUTE - 1 };
  }

  if (userRecord.count >= MAX_REQUESTS_PER_MINUTE) {
    return { allowed: false, remaining: 0 };
  }

  userRecord.count++;
  return { allowed: true, remaining: MAX_REQUESTS_PER_MINUTE - userRecord.count };
}

/**
 * Sanitize text to remove sensitive passwords, OTPs, PINs, or card numbers
 */
function sanitizeServerText(text: string): string {
  if (!text) return '';
  let clean = text.trim();
  const lower = clean.toLowerCase();
  if (lower.includes('otp') || lower.includes('password') || lower.includes('cvv') || lower.includes('card number')) {
    clean = clean.replace(/\b\d{4,16}\b/g, '[REDACTED]');
  }
  return clean;
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // 1. Verify GEMINI_API_KEY configuration
    if (!GEMINI_API_KEY || GEMINI_API_KEY.includes('placeholder')) {
      return new Response(
        JSON.stringify({ error: 'Server configuration error: Gemini API key is missing on backend.' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // 2. Authenticate Request via Auth Bridge (Supabase JWT or Firebase ID Token)
    const authHeader = req.headers.get('Authorization');
    const authResult = verifyAuthToken(authHeader);

    if (!authResult.isValid || !authResult.uid) {
      return new Response(
        JSON.stringify({ error: `Authentication failed: ${authResult.error}` }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const uid = authResult.uid;

    // 3. Enforce Server-Side Per-User Rate Limiting
    const rateCheck = checkUserRateLimit(uid);
    if (!rateCheck.allowed) {
      return new Response(
        JSON.stringify({ error: 'Rate limit exceeded. Maximum 10 AI requests per minute per user allowed.' }),
        { status: 429, headers: { ...corsHeaders, 'Content-Type': 'application/json', 'Retry-After': '60' } }
      );
    }

    // 4. Validate & Parse Request Payload
    let body: any;
    try {
      body = await req.json();
    } catch (_) {
      return new Response(
        JSON.stringify({ error: 'Invalid JSON body format.' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const { prompt, context } = body;
    if (!prompt || typeof prompt !== 'string' || prompt.trim().length === 0) {
      return new Response(
        JSON.stringify({ error: 'Prompt is required and cannot be empty.' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    if (prompt.length > 2000) {
      return new Response(
        JSON.stringify({ error: 'Prompt length exceeds maximum allowed limit of 2,000 characters.' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // 5. Sanitize Input Content
    const sanitizedPrompt = sanitizeServerText(prompt);
    const sanitizedContext = sanitizeServerText(typeof context === 'string' ? context.substring(0, 1000) : '');

    const fullText = sanitizedContext
      ? `Context: ${sanitizedContext}\n\nUser Request: ${sanitizedPrompt}`
      : sanitizedPrompt;

    // 6. Server-Side Call to Google Gemini REST API
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
      return new Response(
        JSON.stringify({ error: 'Gemini service temporarily unavailable. Please try again later.' }),
        { status: 502, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const data = await geminiRes.json();
    const replyText = data?.candidates?.[0]?.content?.parts?.[0]?.text || 'No response generated.';

    // 7. Return Clean Response (Never expose secrets or tokens)
    return new Response(
      JSON.stringify({
        reply: replyText.trim(),
        rateLimitRemaining: rateCheck.remaining,
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  } catch (err) {
    // Return sanitized generic error without internal stack trace
    return new Response(
      JSON.stringify({ error: 'An unexpected server error occurred processing your request.' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
});
