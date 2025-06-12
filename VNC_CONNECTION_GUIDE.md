# 🖥️ VNC Connection Guide for SAGE OS

## 🎯 **Quick Solution for Password Issues**

When Screen Sharing asks for a password:
1. **Leave the password field BLANK**
2. **Click "Connect" without entering anything**
3. **Or press Enter with empty password field**

## 🔧 **Updated QEMU Commands**

All SAGE OS scripts now use `password=off` parameter:

```bash
# VNC with no password required
qemu-system-i386 -drive file=build/macos/sage_os_macos.img,format=raw,if=floppy,readonly=on -boot a -m 128M -vnc :1,password=off -no-fd-bootchk &
```

## 📱 **Step-by-Step Connection Process**

### **Method 1: Screen Sharing App (macOS)**
1. Open **Spotlight** (Cmd+Space)
2. Type "Screen Sharing" and press Enter
3. In the connection dialog, enter: `localhost:5901`
4. Click "Connect"
5. **When prompted for password: Leave blank and click "Connect"**

### **Method 2: Finder Method**
1. Open **Finder**
2. Press **Cmd+K** (Connect to Server)
3. Enter: `vnc://localhost:5901`
4. Click "Connect"
5. **Leave password blank when prompted**

### **Method 3: Command Line**
```bash
open vnc://localhost:5901
```

## 🔍 **Troubleshooting Common Issues**

### **Issue 1: "Address already in use"**
**Solution:** Scripts now automatically find available ports
```bash
# The scripts will try ports 5901, 5902, 5903, etc.
# Connect to the port shown in the output
```

### **Issue 2: "Password required"**
**Solution:** 
- Leave password field completely empty
- Click "Connect" or press Enter
- Do NOT enter any password

### **Issue 3: "Connection refused"**
**Check:**
1. QEMU is running: `ps aux | grep qemu`
2. Port is listening: `lsof -i :5901`
3. Try different port: `vnc://localhost:5902`

### **Issue 4: Black screen or no display**
**Normal behavior:**
- SAGE OS shows black screen with white text
- Look for "SAGE OS Bootloader Working!" message
- "System Ready" prompt should appear

## 🎮 **Available Launch Scripts**

### **Quick Test (Recommended)**
```bash
./quick_test_sage_os.sh
# Choose 'y' to launch
# Connect to the port shown in output
```

### **Full Setup Script**
```bash
./sage-os-macos.sh
# Choose 'y' when prompted to launch
```

### **VNC Connection Test**
```bash
./test_vnc_connection.sh
# Dedicated VNC testing script
```

## 🔗 **Port Information**

- **Default VNC Port**: 5901 (display :1)
- **Alternative Ports**: 5902, 5903, 5904, etc.
- **Port Format**: `localhost:590X` where X is the display number + 1

## ✅ **What You Should See**

When successfully connected to SAGE OS via VNC:

```
SAGE OS Bootloader Working!
Loading kernel...
System Ready - Press any key
_
```

## 🚨 **If Nothing Works**

1. **Kill all QEMU processes:**
   ```bash
   pkill qemu-system-i386
   ```

2. **Check for port conflicts:**
   ```bash
   lsof -i :5901
   lsof -i :5902
   ```

3. **Try manual connection:**
   ```bash
   qemu-system-i386 -drive file=build/macos/sage_os_macos.img,format=raw,if=floppy,readonly=on -boot a -m 128M -vnc :2,password=off -no-fd-bootchk &
   # Then connect to localhost:5902
   ```

4. **Use alternative VNC client:**
   - Download RealVNC Viewer
   - Use built-in VNC in other apps

## 🎉 **Success Indicators**

✅ **QEMU starts without errors**  
✅ **VNC port is accessible**  
✅ **Screen Sharing connects without password**  
✅ **SAGE OS bootloader message appears**  
✅ **Interactive prompt is visible**  

The VNC connection should now work seamlessly without password prompts!