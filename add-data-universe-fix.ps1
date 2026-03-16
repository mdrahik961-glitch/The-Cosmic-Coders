$path = "src\App.tsx"
$c = Get-Content $path -Raw

# 1. Update SearchItem type
$c = $c.Replace(@'
type SearchItem = {
  id: string;
  title: string;
  description: string;
  date: string;
  image?: string;
  source?: string;
};
'@, @'
type SearchItem = {
  id: string;
  title: string;
  description: string;
  date: string;
  image?: string;
  source?: string;
  sourceLink?: string;
};
'@)

# 2. Increase search results from 6 to 24
$c = $c.Replace('.slice(0, 6).map((item: any, index: number) => ({', '.slice(0, 24).map((item: any, index: number) => ({')

# 3. Add sourceLink to nasa search results
$c = $c.Replace(@'
          source: "NASA Image Library",
        }));
'@, @'
          source: "NASA Image Library",
          sourceLink: item?.data?.[0]?.nasa_id
            ? https://images.nasa.gov/details/${item.data[0].nasa_id}
            : item?.href || "",
        }));
'@)

# 4. Add showUniverseEmbed state
$c = $c.Replace(@'
  const [missionResearchOpen, setMissionResearchOpen] = useState<MissionType | null>(null);
'@, @'
  const [missionResearchOpen, setMissionResearchOpen] = useState<MissionType | null>(null);
  const [showUniverseEmbed, setShowUniverseEmbed] = useState(false);
'@)

# 5. Add More About It button in searchResults cards
$c = $c.Replace(@'
                  <div style={{ padding: 14 }}>
                    <h4 style={{ margin: 0, fontSize: 18 }}>{item.title}</h4>
                    <p style={{ ...styles.panelText, marginTop: 10 }}>{item.description}</p>
                    <div style={{ fontSize: 12, color: "rgba(255,255,255,0.45)" }}>{safeDateLabel(item.date)}</div>
                  </div>
'@, @'
                  <div style={{ padding: 14 }}>
                    <h4 style={{ margin: 0, fontSize: 18 }}>{item.title}</h4>
                    <p style={{ ...styles.panelText, marginTop: 10 }}>{item.description}</p>
                    <div style={{ fontSize: 12, color: "rgba(255,255,255,0.45)" }}>{safeDateLabel(item.date)}</div>

                    {item.sourceLink && (
                      <div style={{ marginTop: 14 }}>
                        <a
                          href={item.sourceLink}
                          target="_blank"
                          rel="noreferrer"
                          style={styles.linkBtn}
                        >
                          More About It
                        </a>
                      </div>
                    )}
                  </div>
'@)

# 6. Add More About It button in researchFeed cards
$c = $c.Replace(@'
                  <div style={{ padding: 14 }}>
                    <h4 style={{ margin: 0, fontSize: 18 }}>{item.title}</h4>
                    <p style={{ ...styles.panelText, marginTop: 10 }}>{item.description}</p>
                    <div style={{ fontSize: 12, color: "rgba(255,255,255,0.45)" }}>{item.source}</div>
                  </div>
'@, @'
                  <div style={{ padding: 14 }}>
                    <h4 style={{ margin: 0, fontSize: 18 }}>{item.title}</h4>
                    <p style={{ ...styles.panelText, marginTop: 10 }}>{item.description}</p>
                    <div style={{ fontSize: 12, color: "rgba(255,255,255,0.45)" }}>{item.source}</div>

                    {item.sourceLink && (
                      <div style={{ marginTop: 14 }}>
                        <a
                          href={item.sourceLink}
                          target="_blank"
                          rel="noreferrer"
                          style={styles.linkBtn}
                        >
                          More About It
                        </a>
                      </div>
                    )}
                  </div>
'@)

# 7. Replace NASA 3D Universe link with button
$c = $c.Replace(@'
              <a
                href="https://eyes.nasa.gov/apps/orrery/"
                target="_blank"
                rel="noreferrer"
                style={styles.linkBtn}
              >
                Open NASA 3D Universe
              </a>
'@, @'
              <button
                style={{ ...styles.linkBtn, border: "none", cursor: "pointer" }}
                onClick={() => setShowUniverseEmbed(true)}
              >
                Open NASA 3D Universe
              </button>
'@)

# 8. Add full screen NASA overlay before MissionResearchGalleryModal
$overlay = @'
      {showUniverseEmbed && (
        <div style={styles.universeOverlay}>
          <button
            style={styles.universeCloseBtn}
            onClick={() => setShowUniverseEmbed(false)}
            title="Close"
          >
            ?
          </button>

          <iframe
            src="https://eyes.nasa.gov/apps/orrery/"
            title="NASA 3D Universe"
            style={styles.universeFrame}
            allowFullScreen
          />

          <div style={styles.universeFallbackBar}>
            If the NASA page does not load here, your browser may be blocking embedded content.
            <a
              href="https://eyes.nasa.gov/apps/orrery/"
              target="_blank"
              rel="noreferrer"
              style={{ ...styles.linkBtn, marginLeft: 12 }}
            >
              Open in New Tab
            </a>
          </div>
        </div>
      )}

'@

$c = $c.Replace(@'
      <MissionResearchGalleryModal
'@, $overlay + @'
      <MissionResearchGalleryModal
'@)

# 9. Add new styles
$stylesInsert = @'
  universeOverlay: {
    position: "fixed",
    inset: 0,
    zIndex: 999,
    background: "rgba(0,0,0,0.92)",
    display: "flex",
    flexDirection: "column",
  },
  universeFrame: {
    width: "100%",
    height: "100%",
    border: "none",
    background: "#000",
  },
  universeCloseBtn: {
    position: "absolute",
    top: 16,
    right: 16,
    zIndex: 1000,
    width: 54,
    height: 54,
    borderRadius: "50%",
    border: "1px solid rgba(255,255,255,0.2)",
    background: "rgba(255,255,255,0.08)",
    color: "#fff",
    fontSize: 28,
    cursor: "pointer",
    backdropFilter: "blur(8px)",
  },
  universeFallbackBar: {
    position: "absolute",
    left: 16,
    bottom: 16,
    zIndex: 1000,
    display: "flex",
    alignItems: "center",
    flexWrap: "wrap",
    gap: 10,
    padding: "12px 16px",
    borderRadius: 16,
    background: "rgba(0,0,0,0.55)",
    color: "#fff",
    border: "1px solid rgba(255,255,255,0.12)",
  },
'@

$c = $c.Replace(@'
  phoneFieldWrap: {
    display: "flex",
    alignItems: "center",
    gap: 10,
    marginTop: 12,
  },
};
'@, @'
  phoneFieldWrap: {
    display: "flex",
    alignItems: "center",
    gap: 10,
    marginTop: 12,
  },
'@ + $stylesInsert + @'
};
'@)

Set-Content -Path $path -Value $c
Write-Host "App.tsx updated for Data Analyzed + 3D Universe fullscreen."
