#!/bin/bash
set -e

# 这个脚本只负责打包,它假设二进制文件已经由 CI 构建好了。
BINARY_PATH=".build/release/DDCMenu"
APP_NAME="DDCMenu.app"
APP_PATH="dist/$APP_NAME"
PLIST_PATH="$APP_PATH/Contents/Info.plist"
MACOS_PATH="$APP_PATH/Contents/MacOS"

# 1. 检查二进制文件是否存在
if [ ! -f "$BINARY_PATH" ]; then
    echo "错误: 二进制文件 '$BINARY_PATH' 不存在。请先运行 'swift build -c release'。"
    exit 1
fi

# 2. 创建干净的应用包目录结构
rm -rf dist
mkdir -p "$MACOS_PATH"

# 3. 复制二进制文件
cp "$BINARY_PATH" "$MACOS_PATH/"

# 4. 创建 Info.plist
cat > "$PLIST_PATH" <<EOL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>DDCMenu</string>
    <key>CFBundleIconFile</key>
    <string>icon.icns</string>
    <key>CFBundleIdentifier</key>
    <string>com.depressi0n.DDCMenu</string>
    <key>CFBundleName</key>
    <string>DDCMenu</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOL

echo "成功创建了 '$APP_PATH'"

# 5. 打包成 zip
ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" ./DDCMenu.zip

echo "成功创建了 DDCMenu.zip"