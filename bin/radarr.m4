#!/bin/sh
# $FreeBSD$
#
# PROVIDE: radarr
# REQUIRE: LOGIN
# KEYWORD: shutdown
#
# Add the following lines to /etc/rc.conf.local or /etc/rc.conf
# to enable this service:
#
# radarr_enable:    Set to YES to enable radarr
#            Default: NO
# radarr_user:    The user account used to run the radarr daemon.
#            This is optional, however do not specifically set this to an
#            empty string as this will cause the daemon to run as root.
#            Default: media
# radarr_group:    The group account used to run the radarr daemon.
#            This is optional, however do not specifically set this to an
#            empty string as this will cause the daemon to run with group wheel.
#            Default: media
# radarr_data_dir:    Directory where radarr configuration
#            data is stored.
#            Default: /var/db/radarr

. /etc/rc.subr
name=radarr
rcvar=${name}_enable
load_rc_config $name

: ${radarr_enable:="NO"}
: ${radarr_user:="media"}
: ${radarr_group:="media"}
: ${radarr_data_dir:="/config"}

pidfile="${radarr_data_dir}/radarr.pid"
stop_postcmd="${name}_poststop"
start_precmd="${name}_prestart"

command="/usr/sbin/daemon"
procname="/usr/local/bin/mono"
command_args="-f -p ${pidfile} ${procname} /usr/local/share/Radarr/Radarr.exe --data=${radarr_data_dir} --nobrowser"

radarr_poststop()
{
        rm $pidfile
}
radarr_prestart() {
    if [ ! -d ${radarr_data_dir} ]; then
    install -d -o ${radarr_user} -g ${radarr_group} ${radarr_data_dir}
    fi
    export XDG_CONFIG_HOME=${radarr_data_dir}
}

run_rc_command "$1"
