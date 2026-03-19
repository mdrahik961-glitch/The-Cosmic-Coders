$path = "src\App.tsx"
$c = Get-Content $path -Raw

# 1) keep only one showUniverseEmbed state
$c = [regex]::Replace(
  $c,
  '(const \[showUniverseEmbed, setShowUniverseEmbed\] = useState\(false\);\r?\n)(\s*const \[showUniverseEmbed, setShowUniverseEmbed\] = useState\(false\);\r?\n)+',
  '',
  [System.Text.RegularExpressions.RegexOptions]::Singleline
)

# 2) keep only one universeLoading state
$c = [regex]::Replace(
  $c,
  '(const \[universeLoading, setUniverseLoading\] = useState\(true\);\r?\n)(\s*const \[universeLoading, setUniverseLoading\] = useState\(true\);\r?\n)+',
  '',
  [System.Text.RegularExpressions.RegexOptions]::Singleline
)

# 3) replace the universe open button with a clean one
$c = [regex]::Replace(
  $c,
  '<button[\s\S]*?>\s*Open NASA 3D Universe\s*</button>',
@'
<button
  type="button"
  style={{ ...styles.linkBtn, border: "none", cursor: "pointer" }}
  onClick={() => {
    setUniverseLoading(true);
    setShowUniverseEmbed(true);
  }}
>
  Open NASA 3D Universe
</button>
'@,
  1,
  [System.Text.RegularExpressions.RegexOptions]::Singleline
)

# 4) remove every existing showUniverseEmbed overlay block
$c = [regex]::Replace(
  $c,
  '\{showUniverseEmbed && \([\s\S]*?\n\s*\)\}\r?\n\r?\n',
  '',
  [System.Text.RegularExpressions.RegexOptions]::Singleline
)

# 5) inject one clean overlay before MissionResearchGalleryModal
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

Set-Content -Path $path -Value $c
Write-Host "3D button + overlay fixed."
