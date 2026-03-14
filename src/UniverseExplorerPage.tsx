import React, { useEffect, useMemo, useState } from "react";
import {
  Globe2,
  Search,
  Rocket,
  Orbit,
  Satellite,
  Activity,
  ExternalLink,
  RefreshCcw,
  Stars,
} from "lucide-react";

type NasaApod = {
  title?: string;
  explanation?: string;
  url?: string;
  media_type?: string;
  date?: string;
};

type UniverseObject = {
  id: string;
  name: string;
  type: string;
  distance: string;
  status: string;
  description: string;
};

const TEAM_LOGO = "/team-logo.jpg";
const NASA_API_KEY = "qYZmjIejfH714M1RJLW4uqbhZJKAshBsmtM9Mqzf";

const universeObjectsBase: UniverseObject[] = [
  {
    id: "1",
    name: "Voyager 1",
    type: "Spacecraft",
    distance: "Interstellar Space",
    status: "Active signal relay",
    description: "Humanity’s farthest spacecraft, still sending engineering and science data from beyond the heliosphere.",
  },
  {
    id: "2",
    name: "Hubble Space Telescope",
    type: "Telescope",
    distance: "Low Earth Orbit",
    status: "Observation mode",
    description: "Orbital observatory known for deep-field images, nebulae studies, and landmark cosmic discoveries.",
  },
  {
    id: "3",
    name: "ISS",
    type: "Station",
    distance: "Low Earth Orbit",
    status: "Crewed orbital lab",
    description: "The International Space Station continuously orbits Earth and supports global science experiments.",
  },
  {
    id: "4",
    name: "Europa",
    type: "Moon",
    distance: "Jupiter System",
    status: "Research target",
    description: "An icy moon believed to hide a global ocean beneath its frozen shell.",
  },
  {
    id: "5",
    name: "Mars",
    type: "Planet",
    distance: "Solar System",
    status: "Exploration target",
    description: "The Red Planet remains one of the most studied destinations for habitability and robotic exploration.",
  },
  {
    id: "6",
    name: "James Webb Space Telescope",
    type: "Telescope",
    distance: "Sun-Earth L2",
    status: "Infrared observation",
    description: "A deep space observatory capturing early-universe galaxies and detailed exoplanet data.",
  },
];

function safeDateLabel(date?: string) {
  if (!date) return "Unknown";
  const d = new Date(date);
  if (Number.isNaN(d.getTime())) return "Unknown";
  return d.toLocaleDateString();
}

