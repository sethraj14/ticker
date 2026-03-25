import { ImageResponse } from "next/og"

export const runtime = "edge"

export async function GET() {
  return new ImageResponse(
    (
      <div
        style={{
          width: "1200px",
          height: "630px",
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          justifyContent: "center",
          background:
            "linear-gradient(135deg, #09090b 0%, #1a1a2e 50%, #16213e 100%)",
          fontFamily: "system-ui, sans-serif",
          position: "relative",
        }}
      >
        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: "16px",
            marginBottom: "24px",
          }}
        >
          <div style={{ fontSize: "64px" }}>&#x23F1;</div>
          <div
            style={{
              fontSize: "72px",
              fontWeight: 800,
              color: "white",
              letterSpacing: "-2px",
            }}
          >
            Ticker
          </div>
        </div>

        <div
          style={{
            fontSize: "32px",
            color: "#a1a1aa",
            textAlign: "center",
            maxWidth: "800px",
            lineHeight: 1.4,
          }}
        >
          Your next meeting, always in sight.
        </div>

        <div
          style={{
            display: "flex",
            gap: "12px",
            marginTop: "40px",
          }}
        >
          <div
            style={{
              padding: "10px 24px",
              borderRadius: "10px",
              background: "linear-gradient(90deg, #9333ea, #3b82f6)",
              color: "white",
              fontSize: "20px",
              fontWeight: 600,
            }}
          >
            Free Download
          </div>
          <div
            style={{
              padding: "10px 24px",
              borderRadius: "10px",
              border: "1px solid rgba(255,255,255,0.2)",
              color: "white",
              fontSize: "20px",
              fontWeight: 600,
            }}
          >
            Pro &mdash; $7.99
          </div>
        </div>

        <div
          style={{
            position: "absolute",
            bottom: "32px",
            fontSize: "16px",
            color: "#52525b",
          }}
        >
          Menu bar calendar for macOS
        </div>
      </div>
    ),
    { width: 1200, height: 630 }
  )
}
