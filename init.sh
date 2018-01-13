#!/bin/bash
[ "X$PROFILE" = "X" ] && export PROFILE=~/.bash_profile

#write custom command line in your profile
sed -i '' "/alias ez=/"d $PROFILE
echo "alias ez=\"ruby `pwd`/ez.rb\"" >> $PROFILE

bundle check || bundle install
#Set username/password
echo 'Please input your LDAP USERNAME:'
while read USERNAME
do
  sed -i '' "s/USERNAME/$USERNAME/g" ./config.yml
  break
done

echo 'Please input your LDAP PASSWORD:'
while read -s PASSWORD
do
  sed -i '' "s/PASSWORD/`ruby pw_help.rb $PASSWORD`/g" ./config.yml
  break
done