$path = "src\App.tsx"
$c = Get-Content $path -Raw

# 1) ensure states exist once
if ($c -notmatch 'const \[showUniverseEmbed, setShowUniverseEmbed\]') {
  $c = $c.Replace(
'  const [missionResearchOpen, setMissionResearchOpen] = useState<MissionType | null>(null);',
'  const [missionResearchOpen, setMissionResearchOpen] = useState<MissionType | null>(null);
  const [showUniverseEmbed, setShowUniverseEmbed] = useState(false);
  const [universeLoading, setUniverseLoading] = useState(true);'
  )
}

# 2) replace the exact universe button block
$c = [regex]::Replace(
  $c,
  '<button\s+style=\{\{\s*\.\.\.styles\.linkBtn,\s*border:\s*"none",\s*cursor:\s*"pointer"\s*\}\}\s*onClick=\{\(\)\s*=>\s*\{[\s\S]*?\}\}\s*>\s*Open NASA 3D Universe\s*</button>',
@'
<button
  type="button"
  style={{ ...styles.linkBtn, border: "none", cursor: "pointer" }}
  onClick={() => {
    console.log("NASA 3D button clicked");
    setUniverseLoading(true);
    setShowUniverseEmbed(true);
  }}
>
  Open NASA 3D Universe
</button>
'@,
  [System.Text.RegularExpressions.RegexOptions]::Singleline
)

# 3) fallback if old simpler button still exists
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
  type="button"
  style={{ ...styles.linkBtn, border: "none", cursor: "pointer" }}
  onClick={() => {
    console.log("NASA 3D button clicked");
    setUniverseLoading(true);
    setShowUniverseEmbed(true);
  }}
>
  Open NASA 3D Universe
</button>
'@
)

# 4) add overlay if missing
if ($c -notmatch 'showUniverseEmbed && \(') {
  $overlay = @'
      {showUniverseEmbed && (
        <div style={styles.universeOverlay}>
          <button
            type="button"
            style={styles.universeCloseBtn}
            onClick={() => setShowUniverseEmbed(false)}
            title="Close"
          >
            ?
          </button>

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

          <div style={styles.universeFallbackBar}>
            If embed does not load, use this:
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
  $c = $c.Replace(
@'
      <MissionResearchGalleryModal
'@,
$overlay + @'
      <MissionResearchGalleryModal
'@
  )
}

# 5) ensure styles exist
if ($c -notmatch 'universeOverlay:\s*\{') {
  $styles = @'
  universeOverlay: {
    position: "fixed",
    inset: 0,
    zIndex: 9999,
    background: "rgba(0,0,0,0.96)",
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
    zIndex: 10001,
    width: 56,
    height: 56,
    borderRadius: "50%",
    border: "1px solid rgba(255,255,255,0.18)",
    background: "rgba(255,255,255,0.08)",
    color: "#fff",
    fontSize: 28,
    cursor: "pointer",
  },
  universeLoadingBox: {
    position: "absolute",
    inset: 0,
    zIndex: 10000,
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    background: "rgba(0,0,0,0.45)",
    color: "#fff",
    fontSize: 20,
  },
  universeFallbackBar: {
    position: "absolute",
    left: 16,
    bottom: 16,
    zIndex: 10001,
    padding: "12px 16px",
    borderRadius: 16,
    background: "rgba(0,0,0,0.58)",
    color: "#fff",
    border: "1px solid rgba(255,255,255,0.12)",
  },
'@
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
'@ + $styles + @'
};
'@
  )
}

Set-Content -Path $path -Value $c
Write-Host "Universe button fix applied."
