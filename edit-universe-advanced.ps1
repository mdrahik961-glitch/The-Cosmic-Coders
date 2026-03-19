$path = "src\App.tsx"
$c = Get-Content $path -Raw

# 1) Add state
$c = $c.Replace(
@'
  const [missionResearchOpen, setMissionResearchOpen] = useState<MissionType | null>(null);
'@,
@'
  const [missionResearchOpen, setMissionResearchOpen] = useState<MissionType | null>(null);
  const [showUniverseEmbed, setShowUniverseEmbed] = useState(false);
  const [universeQuery, setUniverseQuery] = useState("galaxy");
  const [universeLoading, setUniverseLoading] = useState(true);
'@
)

# 2) Replace universe open button/link if present
$c = [regex]::Replace(
  $c,
  '<a\s+href="https://eyes\.nasa\.gov/apps/orrery/"[\s\S]*?Open NASA 3D Universe\s*</a>',
@'
<button
  style={{ ...styles.linkBtn, border: "none", cursor: "pointer" }}
  onClick={() => {
    setUniverseLoading(true);
    setShowUniverseEmbed(true);
  }}
>
  Open NASA 3D Universe
</button>
'@,
  [System.Text.RegularExpressions.RegexOptions]::Singleline
)

# 3) Fallback replace if button already exists
$c = $c.Replace(
@'
<button
  style={{ ...styles.linkBtn, border: "none", cursor: "pointer" }}
  onClick={() => setShowUniverseEmbed(true)}
>
  Open NASA 3D Universe
</button>
'@,
@'
<button
  style={{ ...styles.linkBtn, border: "none", cursor: "pointer" }}
  onClick={() => {
    setUniverseLoading(true);
    setShowUniverseEmbed(true);
  }}
>
  Open NASA 3D Universe
</button>
'@
)

# 4) Add overlay before MissionResearchGalleryModal
$overlay = @'
      {showUniverseEmbed && (
        <div style={styles.universeOverlay}>
          <div style={styles.universeTopBar}>
            <div style={styles.universeTopLeft}>
              <div style={{ fontWeight: 700, fontSize: 18 }}>NASA 3D Universe</div>

              <input
                value={universeQuery}
                onChange={(e) => setUniverseQuery(e.target.value)}
                placeholder="Search idea..."
                style={styles.universeSearchInput}
              />

              <div style={styles.universePresetRow}>
                {["Earth", "Mars", "Jupiter", "Voyager", "Hubble"].map((item) => (
                  <button
                    key={item}
                    style={styles.universePresetBtn}
                    onClick={() => setUniverseQuery(item)}
                  >
                    {item}
                  </button>
                ))}
              </div>
            </div>

            <button
              style={styles.universeCloseBtn}
              onClick={() => setShowUniverseEmbed(false)}
              title="Close"
            >
              ?
            </button>
          </div>

          <div style={styles.universeFrameWrap}>
            {universeLoading && (
              <div style={styles.universeLoadingBox}>
                Loading NASA 3D Universe...
              </div>
            )}

            <iframe
              src="https://eyes.nasa.gov/apps/orrery/"
              title="NASA 3D Universe"
              style={styles.universeFrame}
              allowFullScreen
              onLoad={() => setUniverseLoading(false)}
            />
          </div>

          <div style={styles.universeBottomBar}>
            <div>
              Search idea: <strong>{universeQuery}</strong>
            </div>

            <a
              href="https://eyes.nasa.gov/apps/orrery/"
              target="_blank"
              rel="noreferrer"
              style={styles.linkBtn}
            >
              Open in New Tab
            </a>
          </div>
        </div>
      )}

'@

if ($c -notmatch 'showUniverseEmbed && \(') {
  $c = $c.Replace(
@'
      <MissionResearchGalleryModal
'@,
$overlay + @'
      <MissionResearchGalleryModal
'@
  )
}

# 5) Add styles
$stylesInsert = @'
  universeOverlay: {
    position: "fixed",
    inset: 0,
    zIndex: 999,
    background: "rgba(0,0,0,0.95)",
    display: "flex",
    flexDirection: "column",
  },
  universeTopBar: {
    display: "flex",
    justifyContent: "space-between",
    alignItems: "flex-start",
    gap: 16,
    padding: 16,
    borderBottom: "1px solid rgba(255,255,255,0.08)",
    background: "rgba(8,12,28,0.96)",
  },
  universeTopLeft: {
    display: "grid",
    gap: 12,
    flex: 1,
  },
  universeSearchInput: {
    width: "100%",
    padding: "12px 14px",
    borderRadius: 14,
    border: "1px solid rgba(255,255,255,0.12)",
    background: "rgba(255,255,255,0.06)",
    color: "#fff",
    outline: "none",
    fontSize: 14,
    boxSizing: "border-box",
  },
  universePresetRow: {
    display: "flex",
    gap: 10,
    flexWrap: "wrap",
  },
  universePresetBtn: {
    border: "1px solid rgba(255,255,255,0.12)",
    background: "rgba(255,255,255,0.06)",
    color: "#fff",
    borderRadius: 999,
    padding: "8px 14px",
    fontWeight: 600,
    cursor: "pointer",
  },
  universeFrameWrap: {
    position: "relative",
    flex: 1,
  },
  universeFrame: {
    width: "100%",
    height: "100%",
    border: "none",
    background: "#000",
  },
  universeLoadingBox: {
    position: "absolute",
    inset: 0,
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    color: "#fff",
    background: "rgba(0,0,0,0.45)",
    zIndex: 2,
  },
  universeCloseBtn: {
    width: 54,
    height: 54,
    borderRadius: "50%",
    border: "1px solid rgba(255,255,255,0.16)",
    background: "rgba(255,255,255,0.08)",
    color: "#fff",
    fontSize: 28,
    cursor: "pointer",
  },
  universeBottomBar: {
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
    gap: 16,
    flexWrap: "wrap",
    padding: 16,
    borderTop: "1px solid rgba(255,255,255,0.08)",
    background: "rgba(8,12,28,0.96)",
  },
'@

if ($c -notmatch 'universeOverlay:\s*\{') {
  $c = $c.Replace(
@'
  phoneFieldWrap: {
    display: "flex",
    alignItems: "center",
    gap: 10,
    marginTop: 12,
  },
};
'@,
@'
  phoneFieldWrap: {
    display: "flex",
    alignItems: "center",
    gap: 10,
    marginTop: 12,
  },
'@ + $stylesInsert + @'
};
'@
  )
}

Set-Content -Path $path -Value $c
Write-Host "App.tsx advanced universe overlay added."
