#!/bin/zsh

# Variables
SCHEME="Drag and Drop to Open URL"
DESTINATION='platform=macOS,arch=arm64,name=My Mac'
CONFIGURATION="Release"
ARCHIVE_PATH="./build/DragAndDropToOpenURL.xcarchive"
EXPORT_PATH="./build/DragAndDropToOpenURLExport"
PKG_PATH="./build/DragAndDropToOpenURLExport/Drag and Drop to Open URL.pkg"  # Escape spaces in file name
EXPORT_OPTIONS_PLIST="./exportOptions.plist"
API_KEY_ID="8W74YHXYNJ"
ISSUER_ID="69a6de75-7e26-47e3-e053-5b8c7c11a4d1"

# Clean
echo "Cleaning the build..."
xcodebuild clean -scheme "$SCHEME" -destination "$DESTINATION" -configuration "$CONFIGURATION" -quiet

# Build
echo "Building the app..."
xcodebuild build -scheme "$SCHEME" -destination "$DESTINATION" -configuration "$CONFIGURATION" -sdk macosx -quiet

# Archive
echo "Archiving the app..."
xcodebuild archive \
  -scheme "$SCHEME" \
  -destination "$DESTINATION" \
  -configuration "$CONFIGURATION" \
  -archivePath "$ARCHIVE_PATH" \
  -sdk macosx -quiet

# Export the .pkg file from the .xcarchive
echo "Exporting the .pkg file..."
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist "$EXPORT_OPTIONS_PLIST" -quiet

# Check if the .pkg file was created
if [ ! -f "$PKG_PATH" ]; then
  echo "Error: The .pkg file was not created."
  exit 1
fi

echo "Build, validation, and export succeeded!"

# Ask if user wants to submit the .pkg file
read "REPLY?Do you want to submit the .pkg file to App Store Connect? (yes/no): "

if [[ "$REPLY" =~ ^[Yy][Ee][Ss]$ || "$REPLY" =~ ^[Yy]$ ]]; then
    # Submit the .pkg file using altool
    echo "Submitting the .pkg file to App Store Connect..."
    xcrun altool --upload-app \
      -f "$PKG_PATH" \
      -t osx \
      --apiKey "$API_KEY_ID" \
      --apiIssuer "$ISSUER_ID" \
      --output-format xml

    # Check if the submission succeeded
    if [ $? -eq 0 ]; then
      echo "App successfully submitted to App Store Connect!"
    else
      echo "App submission failed. Please check for errors."
      exit 1
    fi
else
    echo "Submission canceled by user."
fi