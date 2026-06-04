import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { create, getNumericDate } from "https://deno.land/x/djwt@v3.0.0/mod.ts";

const APNS_KEY_ID = Deno.env.get("APNS_KEY_ID")!;
const APNS_TEAM_ID = Deno.env.get("APNS_TEAM_ID")!;
const APNS_BUNDLE_ID = Deno.env.get("APNS_BUNDLE_ID")!;
const APNS_PRIVATE_KEY = Deno.env.get("APNS_PRIVATE_KEY")!;

async function generateJWT(): Promise<string> {
  const pemContents = APNS_PRIVATE_KEY
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replace(/\s/g, "");

  const binaryKey = Uint8Array.from(atob(pemContents), (c) => c.charCodeAt(0));

  const key = await crypto.subtle.importKey(
    "pkcs8",
    binaryKey,
    { name: "ECDSA", namedCurve: "P-256" },
    true,
    ["sign"]
  );

  const jwt = await create(
    { alg: "ES256", kid: APNS_KEY_ID },
    { iss: APNS_TEAM_ID, iat: getNumericDate(0) },
    key
  );

  return jwt;
}

async function sendAPNS(deviceToken: string, title: string, body: string) {
  const jwt = await generateJWT();

  for (const env of ["development", "production"]) {
    const url = `https://api.push.apple.com/3/device/${deviceToken}`;
    const response = await fetch(url, {
      method: "POST",
      headers: {
        "authorization": `bearer ${jwt}`,
        "apns-topic": APNS_BUNDLE_ID,
        "apns-push-type": "alert",
        "apns-environment": env,
        "content-type": "application/json",
      },
      body: JSON.stringify({
        aps: { alert: { title, body }, sound: "default" },
      }),
    });
    const responseText = await response.text();
    console.log(`APNs [${env}] response: ${response.status} - ${responseText}`);
    if (response.status === 200) return response.status;
  }
  return 400;
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

    const { data: teamData } = await supabase
      .schema("simulacion_juego")
      .from("team")
      .select("abreviatura")
      .eq("team_id", newRecord.opposing_team_id)
      .single();

    const opponent = teamData?.abreviatura ?? "OPP";

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

    if (oldRecord.current_quarter === 0 && newRecord.current_quarter === 1) {
      title = "Game started";
      body = `Lakers vs ${opponent} — Live now`;
    } else if (oldRecord.current_quarter !== newRecord.current_quarter && newRecord.current_quarter > 1) {
      title = `Q${newRecord.current_quarter} started`;
      body = `LAL ${lakersScore} - ${opponent} ${opponentScore}`;
    } else if (!oldRecord.game_end_time && newRecord.game_end_time) {
      title = newRecord.won ? "Lakers win" : "Lakers lose";
      body = `Final: LAL ${lakersScore} - ${opponent} ${opponentScore}`;
    } else {
      return new Response(JSON.stringify({ message: "No notification needed" }), { status: 200 });
    }

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