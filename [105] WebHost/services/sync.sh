#!/bin/bash
set -e

# === Config ===
REPO_URL="https://github.com/Eric-Philippe/HomeServerConfig.git"
TARGET_PATH="[105] WebHost/services"
LOCAL_FOLDER="$HOME/services"
TMP_DIR="$HOME/tmp_homeserverconfig"

echo "🔧 Preparing to push $LOCAL_FOLDER → $REPO_URL/$TARGET_PATH"

# Cleanup old temp clone
rm -rf "$TMP_DIR"

# Clone repo
git clone "$REPO_URL" "$TMP_DIR"
cd "$TMP_DIR"
mkdir -p "$TARGET_PATH"

echo "📦 Plain folder — using rsync with .gitignore if present"
rsync -av --exclude-from="$LOCAL_FOLDER/.gitignore" "$LOCAL_FOLDER"/ "$TMP_DIR/$TARGET_PATH"/ 2>/dev/null || \
rsync -av "$LOCAL_FOLDER"/ "$TMP_DIR/$TARGET_PATH"/

# Commit & push
cd "$TMP_DIR"
git add "$TARGET_PATH"
if git diff --cached --quiet; then
  echo "✅ No changes to commit."
else
  git commit -m "Sync $TARGET_PATH from webhost machine (ignoring .gitignored files if possible)"
  git push origin main
  echo "🚀 Successfully pushed changes to $REPO_URL"
fi

# Cleanup
cd ~
rm -rf "$TMP_DIR"
echo "✅ Done!"
