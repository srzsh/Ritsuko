define(`new_user_name', `balthasar')dnl
changequote(`[', `]')dnl
define([new_user_ssh_pubkey], [`]esyscmd([printf \[; ssh-add -L | grep 'balthasar' | tr -d $'\n'; printf \]])['])dnl
changequote([`], ['])dnl
ifelse(new_user_ssh_pubkey, `',
		`errprint(`Could not get ssh pubkey from agent
')m4exit(`1')')dnl
define(`new_ssh_port', `69')dnl
