# Setting Up Godot 4 Android Export on Windows 11

This guide gets you from nothing to "APK running on the tablet" in one sitting.
Do the steps in order — the order matters.

**Target device:** 12" octa-core tablet, ~Android 16, 2000×1200 FHD, plenty of RAM.

The Android export side of things requires four things lined up:
- Export templates that match your exact Godot version
- JDK 17 (not newer)
- The Android SDK (platform-tools, build-tools, an SDK platform, the NDK)
- A debug keystore to sign test builds

Steps 1–2 establish the project. Steps 3–8 are machine-wide setup (do once, applies
to every future Godot project). Steps 9–10 are the repeating loop.


## Step 1 — Create the GitHub repo and clone it locally

1. Go to github.com and sign in. Click **New repository**.
2. Name it `ChompStomp`. Set it to Private. Check "Add a README file" so the repo
   isn't empty. Click **Create repository**.
3. On the repo page, click the green **Code** button and copy the HTTPS URL.
4. Open **VS Code**. Press `Ctrl+Shift+P` to open the command palette, type
   `Git: Clone`, and paste the URL. Choose a local parent folder (e.g. `D:\Git`).
   VS Code clones the repo into `D:\Git\ChompStomp` and offers to open it — say yes.
5. You now have `D:\Git\ChompStomp` on disk, tracked by git, open in VS Code.
   The terminal in VS Code (`Ctrl+`\``) is how you'll run git commands going forward.


## Step 2 — Download Godot and create the project inside the repo

1. Go to <https://godotengine.org/download/windows/> and download the
   **Godot Engine – .NET** version if you plan to use C#, or the standard version
   for GDScript. For this project, the standard (GDScript) version is correct.
   Download the 64-bit zip.
2. Unzip it somewhere stable, e.g. `C:\Godot\`. The executable is `Godot_v4.x.x.exe`
   — no installer, just run the exe directly.
3. Launch Godot. The **Project Manager** opens (a list of projects; it's empty on
   first run).
4. Note your exact version number — it's in the title bar or at **Help → About**.
   Write it down (e.g. `4.4.1`). You'll need it exactly in Step 3.
5. Click **New Project**.
   - **Project Name:** `ChompStomp`
   - **Project Path:** browse to `D:\Git\ChompStomp` (the folder you cloned in Step 1)
   - **Renderer:** leave on **Compatibility** — widest Android driver support, correct
     for a 2D mobile game
6. Click **Create & Edit**. Godot creates `project.godot` inside your repo folder and
   opens the editor.
7. Back in VS Code, you'll see `project.godot` and other Godot files appear. Commit
   them: in the VS Code terminal run:
   ```
   git add .
   git commit -m "init: add Godot project"
   git push
   ```


## Step 3 — Install the export templates

This is the easiest step and the one people skip.

Godot's top menu bar has five menus: **Scene · Project · Debug · Editor · Help**.
"Editor" is its own menu — the fourth one, easy to miss.

1. Click **Editor** in the top menu bar.
2. Near the bottom of that dropdown, click **Manage Export Templates…**
3. A small window opens. If it says no templates are installed, click
   **Download and Install**. Godot downloads the templates for your exact editor
   version automatically. Wait for the progress bar to finish.

No files to move — that's it. If the download fails, there's a "Download from"
dropdown with mirror options; pick another and retry.

> **Can't find the option?** Alternative path: **Project → Export → Add… → Android**.
> If templates are missing, a yellow warning at the bottom has a link to install them.


## Step 4 — Install JDK 17

Use version 17. Not 21, not 11. Godot 4's Gradle build is pinned to 17, and a
newer JDK throws cryptic errors.

1. Go to <https://adoptium.net/temurin/releases/>
2. Set filters: **Version = 17**, **Operating System = Windows**,
   **Architecture = x64**, **Package Type = JDK**.
3. Download the `.msi` installer.
4. Run it. On the options screen, turn **ON** "Set JAVA_HOME variable" and
   "Add to PATH" if offered.
5. Note the install path, typically:
   `C:\Program Files\Eclipse Adoptium\jdk-17.x.x-hotspot\`
   You'll paste this into Godot in Step 8.

Verify: open a fresh PowerShell window and run:
```
java -version
```
You should see `openjdk version "17.…`. If it says 21 or "not recognized," reboot
and try again, or just note the install folder for Step 7.


