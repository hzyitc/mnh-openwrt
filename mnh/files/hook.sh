#!/bin/sh

# Global variable
name="$1"
type="$2"
event="$3"
errmsg="$4"
port="$5"
addr="$6"

iptables_check_and_append() {
	iptables -t "filter" -C "MNH" $@ 2>/dev/null \
	|| iptables -t "filter" -A "MNH" $@
}

insert_iptables_rule() {
	iptables_check_and_append -p $type -m $type --dport $port -j ACCEPT
}

remove_iptables_rule() {
	iptables -t "filter" -D "MNH" -p $type -m $type --dport $port -j ACCEPT
}

main() {
	cat <<-EOF >"/var/run/mnh/$name"
		${event}
		${errmsg}
		${port}
		${addr}
	EOF

	case "$event" in
		success)
			insert_iptables_rule
			;;

		disconnected)
			remove_iptables_rule
			;;

	esac
}

main
