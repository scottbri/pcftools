#wget -q -O - https://raw.githubusercontent.com/starkandwayne/homebrew-cf/master/public.key | sudo apt-key add -
#echo "deb http://apt.starkandwayne.com stable main" | sudo tee /etc/apt/sources.list.d/starkandwayne.list
#sudo apt-get update
#sudo apt-get install om


mkdir ~/bin 2>/dev/null
cd ~/bin
wget https://github.com/pivotal-cf/om/releases/download/0.38.0/om-linux
chmod +x ./om-linux
mv om-linux om
