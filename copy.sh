#!/usr/bin/expect -f

set username [lindex $argv 0]
set ip [lindex $argv 1]
set password [lindex $argv 2]

# timeout for SSH response
set timeout 10
spawn scp -r -oStrictHostKeyChecking=no -oCheckHostIP=no ./ $username@$ip:~/.mem

expect {[Pp]assword}
send "$password\r"
expect eof

puts "Done copying"
return 0;
