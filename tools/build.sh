# Build script handling
mkdir -p build/addons/sourcemod/{plugins,scripting}
mkdir -p build/addons/sourcemod/scripting/include

# Compile
spcomp scripting/onlymysteamgroup.sp

# Move around file
mv onlymysteamgroup.smx build/addons/sourcemod/plugins/
cp scripting/onlymysteamgroup.sp build/addons/sourcemod/scripting/
cp scripting/include/SteamWorks.inc build/addons/sourcemod/scripting/include/

# Pack files
zip_name=$(echo "${GITHUB_REF/refs\/tags\//}")
zip "${zip_name}.zip" build/

echo "Done!"
