from pathlib import Path
import re
import shutil

path = Path("src/App.tsx")
backup = Path("src/App.before-landscape-only-mobile.tsx")

if backup.exists():
    shutil.copyfile(backup, path)

text = path.read_text(encoding="utf-8")

hook = '''
function useLandscapeOnlyMobile() {
  const [state, setState] = useState(() => {
    if (typeof window === "undefined") {
      return { isPhoneScreen: false, isLandscape: true };
    }

    return {
      isPhoneScreen: window.innerWidth <= 768,
      isLandscape: window.innerWidth > window.innerHeight,
    };
  });

  useEffect(() => {
    const onResize = () => {
      setState({
        isPhoneScreen: window.innerWidth <= 768,
        isLandscape: window.innerWidth > window.innerHeight,
      });
    };

    window.addEventListener("resize", onResize);
    window.addEventListener("orientationchange", onResize);

    return () => {
      window.removeEventListener("resize", onResize);
      window.removeEventListener("orientationchange", onResize);
    };
  }, []);

  return state;
}
'''

if "function useLandscapeOnlyMobile()" not in text:
    text = re.sub(
        r'(function useIsMobile\(breakpoint = 768\) \{.*?return isMobile;\n\})',
        r'\1\n\n' + hook,
        text,
        flags=re.S
    )

if 'const { isPhoneScreen, isLandscape } = useLandscapeOnlyMobile();' not in text:
    text = text.replace(
        '  const isMobile = useIsMobile();',
        '  const isMobile = useIsMobile();\n  const { isPhoneScreen, isLandscape } = useLandscapeOnlyMobile();'
    )

if "Rotate your phone" not in text:
    text = text.replace(
        '  return (\n    <div style={styles.page}>',
        '''  return (
    <>
      {isPhoneScreen && !isLandscape ? (
        <div style={styles.rotateScreen}>
          <div style={styles.rotateCard}>
            <div style={styles.rotateIcon}>?</div>
            <h2 style={{ margin: "0 0 10px" }}>Rotate your phone</h2>
            <p style={styles.panelText}>
              This website is designed for landscape mode on mobile.
              Please rotate your phone horizontally.
            </p>
          </div>
        </div>
      ) : (
      <div style={styles.page}>'''
    )

    text = re.sub(
        r'\n\s*</div>\n\s*\);\n\}\s*$',
        '''
      </div>
      )}
    </>
  );
}
''',
        text
    )

if "rotateScreen:" not in text:
    text = text.replace(
        'const styles: Record<string, React.CSSProperties> = {',
        '''const styles: Record<string, React.CSSProperties> = {
  rotateScreen: {
    minHeight: "100vh",
    background: "#020617",
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    padding: 24,
    color: "#fff",
    textAlign: "center",
  },
  rotateCard: {
    width: "min(420px, 92%)",
    borderRadius: 28,
    padding: 28,
    background: "rgba(255,255,255,0.06)",
    border: "1px solid rgba(255,255,255,0.12)",
    backdropFilter: "blur(10px)",
  },
  rotateIcon: {
    fontSize: 52,
    marginBottom: 12,
  },'''
    )

path.write_text(text, encoding="utf-8")
print("Patch applied.")
