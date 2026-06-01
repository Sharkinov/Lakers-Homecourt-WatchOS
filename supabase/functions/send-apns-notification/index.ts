import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const APNS_KEY_ID = Deno.env.get("APNS_KEY_ID")!;
const APNS_TEAM_ID = Deno.env.get("APNS_TEAM_ID")!;
const APNS_BUNDLE_ID = Deno.env.get("APNS_BUNDLE_ID")!;
const APNS_PRIVATE_KEY = Deno.env.get("APNS_PRIVATE_KEY")!;

async function generateJWT(): Promise<string> {
  const header = { alg: "ES256", kid: APNS_KEY_ID };
  const payload = { iss: APNS_TEAM_ID, iat: Math.floor(Date.now() / 1000) };

  const encode = (obj: object) =>
    btoa(JSON.stringify(obj))
      .replace(/=/g, "")
      .replace(/\+/g, "-")
      .replace(/\//g, "_");

  const headerB64 = encode(header);
  const payloadB64 = encode(payload);
  const signingInput = `${headerB64}.${payloadB64}`;

  const pemContents = APNS_PRIVATE_KEY
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replace(/\s/g, "");

  const binaryKey = Uint8Array.from(atob(pemContents), (c) => c.charCodeAt(0));

  const key = await crypto.subtle.importKey(
    "pkcs8",
    binaryKey,
    { name: "ECDSA", namedCurve: "P-256" },
    false,
    ["sign"]
  );

  const signature = await crypto.subtle.sign(
    { name: "ECDSA", hash: "SHA-256" },
    key,
    new TextEncoder().encode(signingInput)
  );

  const signatureB64 = btoa(String.fromCharCode(...new Uint8Array(signature)))
    .replace(/=/g, "")
    .replace(/\+/g, "-")
    .replace(/\//g, "_");

  return `${signingInput}.${signatureB64}`;
}

async function sendAPNS(deviceToken: string, title: string, body: string) {
  const jwt = await generateJWT();
  const url = `https://api.push.apple.com/3/device/${deviceToken}`;

  const response = await fetch(url, {
    method: "POST",
    headers: {
      "authorization": `bearer ${jwt}`,
      "apns-topic": APNS_BUNDLE_ID,
      "apns-push-type": "alert",
      "content-type": "application/json",
    },
    body: JSON.stringify({
      aps: { alert: { title, body }, sound: "default" },
    }),
  });

  return response.status;
}

serve(async (req) => {
  try {
    const payload = await req.json();
    const oldRecord = payload.old_record;
    const newRecord = payload.record;

    if (!oldRecord || !newRecord) {
      return new Response(JSON.stringify({ message: "No record data" }), { status: 200 });
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    // Get opponent name
    const { data: teamData } = await supabase
      .schema("simulacion_juego")
      .from("team")
      .select("abreviatura")
      .eq("team_id", newRecord.opposing_team_id)
      .single();

    const opponent = teamData?.abreviatura ?? "OPP";

    // Get scores from v_scoreboard view
    const { data: scoreData } = await supabase
      .schema("simulacion_juego")
      .from("v_scoreboard")
      .select("lakers_score, opposing_score")
      .eq("game_id", newRecord.game_id)
      .single();

    const lakersScore = scoreData?.lakers_score ?? 0;
    const opponentScore = scoreData?.opposing_score ?? 0;

    let title = "";
    let body = "";

    // Game started: current_quarter changed from 0 to 1
    if (oldRecord.current_quarter === 0 && newRecord.current_quarter === 1) {
      title = "Game started";
      body = `Lakers vs ${opponent} — Live now`;
    }
    // Quarter changed
    else if (oldRecord.current_quarter !== newRecord.current_quarter && newRecord.current_quarter > 1) {
      title = `Q${newRecord.current_quarter} started`;
      body = `LAL ${lakersScore} - ${opponent} ${opponentScore}`;
    }
    // Game ended
    else if (!oldRecord.game_end_time && newRecord.game_end_time) {
      title = newRecord.won ? "Lakers win" : "Lakers lose";
      body = `Final: LAL ${lakersScore} - ${opponent} ${opponentScore}`;
    }
    // No relevant change
    else {
      return new Response(JSON.stringify({ message: "No notification needed" }), { status: 200 });
    }

    // Get all device tokens
    const { data: tokens } = await supabase
      .schema("simulacion_juego")
      .from("device_tokens_watchos")
      .select("device_token");

    if (!tokens || tokens.length === 0) {
      return new Response(JSON.stringify({ message: "No tokens found" }), { status: 200 });
    }

    await Promise.all(tokens.map((t) => sendAPNS(t.device_token, title, body)));

    return new Response(JSON.stringify({ sent: tokens.length, title, body }), { status: 200 });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500 });
  }
});