export default function UniverseExplorerPage() {
  const [searchTerm, setSearchTerm] = useState("voyager");
  const [apod, setApod] = useState<NasaApod | null>(null);
  const [loadingApod, setLoadingApod] = useState(false);
  const [activeObjectId, setActiveObjectId] = useState("1");

  const filteredObjects = useMemo(() => {
    const q = searchTerm.trim().toLowerCase();
    if (!q) return universeObjectsBase;
    return universeObjectsBase.filter((item) =>
      `${item.name} ${item.type} ${item.distance} ${item.status} ${item.description}`
        .toLowerCase()
        .includes(q)
    );
  }, [searchTerm]);

  const activeObject =
    filteredObjects.find((item) => item.id === activeObjectId) ||
    filteredObjects[0] ||
    universeObjectsBase[0];

  const loadApod = async () => {
    setLoadingApod(true);
    try {
      const res = await fetch(
        `https://api.nasa.gov/planetary/apod?api_key=${NASA_API_KEY}`
      );
      const data = await res.json();
      setApod(data);
    } catch {
      setApod({
        title: "NASA live card unavailable",
        explanation: "Could not load NASA Astronomy Picture of the Day right now.",
      });
    } finally {
      setLoadingApod(false);
    }
  };

  useEffect(() => {
    loadApod();
    const interval = setInterval(loadApod, 60000);
    return () => clearInterval(interval);
  }, []);

  useEffect(() => {
    if (filteredObjects.length && !filteredObjects.some((x) => x.id === activeObjectId)) {
      setActiveObjectId(filteredObjects[0].id);
    }
  }, [filteredObjects, activeObjectId]);

  return (
    <div style={styles.page}>
      <div style={styles.bg} />
      <div style={styles.overlay} />

      <div style={styles.shell}>
        <header style={styles.header}>
          <div style={styles.headerLeft}>
            <img
              src={TEAM_LOGO}
              alt="Team Logo"
              style={styles.logo}
              onError={(e) => {
                (e.currentTarget as HTMLImageElement).src =
                  "https://via.placeholder.com/60x60?text=LOGO";
              }}
            />
            <div>
              <div style={styles.badge}>TEAM SYSTEM</div>
              <h1 style={styles.title}>Universe Explorer</h1>
              <p style={styles.subtitle}>
                NASA-inspired deep space page for mission objects, live cosmic card,
                and external universe exploration tools.
              </p>
            </div>
          </div>

          <div style={styles.headerRight}>
            <a
              href="https://eyes.nasa.gov/apps/orrery/"
              target="_blank"
              rel="noreferrer"
              style={styles.primaryBtn}
            >
              <ExternalLink size={16} />
              Open NASA Orrery
            </a>
          </div>
        </header>

        <div style={styles.grid}>
          <aside style={styles.leftPanel}>
            <div style={styles.sectionCard}>
              <div style={styles.sectionTitleRow}>
                <Search size={18} color="#7de8ff" />
                <h3 style={{ margin: 0 }}>Search Universe</h3>
              </div>

              <div style={styles.searchWrap}>
                <Search size={16} color="#7de8ff" />
                <input
                  style={styles.searchInput}
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  placeholder="Search spacecraft, planets, telescope..."
                />
              </div>

              <div style={styles.objectList}>
                {filteredObjects.length ? (
                  filteredObjects.map((item) => (
                    <button
                      key={item.id}
                      style={{
                        ...styles.objectBtn,
                        ...(activeObject?.id === item.id ? styles.objectBtnActive : {}),
                      }}
                      onClick={() => setActiveObjectId(item.id)}
                    >
                      <div style={{ fontWeight: 700 }}>{item.name}</div>
                      <div style={styles.objectMeta}>{item.type} · {item.distance}</div>
                    </button>
                  ))
                ) : (
                  <div style={styles.emptyBox}>No object found.</div>
                )}
              </div>
            </div>

            <div style={styles.sectionCard}>
              <div style={styles.sectionTitleRow}>
                <Stars size={18} color="#f7c66a" />
                <h3 style={{ margin: 0 }}>Quick Access</h3>
              </div>

              <div style={styles.quickGrid}>
                <a
                  href="https://eyes.nasa.gov/apps/solar-system/"
                  target="_blank"
                  rel="noreferrer"
                  style={styles.quickBtn}
                >
                  <Orbit size={16} />
                  Solar System
                </a>

                <a
                  href="https://eyes.nasa.gov/apps/earth/"
                  target="_blank"
                  rel="noreferrer"
                  style={styles.quickBtn}
                >
                  <Globe2 size={16} />
                  Earth
                </a>

                <a
                  href="https://eyes.nasa.gov/apps/orrery/"
                  target="_blank"
                  rel="noreferrer"
                  style={styles.quickBtn}
                >
                  <Rocket size={16} />
                  Missions
                </a>

                <a
                  href="https://science.nasa.gov/"
                  target="_blank"
                  rel="noreferrer"
                  style={styles.quickBtn}
                >
                  <Satellite size={16} />
                  Science
                </a>
              </div>
            </div>
          </aside>

          <main style={styles.centerPanel}>
            <div style={styles.viewerCard}>
              <div style={styles.viewerTop}>
                <div>
                  <div style={styles.badge}>ACTIVE OBJECT</div>
                  <h2 style={styles.viewerTitle}>{activeObject?.name}</h2>
                  <div style={styles.viewerSub}>
                    {activeObject?.type} · {activeObject?.distance}
                  </div>
                </div>

                <div style={styles.liveTag}>Universe Mode</div>
              </div>

              <div style={styles.viewerArea}>
                <div style={styles.orbitRing1} />
                <div style={styles.orbitRing2} />
                <div style={styles.glowCore} />
                <div style={styles.objectCenterLabel}>
                  {activeObject?.name}
                </div>
              </div>

              <div style={styles.statsRow}>
                <div style={styles.statCard}>
                  <Rocket size={16} color="#7de8ff" />
                  <div>
                    <div style={styles.statLabel}>STATUS</div>
                    <div style={styles.statValueSmall}>{activeObject?.status}</div>
                  </div>
                </div>

                <div style={styles.statCard}>
                  <Orbit size={16} color="#7de8ff" />
                  <div>
                    <div style={styles.statLabel}>TYPE</div>
                    <div style={styles.statValueSmall}>{activeObject?.type}</div>
                  </div>
                </div>

                <div style={styles.statCard}>
                  <Activity size={16} color="#7de8ff" />
                  <div>
                    <div style={styles.statLabel}>REGION</div>
                    <div style={styles.statValueSmall}>{activeObject?.distance}</div>
                  </div>
                </div>
              </div>

              <div style={styles.detailBox}>
                {activeObject?.description}
              </div>
            </div>
          </main>

          <aside style={styles.rightPanel}>
            <div style={styles.sectionCard}>
              <div style={styles.sectionTitleRow}>
                <RefreshCcw size={18} color="#7de8ff" />
                <h3 style={{ margin: 0 }}>NASA Live Update</h3>
              </div>

              {loadingApod ? (
                <div style={styles.emptyBox}>Refreshing NASA live card...</div>
              ) : apod ? (
                <>
                  {apod.media_type === "image" && apod.url ? (
                    <img
                      src={apod.url}
                      alt={apod.title || "NASA APOD"}
                      style={styles.apodImage}
                    />
                  ) : (
                    <div style={styles.emptyBox}>No image preview available.</div>
                  )}

                  <h3 style={{ marginTop: 14, marginBottom: 8 }}>
                    {apod.title || "NASA APOD"}
                  </h3>
                  <div style={styles.objectMeta}>
                    Date: {safeDateLabel(apod.date)}
                  </div>
                  <p style={styles.text}>
                    {(apod.explanation || "No explanation available.").slice(0, 320)}...
                  </p>
                </>
              ) : (
                <div style={styles.emptyBox}>NASA card unavailable.</div>
              )}
            </div>

            <div style={styles.sectionCard}>
              <div style={styles.sectionTitleRow}>
                <Satellite size={18} color="#f7c66a" />
                <h3 style={{ margin: 0 }}>Control Notes</h3>
              </div>

              <ul style={styles.notesList}>
                <li>This page is separate from your main app.</li>
                <li>Next step: connect it using your universe button.</li>
                <li>Team logo is used instead of NASA branding.</li>
                <li>You can later replace the center viewer with real 3D content.</li>
              </ul>
            </div>
          </aside>
        </div>
      </div>
    </div>
  );
}

