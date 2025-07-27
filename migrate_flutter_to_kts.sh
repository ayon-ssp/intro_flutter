#!/bin/bash

# Flutter Groovy to Kotlin DSL Migration Script
# Usage: ./migrate_flutter_to_kts.sh [project_path]

PROJECT_PATH=${1:-.}
ANDROID_PATH="$PROJECT_PATH/android"

echo "🚀 Starting Flutter Groovy to Kotlin DSL migration..."
echo "Project path: $PROJECT_PATH"

# Check if this is a Flutter project
if [ ! -f "$PROJECT_PATH/pubspec.yaml" ]; then
    echo "❌ Error: Not a Flutter project (pubspec.yaml not found)"
    exit 1
fi

# Check if android folder exists
if [ ! -d "$ANDROID_PATH" ]; then
    echo "❌ Error: Android folder not found"
    exit 1
fi

# Create backup
echo "📦 Creating backup..."
cp -r "$ANDROID_PATH" "$ANDROID_PATH_backup_$(date +%Y%m%d_%H%M%S)"

# Function to rename files
rename_gradle_files() {
    echo "📝 Renaming .gradle files to .gradle.kts..."
    
    if [ -f "$ANDROID_PATH/build.gradle" ]; then
        mv "$ANDROID_PATH/build.gradle" "$ANDROID_PATH/build.gradle.kts"
        echo "✅ Renamed root build.gradle to build.gradle.kts"
    fi
    
    if [ -f "$ANDROID_PATH/settings.gradle" ]; then
        mv "$ANDROID_PATH/settings.gradle" "$ANDROID_PATH/settings.gradle.kts"
        echo "✅ Renamed settings.gradle to settings.gradle.kts"
    fi
    
    if [ -f "$ANDROID_PATH/app/build.gradle" ]; then
        mv "$ANDROID_PATH/app/build.gradle" "$ANDROID_PATH/app/build.gradle.kts"
        echo "✅ Renamed app/build.gradle to app/build.gradle.kts"
    fi
}

# Function to check current state
check_current_state() {
    echo "🔍 Checking current project state..."
    
    if [ -f "$ANDROID_PATH/build.gradle.kts" ]; then
        echo "✅ Project already has build.gradle.kts files"
        echo "💡 This project might already be migrated to Kotlin DSL"
        read -p "Do you want to continue anyway? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "🚪 Exiting..."
            exit 0
        fi
    fi
}

# Function to show next steps
show_next_steps() {
    echo ""
    echo "🎉 File renaming completed!"
    echo ""
    echo "📋 Next steps (manual):"
    echo "1. Update syntax in build.gradle.kts files:"
    echo "   - Change 'apply plugin:' to 'id()'"
    echo "   - Add '=' for property assignments"
    echo "   - Use parentheses for method calls"
    echo "   - Update dependency syntax"
    echo ""
    echo "2. Test the migration:"
    echo "   cd $PROJECT_PATH"
    echo "   flutter clean"
    echo "   flutter pub get"
    echo "   flutter build apk --debug"
    echo ""
    echo "3. Refer to migrate_to_kts.md for detailed syntax examples"
    echo ""
    echo "🔄 If something goes wrong, restore from backup:"
    echo "   rm -rf $ANDROID_PATH && mv $ANDROID_PATH_backup_* $ANDROID_PATH"
}

# Main execution
check_current_state
rename_gradle_files
show_next_steps

echo "✨ Migration preparation complete!"