## Step 5 — Install Python and SCons

The Android export build chain requires Python and SCons.

1. Go to <https://www.python.org/downloads/> and download the latest Python 3.x
   installer for Windows.
2. Run the installer. On the first screen, check **"Add Python to PATH"** before
   clicking Install — this is easy to miss and skipping it means nothing works.
3. Once installed, open a fresh PowerShell window and install SCons:
   ```powershell
   python -m pip install scons
   ```
4. Verify both:
   ```powershell
   python --version
   scons --version
   ```
   Both should print version numbers. If either says "not recognized," reboot and
   try again — the PATH update from the installer requires a fresh session.


## Step 6 — Install the Android SDK

### Part A — Install Android Studio to get sdkmanager

1. Download Android Studio from <https://developer.android.com/studio> and install
   with default options.
2. Launch it. The first-run setup wizard will run — accept defaults, let it download
   the base SDK, accept all license agreements. Then close Android Studio.

   Its only job here is to put `sdkmanager` and the base SDK on disk. You won't
   use its GUI again.

### Part B — Set the ANDROID_HOME environment variable

Tools like `sdkmanager` and `adb` look for this variable to find the SDK. Set it
permanently so you never have to think about it again.

1. Press **Win + R**, type `sysdm.cpl`, press Enter.
2. Go to **Advanced → Environment Variables**.
3. Under **User variables**, click **New**:
   - **Variable name:** `ANDROID_HOME`
   - **Variable value:** paste the output of this PowerShell line:
     ```powershell
     "$env:LOCALAPPDATA\Android\Sdk"
     ```
4. Click OK through all dialogs.
5. **Close and reopen PowerShell** so it picks up the new variable.

### Part C — Find sdkmanager and install all required packages

1. First, find where Android Studio put the command-line tools:
   ```powershell
   ls "$env:LOCALAPPDATA\Android\Sdk\cmdline-tools\"
   ```
   You'll see a version-numbered folder (e.g. `16.0`) or a folder called `latest`.
   Note the name — replace `latest` in the next command if yours is different.

2. Run the installer. This is one long command — paste the whole thing at once,
   do not break it across lines:
   ```powershell
   & "$env:LOCALAPPDATA\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat" "platform-tools" "build-tools;35.0.1" "platforms;android-35" "cmdline-tools;latest" "cmake;3.10.2.4988404" "ndk;28.1.13356709"
   ```
   The tool prints license agreements as it goes — type `y` and Enter each time.
   It downloads and installs everything in one pass.

### Verify

```powershell
ls "$env:LOCALAPPDATA\Android\Sdk\ndk\28.1.13356709\"
```
If that folder lists files, all packages are installed.


## Step 7 — Create the debug keystore

Signs your test builds. Run this in PowerShell, all on one line. (If `keytool`
isn't found, replace it with the full path:
`"C:\Program Files\Eclipse Adoptium\jdk-17.x.x-hotspot\bin\keytool.exe"`)

```powershell
keytool -keyalg RSA -genkeypair -alias androiddebugkey -keypass android -keystore "D:\Godot\debug.keystore" -storepass android -dname "CN=Android Debug,O=Android,C=US" -validity 9999 -deststoretype pkcs12
```

Creates `D:\Godot\debug.keystore`. Alias is `androiddebugkey`, both passwords are
`android`. Remember those for Step 8.


## Step 8 — Point Godot at everything (one time)

