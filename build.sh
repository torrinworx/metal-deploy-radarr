#!/bin/bash

set -e

apt update
apt install -y curl sqlite3

arch=$(dpkg --print-architecture)
case $arch in
	amd64) arch="x64" ;;
	arm|armf|armh) arch="arm" ;;
	arm64) arch="arm64" ;;
	*) echo "Unsupported architecture: $arch" && exit 1 ;;
esac

wget --content-disposition "http://radarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=$arch" -O ./Radarr.tar.gz
tar -xvzf ./Radarr.tar.gz -C ./

mkdir -p ./build/
mv ./Radarr ./build/Radarr/
mkdir -p ~/.radarr-data

cat <<'EOF' > ./build/run.sh
#!/bin/bash

DATA_DIR=$(readlink -f "$HOME/.radarr-data")
exec "./Radarr/Radarr" -nobrowser -data="$DATA_DIR"
EOF

chmod +x ./build/run.sh
rm ./Radarr.tar.gz

echo "Build complete. Run './build/run.sh' to start Radarr."
