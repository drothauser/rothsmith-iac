aws elbv2 describe-load-balancers | grep -i nexus | grep DNSName | awk '{print $2}' | sed 's/[\"\,]//g'
