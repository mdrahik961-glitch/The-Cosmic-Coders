$AppPath = "src\App.tsx"
$FirebaseDir = "src\lib"
$FirebasePath = "src\lib\firebase.ts"

if (-not (Test-Path $AppPath)) {
  Write-Host "App.tsx not found at $AppPath" -ForegroundColor Red
  exit 1
}

New-Item -ItemType Directory -Force -Path $FirebaseDir | Out-Null

@'
import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";

const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY,
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN,
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID,
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID,
  appId: import.meta.env.VITE_FIREBASE_APP_ID,
};

const app = initializeApp(firebaseConfig);

export const db = getFirestore(app);
'@ | Set-Content -Path $FirebasePath -Encoding UTF8

Copy-Item $AppPath "$AppPath.bak" -Force

$content = Get-Content $AppPath -Raw

if ($content -notmatch 'firebase/firestore') {
  $content = $content -replace 'import spaceBg from "\./assets/space-bg\.png";', "import spaceBg from `"./assets/space-bg.png`";`r`nimport { addDoc, collection, onSnapshot, serverTimestamp } from `"firebase/firestore`";`r`nimport { db } from `"./lib/firebase`";"
}

$commentType = @'
type CommentItem = {
  id: string;
  userEmail: string;
  userName: string;
  userImage?: string;
  text: string;
  time: string;
  createdAt?: any;
};
'@

$content = [regex]::Replace(
  $content,
  'type CommentItem = \{.*?\n\};',
  $commentType,
  [System.Text.RegularExpressions.RegexOptions]::Singleline
)

$content = $content -replace 'const \[comments, setComments\] = useLocalStorageState<CommentItem\[]>\("cosmic-comments", \[\]\);', 'const [comments, setComments] = useState<CommentItem[]>([]);'

$firestoreEffect = @'
  useEffect(() => {
    const unsubscribe = onSnapshot(collection(db, "comments"), (snapshot) => {
      const items: CommentItem[] = snapshot.docs
        .map((doc) => {
          const data = doc.data() as any;
          return {
            id: doc.id,
            userEmail: data.userEmail || "",
            userName: data.userName || "Anonymous",
            userImage: data.userImage || "",
            text: data.text || "",
            time: data.time || "",
            createdAt: data.createdAt || null,
          };
        })
        .sort((a, b) => {
          const aSec = a.createdAt?.seconds || 0;
          const bSec = b.createdAt?.seconds || 0;
          return bSec - aSec;
        });

      setComments(items);
    });

    return () => unsubscribe();
  }, []);

'@

if ($content -notmatch 'onSnapshot\(collection\(db, "comments"\)') {
  $content = $content -replace '(\s*const filteredObservationItems = useMemo\(\(\) => \{)', "$firestoreEffect`$1"
}

$newAddComment = @'
  const addComment = async () => {
    if (!commentDraft.trim() || !loggedInVisitor) return;

    try {
      await addDoc(collection(db, "comments"), {
        userEmail: loggedInVisitor.email,
        userName: loggedInVisitor.name,
        userImage: loggedInVisitor.profileImage || "",
        text: commentDraft.trim(),
        time: new Date().toLocaleString(),
        createdAt: serverTimestamp(),
      });

      setCommentDraft("");
      addVisitorLog(loggedInVisitor, "Visitor added a comment");
      speakInfo("Comment added.");
    } catch (error) {
      console.error("Failed to add comment:", error);
      speakInfo("Comment upload failed.");
    }
  };
'@

$content = [regex]::Replace(
  $content,
  'const addComment = \(\) => \{.*?\n  \};\r?\n\r?\n  const logoutAll = \(\) => \{',
  "$newAddComment`r`n`r`n  const logoutAll = () => {",
  [System.Text.RegularExpressions.RegexOptions]::Singleline
)

Set-Content -Path $AppPath -Value $content -Encoding UTF8

Write-Host "Done: App.tsx patched and firebase.ts created." -ForegroundColor Green
Write-Host "Backup: src\App.tsx.bak" -ForegroundColor Yellow