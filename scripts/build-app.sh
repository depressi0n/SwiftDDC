#!/bin/bash
set -e

echo "=== 步骤 1: 清理旧产物 ==="
rm -rf DDCMenu.app DDCMenu.zip .build

echo "=== 步骤 2: 使用 swift build 编译 ==="
swift build -c release --product DDCMenu

echo "=== 步骤 3: 确定可执行文件路径 ==="
EXECUTABLE_PATH=".build/release/DDCMenu"

if [ ! -f "$EXECUTABLE_PATH" ]; then
  echo "错误：找不到可执行文件 $EXECUTABLE_PATH"
  exit 1
fi

echo "找到可执行文件: $EXECUTABLE_PATH"

echo "=== 步骤 4: 创建 .app 包结构 ==="
mkdir -p DDCMenu.app/Contents/MacOS
mkdir -p DDCMenu.app/Contents/Resources

echo "=== 步骤 5: 复制可执行文件 ==="
cp "$EXECUTABLE_PATH" DDCMenu.app/Contents/MacOS/DDCMenu
chmod +x DDCMenu.app/Contents/MacOS/DDCMenu

echo "=== 步骤 6: 创建 Info.plist ==="
cat > DDCMenu.app/Contents/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>DDCMenu</string>
    <key>CFBundleIdentifier</key>
    <string>com.github.depressi0n.DDCMenu</string>
    <key>CFBundleName</key>
    <string>DDCMenu</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>11.0</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF

echo "=== 步骤 7: 打包为 .zip ==="
ditto -c -k --sequesterRsrc --keepParent DDCMenu.app DDCMenu.zip

echo "=== 构建成功 ==="
ls -lh DDCMenu.zip
echo "验证成功：DDCMenu.zip 已创建"