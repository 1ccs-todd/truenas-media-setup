#!/bin/sh
# PROVIDE: bazarr
# REQUIRE: LOGIN
# KEYWORD: shutdown

# Add the following lines to /etc/rc.conf.local or /etc/rc.conf
# to enable this service:
# bazarr_enable="YES"
# Optionally add:
# Note: The bazarr_user must be unique as the stop_postcmd kills the other running process
# bazarr_user="bazarr"

. /etc/rc.subr

name="bazarr"
rcvar=bazarr_enable
load_rc_config $name

: ${bazarr_enable="NO"}
: ${bazarr_user:="bazarr"}
: ${bazarr_group:="bazarr"}
: ${bazarr_data_dir:="/config"}

pidfile="${bazarr_data_dir}/bazarr.pid"
start_precmd=bazarr_prestart
stop_postcmd=bazarr_poststop

procname="/usr/local/bin/python3"
command="/usr/sbin/daemon"
command_args="-f -p ${pidfile} ${procname} /usr/local/share/bazarr/bazarr.py"

bazarr_poststop()
{
}
bazarr_prestart()
{
	export XDG_CONFIG_HOME=${bazarr_data_dir}
        export GIT_PYTHON_REFRESH=quiet

	if [ ! -d ${bazarr_data_dir} ]; then
		install -d -o ${bazarr_user} ${bazarr_data_dir}
	fi
}

run_rc_command "$1"
