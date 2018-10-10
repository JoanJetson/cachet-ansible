#!/bin/bash
# Author: Joan Bohlman
# Peace Among Worlds
# This can be improved a lot but it isn't too important

echo "Creating status_page"
cd status_page
make all
cd ..
echo "Creating cachet-monitor"
cd cachet_monitor
make all