1. In Godot: **Editor → Editor Settings**.
2. In the search box, type `android`. You'll land on **Export → Android**.
3. Fill in:
   - **Java SDK Path** → the specific JDK subfolder, not the Adoptium parent.
     Point it at the folder that contains a `bin\` directory with `java.exe` inside.
     It looks like `C:\Program Files\Eclipse Adoptium\jdk-17.0.x.x-hotspot` — the
     version numbers in the folder name will match whatever you installed.
     To find the exact path, run in PowerShell:
     ```powershell
     ls "C:\Program Files\Eclipse Adoptium\"
     ```
     Copy the full name of the `jdk-17...` folder shown and prepend
     `C:\Program Files\Eclipse Adoptium\` to it.
   - **Android SDK Path** → SDK location from Step 6.
     Godot's path field doesn't expand environment variables, so run this in
     PowerShell to print the exact string to copy-paste:
     ```powershell
     "$env:LOCALAPPDATA\Android\Sdk"
     ```
   - **Debug Keystore** → `D:\Godot\debug.keystore`
   - **Debug Keystore User** → `androiddebugkey`
   - **Debug Keystore Pass** → `android`

Close Editor Settings. A wrong path shows as a red warning when you try to export.


## Step 9 — Install the Android Build Template into the project

Per-project, not per-machine. Do this once for ChompStomp.

1. With ChompStomp open in Godot: **Project → Install Android Build Template**.
2. Confirm. Godot unpacks Gradle build files into an `android/` folder inside your
   project. Commit that folder to git — it's part of the project.
   (Redo this only if you upgrade Godot versions.)


## Step 10 — Configure the export preset and build

1. **Project → Export**.
2. Click **Add…** and choose **Android**.
3. The preset opens. With Steps 3–9 done, there should be no red error text at the
   bottom. (If there is, it names the missing piece.)
4. Set SDK versions to match the tablet:
   - **Min SDK** — 26 (Android 8+)
   - **Target SDK** — 35; bump to 36 once available and the tablet confirms Android 16
5. Set screen orientation to **Landscape**.
6. The 2000×1200 FHD display is handled automatically — no special export setting needed.
7. Click **Export Project**, name the file `chomp-stomp.apk`, leave
   "Export With Debug" checked for all test builds.

The first build is slow (Gradle downloads dependencies). Later builds are fast.


## Step 11 — Get it onto the tablet

1. On the tablet: **Settings → About → tap "Build number" seven times** to unlock
   Developer Options. Then in Developer Options, turn on **USB debugging**.
2. Plug the tablet into the PC. Accept the "Allow USB debugging?" prompt on the tablet.
3. In PowerShell, verify the tablet is visible:
   ```powershell
   & "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" devices
   ```
4. Install the APK:
   ```powershell
   & "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" install -r "D:\path\to\chomp-stomp.apk"
   ```

The `-r` flag means reinstall/replace — run it again after every new build.

That's the loop: **Export Project** in Godot → `adb install -r` → play on the tablet.


## Quick troubleshooting

| Symptom | Fix |
|---|---|
| "A valid Java SDK path is required" | Java SDK Path in Editor Settings points at the wrong folder or at JDK 21. Repoint it at the JDK 17 folder from Step 4. |
| Wall of red Gradle text | Version mismatch. Confirm editor version == templates version (Step 3), and JDK is 17 (Step 4). |
| Export button greyed out | Templates not installed (redo Step 3) or build template missing from project (redo Step 9). |
| `adb` not recognized | Use the full path to `adb.exe` as shown in Step 11, or add the `platform-tools` folder to your PATH. |
| Tablet not in `adb devices` | USB debugging off, bad cable, or missed the "Allow" prompt. Unplug, replug, watch the tablet screen. |
| Build crashes on tablet at launch | Target SDK mismatch (Step 10). A wrong target SDK can cause instant crashes on Android 15/16. |


## Once this works

Steps 1–9 are done forever. You only ever repeat Steps 10 and 11. When Claude Code
builds a new stage of the game, this pipeline turns it into something Chloe and Ryan
can hold within a couple of minutes.
