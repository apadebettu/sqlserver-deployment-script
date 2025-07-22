---

# 🛠️ Silent SQL Server 2022/2025 Installer (ManageEngine)

This project provides a Windows batch script for silently installing **SQL Server 2022 or 2025 Developer Edition** using a mounted ISO and configuration file. It's especially useful for **mass deployments**, such as via **ManageEngine Endpoint Central**.

---

## 📦 What This Does

* 🗂 **Mounts** the SQL Server ISO automatically
* 🔍 **Detects** the mounted drive letter
* ⚙️ **Runs** SQL Server Setup using a custom configuration file
* 🪵 **Logs** the entire process to `sql_install_log.txt`
* 💿 **Dismounts** the ISO after installation

---

## 📁 Folder Structure

Place all three files in the same folder:

```
/Your-Folder/
├── SQLServer2022-x64-ENU-Dev.iso
├── ConfigurationFile.ini
└── install.bat
```

---

## ⚙️ Setup Instructions

### Step 1: 📥 Download SQL Server

1. Visit [Microsoft SQL Server Downloads](https://www.microsoft.com/en-us/sql-server/sql-server-downloads)
2. Download the **EXE installer**
3. Run the EXE **locally** (not from a fileshare!)
4. Choose **“Download Media”**, then select **ISO**
5. Save the ISO in a **dedicated folder on your desktop** (not on a network drive)

> 💡 Avoid using Web installers (filesize in KB) — they are not compatible with silent ISO deployment.

---

### Step 2: 📝 Create Configuration File

1. Open a new text file and paste a valid SQL Server configuration
2. Save the file as `ConfigurationFile.ini`

<details>
<summary>📄 Sample ConfigurationFile.ini</summary>

```ini
[OPTIONS]
ACTION="Install"
IACCEPTSQLSERVERLICENSETERMS="1"
FEATURES=SQLENGINE,REPLICATION,FULLTEXT,CONN
INSTANCENAME="MSSQLSERVER"
SECURITYMODE="SQL"
SAPWD="Your_Strong_Password123"
SQLSYSADMINACCOUNTS="BUILTIN\Administrators"
AGTSVCACCOUNT="NT AUTHORITY\SYSTEM"
SQLSVCACCOUNT="NT AUTHORITY\SYSTEM"
```

</details>

> 🛑 Every environment is unique. Adjust the settings for your environment.

---

### Step 3: 🔧 Download the Installer Script

1. Ensure the script is saved as `install.bat`
2. Update the file names inside the script if using SQL Server 2025 or different ISO names

---

### Step 4: 🧪 Test the Installer Locally

1. Open **Command Prompt as Administrator**
2. Navigate to the folder
3. Run:

   ```cmd
   install.bat
   ```
4. Wait for SQL Server to install and check `sql_install_log.txt`

---

### Step 5: 📚 Prepare for Deployment (ManageEngine)

1. Confirm your folder contains **exactly 3 files**:

   * ISO file
   * `ConfigurationFile.ini`
   * `install.bat`
2. Select all 3 files (`Ctrl+A`) → Right-click → Send to > Compressed (zipped) folder
3. ⚠️ Ensure **no subfolders** exist inside the ZIP

> 📌 ManageEngine won’t work with nested folders inside the ZIP.

---

## 🖥️ Deploy via ManageEngine Endpoint Central

### ✅ Create Package

1. Login to Endpoint Central → **Software Deployment > Packages**
2. Click **Add Package → Windows**
3. Fill in:

   * **Name**: Microsoft SQL Server 2022
   * **Type**: EXE/MSI/Command
   * **Upload ZIP** from your local computer
   * **Install Command**: `install.bat`
   * **Run As**: System Account (ensure Admin privileges)
4. Click **Add Package**

---

### 🚀 Create Deployment Task

1. Go to **Install/Uninstall Software**
2. Create a configuration (e.g., *Deploy SQL 2022*)
3. Select:

   * **Package Name** you created
   * **System User** (do not allow user interaction)
   * **Deploy Any Time at the Earliest**
4. **Target**: Start with a non-critical machine (like your own)
5. Click **Deploy Immediately** or **Deploy**

---
