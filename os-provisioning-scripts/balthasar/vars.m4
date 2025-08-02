divert(`-1')
define(`host_name', `balthasar')
define(`new_user_name', host_name)
changequote(`[', `]')
define([new_user_ssh_pubkey], [`]esyscmd([printf \[; ssh-add -L | grep 'balthasar' | tr -d $'\n'; printf \]])['])
changequote([`], ['])
ifelse(new_user_ssh_pubkey, `',
		`errprint(`Could not get ssh pubkey from agent
')m4exit(`1')')
define(`new_ssh_port', `69')
divert(`0')dnl
