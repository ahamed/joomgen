sudo install joomgen.sh /usr/local/bin/joomgen && sudo cp -r shell_components /usr/local/bin
sudo chmod -R 777 /usr/local/bin/shell_components

echo "Installation completed!"
echo "run joomgen -c for creating component"
echo "run joomgen -v for creating backend view"
echo "run joomgen -v -f for frontend view"