const styles: Record<string, React.CSSProperties> = {
  page: {
    minHeight: "100vh",
    position: "relative",
    overflowX: "hidden",
    color: "#fff",
    background:
      "radial-gradient(circle at top, rgba(23,37,84,0.65), rgba(2,6,23,1) 55%, #000 100%)",
    fontFamily:
      'Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif',
  },
  bg: {
    position: "fixed",
    inset: 0,
    backgroundImage:
      "radial-gradient(rgba(255,255,255,0.18) 1px, transparent 1px)",
    backgroundSize: "28px 28px",
    opacity: 0.16,
    pointerEvents: "none",
  },
  overlay: {
    position: "fixed",
    inset: 0,
    background:
      "linear-gradient(to bottom, rgba(2,6,23,0.18), rgba(2,6,23,0.35), rgba(0,0,0,0.52))",
    pointerEvents: "none",
  },
  shell: {
    position: "relative",
    zIndex: 2,
    width: "min(1440px, 96%)",
    margin: "0 auto",
    padding: "28px 0 36px",
  },
  header: {
    display: "flex",
    justifyContent: "space-between",
    gap: 20,
    alignItems: "flex-start",
    flexWrap: "wrap",
    marginBottom: 24,
  },
  headerLeft: {
    display: "flex",
    gap: 16,
    alignItems: "flex-start",
    flexWrap: "wrap",
  },
  headerRight: {
    display: "flex",
    alignItems: "center",
  },
  logo: {
    width: 64,
    height: 64,
    objectFit: "cover",
    borderRadius: "50%",
    border: "1px solid rgba(255,255,255,0.15)",
    boxShadow: "0 8px 24px rgba(0,0,0,0.3)",
  },
  badge: {
    display: "inline-block",
    padding: "7px 12px",
    borderRadius: 999,
    background: "rgba(255,255,255,0.08)",
    border: "1px solid rgba(255,255,255,0.12)",
    color: "#98e9ff",
    fontSize: 12,
    marginBottom: 10,
  },
  title: {
    margin: 0,
    fontSize: "clamp(30px, 4vw, 54px)",
    lineHeight: 1.05,
  },
  subtitle: {
    marginTop: 10,
    marginBottom: 0,
    maxWidth: 760,
    color: "rgba(255,255,255,0.72)",
    lineHeight: 1.7,
  },
  primaryBtn: {
    display: "inline-flex",
    alignItems: "center",
    gap: 8,
    textDecoration: "none",
    borderRadius: 999,
    background: "#7de8ff",
    color: "#00131b",
    padding: "14px 20px",
    fontWeight: 800,
  },
  grid: {
    display: "grid",
    gridTemplateColumns: "320px 1fr 360px",
    gap: 18,
  },
  leftPanel: {
    display: "grid",
    gap: 18,
    alignSelf: "start",
  },
  centerPanel: {
    display: "grid",
    gap: 18,
    alignSelf: "start",
  },
  rightPanel: {
    display: "grid",
    gap: 18,
    alignSelf: "start",
  },
  sectionCard: {
    borderRadius: 24,
    padding: 18,
    background: "rgba(255,255,255,0.05)",
    border: "1px solid rgba(255,255,255,0.1)",
    backdropFilter: "blur(12px)",
  },
  sectionTitleRow: {
    display: "flex",
    alignItems: "center",
    gap: 10,
    marginBottom: 14,
  },
  searchWrap: {
    display: "flex",
    alignItems: "center",
    gap: 10,
    borderRadius: 16,
    border: "1px solid rgba(255,255,255,0.1)",
    background: "rgba(255,255,255,0.05)",
    padding: "12px 14px",
  },
  searchInput: {
    width: "100%",
    border: "none",
    outline: "none",
    background: "transparent",
    color: "#fff",
    fontSize: 14,
  },
  objectList: {
    display: "grid",
    gap: 10,
    marginTop: 14,
  },
  objectBtn: {
    textAlign: "left",
    padding: 14,
    borderRadius: 16,
    border: "1px solid rgba(255,255,255,0.08)",
    background: "rgba(255,255,255,0.04)",
    color: "#fff",
    cursor: "pointer",
  },
  objectBtnActive: {
    background: "rgba(125,232,255,0.12)",
    border: "1px solid rgba(125,232,255,0.28)",
  },
  objectMeta: {
    marginTop: 6,
    fontSize: 13,
    color: "rgba(255,255,255,0.55)",
  },
  emptyBox: {
    borderRadius: 16,
    padding: 20,
    textAlign: "center",
    color: "rgba(255,255,255,0.55)",
    background: "rgba(0,0,0,0.2)",
    border: "1px dashed rgba(255,255,255,0.12)",
  },
  quickGrid: {
    display: "grid",
    gridTemplateColumns: "1fr 1fr",
    gap: 10,
  },
  quickBtn: {
    display: "inline-flex",
    alignItems: "center",
    justifyContent: "center",
    gap: 8,
    textDecoration: "none",
    color: "#fff",
    borderRadius: 16,
    padding: "14px 12px",
    background: "rgba(255,255,255,0.05)",
    border: "1px solid rgba(255,255,255,0.08)",
  },
  viewerCard: {
    borderRadius: 28,
    padding: 20,
    background:
      "linear-gradient(180deg, rgba(255,255,255,0.05), rgba(255,255,255,0.035))",
    border: "1px solid rgba(255,255,255,0.1)",
    backdropFilter: "blur(12px)",
  },
  viewerTop: {
    display: "flex",
    justifyContent: "space-between",
    gap: 16,
    alignItems: "flex-start",
    flexWrap: "wrap",
    marginBottom: 18,
  },
  viewerTitle: {
    margin: 0,
    fontSize: "clamp(28px, 4vw, 42px)",
    lineHeight: 1.06,
  },
  viewerSub: {
    marginTop: 8,
    color: "rgba(255,255,255,0.6)",
  },
  liveTag: {
    borderRadius: 999,
    padding: "10px 14px",
    background: "rgba(125,232,255,0.12)",
    border: "1px solid rgba(125,232,255,0.22)",
    color: "#9fe7ff",
    fontSize: 13,
    whiteSpace: "nowrap",
  },
  viewerArea: {
    position: "relative",
    height: 440,
    borderRadius: 26,
    overflow: "hidden",
    background:
      "radial-gradient(circle at center, rgba(0,180,255,0.14), rgba(0,0,0,0.2) 35%, rgba(0,0,0,0.75) 100%)",
    border: "1px solid rgba(255,255,255,0.08)",
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
  },
  orbitRing1: {
    position: "absolute",
    width: 320,
    height: 320,
    borderRadius: "50%",
    border: "1px solid rgba(125,232,255,0.2)",
    boxShadow: "0 0 60px rgba(125,232,255,0.08) inset",
  },
  orbitRing2: {
    position: "absolute",
    width: 220,
    height: 220,
    borderRadius: "50%",
    border: "1px dashed rgba(247,198,106,0.28)",
  },
  glowCore: {
    width: 84,
    height: 84,
    borderRadius: "50%",
    background:
      "radial-gradient(circle, rgba(125,232,255,1) 0%, rgba(125,232,255,0.55) 40%, rgba(125,232,255,0.06) 100%)",
    boxShadow: "0 0 80px rgba(125,232,255,0.4)",
  },
  objectCenterLabel: {
    position: "absolute",
    bottom: 26,
    left: "50%",
    transform: "translateX(-50%)",
    borderRadius: 999,
    padding: "10px 16px",
    background: "rgba(0,0,0,0.45)",
    border: "1px solid rgba(255,255,255,0.08)",
  },
  statsRow: {
    display: "grid",
    gridTemplateColumns: "repeat(3, minmax(0, 1fr))",
    gap: 12,
    marginTop: 16,
  },
  statCard: {
    display: "flex",
    alignItems: "center",
    gap: 10,
    borderRadius: 18,
    padding: 14,
    background: "rgba(255,255,255,0.05)",
    border: "1px solid rgba(255,255,255,0.08)",
  },
  statLabel: {
    fontSize: 11,
    letterSpacing: "0.12em",
    color: "rgba(255,255,255,0.5)",
  },
  statValueSmall: {
    marginTop: 4,
    fontWeight: 700,
    color: "#fff",
  },
  detailBox: {
    marginTop: 16,
    borderRadius: 18,
    padding: 16,
    background: "rgba(255,255,255,0.04)",
    border: "1px solid rgba(255,255,255,0.08)",
    lineHeight: 1.8,
    color: "rgba(255,255,255,0.82)",
  },
  apodImage: {
    width: "100%",
    height: 220,
    objectFit: "cover",
    borderRadius: 18,
    border: "1px solid rgba(255,255,255,0.08)",
  },
  text: {
    color: "rgba(255,255,255,0.78)",
    lineHeight: 1.8,
    marginBottom: 0,
  },
  notesList: {
    margin: 0,
    paddingLeft: 20,
    color: "rgba(255,255,255,0.8)",
    lineHeight: 1.9,
  },
};