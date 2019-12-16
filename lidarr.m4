include(variables.m4)dnl
#!/bin/sh

# $FreeBSD$
#
# PROVIDE: lidarr
# REQUIRE: LOGIN
# KEYWORD: shutdown
#
# Add the following lines to /etc/rc.conf.local or /etc/rc.conf
# to enable this service:
#
# lidarr_enable:    Set to YES to enable lidarr
#            Default: NO

. /etc/rc.subr
name=lidarr
rcvar=${name}_enable
load_rc_config $name

: ${lidarr_enable:="NO"}
: ${lidarr_user:="__MEDIA_USER__"}
: ${lidarr_group:="__MEDIA_USER__"}
: ${lidarr_data_dir:="/config"}

command="/usr/sbin/daemon"
procname="/usr/local/bin/mono"
command_args="-p ${lidarr_data_dir}/lidarr.pid -f ${procname} /usr/local/share/Lidarr/Lidarr.exe -- data=${lidarr_data_dir} --nobrowser"

start_precmd=lidarr_precmd
lidarr_precmd() {
    export USER=${lidarr_user}
    if [ ! -d ${lidarr_data_dir} ]; then
    install -d -o ${lidarr_user} -g ${lidarr_group} ${lidarr_data_dir}
    fi

    export XDG_CONFIG_HOME=${lidarr_data_dir}
}

run_rc_command "$1"
