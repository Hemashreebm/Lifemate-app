export async function GET() {
  return new Response('google-site-verification: google9151c5689f04c1cd.html', {
    headers: {
      'Content-Type': 'text/html',
    },
  });
}
