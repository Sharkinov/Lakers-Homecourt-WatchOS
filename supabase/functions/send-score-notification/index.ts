import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const APNS_KEY_ID = Deno.env.get("APNS_KEY_ID")!;
const APNS_TEAM_ID = Deno.env.get("APNS_TEAM_ID")!;
const APNS_BUNDLE_ID = Deno.env.get("APNS_BUNDLE_ID")!;
const APNS_PRIVATE_KEY = Deno.env.get("APNS_PRIVATE_KEY")!;

const LAKERS_TEAM_ID = 1;

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
    const newRecord = payload.record;

    if (!newRecord) {
      return new Response(JSON.stringify({ message: "No record data" }), { status: 200 });
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    // get player's team
    const { data: playerData } = await supabase
      .schema("simulacion_juego")
      .from("team_player")
      .select("team_id")
      .eq("team_player_id", newRecord.team_player_id)
      .single();

    if (!playerData) {
      return new Response(JSON.stringify({ message: "Player not found" }), { status: 200 });
    }

    const scoringTeamId = playerData.team_id;

    // only notify when Lakers score
    if (scoringTeamId !== LAKERS_TEAM_ID) {
      return new Response(JSON.stringify({ message: "Opponent scored, no notification" }), { status: 200 });
    }

    const gameId = newRecord.game_id;

    // get current scores
    const { data: scoreData } = await supabase
      .schema("simulacion_juego")
      .from("v_scoreboard")
      .select("lakers_score, opposing_score")
      .eq("game_id", gameId)
      .single();

    if (!scoreData) {
      return new Response(JSON.stringify({ message: "Score not found" }), { status: 200 });
    }

    const lakersScore = scoreData.lakers_score ?? 0;
    const opponentScore = scoreData.opposing_score ?? 0;

    // get opponent abbreviation
    const { data: gameData } = await supabase
      .schema("simulacion_juego")
      .from("game")
      .select("opposing_team_id")
      .eq("game_id", gameId)
      .single();

    const { data: teamData } = await supabase
      .schema("simulacion_juego")
      .from("team")
      .select("abreviatura")
      .eq("team_id", gameData?.opposing_team_id)
      .single();

    const opponentAbbr = teamData?.abreviatura ?? "OPP";

    let title = "Lakers score";
    let body = `LAL ${lakersScore} - ${opponentAbbr} ${opponentScore}`;

    // check for lakers run — 5+ unanswered points
    const { data: recentStats } = await supabase
      .schema("simulacion_juego")
      .from("team_player_stats")
      .select("team_player_id, points")
      .eq("game_id", gameId)
      .order("team_player_stats_id", { ascending: false })
      .limit(20);

    if (recentStats) {
      let lakersRun = 0;
      for (const stat of recentStats) {
        const { data: tp } = await supabase
          .schema("simulacion_juego")
          .from("team_player")
          .select("team_id")
          .eq("team_player_id", stat.team_player_id)
          .single();

        if (tp?.team_id === LAKERS_TEAM_ID) {
          lakersRun += stat.points;
        } else if (stat.points > 0) {
          break;
        }
      }

      if (lakersRun >= 5) {
        title = "Lakers on a run";
        body = `${lakersRun} unanswered points — LAL ${lakersScore} - ${opponentAbbr} ${opponentScore}`;
      }
    }

    // get all device tokens
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