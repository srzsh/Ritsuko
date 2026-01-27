divert(`-1')
define(`host_name', `ayanami')
define(`new_user_name', `rei')
changequote(`[', `]')
define([new_user_ssh_pubkey], [`]esyscmd([printf \[; ssh-add -L | grep 'ayanami' | tr -d $'\n'; printf \]])['])
changequote([`], ['])
ifelse(new_user_ssh_pubkey, `',
		`errprint(`Could not get ssh pubkey from agent
')m4exit(`1')')
divert(`0')dnl
