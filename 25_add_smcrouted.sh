#!/bin/bash

which smcroute &> /dev/null
if [ ! "$?" == "0" ] ; then
    sudo apt-get update
    sudo apt-get install \
        smcroute
fi

SMC_CONFIG=/etc/smcroute.conf

if [ ! -f ${SMC_CONFIG} ] ; then
    sudo touch ${SMC_CONFIG} 
    echo 'mgroup from weave group 239.255.255.250' | sudo tee -a ${SMC_CONFIG}
    echo 'mroute from weave group 239.255.255.250 to eno1' | sudo tee -a ${SMC_CONFIG}
fi

echo "smcroute configured"
echo "You're not done yet!"
echo "You still need to add a static route to your router to route 10.32.0.0/12 to the master node."

