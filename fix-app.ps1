$path = "src\App.tsx"
$c = Get-Content $path -Raw

# 1) Fix duplicate firestore imports
$importPattern = 'import \{\s*collection,\s*addDoc,\s*onSnapshot,\s*serverTimestamp,\s*doc,\s*\}\s*from "firebase/firestore";\s*import \{ db \} from "\./lib/firebase";\s*import \{\s*collection,\s*addDoc,\s*onSnapshot,\s*serverTimestamp,\s*doc,\s*setDoc,\s*getDocs,\s*query,\s*where,\s*updateDoc,\s*getDoc,\s*\}\s*from "firebase/firestore";'
$importReplace = @'
import {
  collection,
  addDoc,
  onSnapshot,
  serverTimestamp,
  doc,
  setDoc,
  getDocs,
  query,
  where,
} from "firebase/firestore";
import { db } from "./lib/firebase";
'@
$c = [regex]::Replace($c, $importPattern, $importReplace, [System.Text.RegularExpressions.RegexOptions]::Singleline)

# 2) Fix signup function
$signupPattern = 'const handleVisitorSignup = async \(\) => \{.*?const handleVisitorLogin = async \(\) => \{'
$signupReplace = @'
const handleVisitorSignup = async () => {
  const { name, email, phone, dob, password } = visitorAuth;

  if (!name || !email || !phone || !dob || !password) {
    speakInfo("Please complete all visitor sign up fields.");
    return;
  }

  if (!isValidGmail(email)) {
    speakInfo("Only full Gmail addresses are allowed for sign up.");
    return;
  }

  if (!isValidBdPhone(phone)) {
    speakInfo("Phone number must be exactly 11 digits and start with 01.");
    return;
  }

  if (!isValidDob(dob)) {
    speakInfo("Please enter a valid date of birth with a four digit year.");
    return;
  }

  const exists = visitorAccounts.some(
    (item) => item.email.trim().toLowerCase() === email.trim().toLowerCase()
  );

  if (exists) {
    speakInfo("This email already has an account. Please use log in.");
    return;
  }

  try {
    const accountRef = doc(collection(db, "visitorAccounts"));

    const account: VisitorAccount = {
      id: accountRef.id,
      name,
      email: email.trim().toLowerCase(),
      phone,
      dob,
      password,
      profileImage: "",
      createdAt: new Date().toISOString(),
    };

    await setDoc(accountRef, account);

    setLoggedInVisitor(account);
    setActiveVisitorId(account.id);
    await addVisitorLog(account, "Visitor signed up and entered website");

    if (!birthdayMemory) {
      await loadBirthdayMemory(dob);
    }

    setScreen("intro");
  } catch (error) {
    console.error(error);
    speakInfo("Visitor account creation failed.");
  }
};

const handleVisitorLogin = async () => {
'@
$c = [regex]::Replace($c, $signupPattern, $signupReplace, [System.Text.RegularExpressions.RegexOptions]::Singleline)

# 3) Fix profile/photo/comment block
$profilePattern = 'const handleVisitorProfileSave =.*?const logoutAll = \(\) => \{'
$profileReplace = @'
const handleVisitorProfileSave = async () => {
  if (!loggedInVisitor) return;

  if (!isValidBdPhone(loggedInVisitor.phone)) {
    speakInfo("Phone number must be exactly 11 digits.");
    return;
  }

  if (!isValidDob(loggedInVisitor.dob)) {
    speakInfo("Date of birth year must be four digits.");
    return;
  }

  try {
    await setDoc(doc(db, "visitorAccounts", loggedInVisitor.id), loggedInVisitor);
    setLoggedInVisitor(loggedInVisitor);
    setActiveVisitorId(loggedInVisitor.id);
    await addVisitorLog(loggedInVisitor, "Visitor updated account profile");
    setProfileMessage("Profile updated and saved.");
    speakInfo("Profile updated and saved.");
  } catch (error) {
    console.error(error);
    setProfileMessage("Profile update failed.");
    speakInfo("Profile update failed.");
  }
};

const handleVisitorPhotoUpload = async (file: File | null) => {
  if (!file || !loggedInVisitor) return;

  try {
    const url = await resizeImageFile(file, 500, 0.7);
    const updatedVisitor = { ...loggedInVisitor, profileImage: url };

    await setDoc(doc(db, "visitorAccounts", updatedVisitor.id), updatedVisitor);

    setLoggedInVisitor(updatedVisitor);
    setActiveVisitorId(updatedVisitor.id);

    await addVisitorLog(updatedVisitor, "Visitor updated profile photo");
    setProfileMessage("Profile photo saved for future login.");
    speakInfo("Profile photo saved for future login.");
  } catch (error) {
    console.error(error);
    setProfileMessage("Image upload failed.");
    speakInfo("Image upload failed.");
  }
};

const handleCreatorPhotoUpload = async (file: File | null) => {
  if (!file) return;

  try {
    const url = await resizeImageFile(file, 500, 0.7);

    const next = {
      email: ADMIN_EMAIL,
      image: url,
    };

    await setDoc(doc(db, "settings", "creatorProfile"), next);

    setCreatorAccount(next);
    speakInfo("Creator photo updated.");
  } catch (error) {
    console.error(error);
    speakInfo("Creator photo upload failed.");
  }
};

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
    console.error(error);
    speakInfo("Comment save failed.");
  }
};

const logoutAll = () => {
'@
$c = [regex]::Replace($c, $profilePattern, $profileReplace, [System.Text.RegularExpressions.RegexOptions]::Singleline)

Set-Content -Path $path -Value $c
Write-Host "App.tsx fixed."
