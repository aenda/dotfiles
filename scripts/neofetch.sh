#!/usr/bin/env bash
# set -x
# vim: noai:ts=4:sw=4:expandtab
#
# Neofetch: Simple system information script.
# https://github.com/dylanaraps/neofetch
#
# Created by Dylan Araps
# https://github.com/dylanaraps/

# Neofetch version.
version="3.4.1-git"

bash_version="${BASH_VERSION/.*}"
sys_locale="${LANG:-C}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"

# Speed up script by not using unicode.
export LC_ALL=C
export LANG=C

# Add more paths to $PATH.
export PATH="/usr/xpg4/bin:/usr/sbin:/sbin:/usr/etc:/usr/libexec:${PATH}"

# Fix issues with gsettings.
export GIO_EXTRA_MODULES="/usr/lib/x86_64-linux-gnu/gio/modules/"

# Set no case match.
shopt -s nocasematch

# Reset colors and bold.
reset="\e[0m"

# DETECT INFORMATION

get_os() {
    # $kernel_name is set in a function called cache_uname and is
    # just the output of "uname -s".
    case "$kernel_name" in
        "Linux" | "GNU"*) os="Linux" ;;
        "Darwin") os="$(sw_vers -productName)" ;;
        *"BSD" | "DragonFly" | "Bitrig") os="BSD" ;;
        "CYGWIN"* | "MSYS"* | "MINGW"*) os="Windows" ;;
        "SunOS") os="Solaris" ;;
        "Haiku") os="Haiku" ;;
        "MINIX") os="MINIX" ;;
        "AIX") os="AIX" ;;
        "IRIX"*) os="IRIX" ;;
        "FreeMiNT") os="FreeMiNT" ;;
        *)
            printf "%s\n" "Unknown OS detected: '$kernel_name', aborting..." >&2
            printf "%s\n" "Open an issue on GitHub to add support for your OS." >&2
            exit 1
        ;;
    esac
}

get_distro() {
    [[ "$distro" ]] && return

    case "$os" in
        "Linux" | "BSD" | "MINIX")
            if [[ -f "/etc/redstar-release" ]]; then
                case "$distro_shorthand" in
                    "on" | "tiny") distro="Red Star OS" ;;
                    *) distro="Red Star OS $(awk -F'[^0-9*]' '$0=$2' /etc/redstar-release)"
                esac

            elif [[ -f "/etc/siduction-version" ]]; then
                case "$distro_shorthand" in
                    "on" | "tiny") distro="Siduction" ;;
                    *) distro="Siduction ($(lsb_release -sic))"
                esac

            elif type -p lsb_release >/dev/null; then
                case "$distro_shorthand" in
                    "on")   lsb_flags="-sir" ;;
                    "tiny") lsb_flags="-si" ;;
                    *)      lsb_flags="-sd" ;;
                esac
                distro="$(lsb_release $lsb_flags)"

            elif [[ -f "/etc/GoboLinuxVersion" ]]; then
                case "$distro_shorthand" in
                    "on" | "tiny") distro="GoboLinux" ;;
                    *) distro="GoboLinux $(< /etc/GoboLinuxVersion)"
                esac

            elif type -p guix >/dev/null; then
                case "$distro_shorthand" in
                    "on" | "tiny") distro="GuixSD" ;;
                    *) distro="GuixSD $(guix system -V | awk 'NR==1{printf $5}')"
                esac

            elif type -p crux >/dev/null; then
                distro="$(crux)"
                case "$distro_shorthand" in
                    "on")   distro="${distro//version}" ;;
                    "tiny") distro="${distro//version*}" ;;
                esac

            elif type -p tazpkg >/dev/null; then
                distro="SliTaz $(< /etc/slitaz-release)"

            elif type -p kpt >/dev/null && \
                 type -p kpm >/dev/null; then
                distro="KSLinux"

            elif [[ -d "/system/app/" && -d "/system/priv-app" ]]; then
                distro="Android $(getprop ro.build.version.release)"

            # Chrome OS doesn't conform to the /etc/*-release standard.
            # While the file is a series of variables they can't be sourced
            # by the shell since the values aren't quoted.
            elif [[ -f "/etc/lsb-release" && "$(< /etc/lsb-release)" == *CHROMEOS* ]]; then
                distro="$(awk -F '=' '/NAME|VERSION/ {printf $2 " "}' /etc/lsb-release)"

            elif [[ -f "/etc/os-release" || \
                    -f "/usr/lib/os-release" || \
                    -f "/etc/openwrt_release" ]]; then
                files=("/etc/os-release" "/usr/lib/os-release" "/etc/openwrt_release")

                # Source the os-release file
                for file in "${files[@]}"; do
                    source "$file" && break
                done

                # Format the distro name.
                case "$distro_shorthand" in
                    "on") distro="${NAME:-${DISTRIB_ID}} ${VERSION_ID:-${DISTRIB_RELEASE}}" ;;
                    "tiny") distro="${NAME:-${DISTRIB_ID:-${TAILS_PRODUCT_NAME}}}" ;;
                    "off") distro="${PRETTY_NAME:-${DISTRIB_DESCRIPTION}} ${UBUNTU_CODENAME}" ;;
                esac

                # Workarounds for distros that go against the os-release standard.
                [[ -z "${distro// }" ]] && distro="$(awk '/BLAG/ {print $1; exit}')" "${files[@]}"
                [[ -z "${distro// }" ]] && distro="$(awk -F'=' '{print $2; exit}')"  "${files[@]}"

            else
                for release_file in /etc/*-release; do
                    distro+="$(< "$release_file")"
                done

                if [[ -z "$distro" ]]; then
                    case "$distro_shorthand" in
                        "on" | "tiny") distro="$kernel_name" ;;
                        *) distro="$kernel_name $kernel_version" ;;
                    esac
                    distro="${distro/DragonFly/DragonFlyBSD}"

                    # Workarounds for FreeBSD based distros.
                    [[ -f "/etc/pcbsd-lang" ]] && distro="PCBSD"
                    [[ -f "/etc/trueos-lang" ]] && distro="TrueOS"

                    # /etc/pacbsd-release is an empty file
                    [[ -f "/etc/pacbsd-release" ]] && distro="PacBSD"
                fi
            fi

            if [[ "$(< /proc/version)" == *"Microsoft"* ||
                  "$kernel_version" == *"Microsoft"* ]]; then
                case "$distro_shorthand" in
                    "on")   distro+=" [Windows 10]" ;;
                    "tiny") distro="Windows 10" ;;
                    *)      distro+=" on Windows 10" ;;
                esac

            elif [[ "$(< /proc/version)" == *"chrome-bot"* || -f "/dev/cros_ec" ]]; then
                case "$distro_shorthand" in
                    "on")   distro+=" [Chrome OS]" ;;
                    "tiny") distro="Chrome OS" ;;
                    *)      distro+=" on Chrome OS" ;;
                esac
            fi

            distro="$(trim_quotes "$distro")"
            distro="${distro/'NAME='}"
        ;;

        "Mac OS X")
            osx_version="$(sw_vers -productVersion)"
            osx_build="$(sw_vers -buildVersion)"

            case "$osx_version" in
                "10.4"*)  codename="Mac OS X Tiger" ;;
                "10.5"*)  codename="Mac OS X Leopard" ;;
                "10.6"*)  codename="Mac OS X Snow Leopard" ;;
                "10.7"*)  codename="Mac OS X Lion" ;;
                "10.8"*)  codename="OS X Mountain Lion" ;;
                "10.9"*)  codename="OS X Mavericks" ;;
                "10.10"*) codename="OS X Yosemite" ;;
                "10.11"*) codename="OS X El Capitan" ;;
                "10.12"*) codename="macOS Sierra" ;;
                "10.13"*) codename="macOS High Sierra" ;;
                *)        codename="macOS" ;;
            esac
            distro="$codename $osx_version $osx_build"

            case "$distro_shorthand" in
                "on") distro="${distro/ ${osx_build}}" ;;
                "tiny")
                    case "$osx_version" in
                        "10."[4-7]*) distro="${distro/${codename}/Mac OS X}" ;;
                        "10."[8-9]* | "10.1"[0-1]*) distro="${distro/${codename}/OS X}" ;;
                        "10.1"[2-3]*) distro="${distro/${codename}/macOS}" ;;
                    esac
                    distro="${distro/ ${osx_build}}"
                ;;
            esac
        ;;

        "iPhone OS")
            distro="iOS $(sw_vers -productVersion)"

            # "uname -m" doesn't print architecture on iOS so we force it off.
            os_arch="off"
        ;;

        "Windows")
            distro="$(wmic os get Caption)"

            # Strip crap from the output of wmic.
            distro="${distro/Caption}"
            distro="${distro/Microsoft }"
        ;;

        "Solaris")
            case "$distro_shorthand" in
                "on" | "tiny") distro="$(awk 'NR==1{print $1 " " $3;}' /etc/release)" ;;
                *) distro="$(awk 'NR==1{print $1 " " $2 " " $3;}' /etc/release)" ;;
            esac
            distro="${distro/\(*}"
        ;;

        "Haiku")
            distro="$(uname -sv | awk '{print $1 " " $2}')"
        ;;

        "AIX")
            distro="AIX $(oslevel)"
        ;;

        "IRIX")
            distro="IRIX ${kernel_version}"
        ;;

        "FreeMiNT")
            distro="FreeMiNT"
        ;;
    esac

    distro="${distro//Enterprise Server}"

    [[ -z "$distro" ]] && distro="$os (Unknown)"

    # Get OS architecture.
    case "$os" in
        "Solaris" | "AIX" | "Haiku" | "IRIX" | "FreeMiNT") machine_arch="$(uname -p)" ;;
        *) machine_arch="$(uname -m)" ;;

    esac
    if [[ "$os_arch" == "on" ]]; then
        distro+=" ${machine_arch}"
    fi

    [[ "${ascii_distro:-auto}" == "auto" ]] && \
        ascii_distro="$(trim "$distro")"
}

get_model() {
    case "$os" in
        "Linux")
            if [[ -d "/system/app/" && -d "/system/priv-app" ]]; then
                model="$(getprop ro.product.brand) $(getprop ro.product.model)"

            elif [[ -f /sys/devices/virtual/dmi/id/product_name ||
                    -f /sys/devices/virtual/dmi/id/product_version ]]; then
                model="$(< /sys/devices/virtual/dmi/id/product_name)"
                model+=" $(< /sys/devices/virtual/dmi/id/product_version)"

            elif [[ -f /sys/firmware/devicetree/base/model ]]; then
                model="$(< /sys/firmware/devicetree/base/model)"

            elif [[ -f /tmp/sysinfo/model ]]; then
                model="$(< /tmp/sysinfo/model)"
            fi
        ;;

        "Mac OS X")
            if [[ "$(kextstat | grep "FakeSMC")" != "" ]]; then
                model="Hackintosh (SMBIOS: $(sysctl -n hw.model))"
            else
                model="$(sysctl -n hw.model)"
            fi
        ;;

        "iPhone OS")
            case "$machine_arch" in
                "iPad1,1") model="iPad" ;;
                "iPad2,"[1-4]) model="iPad 2" ;;
                "iPad3,"[1-3]) model="iPad 3" ;;
                "iPad3,"[4-6]) model="iPad 4" ;;
                "iPad6,11" | "iPad 6,12") model="iPad 5" ;;
                "iPad4,"[1-3]) model="iPad Air" ;;
                "iPad5,"[3-4]) model="iPad Air 2" ;;
                "iPad6,"[7-8]) model="iPad Pro (12.9 Inch)" ;;
                "iPad6,"[3-4]) model="iPad Pro (9.7 Inch)" ;;
                "iPad7,"[1-2]) model="iPad Pro 2 (12.9 Inch)" ;;
                "iPad7,"[3-4]) model="iPad Pro (10.5 Inch)" ;;
                "iPad2,"[5-7]) model="iPad mini" ;;
                "iPad4,"[4-6]) model="iPad mini 2" ;;
                "iPad4,"[7-9]) model="iPad mini 3" ;;
                "iPad5,"[1-2]) model="iPad mini 4" ;;

                "iPhone1,1") model="iPhone" ;;
                "iPhone1,2") model="iPhone 3G" ;;
                "iPhone2,1") model="iPhone 3GS" ;;
                "iPhone3,"[1-3]) model="iPhone 4" ;;
                "iPhone4,1") model="iPhone 4S" ;;
                "iPhone5,"[1-2]) model="iPhone 5" ;;
                "iPhone5,"[3-4]) model="iPhone 5c" ;;
                "iPhone6,"[1-2]) model="iPhone 5s" ;;
                "iPhone7,2") model="iPhone 6" ;;
                "iPhone7,1") model="iPhone 6 Plus" ;;
                "iPhone8,1") model="iPhone 6s" ;;
                "iPhone8,2") model="iPhone 6s Plus" ;;
                "iPhone8,4") model="iPhone SE" ;;
                "iPhone9,1" | "iPhone9,3") model="iPhone 7" ;;
                "iPhone9,2" | "iPhone9,4") model="iPhone 7 Plus" ;;
                "iPhone10,1" | "iPhone10,4") model="iPhone 8" ;;
                "iPhone10,2" | "iPhone10,5") model="iPhone 8 Plus" ;;
                "iPhone10,3" | "iPhone10,6") model="iPhone X" ;;

                "iPod1,1") model="iPod touch" ;;
                "ipod2,1") model="iPod touch 2G" ;;
                "ipod3,1") model="iPod touch 3G" ;;
                "ipod4,1") model="iPod touch 4G" ;;
                "ipod5,1") model="iPod touch 5G" ;;
                "ipod7,1") model="iPod touch 6G" ;;
            esac
        ;;

        "BSD" | "MINIX")
            model="$(sysctl -n hw.vendor hw.product)"
        ;;

        "Windows")
            model="$(wmic computersystem get manufacturer,model)"
            model="${model/Manufacturer}"
            model="${model/Model}"
        ;;

        "Solaris")
            model="$(prtconf -b | awk -F':' '/banner-name/ {printf $2}')"
        ;;

        "AIX")
            model="$(/usr/bin/uname -M)"
        ;;

        "FreeMiNT")
            model="$(sysctl -n hw.model)"
        ;;
    esac

    # Remove dummy OEM info.
    model="${model//To be filled by O.E.M.}"
    model="${model//To Be Filled*}"
    model="${model//OEM*}"
    model="${model//Not Applicable}"
    model="${model//System Product Name}"
    model="${model//System Version}"
    model="${model//Undefined}"
    model="${model//Default string}"
    model="${model//Not Specified}"
    model="${model//Type1ProductConfigId}"
    model="${model//INVALID}"
    model="${model//�}"

    case "$model" in
        "Standard PC"*) model="KVM/QEMU (${model})" ;;
    esac
}

get_title() {
    user="${USER:-$(whoami || printf "%s" "${HOME/*\/}")}"
    hostname="${HOSTNAME:-$(hostname)}"
    title="${title_color}${bold}${user}${at_color}@${title_color}${bold}${hostname}"
    length="$((${#user} + ${#hostname} + 1))"
}

get_kernel() {
    # Since these OS are integrated systems, it's better to skip this function altogether
    [[ "$os" =~ (AIX|IRIX) ]] && return

    case "$kernel_shorthand" in
        "on")  kernel="$kernel_version" ;;
        "off") kernel="$kernel_name $kernel_version" ;;
    esac

    # Hide kernel info if it's identical to the distro info.
    if [[ "$os" =~ (BSD|MINIX) && "$distro" == *"$kernel_name"* ]]; then
        case "$distro_shorthand" in
            "on" | "tiny") kernel="$kernel_version" ;;
            *) unset kernel ;;
        esac
    fi
}

get_uptime() {
    # Since Haiku's uptime cannot be fetched in seconds, a case outside
    # the usual case is needed.
    case "$os" in
        "Haiku")
            uptime="$(uptime -u)"
            uptime="${uptime/up }"
        ;;

        *)
            # Get uptime in seconds.
            case "$os" in
                "Linux" | "Windows" | "MINIX")
                    seconds="$(< /proc/uptime)"
                    seconds="${seconds/.*}"
                ;;

                "Mac OS X" | "iPhone OS" | "BSD" | "FreeMiNT")
                    boot="$(sysctl -n kern.boottime)"
                    boot="${boot/'{ sec = '}"
                    boot="${boot/,*}"

                    # Get current date in seconds.
                    now="$(date +%s)"
                    seconds="$((now - boot))"
                ;;

                "Solaris")
                    seconds="$(kstat -p unix:0:system_misc:snaptime | awk '{print $2}')"
                    seconds="${seconds/.*}"
                ;;

                "AIX" | "IRIX")
                    t="$(LC_ALL=POSIX ps -o etime= -p 1)"
                    d="0" h="0"
                    case "$t" in *"-"*) d="${t%%-*}"; t="${t#*-}";; esac
                    case "$t" in *":"*":"*) h="${t%%:*}"; t="${t#*:}";; esac
                    h="${h#0}" t="${t#0}"
                    seconds="$((d*86400 + h*3600 + ${t%%:*}*60 + ${t#*:}))"
                ;;
            esac

            days="$((seconds / 60 / 60 / 24)) days"
            hours="$((seconds / 60 / 60 % 24)) hours"
            mins="$((seconds / 60 % 60)) minutes"

            # Format the days, hours and minutes.
            strip_date() {
                case "$1" in
                    "0 "*) unset "${1/* }" ;;
                    "1 "*) printf "%s" "${1/s}" ;;
                    *)     printf "%s" "$1" ;;
                esac
            }

            days="$(strip_date "$days")"
            hours="$(strip_date "$hours")"
            mins="$(strip_date "$mins")"

            uptime="${days:+$days, }${hours:+$hours, }${mins}"
            uptime="${uptime%', '}"
            uptime="${uptime:-${seconds} seconds}"
        ;;
    esac

    # Make the output of uptime smaller.
    case "$uptime_shorthand" in
        "on")
            uptime="${uptime/minutes/mins}"
            uptime="${uptime/minute/min}"
            uptime="${uptime/seconds/secs}"
        ;;

        "tiny")
            uptime="${uptime/ days/d}"
            uptime="${uptime/ day/d}"
            uptime="${uptime/ hours/h}"
            uptime="${uptime/ hour/h}"
            uptime="${uptime/ minutes/m}"
            uptime="${uptime/ minute/m}"
            uptime="${uptime/ seconds/s}"
            uptime="${uptime//,}"
        ;;
    esac
}

get_packages() {
    case "$os" in
        "Linux" | "BSD" | "iPhone OS" | "Solaris")
            type -p paclog-pkglist >/dev/null && \
                packages="$(pacman -Qq --color never | wc -l)"

            type -p dpkg >/dev/null && \
                packages="$((packages+=$(dpkg --get-selections | grep -cv deinstall$)))"

            type -p pkgtool >/dev/null && \
                packages="$((packages+=$(ls -1 /var/log/packages | wc -l)))"

            type -p rpm >/dev/null && \
                packages="$((packages+=$(rpm -qa | wc -l)))"

            type -p xbps-query >/dev/null && \
                packages="$((packages+=$(xbps-query -l | wc -l)))"

            type -p pkginfo >/dev/null && \
                packages="$((packages+=$(pkginfo -i | wc -l)))"

            type -p emerge >/dev/null && \
                packages="$((packages+=$(ls -d /var/db/pkg/*/* | wc -l)))"

            type -p nix-env >/dev/null && \
                packages="$((packages+=$(ls -d -1 /nix/store/*/ | wc -l)))"

            type -p guix >/dev/null && \
                packages="$((packages+=$(ls -d -1 /gnu/store/*/ | wc -l)))"

            type -p apk >/dev/null && \
                packages="$((packages+=$(apk info | wc -l)))"

            type -p opkg >/dev/null && \
                packages="$((packages+=$(opkg list-installed | wc -l)))"

            type -p pacman-g2 >/dev/null && \
                packages="$((packages+=$(pacman-g2 -Q | wc -l)))"

            type -p lvu >/dev/null && \
                packages="$((packages+=$(lvu installed | wc -l)))"

            type -p tce-status >/dev/null && \
                packages="$((packages+=$(tce-status -i | wc -l)))"

            type -p Compile >/dev/null && \
                packages="$((packages+=$(ls -d -1 /Programs/*/ | wc -l)))"

            type -p eopkg >/dev/null && \
                packages="$((packages+=$(ls -1 /var/lib/eopkg/package | wc -l)))"

            type -p pkg_info >/dev/null && \
                packages="$((packages+=$(pkg_info | wc -l)))"

            type -p crew >/dev/null && \
                packages="$((packages+=$(ls -l /usr/local/etc/crew/meta/*.filelist | wc -l)))"

            type -p tazpkg >/dev/null && \
                packages="$((packages+=$(tazpkg list | wc -l) - 6))"

            type -p sorcery >/dev/null && \
                packages="$((packages+=$(gaze installed | wc -l)))"

            type -p alps >/dev/null && \
                packages="$((packages+=$(alps showinstalled | wc -l)))"

            type -p kpt >/dev/null && \
            type -p kpm >/dev/null && \
                packages="$((packages+=$(kpm --get-selections | grep -cv deinstall$)))"

            if type -p cave >/dev/null; then
                package_dir=(/var/db/paludis/repositories/{cross-installed,installed}/*/data/*)
                packages="$((packages+=$(ls -d -1 "${package_dir[@]}" | wc -l)))"
            fi

            type -p butch >/dev/null && \
                packages="$((packages+=$(butch list | wc -l)))"

            if type -p pkg >/dev/null; then
                case "$kernel_name" in
                    "FreeBSD") packages="$((packages+=$(pkg info | wc -l)))" ;;
                    *)
                        packages="$((packages+=$(ls -1 /var/db/pkg | wc -l)))"
                        ((packages == 0)) && packages="$((packages+=$(pkg list | wc -l)))"
                esac
            fi
        ;;

        "Mac OS X" | "MINIX")
            [[ -d "/usr/local/bin" ]] && \
                packages="$(($(ls -l /usr/local/bin/ | grep -cv "\(../Cellar/\|brew\)") - 1))"

            type -p port >/dev/null && \
                packages="$((packages + $(port installed | wc -l) - 1))"

            type -p brew >/dev/null && \
                packages="$((packages + $(find /usr/local/Cellar -maxdepth 1 | wc -l) - 1))"

            type -p pkgin >/dev/null && \
                packages="$((packages + $(pkgin list | wc -l)))"
        ;;

        "Windows")
            case "$kernel_name" in
                "CYGWIN"*) packages="$(cygcheck -cd | wc -l)" ;;
                "MSYS"*) packages="$(pacman -Qq --color never | wc -l)"
            esac

            # Count chocolatey packages.
            [[ -d "/cygdrive/c/ProgramData/chocolatey/lib" ]] && \
                packages="$((packages+=$(ls -1 /cygdrive/c/ProgramData/chocolatey/lib | wc -l)))"
        ;;

        "Haiku")
            packages="$(ls -1 /boot/system/package-links | wc -l)"
        ;;

        "AIX")
            packages="$(lslpp -J -l -q | grep -cv '^#')"
            packages="$((packages+=$(rpm -qa | wc -l)))"
        ;;

        "IRIX")
            packages="$(($(versions -b | wc -l)-3))"
        ;;

        "FreeMiNT")
            type -p rpm >/dev/null && \
                packages="$((packages+=$(rpm -qa | wc -l)))"
        ;;
    esac

    ((packages == 0)) && unset packages
}

get_shell() {
    case "$shell_path" in
        "on")  shell="$SHELL " ;;
        "off") shell="${SHELL##*/} " ;;
    esac

    if [[ "$shell_version" == "on" ]]; then
        case "${shell_name:=${SHELL##*/}}" in
            "bash") shell+="${BASH_VERSION/-*}" ;;
            "sh" | "ash" | "dash") ;;

            "mksh" | "ksh")
                shell+="$("$SHELL" -c 'printf "%s" "$KSH_VERSION"')"
                shell="${shell/ * KSH}"
                shell="${shell/version}"
            ;;

            "tcsh")
                shell+="$("$SHELL" -c 'printf "%s" "$tcsh"')"
            ;;

            *)
                shell+="$("$SHELL" --version 2>&1)"
                shell="${shell/ "${shell_name}"}"
            ;;
        esac

        # Remove unwanted info.
        shell="${shell/, version}"
        shell="${shell/xonsh\//xonsh }"
        shell="${shell/options*}"
        shell="${shell/\(*\)}"
    fi
}

get_de() {
    # If function was run, stop here.
    ((de_run == 1)) && return

    case "$os" in
        "Mac OS X") de="Aqua" ;;
        "Windows")
            case "$distro" in
                "Windows 8"* | "Windows 10"*) de="Modern UI/Metro" ;;
                *) de="Aero" ;;
            esac
        ;;

        "FreeMiNT")
            get_wm

            for files in /proc/*; do
                case "$files" in
                    *thing*) de="Thing" ;;
                    *jinnee*) de="Jinnee" ;;
                    *tera*) de="Teradesk" ;;
                    *neod*) de="NeoDesk" ;;
                    *zdesk*) de="zDesk" ;;
                    *mdesk*) de="mDesk" ;;
                esac
            done
        ;;

        *)
            ((wm_run != 1)) && get_wm

            if [[ "$XDG_CURRENT_DESKTOP" ]]; then
                de="${XDG_CURRENT_DESKTOP/'X-'}"
                de="${de/Budgie:GNOME/Budgie}"

            elif [[ "$DESKTOP_SESSION" ]]; then
                de="${DESKTOP_SESSION##*/}"

            elif [[ "$GNOME_DESKTOP_SESSION_ID" ]]; then
                de="GNOME"

            elif [[ "$MATE_DESKTOP_SESSION_ID" ]]; then
                de="MATE"

            elif [[ "$TDE_FULL_SESSION" ]]; then
                de="Trinity"
            fi

            # When a window manager is started from a display manager
            # the desktop variables are sometimes also set to the
            # window manager name. This checks to see if WM == DE
            # and dicards the DE value.
            [[ "$wm" && "$de" =~ ^$wm$ ]] && { unset -v de; return; }
        ;;
    esac

    # Fallback to using xprop.
    [[ "$DISPLAY" && -z "$de" ]] && \
        de="$(xprop -root | awk '/KDE_SESSION_VERSION|^_MUFFIN|xfce4|xfce5/')"

    # Format strings.
    case "$de" in
        "KDE_SESSION_VERSION"*) de="KDE${de/* = }" ;;
        *"MUFFIN"* | "Cinnamon") de="$(cinnamon --version)"; de="${de:-Cinnamon}" ;;
        *"xfce4"*) de="Xfce4" ;;
        *"xfce5"*) de="Xfce5" ;;
        *"xfce"*)  de="Xfce" ;;
        *"mate"*)  de="MATE" ;;
        *"GNOME"*)
            de="$(gnome-shell --version)"
            de="${de/Shell }"
        ;;
    esac

    # Log that the function was run.
    de_run=1
}

get_wm() {
    # If function was run, stop here.
    ((wm_run == 1)) && return

    if [[ "$WAYLAND_DISPLAY" ]]; then
        wm="$(ps -e | grep -m 1 -o -F \
                           -e "asc" \
                           -e "fireplace" \
                           -e "grefsen" \
                           -e "mazecompositor" \
                           -e "maynard" \
                           -e "motorcar" \
                           -e "orbment" \
                           -e "orbital" \
                           -e "perceptia" \
                           -e "rustland" \
                           -e "sway" \
                           -e "velox" \
                           -e "wavy" \
                           -e "wayhouse" \
                           -e "way-cooler" \
                           -e "westford" \
                           -e "weston")"

    elif [[ "$DISPLAY" && "$os" != "Mac OS X" && "$os" != "FreeMiNT" ]]; then
        id="$(xprop -root -notype _NET_SUPPORTING_WM_CHECK)"
        id="${id##* }"
        wm="$(xprop -id "$id" -notype -len 100 -f _NET_WM_NAME 8t)"
        wm="${wm/*WM_NAME = }"
        wm="${wm/\"}"
        wm="${wm/\"*}"

        # Window Maker does not set _NET_WM_NAME
        [[ "$wm" =~ "WINDOWMAKER" ]] && wm="wmaker"

        # Fallback for non-EWMH WMs.
        [[ -z "$wm" ]] && \
            wm="$(ps -e | grep -m 1 -o -F \
                               -e "catwm" \
                               -e "monsterwm" \
                               -e "tinywm")"

    else
        case "$os" in
            "Mac OS X")
                ps_line="$(ps -e | grep -o '[S]pectacle\|[A]methyst\|[k]wm\|[c]hun[k]wm')"

                case "$ps_line" in
                    *"chunkwm"*) wm="chunkwm" ;;
                    *"kwm"*) wm="Kwm" ;;
                    *"Amethyst"*) wm="Amethyst" ;;
                    *"Spectacle"*) wm="Spectacle" ;;
                    *) wm="Quartz Compositor" ;;
                esac
            ;;

            "Windows")
                wm="$(tasklist | grep -m 1 -o -F \
                                      -e "bugn" \
                                      -e "Windawesome" \
                                      -e "blackbox" \
                                      -e "emerge" \
                                      -e "litestep")"

                [[ "$wm" == "blackbox" ]] && wm="bbLean (Blackbox)"
                wm="${wm:+$wm, }Explorer"
            ;;

            "FreeMiNT")
                wm="Atari AES"
                for files in /proc/*; do
                    case "$files" in
                        *xaaes*) wm="XaAES" ;;
                        *myaes*) wm="MyAES" ;;
                        *naes*) wm="N.AES" ;;
                        geneva) wm="Geneva" ;;
                    esac
                done
            ;;
        esac
    fi

    # Log that the function was run.
    wm_run=1
}

get_wm_theme() {
    ((wm_run != 1)) && get_wm
    ((de_run != 1)) && get_de

    case "$wm"  in
        "E16")
            wm_theme="$(awk -F "= " '/theme.name/ {print $2}' "${HOME}/.e16/e_config--0.0.cfg")"
        ;;

        "Sawfish")
            wm_theme="$(awk -F '\\(quote|\\)' '/default-frame-style/ {print $(NF-4)}' \
                      "${HOME}/.sawfish/custom")"
        ;;

        "Cinnamon" | "Muffin" | "Mutter (Muffin)")
            detheme="$(gsettings get org.cinnamon.theme name)"
            wm_theme="$(gsettings get org.cinnamon.desktop.wm.preferences theme)"
            wm_theme="$detheme (${wm_theme})"
        ;;

        "Compiz" | "Mutter" | "GNOME Shell" | "Gala")
            if type -p gsettings >/dev/null; then
                wm_theme="$(gsettings get org.gnome.shell.extensions.user-theme name)"

                [[ -z "${wm_theme//\'}" ]] && \
                    wm_theme="$(gsettings get org.gnome.desktop.wm.preferences theme)"

            elif type -p gconftool-2 >/dev/null; then
                wm_theme="$(gconftool-2 -g /apps/metacity/general/theme)"
            fi
        ;;

        "Metacity"*)
            if [[ "$de" == "Deepin" ]]; then
                wm_theme="$(gsettings get com.deepin.wrap.gnome.desktop.wm.preferences theme)"

            elif [[ "$de" == "MATE" ]]; then
                wm_theme="$(gsettings get org.mate.Marco.general theme)"

            else
                wm_theme="$(gconftool-2 -g /apps/metacity/general/theme)"
            fi
        ;;

        "E17" | "Enlightenment")
            if type -p eet >/dev/null; then
                wm_theme="$(eet -d "${HOME}/.e/e/config/standard/e.cfg" config |\
                            awk '/value \"file\" string.*.edj/ {print $4}')"
                wm_theme="${wm_theme##*/}"
                wm_theme="${wm_theme%.*}"
            fi
        ;;

        "Fluxbox")
            [[ -f "${HOME}/.fluxbox/init" ]] && \
                wm_theme="$(awk -F "/" '/styleFile/ {print $NF}' "${HOME}/.fluxbox/init")"
        ;;

        "IceWM"*)
            [[ -f "${HOME}/.icewm/theme" ]] && \
                wm_theme="$(awk -F "[\",/]" '!/#/ {print $2}' "${HOME}/.icewm/theme")"
        ;;

        "Openbox")
            if [[ "$de" == "LXDE" && -f "${HOME}/.config/openbox/lxde-rc.xml" ]]; then
                ob_file="lxde-rc"

            elif [[ -f "${HOME}/.config/openbox/rc.xml" ]]; then
                ob_file="rc"
            fi

            wm_theme="$(awk -F "[<,>]" '/<theme/ {getline; print $3}' \
                        "${XDG_CONFIG_HOME}/openbox/${ob_file}.xml")";
        ;;

        "PekWM")
            [[ -f "${HOME}/.pekwm/config" ]] && \
                wm_theme="$(awk -F "/" '/Theme/{gsub(/\"/,""); print $NF}' "${HOME}/.pekwm/config")"
        ;;

        "Xfwm4")
            [[ -f "${HOME}/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml" ]] && \
                wm_theme="$(xfconf-query -c xfwm4 -p /general/theme)"
        ;;

        "KWin"*)
            kde_config_dir
            kwinrc="${kde_config_dir}/kwinrc"
            kdebugrc="${kde_config_dir}/kdebugrc"

            if [[ -f "$kwinrc" ]]; then
                wm_theme="$(awk '/theme=/{gsub(/theme=.*qml_|theme=.*svg__/,"",$0);\
                                 print $0; exit}' "$kwinrc")"

                [[ -z "$wm_theme" ]] && \
                    wm_theme="$(awk '/library=org.kde/{gsub(/library=org.kde./,"",$0);\
                                     print $0; exit}' "$kwinrc")"
                [[ -z "$wm_theme" ]] && \
                    wm_theme="$(awk '/PluginLib=kwin3_/{gsub(/PluginLib=kwin3_/,"",$0);\
                                     print $0; exit}' "$kwinrc")"

            elif [[ -f "$kdebugrc" ]]; then
                wm_theme="$(awk '/(decoration)/ {gsub(/\[/,"",$1); print $1; exit}' "$kdebugrc")"
            fi

            wm_theme="${wm_theme/'theme='}"
        ;;

        "Quartz Compositor")
            global_preferences="${HOME}/Library/Preferences/.GlobalPreferences.plist"
            wm_theme="$(PlistBuddy -c "Print AppleInterfaceStyle" "$global_preferences")"
            wm_theme_color="$(PlistBuddy -c "Print AppleAquaColorVariant" "$global_preferences")"

            [[ -z "$wm_theme" ]] && wm_theme="Light"

            if [[ -z "$wm_theme_color" ]] || ((wm_theme_color == 1)); then
                wm_theme_color="Blue"
            else
                wm_theme_color="Graphite"
            fi

            wm_theme="$wm_theme_color ($wm_theme)"
        ;;

        *"Explorer")
            path="/proc/registry/HKEY_CURRENT_USER/Software/Microsoft"
            path+="/Windows/CurrentVersion/Themes/CurrentTheme"

            wm_theme="$(head -n1 "$path")"
            wm_theme="${wm_theme##*\\}"
            wm_theme="${wm_theme%.*}"
        ;;

        "Blackbox" | "bbLean"*)
            path="$(wmic process get ExecutablePath | grep -F "blackbox")"
            path="${path//\\/\/}"

            wm_theme="$(grep "^session\.styleFile:" "${path/\.exe/.rc}")"
            wm_theme="${wm_theme/'session.styleFile: '}"
            wm_theme="${wm_theme##*\\}"
            wm_theme="${wm_theme%.*}"
        ;;
    esac

    wm_theme="$(trim_quotes "$wm_theme")"
    wm_theme="$(uppercase "$wm_theme")"
}

get_cpu() {
    # NetBSD emulates the Linux /proc filesystem instead of using sysctl for hw
    # information so we have to use this block below which temporarily sets the
    # OS to "Linux" for the duration of this function.
    [[ "$distro" == "NetBSD"* ]] && local os="Linux"

    case "$os" in
        "Linux" | "MINIX" | "Windows")
            # Get CPU name.
            cpu_file="/proc/cpuinfo"

            case "$machine_arch" in
                "frv" | "hppa" | "m68k" | "openrisc" | "or"* | "powerpc" | "ppc"* | "sparc"*)
                    cpu="$(awk -F':' '/^cpu\t|^CPU/ {printf $2; exit}' "$cpu_file")"
                ;;

                "s390"*)
                    cpu="$(awk -F'=' '/machine/ {print $4; exit}' "$cpu_file")"
                ;;

                "ia64" | "m32r")
                    cpu="$(awk -F':' '/model/ {print $2; exit}' "$cpu_file")"
                    [[ -z "$cpu" ]] && cpu="$(awk -F':' '/family/ {printf $2; exit}' "$cpu_file")"
                ;;

                *)
                    cpu="$(awk -F ': | @' '/model name|Processor|^cpu model|chip type|^cpu type/\
                                           {printf $2; exit}' "$cpu_file")"

                    [[ "$cpu" == *"processor rev"* ]] && \
                        cpu="$(awk -F':' '/Hardware/ {print $2; exit}' "$cpu_file")"
                ;;
            esac

            speed_dir="/sys/devices/system/cpu/cpu0/cpufreq"

            # Select the right temperature file.
            for temp_dir in /sys/class/hwmon/*; do
                [[ "$(< "${temp_dir}/name")" =~ (coretemp|fam15h_power) ]] && \
                    { temp_dir="${temp_dir}/temp1_input"; break; }
            done

            # Get CPU speed.
            if [[ -d "$speed_dir" ]]; then
                # Fallback to bios_limit if $speed_type fails.
                speed="$(< "${speed_dir}/${speed_type}")" ||\
                speed="$(< "${speed_dir}/bios_limit")" ||\
                speed="$(< "${speed_dir}/scaling_max_freq")" ||\
                speed="$(< "${speed_dir}/cpuinfo_max_freq")"
                speed="$((speed / 1000))"

            else
                speed="$(awk -F ': |\\.' '/cpu MHz|^clock/ {printf $2; exit}' "$cpu_file")"
                speed="${speed/MHz}"
            fi

            # Get CPU temp.
            if [[ -f "$temp_dir" ]]; then
                deg="$(< "$temp_dir")"
                deg="$((deg * 100 / 10000))"
            fi

            # Get CPU cores.
            case "$cpu_cores" in
                "logical" | "on") cores="$(grep -c "^processor" "$cpu_file")" ;;
                "physical") cores="$(grep "^core id" "$cpu_file" | sort -u | wc -l)" ;;
            esac
        ;;

        "Mac OS X")
            cpu="$(sysctl -n machdep.cpu.brand_string)"

            # Get CPU cores.
            case "$cpu_cores" in
                "logical" | "on") cores="$(sysctl -n hw.logicalcpu_max)" ;;
                "physical") cores="$(sysctl -n hw.physicalcpu_max)" ;;
            esac
        ;;

        "iPhone OS")
            case "$machine_arch" in
                "iPhone1,"[1-2] | "iPod1,1") cpu="Samsung S5L8900 (1) @ 412MHz" ;;
                "iPhone2,1") cpu="Samsung S5PC100 (1) @ 600MHz" ;;
                "iPhone3,"[1-3] | "iPod4,1") cpu="Apple A4 (1) @ 800MHz" ;;
                "iPhone4,1" | "iPod5,1") cpu="Apple A5 (2) @ 800MHz" ;;
                "iPhone5,"[1-4]) cpu="Apple A6 (2) @ 1.3GHz" ;;
                "iPhone6,"[1-2]) cpu="Apple A7 (2) @ 1.3GHz" ;;
                "iPhone7,"[1-2]) cpu="Apple A8 (2) @ 1.4GHz" ;;
                "iPhone8,"[1-4]) cpu="Apple A9 (2) @ 1.85GHz" ;;
                "iPhone9,"[1-4]) cpu="Apple A10 Fusion (4) @ 2.34GHz" ;;
                "iPod2,1") cpu="Samsung S5L8720 (1) @ 533MHz" ;;
                "iPod3,1") cpu="Samsung S5L8922 (1) @ 600MHz" ;;
                "iPod7,1") cpu="Apple A8 (2) @ 1.1GHz" ;;
                "iPad1,1") cpu="Apple A4 (1) @ 1GHz" ;;
                "iPad2,"[1-7]) cpu="Apple A5 (2) @ 1GHz" ;;
                "iPad3,"[1-3]) cpu="Apple A5X (2) @ 1GHz" ;;
                "iPad3,"[4-6]) cpu="Apple A6X (2) @ 1.4GHz" ;;
                "iPad4,"[1-3]) cpu="Apple A7 (2) @ 1.4GHz" ;;
                "iPad4,"[4-9]) cpu="Apple A7 (2) @ 1.4GHz" ;;
                "iPad5,"[1-2]) cpu="Apple A8 (2) @ 1.5GHz" ;;
                "iPad5,"[3-4]) cpu="Apple A8X (3) @ 1.5GHz" ;;
                "iPad6,"[3-4]) cpu="Apple A9X (2) @ 2.16GHz" ;;
                "iPad6,"[7-8]) cpu="Apple A9X (2) @ 2.26GHz" ;;
            esac
        ;;

        "BSD")
            # Get CPU name.
            cpu="$(sysctl -n hw.model)"
            cpu="${cpu/[0-9]\.*}"
            cpu="${cpu/ @*}"

            # Get CPU speed.
            speed="$(sysctl -n hw.cpuspeed)"
            [[ -z "$speed" ]] && speed="$(sysctl -n  hw.clockrate)"

            # Get CPU cores.
            cores="$(sysctl -n hw.ncpu)"

            # Get CPU temp.
            case "$kernel_name" in
                "FreeBSD"* | "DragonFly"* | "NetBSD"*)
                    deg="$(sysctl -n dev.cpu.0.temperature)"
                    deg="${deg/C}"
                ;;
                "OpenBSD"* | "Bitrig"*)
                    deg="$(sysctl hw.sensors | \
                           awk -F '=| degC' '/lm0.temp|cpu0.temp/ {print $2; exit}')"
                    deg="${deg/00/0}"
                ;;
            esac
        ;;

        "Solaris")
            # Get CPU name.
            cpu="$(psrinfo -pv)"
            cpu="${cpu//*$'\n'}"
            cpu="${cpu/[0-9]\.*}"
            cpu="${cpu/ @*}"
            cpu="${cpu/\(portid*}"

            # Get CPU speed.
            speed="$(psrinfo -v | awk '/operates at/ {print $6; exit}')"

            # Get CPU cores.
            case "$cpu_cores" in
                "logical" | "on") cores="$(kstat -m cpu_info | grep -c -F "chip_id")" ;;
                "physical") cores="$(psrinfo -p)" ;;
            esac
        ;;

        "Haiku")
            # Get CPU name.
            cpu="$(sysinfo -cpu | awk -F '\\"' '/CPU #0/ {print $2}')"
            cpu="${cpu/@*}"

            # Get CPU speed.
            speed="$(sysinfo -cpu | awk '/running at/ {print $NF; exit}')"
            speed="${speed/MHz}"

            # Get CPU cores.
            cores="$(sysinfo -cpu | grep -c -F 'CPU #')"
        ;;

        "AIX")
            # Get CPU name.
            cpu="$(lsattr -El proc0 -a type | awk '{printf $2}')"

            # Get CPU speed.
            speed="$(prtconf -s | awk -F':' '{printf $2}')"
            speed="${speed/MHz}"

            # Get CPU cores.
            case "$cpu_cores" in
                "logical" | "on")
                    cores="$(lparstat -i | awk -F':' '/Online Virtual CPUs/ {printf $2}')"
                ;;

                "physical") cores="$(lparstat -i | awk -F':' '/Active Physical CPUs/ {printf $2}')"
            esac
        ;;

        "IRIX")
            # Get CPU name.
            cpu="$(hinv -c processor | awk -F':' '/CPU:/ {printf $2}')"

            # Get CPU speed.
            speed="$(hinv -c processor | awk '/MHZ/ {printf $2}')"

            # Get CPU cores.
            cores="$(sysconf NPROC_ONLN)"
        ;;

        "FreeMiNT")
            cpu="$(awk -F':' '/CPU:/ {printf $2}' /kern/cpuinfo)"
            speed="$(awk -F '[:.M]' '/Clocking:/ {printf $2}' /kern/cpuinfo)"
        ;;
    esac

    # Remove un-needed patterns from cpu output.
    cpu="${cpu//(TM)}"
    cpu="${cpu//(tm)}"
    cpu="${cpu//(R)}"
    cpu="${cpu//(r)}"
    cpu="${cpu//CPU}"
    cpu="${cpu//Processor}"
    cpu="${cpu//Dual-Core}"
    cpu="${cpu//Quad-Core}"
    cpu="${cpu//Six-Core}"
    cpu="${cpu//Eight-Core}"
    cpu="${cpu//, * Compute Cores}"
    cpu="${cpu//Core / }"
    cpu="${cpu//(\"AuthenticAMD\"*)}"
    cpu="${cpu//with Radeon * Graphics}"
    cpu="${cpu//, altivec supported}"
    cpu="${cpu//FPU*}"
    cpu="${cpu//Chip Revision*}"
    cpu="${cpu//Technologies, Inc}"
    cpu="${cpu//Core2/Core 2}"

    # Trim spaces from core and speed output
    cores="${cores//[[:space:]]}"
    speed="${speed//[[:space:]]}"

    # Remove CPU brand from the output.
    if [[ "$cpu_brand" == "off" ]]; then
        cpu="${cpu/AMD }"
        cpu="${cpu/Intel }"
        cpu="${cpu/Core? Duo }"
        cpu="${cpu/Qualcomm }"
    fi

    # Add CPU cores to the output.
    [[ "$cpu_cores" != "off" && "$cores" ]] && \
        case "$os" in
            "Mac OS X") cpu="${cpu/@/(${cores}) @}" ;;
            *) cpu="$cpu ($cores)" ;;
        esac

    # Add CPU speed to the output.
    if [[ "$cpu_speed" != "off" && "$speed" ]]; then
        if (( speed < 1000 )); then
            cpu="$cpu @ ${speed}MHz"
        else
            [[ "$speed_shorthand" == "on" ]] && speed="$((speed / 100))"
            speed="${speed:0:1}.${speed:1}"
            cpu="$cpu @ ${speed}GHz"
        fi
    fi

    # Add CPU temp to the output.
    if [[ "$cpu_temp" != "off" && "$deg" ]]; then
        deg="${deg//.}"

        # Convert to Fahrenheit if enabled
        [[ "$cpu_temp" == "F" ]] && deg="$((deg * 90 / 50 + 320))"

        # Format the output
        deg="[${deg/${deg: -1}}.${deg: -1}°${cpu_temp:-C}]"
        cpu="$cpu $deg"
    fi
}

get_cpu_usage() {
    case "$os" in
        "Windows")
            cpu_usage="$(wmic cpu get loadpercentage)"
            cpu_usage="${cpu_usage/LoadPercentage}"
            cpu_usage="${cpu_usage//[[:space:]]}"
        ;;

        *)
            # Get CPU cores if unset.
            if [[ "$cpu_cores" != "logical" ]]; then
                case "$os" in
                    "Linux" | "MINIX") cores="$(grep -c "^processor" /proc/cpuinfo)" ;;
                    "Mac OS X") cores="$(sysctl -n hw.logicalcpu_max)" ;;
                    "BSD") cores="$(sysctl -n hw.ncpu)" ;;
                    "Solaris") cores="$(kstat -m cpu_info | grep -c -F "chip_id")" ;;
                    "Haiku") cores="$(sysinfo -cpu | grep -c -F 'CPU #')" ;;
                    "iPhone OS") cores="${cpu/*\(}"; cores="${cores/\)*}" ;;
                    "AIX") cores="$(lparstat -i | awk -F':' '/Online Virtual CPUs/ {printf $2}')" ;;
                    "IRIX") cores="$(sysconf NPROC_ONLN)" ;;
                    "FreeMiNT") cores="$(sysctl -n hw.ncpu)"
                esac
            fi

            cpu_usage="$(ps aux | awk 'BEGIN {sum=0} {sum+=$3}; END {print sum}')"
            cpu_usage="$((${cpu_usage/\.*} / ${cores:-1}))"
        ;;
    esac

    # Print the bar.
    case "$cpu_display" in
        "bar") cpu_usage="$(bar "$cpu_usage" 100)" ;;
        "infobar") cpu_usage="${cpu_usage}% $(bar "$cpu_usage" 100)" ;;
        "barinfo") cpu_usage="$(bar "$cpu_usage" 100)${info_color} ${cpu_usage}%" ;;
        *) cpu_usage="${cpu_usage}%" ;;
    esac
}

get_gpu() {
    case "$os" in
        "Linux")
            # Read GPUs into array.
            gpu_cmd="$(lspci -mm | awk -F '\\"|\\" \\"|\\(' \
                                          '/"Display|"3D|"VGA/ {a[$0] = $3 " " $4} END{for(i in a)
                                           {if(!seen[a[i]]++) print a[i]}}')"
            IFS=$'\n' read -d "" -ra gpus <<< "$gpu_cmd"

            # Remove duplicate Intel Graphics outputs.
            # This fixes cases where the outputs are both
            # Intel but not entirely identical.
            #
            # Checking the first two array elements should
            # be safe since there won't be 2 intel outputs if
            # there's a dedicated GPU in play.
            [[ "${gpus[0]}" == *Intel* && \
               "${gpus[1]}" == *Intel* ]] && \
               unset -v "gpus[0]"

            for gpu in "${gpus[@]}"; do
                # GPU shorthand tests.
                [[ "$gpu_type" == "dedicated" && "$gpu" == *Intel* ]] || \
                [[ "$gpu_type" == "integrated" && ! "$gpu" == *Intel* ]] && \
                    { unset -v gpu; continue; }

                case "$gpu" in
                    *"advanced"*)
                        gpu="${gpu/'[AMD/ATI]' }"
                        gpu="${gpu/'[AMD]' }"
                        gpu="${gpu/OEM }"
                        gpu="${gpu/Advanced Micro Devices, Inc.}"
                        gpu="${gpu/ \/ *}"
                        gpu="${gpu/*\[}"
                        gpu="${gpu/\]*}"
                        gpu="AMD $gpu"
                    ;;

                    *"nvidia"*)
                        gpu="${gpu/*\[}"
                        gpu="${gpu/\]*}"
                        gpu="NVIDIA $gpu"
                    ;;

                    *"intel"*)
                        type -p glxinfo >/dev/null && \
                            gpu="$(glxinfo | grep "Device:.*Intel")"

                        gpu="${gpu/*Intel/Intel}"
                        gpu="${gpu/'(R)'}"
                        gpu="${gpu/'Corporation'}"
                        gpu="${gpu/ \(*}"
                        gpu="${gpu/Integrated Graphics Controller}"

                        [[ -z "$(trim "$gpu")" ]] && gpu="Intel Integrated Graphics"
                    ;;

                    *"virtualbox"*)
                        gpu="VirtualBox Graphics Adapter"
                    ;;
                esac

                if [[ "$gpu_brand" == "off" ]]; then
                    gpu="${gpu/AMD }"
                    gpu="${gpu/NVIDIA }"
                    gpu="${gpu/Intel }"
                fi

                prin "${subtitle:+${subtitle}${gpu_name}}" "$gpu"
            done

            return
        ;;

        "Mac OS X")
            if [[ -f "${cache_dir}/neofetch/gpu" ]]; then
                source "${cache_dir}/neofetch/gpu"

            else
                gpu="$(system_profiler SPDisplaysDataType |\
                       awk -F': ' '/^\ *Chipset Model:/ {printf $2 ", "}')"
                gpu="${gpu//'/ $'}"
                gpu="${gpu%,*}"

                cache "gpu" "$gpu"
            fi
        ;;

        "iPhone OS")
            case "$machine_arch" in
                "iPhone1,"[1-2]) gpu="PowerVR MBX Lite 3D" ;;
                "iPhone5,"[1-4]) gpu="PowerVR SGX543MP3" ;;
                "iPhone8,"[1-4]) gpu="PowerVR GT7600" ;;
                "iPad3,"[1-3]) gpu="PowerVR SGX534MP4" ;;
                "iPad3,"[4-6]) gpu="PowerVR SGX554MP4" ;;
                "iPad5,"[3-4]) gpu="PowerVR GXA6850" ;;
                "iPad6,"[3-8]) gpu="PowerVR 7XT" ;;

                "iPhone2,1" | "iPhone3,"[1-3] | "iPod3,1" | "iPod4,1" | "iPad1,1")
                    gpu="PowerVR SGX535"
                ;;

                "iPhone4,1" | "iPad2,"[1-7] | "iPod5,1")
                    gpu="PowerVR SGX543MP2"
                ;;

                "iPhone6,"[1-2] | "iPad4,"[1-9])
                    gpu="PowerVR G6430"
                ;;

                "iPhone7,"[1-2] | "iPod7,1" | "iPad5,"[1-2])
                    gpu="PowerVR GX6450"
                ;;

                "iPod1,1" | "iPod2,1")
                    gpu="PowerVR MBX Lite"
                ;;
            esac
        ;;

        "Windows")
            gpu="$(wmic path Win32_VideoController get caption)"
            gpu="${gpu//Caption}"
        ;;

        "Haiku")
            gpu="$(listdev | grep -A2 -F 'device Display controller' |\
                   awk -F':' '/device beef/ {print $2}')"
        ;;

        *)
            case "$kernel_name" in
                "FreeBSD"* | "DragonFly"*)
                    gpu="$(pciconf -lv | grep -B 4 -F "VGA" | grep -F "device")"
                    gpu="${gpu/*device*= }"
                    gpu="$(trim_quotes "$gpu")"
                ;;

                *)
                    gpu="$(glxinfo | grep -F 'OpenGL renderer string')"
                    gpu="${gpu/'OpenGL renderer string: '}"
                ;;
            esac
        ;;
    esac

    if [[ "$gpu_brand" == "off" ]]; then
        gpu="${gpu/AMD}"
        gpu="${gpu/NVIDIA}"
        gpu="${gpu/Intel}"
    fi
}

get_memory() {
    case "$os" in
        "Linux" | "Windows")
            # MemUsed = Memtotal + Shmem - MemFree - Buffers - Cached - SReclaimable
            # Source: https://github.com/KittyKatt/screenFetch/issues/386#issuecomment-249312716
            while IFS=":" read -r a b; do
                case "$a" in
                    "MemTotal") mem_used="$((mem_used+=${b/kB}))"; mem_total="${b/kB}" ;;
                    "Shmem") mem_used="$((mem_used+=${b/kB}))"  ;;
                    "MemFree" | "Buffers" | "Cached" | "SReclaimable")
                        mem_used="$((mem_used-=${b/kB}))"
                    ;;
                esac
            done < /proc/meminfo

            mem_used="$((mem_used / 1024))"
            mem_total="$((mem_total / 1024))"
        ;;

        "Mac OS X" | "iPhone OS")
            mem_total="$(($(sysctl -n hw.memsize) / 1024 / 1024))"
            mem_wired="$(vm_stat | awk '/wired/ { print $4 }')"
            mem_active="$(vm_stat | awk '/active / { printf $3 }')"
            mem_compressed="$(vm_stat | awk '/occupied/ { printf $5 }')"
            mem_used="$(((${mem_wired//.} + ${mem_active//.} + ${mem_compressed//.}) * 4 / 1024))"
        ;;

        "BSD" | "MINIX")
            # Mem total.
            case "$kernel_name" in
                "NetBSD"*) mem_total="$(($(sysctl -n hw.physmem64) / 1024 / 1024))" ;;
                *) mem_total="$(($(sysctl -n hw.physmem) / 1024 / 1024))" ;;
            esac

            # Mem free.
            case "$kernel_name" in
                "NetBSD"*)
                    mem_free="$(($(awk -F ':|kB' '/MemFree:/ {printf $2}' /proc/meminfo) / 1024))"
                ;;

                "FreeBSD"* | "DragonFly"*)
                    hw_pagesize="$(sysctl -n hw.pagesize)"
                    mem_inactive="$(($(sysctl -n vm.stats.vm.v_inactive_count) * hw_pagesize))"
                    mem_unused="$(($(sysctl -n vm.stats.vm.v_free_count) * hw_pagesize))"
                    mem_cache="$(($(sysctl -n vm.stats.vm.v_cache_count) * hw_pagesize))"
                    mem_free="$(((mem_inactive + mem_unused + mem_cache) / 1024 / 1024))"
                ;;

                "MINIX")
                    mem_free="$(top -d 1 | awk -F ',' '/^Memory:/ {print $2}')"
                    mem_free="${mem_free/M Free}"
                ;;

                "OpenBSD"*) ;;
                *) mem_free="$(($(vmstat | awk 'END{printf $5}') / 1024))" ;;
            esac

            # Mem used.
            case "$kernel_name" in
                "OpenBSD"*)
                    mem_used="$(vmstat | awk 'END{printf $3}')"
                    mem_used="${mem_used/M}"
                ;;

                *) mem_used="$((mem_total - mem_free))" ;;
            esac
        ;;

        "Solaris")
            mem_total="$(prtconf | awk '/Memory/ {print $3}')"
            mem_free="$(($(vmstat | awk 'NR==3{printf $5}') / 1024))"
            mem_used="$((mem_total - mem_free))"
        ;;

        "Haiku")
            mem_total="$(($(sysinfo -mem | awk -F '\\/ |)' '{print $2; exit}') / 1024 / 1024))"
            mem_used="$(sysinfo -mem | awk -F '\\/|)' '{print $2; exit}')"
            mem_used="$((${mem_used/max} / 1024 / 1024))"
        ;;

        "AIX")
            mem_stat=($(svmon -G -O unit=MB))
            mem_total="${mem_stat[11]/.*}"
            mem_free="${mem_stat[16]/.*}"
            mem_used="$((mem_total - mem_free))"
            mem_label="MB"
        ;;

        "IRIX")
            mem_stat=($(pmem | head -1))
            mem_total="$((mem_stat[3] / 1024))"
            mem_free="$((mem_stat[5] / 1024))"
            mem_used="$((mem_total - mem_free))"
        ;;

        "FreeMiNT")
            mem="$(awk -F ':|kB' '/MemTotal:|MemFree:/ {printf $2, " "}' /kern/meminfo)"
            mem_free="${mem/*  }"
            mem_total="${mem/  *}"
            mem_used="$((mem_total - mem_free))"
            mem_total="$((mem_total / 1024))"
            mem_used="$((mem_used / 1024))"
        ;;

    esac
    memory="${mem_used}${mem_label:-MiB} / ${mem_total}${mem_label:-MiB}"

    # Bars.
    case "$memory_display" in
        "bar") memory="$(bar "${mem_used}" "${mem_total}")" ;;
        "infobar") memory="${memory} $(bar "${mem_used}" "${mem_total}")" ;;
        "barinfo") memory="$(bar "${mem_used}" "${mem_total}")${info_color} ${memory}" ;;
    esac
}

get_song() {
    player="$(ps -e | grep -m 1 -o \
                           -e "Google Play" \
                           -e "Spotify" \
                           -e "amarok" \
                           -e "audacious" \
                           -e "banshee" \
                           -e "bluemindo" \
                           -e "clementine" \
                           -e "cmus" \
                           -e "deadbeef" \
                           -e "deepin-music" \
                           -e "elisa" \
                           -e "exaile" \
                           -e "gnome-music" \
                           -e "guayadeque" \
                           -e "iTunes$" \
                           -e "juk" \
                           -e "lollypop" \
                           -e "mocp" \
                           -e "mopidy" \
                           -e "mpd" \
                           -e "pogo" \
                           -e "pragha" \
                           -e "qmmp" \
                           -e "quodlibet" \
                           -e "rhythmbox" \
                           -e "spotify" \
                           -e "tomahawk" \
                           -e "xmms2d" \
                           -e "yarock")"

    [[ "$music_player" && "$music_player" != "auto" ]] && \
        player="$music_player"

    get_song_dbus() {
        # Multiple players use an almost identical dbus command to get the information.
        # This function saves us using the same command throughout the function.
        song="$(\
            dbus-send --print-reply --dest=org.mpris.MediaPlayer2."${1}" /org/mpris/MediaPlayer2 \
            org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' \
            string:'Metadata' |\
            awk -F 'string "' '/string|array/ {printf "%s",$2; next}{print ""}' |\
            awk -F '"' '/artist/ {a=$2} /title/ {t=$2} END{print a " - " t}'
        )"
    }

    case "${player/*\/}" in
        "mpd"* | "mopidy"*) song="$(mpc current)" ;;
        "mocp"*)         song="$(mocp -Q "%artist - %song")" ;;
        "google play"*)  song="$(gpmdp-remote current)" ;;
        "rhythmbox"*)    song="$(rhythmbox-client --print-playing)" ;;
        "deadbeef"*)     song="$(deadbeef --nowplaying-tf  '%artist% - %title%')" ;;
        "xmms2d"*)       song="$(xmms2 current -f '${artist} - ${title}')" ;;
        "qmmp"*)         song="$(qmmp --nowplaying '%p - %t')" ;;
        "gnome-music"*)  get_song_dbus "GnomeMusic" ;;
        "lollypop"*)     get_song_dbus "Lollypop" ;;
        "clementine"*)   get_song_dbus "clementine" ;;
        "juk"*)          get_song_dbus "juk" ;;
        "bluemindo"*)    get_song_dbus "Bluemindo" ;;
        "guayadeque"*)   get_song_dbus "guayadeque" ;;
        "yarock"*)       get_song_dbus "yarock" ;;
        "deepin-music"*) get_song_dbus "deepinmusic" ;;
        "tomahawk"*)     get_song_dbus "tomahawk" ;;
        "elisa"*)        get_song_dbus "elisa" ;;

        "audacious"*)
            song="$(audtool current-song)"

            # Remove Album from 'Artist - Album - Title'
            song="${song/-* -/-}"

            [[ -z "$song" ]] && get_song_dbus "audacious"
        ;;

        "cmus"*)
            song="$(cmus-remote -Q | awk '/tag artist/ {$1=$2=""; print; print " - "}\
                                          /tag title/ {$1=$2=""; print}')"
        ;;

        "spotify"*)
            case "$os" in
                "Linux") get_song_dbus "spotify" ;;

                "Mac OS X")
                    song="$(osascript <<END
                            if application "Spotify" is running then
                                tell application "Spotify"
                                    artist of current track as string & \
                                    " - " & name of current track as string
                                end tell
                            end if
END
)"
                ;;
            esac
        ;;

        "itunes"*)
            song="$(osascript <<END
                    if application "iTunes" is running then
                        tell application "iTunes"
                            artist of current track as string & \
                            " - " & name of current track as string
                        end tell
                    end if
END
)"
        ;;

        "banshee"*)
            song="$(banshee --query-artist --query-title |\
                    awk -F':' '/^artist/ {a=$2} /^title/ {t=$2} END{print a " - " t}')"
        ;;

        "amarok"*)
            song="$(qdbus org.kde.amarok /Player GetMetadata |\
                    awk -F':' '/^artist/ {a=$2} /^title/ {t=$2} END{print a " - " t}')"
        ;;

        "pragha"*)
            song="$(pragha -c | awk -F':' '/^artist/ {a=$2} /^title/ {t=$2} END{print a " - " t}')"
        ;;

        "exaile"*)
            song="$(dbus-send --print-reply --dest=org.exaile.Exaile  /org/exaile/Exaile \
                    org.exaile.Exaile.Query | awk -F':|,' '{if ($6 && $4) printf $6 " -" $4}')"
        ;;

        "quodlibet"*)
            song="$(dbus-send --print-reply --dest=net.sacredchao.QuodLibet \
                    /net/sacredchao/QuodLibet net.sacredchao.QuodLibet.CurrentSong |\
                    awk -F'"' '/artist/ {getline; a=$2} \
                               /title/ {getline; t=$2} END{print a " - " t}')"
        ;;

        "pogo"*)
            song="$(dbus-send --print-reply --dest=org.mpris.pogo /Player \
                    org.freedesktop.MediaPlayer.GetMetadata |
                    awk -F'"' '/string "artist"/ {getline; a=$2} /string "title"/ {getline; t=$2} \
                               END{print a " - " t}')"
        ;;

        *) mpc >/dev/null 2>&1 && song="$(mpc current)" ;;
    esac

    [[ "$(trim "$song")" == "-" ]] && unset -v song

    # Display Artist and Title on separate lines.
    if [[ "$song_shorthand" == "on" && "$song" ]]; then
        artist="${song/ -*}"
        song="${song/*-}"

        if [[ "$song" != "$artist" ]]; then
            prin "Artist" "$artist"
            prin "Song" "$song"
        else
            prin "$subtitle" "$song"
        fi
    fi
}

get_resolution() {
    case "$os" in
        "Mac OS X")
            if type -p screenresolution >/dev/null; then
                resolution="$(screenresolution get 2>&1 | awk '/Display/ {printf $6 "Hz, "}')"
                resolution="${resolution//x??@/ @ }"

            else
                resolution="$(system_profiler SPDisplaysDataType |\
                              awk '/Resolution:/ {printf $2"x"$4" @ "$6"Hz, "}')"
            fi

            if [[ -e "/Library/Preferences/com.apple.windowserver.plist" ]]; then
                scale_factor="$(PlistBuddy -c "Print DisplayAnyUserSets:0:0:Resolution" \
                                /Library/Preferences/com.apple.windowserver.plist)"
            else
                scale_factor=""
            fi

            # If no refresh rate is empty.
            [[ "$resolution" == *"@ Hz"* ]] && \
                resolution="${resolution//@ Hz}"

            [[ "${scale_factor%.*}" == 2 ]] && \
                resolution="${resolution// @/@2x @}"

            if [[ "$refresh_rate" == "off" ]]; then
                resolution="${resolution// @ [0-9][0-9]Hz}"
                resolution="${resolution// @ [0-9][0-9][0-9]Hz}"
            fi

            [[ "$resolution" == *"0Hz"* ]] && \
                resolution="${resolution// @ 0Hz}"
        ;;

        "Windows")
            local width=""
            width="$(wmic path Win32_VideoController get CurrentHorizontalResolution)"
            width="${width//CurrentHorizontalResolution/}"

            local height=""
            height="$(wmic path Win32_VideoController get CurrentVerticalResolution)"
            height="${height//CurrentVerticalResolution/}"

            [[ "$(trim "$width")" ]] && resolution="${width//[[:space:]]}x${height//[[:space:]]}"
        ;;

        "Haiku")
            resolution="$(screenmode | awk -F ' |, ' '{printf $2 "x" $3 " @ " $6 $7}')"

            [[ "$refresh_rate" == "off" ]] && resolution="${resolution/ @*}"
        ;;

        *)
            if type -p xrandr >/dev/null; then
                case "$refresh_rate" in
                    "on")
                        resolution="$(xrandr --nograb --current |\
                                      awk 'match($0,/[0-9]*\.[0-9]*\*/) {printf $1 " @ "\
                                           substr($0,RSTART,RLENGTH) "Hz, "}')"
                    ;;

                    "off")
                        resolution="$(xrandr --nograb --current |\
                                      awk -F 'connected |\\+|\\(' \
                                             '/ connected/ && $2 {printf $2 ", "}')"
                        resolution="${resolution/primary }"
                    ;;
                esac
                resolution="${resolution//\*}"

            elif type -p xdpyinfo >/dev/null; then
                resolution="$(xdpyinfo | awk '/dimensions:/ {printf $2}')"
            fi
        ;;
    esac

    resolution="${resolution%,*}"
}

get_style() {
    # Fix weird output when the function is run multiple times.
    unset gtk2_theme gtk3_theme theme path

    if [[ "$DISPLAY" && "$os" != "Mac OS X" ]]; then
        # Get DE if user has disabled the function.
        ((de_run != 1)) && get_de

        # Check for DE Theme.
        case "$de" in
            "KDE"*)
                kde_config_dir

                if [[ -f "${kde_config_dir}/kdeglobals" ]]; then
                    kde_config_file="${kde_config_dir}/kdeglobals"

                    kde_theme="$(grep "^${kde}" "$kde_config_file")"
                    kde_theme="${kde_theme/*=}"
                    if [[ "$kde" == "font" ]]; then
                        kde_font_size="${kde_theme#*,}"
                        kde_font_size="${kde_font_size/,*}"
                        kde_theme="${kde_theme/,*} ${kde_theme/*,} ${kde_font_size}"
                    fi
                    kde_theme="$(uppercase "$kde_theme") [KDE], "
                else
                    err "Theme: KDE config files not found, skipping."
                fi
            ;;

            *"Cinnamon"*)
                if type -p gsettings >/dev/null; then
                    gtk3_theme="$(gsettings get org.cinnamon.desktop.interface "$gsettings")"
                    gtk2_theme="$gtk3_theme"
                fi
            ;;

            "Gnome"* | "Unity"* | "Budgie"*)
                if type -p gsettings >/dev/null; then
                    gtk3_theme="$(gsettings get org.gnome.desktop.interface "$gsettings")"
                    gtk2_theme="$gtk3_theme"

                elif type -p gconftool-2 >/dev/null; then
                    gtk2_theme="$(gconftool-2 -g /desktop/gnome/interface/"$gconf")"
                fi
            ;;

            "Mate"*)
                gtk3_theme="$(gsettings get org.mate.interface "$gsettings")"
                gtk2_theme="$gtk3_theme"
            ;;

            "Xfce"*)
                type -p xfconf-query >/dev/null && \
                    gtk2_theme="$(xfconf-query -c xsettings -p "$xfconf")"
            ;;
        esac

        # Check for general GTK2 Theme.
        if [[ -z "$gtk2_theme" ]]; then
            if [[ -f "${GTK2_RC_FILES:-${HOME}/.gtkrc-2.0}" ]]; then
                gtk2_theme="$(grep "^[^#]*${name}" "${GTK2_RC_FILES:-${HOME}/.gtkrc-2.0}")"

            elif [[ -f "/usr/share/gtk-2.0/gtkrc" ]]; then
                gtk2_theme="$(grep "^[^#]*${name}" /usr/share/gtk-2.0/gtkrc)"

            elif [[ -f "/etc/gtk-2.0/gtkrc" ]]; then
                gtk2_theme="$(grep "^[^#]*${name}" /etc/gtk-2.0/gtkrc)"
            fi

            gtk2_theme="${gtk2_theme/${name}*=}"
        fi

        # Check for general GTK3 Theme.
        if [[ -z "$gtk3_theme" ]]; then
            if [[ -f "${XDG_CONFIG_HOME}/gtk-3.0/settings.ini" ]]; then
                gtk3_theme="$(grep "^[^#]*$name" "${XDG_CONFIG_HOME}/gtk-3.0/settings.ini")"

            elif type -p gsettings >/dev/null; then
                gtk3_theme="$(gsettings get org.gnome.desktop.interface "$gsettings")"

            elif [[ -f "/usr/share/gtk-3.0/settings.ini" ]]; then
                gtk3_theme="$(grep "^[^#]*$name" /usr/share/gtk-3.0/settings.ini)"

            elif [[ -f "/etc/gtk-3.0/settings.ini" ]]; then
                gtk3_theme="$(grep "^[^#]*$name" /etc/gtk-3.0/settings.ini)"
            fi

            gtk3_theme="${gtk3_theme/${name}*=}"
        fi

        # Trim whitespace.
        gtk2_theme="$(trim "$gtk2_theme")"
        gtk3_theme="$(trim "$gtk3_theme")"

        # Remove quotes.
        gtk2_theme="$(trim_quotes "$gtk2_theme")"
        gtk3_theme="$(trim_quotes "$gtk3_theme")"

        # Uppercase the first letter of each GTK theme.
        gtk2_theme="$(uppercase "$gtk2_theme")"
        gtk3_theme="$(uppercase "$gtk3_theme")"

        # Toggle visibility of GTK themes.
        [[ "$gtk2" == "off" ]] && unset gtk2_theme
        [[ "$gtk3" == "off" ]] && unset gtk3_theme

        # Format the string based on which themes exist.
        if [[ "$gtk2_theme" && "$gtk2_theme" == "$gtk3_theme" ]]; then
            gtk3_theme+=" [GTK2/3]"
            unset gtk2_theme

        elif [[ "$gtk2_theme" && "$gtk3_theme" ]]; then
            gtk2_theme+=" [GTK2], "
            gtk3_theme+=" [GTK3] "

        else
            [[ "$gtk2_theme" ]] && gtk2_theme+=" [GTK2] "
            [[ "$gtk3_theme" ]] && gtk3_theme+=" [GTK3] "
        fi

        # Final string.
        theme="${kde_theme}${gtk2_theme}${gtk3_theme}"
        theme="${theme%, }"

        # Make the output shorter by removing "[GTKX]" from the string.
        if [[ "$gtk_shorthand" == "on" ]]; then
            theme="${theme// '[GTK'[0-9]']'}"
            theme="${theme/ '[GTK2/3]'}"
            theme="${theme/ '[KDE]'}"
        fi
    fi
}

get_theme() {
    name="gtk-theme-name"
    gsettings="gtk-theme"
    gconf="gtk_theme"
    xfconf="/Net/ThemeName"
    kde="Name"

    get_style
}

get_icons() {
    name="gtk-icon-theme-name"
    gsettings="icon-theme"
    gconf="icon_theme"
    xfconf="/Net/IconThemeName"
    kde="Theme"

    get_style
    icons="$theme"
}

get_font() {
    name="gtk-font-name"
    gsettings="font-name"
    gconf="font_theme"
    xfconf="/Gtk/FontName"
    kde="font"

    get_style
    font="$theme"
}

get_term() {
    # If function was run, stop here.
    ((term_run == 1)) && return

    # Workaround for macOS systems that
    # don't support the block below.
    case "$TERM_PROGRAM" in
        "iTerm.app") term="iTerm2" ;;
        "Terminal.app") term="Apple Terminal" ;;
        "Hyper") term="HyperTerm" ;;
        *) term="${TERM_PROGRAM/\.app}" ;;
    esac

    # Most likely TosWin2 on FreeMiNT - quick check
    [[ "$TERM" == "tw52" || "$TERM" == "tw100" ]] && \
        term="TosWin2"

    # Check $PPID for terminal emulator.
    while [[ -z "$term" ]]; do
        if [[ "$SSH_CONNECTION" ]]; then
            term="$SSH_TTY"; break
        else
            parent="$(get_ppid "$parent")"
            [[ -z "$parent" ]] && break
            name="$(get_process_name "$parent")"
            case "${name// }" in
                "${SHELL/*\/}" | *"sh" | "tmux"* | "screen" | "su"*) ;;
                "login"* | *"Login"* | "init" | "(init)") term="$(tty)" ;;
                "ruby" | "1" | "systemd" | "sshd"* | "python"* | "USER"*"PID"* | "kdeinit"*)
                    break
                ;;
                "gnome-terminal-") term="gnome-terminal" ;;
                *"nvim") term="Neovim Terminal" ;;
                *"NeoVimServer"*) term="VimR Terminal" ;;
                *) term="${name##*/}" ;;
            esac
        fi
    done

    # Log that the function was run.
    term_run=1
}

get_term_font() {
    ((term_run != 1)) && get_term

    case "$term" in
        "alacritty"*)
            if [[ -f "${XDG_CONFIG_HOME}/alacritty.yml" ]]; then
                alacritty_file="${XDG_CONFIG_HOME}/alacritty.yml"

            elif [[ -f "${XDG_CONFIG_HOME}/alacritty/alacritty.yml" ]]; then
                alacritty_file="${XDG_CONFIG_HOME}/alacritty/alacritty.yml"

            elif [[ -f "${HOME}/.alacritty.yml" ]]; then
                alacritty_file="${HOME}/.alacritty.yml"
            fi

            term_font="$(awk -F ':|#' '/normal:/ {getline; print}' \
                         "$alacritty_file")"
            term_font="${term_font/*family:}"
            term_font="${term_font/$'\n'*}"
            term_font="${term_font/\#*}"
        ;;

        "Apple_Terminal")
            term_font="$(osascript <<END
                         tell application "Terminal" to font name of window frontmost
END
)"
        ;;

        "iTerm2")
            # Unfortunately the profile name is not unique, but it seems to be the only thing
            # that identifies an active profile. There is the "id of current session of current win-
            # dow" though, but that does not match to a guid in the plist.
            # So, be warned, collisions may occur!
            # See: https://groups.google.com/forum/#!topic/iterm2-discuss/0tO3xZ4Zlwg
            local current_profile_name profiles_count profile_name diff_font none_ascii

            current_profile_name="$(osascript <<END
                                    tell application "iTerm2" to profile name \
                                    of current session of current window
END
)"

            # Warning: Dynamic profiles are not taken into account here!
            # https://www.iterm2.com/documentation-dynamic-profiles.html
            font_file="${HOME}/Library/Preferences/com.googlecode.iterm2.plist"

            # Count Guids in "New Bookmarks"; they should be unique
            profiles_count="$(PlistBuddy -c "Print :New\ Bookmarks:" "$font_file" | grep -c "Guid")"

            for ((i=0; i<=profiles_count; i++)); do
                profile_name="$(PlistBuddy -c "Print :New\ Bookmarks:${i}:Name:" "$font_file")"

                if [[ "$profile_name" == "$current_profile_name" ]]; then
                    # "Normal Font"
                    term_font="$(PlistBuddy -c "Print :New\ Bookmarks:${i}:Normal\ Font:" \
                                 "$font_file")"

                    # Font for non-ascii characters
                    # Only check for a different non-ascii font, if the user checked
                    # the "use a different font for non-ascii text" switch.
                    diff_font="$(PlistBuddy -c "Print :New\ Bookmarks:${i}:Use\ Non-ASCII\ Font:" \
                                 "$font_file")"

                    if [[ "$diff_font" == "true" ]]; then
                        non_ascii="$(PlistBuddy -c "Print :New\ Bookmarks:${i}:Non\ Ascii\ Font:" \
                                     "$font_file")"

                        [[ "$term_font" != "$non_ascii" ]] && \
                            term_font="$term_font (normal) / $non_ascii (non-ascii)"
                    fi
                fi
            done
        ;;

        "deepin-terminal"*)
            term_font="$(awk -F '=' '/font=/ {a=$2} /font_size/ {b=$2} END{print a " " b}' \
                         "${XDG_CONFIG_HOME}/deepin/deepin-terminal/config.conf")"
        ;;

        "GNUstep_Terminal")
             term_font="$(awk -F '>|<' '/>TerminalFont</ {getline; f=$3}
                          />TerminalFontSize</ {getline; s=$3} END{print f " " s}' \
                          "${HOME}/GNUstep/Defaults/Terminal.plist")"
        ;;

        "Hyper"*)
            term_font="$(awk -F':|,' '/fontFamily/ {print $2; exit}' "${HOME}/.hyper.js")"
            term_font="$(trim_quotes "$term_font")"
        ;;

        "kitty"*)
            if [[ -f "${KITTY_CONFIG_DIRECTORY}/kitty/kitty.conf" ]]; then
                kitty_file="${KITTY_CONFIG_DIRECTORY}/kitty/kitty.conf"

            elif [[ -f "${XDG_CONFIG_HOME}/kitty/kitty.conf" ]]; then
                kitty_file="${XDG_CONFIG_HOME}/kitty/kitty.conf"

            elif [[ -f "${HOME}/.config/kitty/kitty.conf" ]]; then
                kitty_file="${HOME}/.config/kitty/kitty.conf"

            elif [[ -f "${HOME}/Library/Preferences/kitty/kitty.conf" ]]; then
                kitty_file="${HOME}/Library/Preferences/kitty/kitty.conf"

            fi

            term_font="$(awk '/font_family/ { $1 = ""; gsub(/^[[:space:]]/, ""); font = $0 } \
                         /\s?font_size\s/ { size = $2 } END { print font " " size}' \
                         "${kitty_file}")"
        ;;

        "konsole"*)
            # Get Process ID of current konsole window / tab
            child="$(get_ppid "$$")"

            konsole_instances=($(qdbus | grep 'org.kde.konsole'))

            for i in "${konsole_instances[@]}"; do
                konsole_sessions=($(qdbus "${i}" | grep '/Sessions/'))
                for session in "${konsole_sessions[@]}"; do
                    if ((child == "$(qdbus "${i}" "${session}" processId)")); then
                        profile="$(qdbus "${i}" "${session}" environment |\
                                   awk -F '=' '/KONSOLE_PROFILE_NAME/ {print $2}')"
                        break
                    fi
                done
                [[ "$profile" ]] && break
            done

            # We could have two profile files for the same profile name, take first match
            profile_filename="$(grep -l "Name=${profile}" "${HOME}"/.local/share/konsole/*.profile)"
            profile_filename="${profile_filename/$'\n'*}"
            [[ "$profile_filename" ]] && \
                term_font="$(awk -F '=|,' '/Font=/ {print $2 " " $3}' "$profile_filename")"
        ;;

        "lxterminal"*)
            term_font="$(awk -F '=' '/fontname=/ {print $2; exit}' \
                         "${XDG_CONFIG_HOME}/lxterminal/lxterminal.conf")"
        ;;

        "mate-terminal")
            # To get the actual config we have to create a temporarily file with the
            # --save-config option.
            mateterm_config="/tmp/mateterm.cfg"

            # Ensure /tmp exists and we do not overwrite anything.
            if [[ -d /tmp && ! -f "$mateterm_config" ]]; then
                mate-terminal --save-config="$mateterm_config"

                role="$(xprop -id "${WINDOWID}" WM_WINDOW_ROLE)"
                role="${role##* }"
                role="${role//\"}"

                profile="$(awk -F '=' -v r="$role" \
                           '$0~r {getline; if(/Maximized/) getline; \
                            if(/Fullscreen/) getline; id=$2"]"} \
                            $0~id {if(id) {getline; print $2; exit}}' "$mateterm_config")"

                rm -f "$mateterm_config"

                mate_get() {
                   gsettings get org.mate.terminal.profile:/org/mate/terminal/profiles/"$1"/ "$2"
                }

                if [[ "$(mate_get "$profile" "use-system-font")" == "true" ]]; then
                    term_font="$(gsettings get org.mate.interface monospace-font-name)"
                else
                    term_font="$(mate_get "$profile" "font")"
                fi
                term_font="$(trim_quotes "$term_font")"
            fi
        ;;

        "mintty")
            term_font="$(awk -F '=' '!/^($|#)/ && /Font/ {printf $2; exit}' "${HOME}/.minttyrc")"
        ;;

        "pantheon"*)
            term_font="$(gsettings get org.pantheon.terminal.settings font)"

            [[ -z "${term_font//\'}" ]] && \
                term_font="$(gsettings get org.gnome.desktop.interface monospace-font-name)"

            term_font="$(trim_quotes "$term_font")"
        ;;

        "sakura"*)
            term_font="$(awk -F '=' '/^font=/ {print $2; exit}' \
                         "${XDG_CONFIG_HOME}/sakura/sakura.conf")"
        ;;

        "st")
            term_font="$(ps -o command= -p "$parent" | grep -F -- "-f")"

            if [[ "$term_font" ]]; then
                term_font="${term_font/*-f/}"
                term_font="${term_font/ -*/}"

            else
                # On Linux we can get the exact path to the running binary through the procfs
                # (in case `st` is launched from outside of $PATH) on other systems we just
                # have to guess and assume `st` is invoked from somewhere in the users $PATH
                [[ -L /proc/$parent/exe ]] && binary="/proc/$parent/exe" || binary="$(type -p st)"

                # Grep the output of strings on the `st` binary for anything that looks vaguely
                # like a font definition. NOTE: There is a slight limitation in this approach.
                # Technically "Font Name" is a valid font. As it doesn't specify any font options
                # though it is hard to match it correctly amongst the rest of the noise.
                [[ -n "$binary" ]] && \
                    term_font="$(strings "$binary" | grep -F -m 1 \
                                                          -e "pixelsize=" \
                                                          -e "size=" \
                                                          -e "antialias=" \
                                                          -e "autohint=")"
            fi

            term_font="${term_font/xft:}"
            term_font="${term_font/:*}"
        ;;

        "terminology")
            term_font="$(strings "${XDG_CONFIG_HOME}/terminology/config/standard/base.cfg" |\
                         awk '/^font\.name$/{print a}{a=$0}')"
            term_font="${term_font/.pcf}"
            term_font="${term_font/:*}"
        ;;

        "termite")
            [[ -f "${XDG_CONFIG_HOME}/termite/config" ]] && \
                termite_config="${XDG_CONFIG_HOME}/termite/config"

            term_font="$(awk -F '= ' '/\[options\]/ {opt=1} /^\s*font/ {if(opt==1) a=$2; opt=0} \
                                      END{print a}' "/etc/xdg/termite/config" "$termite_config")"
        ;;

        "urxvt" | "urxvtd" | "rxvt-unicode" | "xterm")
            xrdb="$(xrdb -query)"
            term_font="$(grep -i "${term/d}\**\.*font" <<< "$xrdb")"
            term_font="${term_font/*"*font:"}"
            term_font="${term_font/*".font:"}"
            term_font="${term_font/*"*.font:"}"
            term_font="$(trim "$term_font")"

            if [[ -z "$term_font" && "$term" == "xterm" ]]; then
                term_font="$(grep -E '^XTerm.vt100.faceName' <<< "$xrdb")"
                term_font="${term_font/*"faceName:"}"
            fi

            # xft: isn't required at the beginning so we prepend it if it's missing
            if [[ "${term_font:0:1}" != "-" && \
                  "${term_font:0:4}" != "xft:" ]]; then
                term_font="xft:$term_font"
            fi

            # Xresources has two different font formats, this checks which
            # one is in use and formats it accordingly.
            case "$term_font" in
                *"xft:"*)
                    term_font="${term_font/xft:}"
                    term_font="${term_font/:*}"
                ;;

                "-"*) term_font="$(awk -F '\\-' '{printf $3}' <<< "$term_font")" ;;
            esac
        ;;

        "xfce4-terminal")
            term_font="$(awk -F '=' '/^FontName/ {a=$2} /^FontUseSystem=TRUE/ {a=$0} END{print a}' \
                         "${XDG_CONFIG_HOME}/xfce4/terminal/terminalrc")"

            if [[ "$term_font" == "FontUseSystem=TRUE" ]]; then
                term_font="$(gsettings get org.gnome.desktop.interface monospace-font-name)"
                term_font="$(trim_quotes "$term_font")"
            fi

            # Default fallback font hardcoded in terminal-preferences.c
            [[ -z "$term_font" ]] && term_font="Monospace 12"
        ;;
    esac
}

get_disk() {
    type -p df >/dev/null 2>&1 ||\
        { err "Disk requires 'df' to function. Install 'df' to get disk info."; return; }

    # Get "df" version.
    df_version="$(df --version 2>&1)"
    case "$df_version" in
        *"Tracker"*) # Haiku
            err "Your version of df cannot be used due to the non-standard flags"
            return
        ;;
        *"IMitv"*) df_flags=(-P -g) ;; # AIX
        *"befhikm"*) df_flags=(-P -k) ;; # IRIX
        *) df_flags=(-P -h) ;;
    esac

    # Create an array called 'disks' where each element is a separate line from
    # df's output. We then unset the first element which removes the column titles.
    IFS=$'\n' read -d "" -ra disks <<< "$(df "${df_flags[@]}" "${disk_show[@]:-/}")"
    unset "disks[0]"

    # Stop here if 'df' fails to print disk info.
    if [[ -z "${disks[*]}" ]]; then
        err "Disk: df failed to print the disks, make sure the disk_show array is set properly."
        return
    fi

    for disk in "${disks[@]}"; do
        # Create a second array and make each element split at whitespace this time.
        IFS=" " read -ra disk_info <<< "$disk"
        disk_perc="${disk_info[4]/'%'}"

        case "$df_version" in
            *"befhikm"*)
                disk="$((disk_info[2]/1024/1024))G / $((disk_info[1]/1024/1024))G (${disk_perc}%)"
            ;;
            *) disk="${disk_info[2]/i} / ${disk_info[1]/i} (${disk_perc}%)" ;;
        esac

        # Subtitle.
        case "$disk_subtitle" in
            "name") disk_sub="${disk_info[0]}" ;;
            "dir")
                disk_sub="${disk_info[5]/*\/}"
                [[ -z "$disk_sub" ]] && disk_sub="${disk_info[5]}"
            ;;
            *) disk_sub="${disk_info[5]}" ;;
        esac

        # Bar.
        case "$disk_display" in
            "bar") disk="$(bar "$disk_perc" "100")" ;;
            "infobar") disk+=" $(bar "$disk_perc" "100")" ;;
            "barinfo") disk="$(bar "$disk_perc" "100")${info_color} $disk" ;;
            "perc") disk="${disk_perc}% $(bar "$disk_perc" "100")" ;;
        esac

        # Append '(disk mount point)' to the subtitle.
        if [[ -z "$subtitle" ]]; then
            prin "${disk_sub}" "$disk"
        else
            prin "${subtitle} (${disk_sub})" "$disk"
        fi
    done
}

get_battery() {
    case "$os" in
        "Linux")
            # We use 'prin' here so that we can do multi battery support
            # with a single battery per line.
            for bat in "/sys/class/power_supply/"{BAT,axp288_fuel_gauge,CMB}*; do
                capacity="$(< "${bat}/capacity")"
                status="$(< "${bat}/status")"

                if [[ "$capacity" ]]; then
                    battery="${capacity}% [${status}]"

                    case "$battery_display" in
                        "bar") battery="$(bar "$capacity" 100)" ;;
                        "infobar") battery+=" $(bar "$capacity" 100)" ;;
                        "barinfo") battery="$(bar "$capacity" 100)${info_color} ${battery}" ;;
                    esac

                    bat="${bat/*axp288_fuel_gauge}"
                    prin "${subtitle:+${subtitle}${bat: -1}}" "$battery"
                fi
            done
            return
        ;;

        "BSD")
            case "$kernel_name" in
                "FreeBSD"* | "DragonFly"*)
                    battery="$(acpiconf -i 0 | awk -F ':\t' '/Remaining capacity/ {print $2}')"
                    battery_state="$(acpiconf -i 0 | awk -F ':\t\t\t' '/State/ {print $2}')"
                ;;

                "NetBSD"*)
                    battery="$(envstat | awk '\\(|\\)' '/charge:/ {print $2}')"
                    battery="${battery/\.*/%}"
                ;;

                "OpenBSD"* | "Bitrig"*)
                    battery0full="$(sysctl -n hw.sensors.acpibat0.watthour0)"
                    battery0full="${battery0full/ Wh*}"

                    battery0now="$(sysctl -n hw.sensors.acpibat0.watthour3)"
                    battery0now="${battery0now/ Wh*}"

                    [[ "$battery0full" ]] && \
                    battery="$((100 * ${battery0now/\.} / ${battery0full/\.}))%"
                ;;
            esac
        ;;

        "Mac OS X")
            battery="$(pmset -g batt | grep -o '[0-9]*%')"
            state="$(pmset -g batt | awk '/;/ {print $4}')"
            [[ "$state" == "charging;" ]] && battery_state="charging"
        ;;

        "Windows")
            battery="$(wmic Path Win32_Battery get EstimatedChargeRemaining)"
            battery="${battery/EstimatedChargeRemaining}"
            batttery="$(trim "$battery")%"
        ;;

        "Haiku")
            battery0full="$(awk -F '[^0-9]*' 'NR==2 {print $4}' /dev/power/acpi_battery/0)"
            battery0now="$(awk -F '[^0-9]*' 'NR==5 {print $4}' /dev/power/acpi_battery/0)"
            battery="$((battery0full * 100 / battery0now))%"
        ;;
    esac

    [[ "$battery_state" ]] && battery+=" Charging"

    case "$battery_display" in
        "bar") battery="$(bar "${battery/'%'*}" 100)" ;;
        "infobar") battery="${battery} $(bar "${battery/'%'*}" 100)" ;;
        "barinfo") battery="$(bar "${battery/'%'*}" 100)${info_color} ${battery}" ;;
    esac
}

get_local_ip() {
    case "$os" in
        "Linux" | "BSD" | "Solaris" | "AIX" | "IRIX")
            local_ip="$(ip route get 1 | awk -F'src' '{print $2; exit}')"
            local_ip="${local_ip/uid*}"
            [[ -z "$local_ip" ]] && local_ip="$(ifconfig -a | awk '/broadcast/ {print $2; exit}')"
        ;;

        "MINIX")
            local_ip="$(ifconfig | awk '{printf $3; exit}')"
        ;;

        "Mac OS X" | "iPhone OS")
            local_ip="$(ipconfig getifaddr en0)"
            [[ -z "$local_ip" ]] && local_ip="$(ipconfig getifaddr en1)"
        ;;

        "Windows")
            local_ip="$(ipconfig | awk -F ': ' '/IPv4 Address/ {printf $2 ", "}')"
            local_ip="${local_ip%\,*}"
        ;;

        "Haiku")
            local_ip="$(ifconfig | awk -F ': ' '/Bcast/ {print $2}')"
            local_ip="${local_ip/', Bcast'}"
        ;;
    esac
}

get_public_ip() {
    if type -p dig >/dev/null; then
        public_ip="$(dig +time=1 +tries=1 +short myip.opendns.com @resolver1.opendns.com)"
       [[ "$public_ip" =~ ^\; ]] && unset public_ip
    fi

    if [[ -z "$public_ip" ]] && type -p curl >/dev/null; then
        public_ip="$(curl --max-time 10 -w '\n' "$public_ip_host")"
    fi

    if [[ -z "$public_ip" ]] && type -p wget >/dev/null; then
        public_ip="$(wget -T 10 -qO- "$public_ip_host")"
    fi
}

get_users() {
    users="$(who | awk '!seen[$1]++ {printf $1 ", "}')"
    users="${users%\,*}"
}

get_install_date() {
    case "$os" in
        "Linux" | "iPhone OS") install_file="/lost+found" ;;
        "Mac OS X") install_file="/var/log/install.log" ;;
        "Solaris") install_file="/var/sadm/system/logs/install_log" ;;
        "Windows")
            case "$kernel_name" in
                "CYGWIN"*) install_file="/cygdrive/c/Windows/explorer.exe" ;;
                "MSYS"* | "MINGW"*) install_file="/c/Windows/explorer.exe" ;;
            esac
        ;;
        "Haiku") install_file="/boot" ;;
        "BSD" | "MINIX" | "IRIX")
            case "$kernel_name" in
                "FreeBSD") install_file="/etc/hostid" ;;
                "NetBSD" | "DragonFly"*) install_file="/etc/defaults/rc.conf" ;;
                *) install_file="/" ;;
            esac
        ;;
        "AIX") install_file="/var/adm/ras/bosinstlog" ;;
    esac

    ls_prog="$(ls --version 2>&1)"
    case "$ls_prog" in
        *"BusyBox"*)
            install_date="$(ls -tdce "$install_file" | awk '{printf $10 " " $7 " " $8 " " $9}')"
        ;;

        *"crtime"*) # xpg4 (Solaris)
            install_date="$(ls -tdcE "$install_file" | awk '{printf $6 " " $7}')"
        ;;

        *"ACFHLRSZ"*) # Toybox
            install_date="$(ls -dl "$install_file" | awk '{printf $6 " " $7}')"
        ;;

        *"GNU coreutils"*)
            install_date="$(ls -tcd --full-time "$install_file" | awk '{printf $6 " " $7}')"
        ;;

        *"ACFHLNRS"* | *"RadC1xmnlog"*) # AIX ls / IRIX ls
            err "Install Date doesn't work because your 'ls' doesn't support full date/time."
            return
        ;;

        *"HLOPRSTUWabc"*) # macOS ls
            install_date="$(ls -dlctUT "$install_file" | awk '{printf $9 " " $6 " "$7 " " $8}')"
        ;;

        *)
            install_date="$(ls -dlctT "$install_file" | awk '{printf $9 " " $6 " " $7 " " $8}')"
        ;;
    esac

    install_date="${install_date//-/ }"
    install_date="${install_date%:*}"
    IFS=" " read -ra install_date <<< "$install_date"
    install_date="$(convert_time "${install_date[@]}")"
}

get_locale() {
    locale="$sys_locale"
}

get_gpu_driver() {
    case "$os" in
        "Linux")
            gpu_driver="$(lspci -nnk | awk -F ': ' \
                          '/Display|3D|VGA/{nr[NR+2]}; NR in nr {printf $2 ", "}')"
            gpu_driver="${gpu_driver%, }"

            if [[ "$gpu_driver" == *"nvidia"* ]]; then
                gpu_driver="$(< /proc/driver/nvidia/version)"
                gpu_driver="${gpu_driver/*Module  }"
                gpu_driver="NVIDIA ${gpu_driver/  *}"
            fi
        ;;
        "Mac OS X")
            if [[ "$(kextstat | grep "GeForceWeb")" != "" ]]; then
                gpu_driver="NVIDIA Web Driver"
            else
                gpu_driver="macOS Default Graphics Driver"
            fi
        ;;
    esac
}

get_cols() {
    if [[ "$color_blocks" == "on" ]]; then
        # Convert the width to space chars.
        printf -v block_width "%${block_width}s"

        # Set variables.
        start="${block_range[0]}"
        end="${block_range[1]}"

        # Generate the string.
        for ((start; start<=end; start++)); do
            case "$start" in
                [0-6]) blocks+="${reset}\e[3${start}m\e[4${start}m${block_width}" ;;
                7) blocks+="${reset}\e[3${start}m\e[4${start}m${block_width}" ;;
                *) blocks2+="\e[38;5;${start}m\e[48;5;${start}m${block_width}" ;;
            esac
        done

        # Convert height into spaces.
        printf -v block_spaces "%${block_height}s"

        # Convert the spaces into rows of blocks.
        [[ "$blocks" ]] &&  cols+="${block_spaces// /${blocks}${reset}nl}"
        [[ "$blocks2" ]] && cols+="${block_spaces// /${blocks2}${reset}nl}"

        # Add newlines to the string.
        cols="${cols%%'nl'}"
        cols="${cols//nl/\\n\\e[${text_padding}C${zws}}"

        # Add block height to info height.
        info_height="$((info_height+=block_height+2))"

        printf "%b\n" "\e[${text_padding}C${zws}${cols}"
    fi

    unset -v blocks blocks2 cols

    # TosWin2 on FreeMiNT is terrible at this,
    # so we'll reset colors arbitrarily.
    [[ "$term" == "TosWin2" ]] && \
        printf "%b\n" "\e[30;47m"

    # Tell info() that we printed manually.
    prin=1
}

# IMAGES

image_backend() {
    if [[ ! "$image_backend" =~ ^(off|ascii)$ ]]; then
        if ! type -p convert >/dev/null 2>&1; then
            image_backend="ascii"
            err "Image: Imagemagick not found, falling back to ascii mode."
        fi
    fi

    case "${image_backend:-off}" in
        "ascii") get_ascii ;;
        "off") image_backend="off" ;;

        "caca" | "catimg" | "jp2a" | "iterm2" | "termpix" |\
        "tycat" | "w3m" | "sixel" | "pixterm")
            get_image_source

            if [[ ! -f "$image" ]]; then
                to_ascii "Image: '$image_source' doesn't exist, falling back to ascii mode."
                return
            fi

            get_term_size

            if [[ "$term_width" ]] && ((term_width >= 1)); then
                clear
            else
                to_ascii "Image: Failed to find terminal window size."
                err "Image: Check the 'Images in the terminal' wiki page for more info,"
                return
            fi

            get_image_size
            make_thumbnail
            display_image
        ;;

        *)
            err "Image: Unknown image backend specified '$image_backend'."
            err "Image: Valid backends are: 'ascii', 'caca', 'catimg', 'jp2a', 'iterm2',
                                            'off', 'sixel', 'pixterm', 'termpix', 'tycat', 'w3m')"
            err "Image: Falling back to ascii mode."
            get_ascii
        ;;
    esac

    # Set cursor position next image/ascii.
    [[ "$image_backend" != "off" ]] && printf "%b" "\e[${lines:-0}A\e[9999999D"
}

get_ascii() {
    if [[ ! -f "$image_source" ||
          "$image_source" =~ ^(auto|ascii)$ ||
          "$image_source" =~ \.(png|jpg|jpe|jpeg|gif)$ ]]; then

        # Fallback to distro ascii mode if custom ascii isn't found.
        [[ ! "$image_source" =~ ^(auto|ascii)$ ]] && \
            err "Ascii: Ascii file not found, using distro ascii."

        # Fallback to distro ascii mode if source is an image.
        [[ "$image_source" =~ \.(png|jpg|jpe|jpeg|gif)$ ]] && \
            err "Image: Source is image file but ascii backend was selected. Using distro ascii."

        if [[ -d "ASCIIDIR" ]]; then
            ascii_dir="ASCIIDIR"
        else
            [[ -z "$script_dir" ]] && script_dir="$(get_full_path "$0")"
            ascii_dir="${script_dir%/*}/ascii/distro"
        fi

        image_source="${ascii_dir}/${ascii_file}"

        # Fallback to no ascii mode if distro ascii isn't found.
        [[ ! -f "$image_source" ]] && \
            { to_off "Ascii: Failed to find distro ascii, falling back to no ascii mode."; return; }
    fi

    # Set locale to get correct padding.
    export LC_ALL="$sys_locale"

    # Turn file into variable.
    while IFS=$'\n' read -r line; do
        print+="$line \n"

        # Calculate size of ascii file in line length / line count.
        line="${line//[??;?;??m}"
        line="${line//[??;?;???m}"
        line="${line//[0m}"
        line="${line//\$\{??\}}"
        line="${line//\\\\/\\}"
        ((${#line} > ascii_length)) && ascii_length="${#line}"
        ((++lines))
    done < "$image_source"

    # Colors.
    print="${print//'${c1}'/$c1}"
    print="${print//'${c2}'/$c2}"
    print="${print//'${c3}'/$c3}"
    print="${print//'${c4}'/$c4}"
    print="${print//'${c5}'/$c5}"
    print="${print//'${c6}'/$c6}"

    # Overwrite padding if ascii_length_force is set.
    [[ "$ascii_length_force" ]] && ascii_length="$ascii_length_force"

    text_padding="$((ascii_length + gap))"
    printf "%b" "$print"
    export LC_ALL=C
}

get_image_source() {
    case "$image_source" in
        "auto" | "wall" | "wallpaper")
            get_wallpaper
        ;;

        *)
            # Get the absolute path.
            image_source="$(get_full_path "$image_source")"

            if [[ -d "$image_source" ]]; then
                shopt -s nullglob
                files=("${image_source%/}"/*.{png,jpg,jpeg,jpe,gif,svg})
                shopt -u nullglob
                image="${files[RANDOM % ${#files[@]}]}"

            else
                image="$image_source"
            fi
        ;;
    esac

    err "Image: Using image '$image'"
}

get_wallpaper() {
    case "$os" in
        "Mac OS X")
            image="$(osascript <<END
                     tell application "System Events" to picture of current desktop
END
)"
        ;;

        "Windows")
            case "$distro" in
                "Windows XP")
                    case "$kernel_name" in
                        "CYGWIN"*) image="/cygdrive/c/Documents and Settings/${USER}" ;;
                        "MSYS2"* | "MINGW*")  image="/c/Documents and Settings/${USER}" ;;
                    esac
                    image+="/Local Settings/Application Data/Microsoft"
                    image+="/Wallpaper1.bmp"
                ;;

                "Windows"*)
                    image="$APPDATA/Microsoft/Windows/Themes"
                    image+="/TranscodedWallpaper.jpg"
                ;;
            esac
        ;;

        *)
            # Get DE if user has disabled the function.
            ((de_run != 1)) && get_de

            if type -p wal >/dev/null && [[ -f "${HOME}/.cache/wal/wal" ]]; then
               image="$(< "${HOME}/.cache/wal/wal")"
               return
            fi

            case "$de" in
                "MATE"*) image="$(gsettings get org.mate.background picture-filename)" ;;
                "Xfce"*)
                    image="$(xfconf-query -c xfce4-desktop -p \
                             "/backdrop/screen0/monitor0/workspace0/last-image")"
                ;;

                "Cinnamon"*)
                    image="$(gsettings get org.cinnamon.desktop.background picture-uri)"
                    image="$(decode_url "$image")"
                ;;

                *)
                    if type -p feh >/dev/null && [[ -f "${HOME}/.fehbg" ]]; then
                        image="$(awk -F\' '/feh/ {printf $(NF-1)}' "${HOME}/.fehbg")"

                    elif type -p nitrogen >/dev/null; then
                        image="$(awk -F'=' '/file/ {printf $2;exit;}' \
                                 "${XDG_CONFIG_HOME}/nitrogen/bg-saved.cfg")"

                    else
                        image="$(gsettings get org.gnome.desktop.background picture-uri)"
                        image="$(decode_url "$image")"
                    fi
                ;;
            esac

            # Strip un-needed info from the path.
            image="${image/'file://'}"
            image="$(trim_quotes "$image")"
        ;;
    esac

    # If image is an xml file, don't use it.
    [[ "${image/*\./}" == "xml" ]] && image=""
}

get_w3m_img_path() {
    # Find w3m-img path.
    if [[ -x "/usr/lib/w3m/w3mimgdisplay" ]]; then
        w3m_img_path="/usr/lib/w3m/w3mimgdisplay"

    elif [[ -x "/usr/libexec/w3m/w3mimgdisplay" ]]; then
        w3m_img_path="/usr/libexec/w3m/w3mimgdisplay"

    elif [[ -x "/usr/lib64/w3m/w3mimgdisplay" ]]; then
        w3m_img_path="/usr/lib64/w3m/w3mimgdisplay"

    elif [[ -x  "/usr/libexec64/w3m/w3mimgdisplay" ]]; then
        w3m_img_path="/usr/libexec64/w3m/w3mimgdisplay"

    elif [[ -x "/usr/local/libexec/w3m/w3mimgdisplay" ]]; then
        w3m_img_path="/usr/local/libexec/w3m/w3mimgdisplay"

    elif [[ -x "$HOME/.nix-profile/libexec/w3m/w3mimgdisplay" ]]; then
        w3m_img_path="$HOME/.nix-profile/libexec/w3m/w3mimgdisplay"

    else
        err "Image: w3m-img wasn't found on your system"
    fi
}

get_term_size() {
    # This functions gets the current window size in
    # pixels.
    #
    # We first try to use the escape sequence "\044[14t"
    # to get the terminal window size in pixels. If this
    # fails we then fallback to using "xdotool" or other
    # programs.

    # Tmux has a special way of reading escape sequences
    # so we have to use a slightly different sequence to
    # get the terminal size.
    if [[ -n "$TMUX" ]]; then
        printf "%b" "\ePtmux;\e\e[14t\e\e[c\e\\"
        read_flags=(-d c)

    elif [[ "$image_backend" == "tycat" ]]; then
        printf "%b" "\e}qs\000"

    else
        printf "%b" "\e[14t\e[c"
        read_flags=(-d c)
    fi

    # The escape codes above print the desired output as
    # user input so we have to use read to store the out
    # -put as a variable.
    IFS=";" read -s -t 1 "${read_flags[@]}" -r -a term_size

    # Split the string into height/width.
    if [[ "$image_backend" == "tycat" ]]; then
        term_width="$((term_size[2] * term_size[0]))"
        term_height="$((term_size[3] * term_size[1]))"

    else
        term_height="${term_size[1]}"
        term_width="${term_size[2]/t*}"
    fi

    # Get terminal width/height if \e[14t is unsupported.
    if [[ -z "$term_width" ]] || (( "$term_width" < 50 )); then
        if type -p xdotool >/dev/null 2>&1; then
            current_window="$(xdotool getactivewindow)"
            source <(xdotool getwindowgeometry --shell "$current_window")
            term_height="$HEIGHT"
            term_width="$WIDTH"

        elif type -p xwininfo >/dev/null 2>&1; then
            # Get the focused window's ID.
            if type -p xdpyinfo >/dev/null 2>&1; then
                current_window="$(xdpyinfo | grep -E -o "focus:.*0x[0-9a-f]+")"
                current_window="${current_window/*window }"
            elif type -p xprop >/dev/null 2>&1; then
                current_window="$(xprop -root _NET_ACTIVE_WINDOW)"
                current_window="${current_window##* }"
            fi

            # If the ID was found get the window size.
            if [[ "$current_window" ]]; then
                term_size="$(xwininfo -id "$current_window" |\
                             awk -F ': ' '/Width|Height/ {printf $2 " "}')"
                term_width="${term_size/ *}"
                term_height="${term_size/${term_width}}"
            else
                term_width=0
            fi
        else
            term_width=0
        fi
    fi
}

get_image_size() {
    # This functions determines the size to make
    # the thumbnail image.

    # Get terminal lines and columns.
    term_blocks="$(stty size)"
    columns="${term_blocks/* }"
    lines="${term_blocks/ *}"

    # Calculate font size.
    font_width="$((term_width / columns))"
    font_height="$((term_height / lines))"

    case "$image_size" in
        "auto")
            image_size="$((columns * font_width / 2))"
            term_height="$((term_height - term_height / 4))"

            ((term_height < image_size)) && \
                image_size="$term_height"
        ;;

        *"%")
            percent="${image_size/\%}"
            image_size="$((percent * term_width / 100))"

            (((percent * term_height / 50) < image_size)) && \
                image_size="$((percent * term_height / 100))"
        ;;

        "none")
            # Get image size so that we can do a better crop.
            size="$(identify -format "%w %h" "$image")"
            width="${size%% *}"
            height="${size##* }"
            crop_mode="none"

            while (( "$width" >= ("$term_width" / 2) ||
                     "$height" >= "$term_height" )); do
                width="$((width / 2))"
                height="$((height / 2))"
            done
        ;;

        *) image_size="${image_size/px}" ;;
    esac

    width="${width:-$image_size}"
    height="${height:-$image_size}"

    text_padding="$((width / font_width + gap + xoffset/font_width))"
}

make_thumbnail() {
    # Name the thumbnail using variables so we can
    # use it later.
    image_name="$crop_mode-$crop_offset-$width-$height-${image##*/}"

    # Handle file extensions.
    case "${image##*.}" in
        "eps"|"pdf"|"svg"|"gif"|"png")
            image_name+=".png" ;;
        *)  image_name+=".jpg" ;;
    esac

    # Create the thumbnail dir if it doesn't exist.
    mkdir -p "$thumbnail_dir"

    # Check to see if the thumbnail exists before we do any cropping.
    if [[ ! -f "$thumbnail_dir/$image_name" ]]; then
        # Get image size so that we can do a better crop.
        if [[ -z "$size" ]]; then
            size="$(identify -format "%w %h" "$image")"
            og_width="${size%% *}"
            og_height="${size##* }"

            # This checks to see if height is greater than width
            # so we can do a better crop of portrait images.
            size="$og_height"
            ((og_height > og_width)) && size="$og_width"
        fi

        case "$crop_mode" in
            "fit")
                c="$(convert "$image" \
                    -colorspace srgb \
                    -format "%[pixel:p{0,0}]" info:)"

                convert \
                    -background none \
                    "$image" \
                    -trim +repage \
                    -gravity south \
                    -background "$c" \
                    -extent "$size"x"$size" \
                    -scale "$width"x"$height" \
                    "$thumbnail_dir/$image_name"
            ;;

            "fill")
                convert \
                    -background none \
                    "$image" \
                    -trim +repage \
                    -scale "$width"x"$height"^ \
                    -extent "$width"x"$height" \
                    "$thumbnail_dir/$image_name"
            ;;

            "none") cp "$image" "$thumbnail_dir/$image_name" ;;
            *)
                convert \
                    -background none \
                    "$image" \
                    -gravity "$crop_offset" \
                    -crop "$size"x"$size"+0+0 \
                    -quality 95 \
                    -scale "$width"x"$height" \
                    "$thumbnail_dir/$image_name"
            ;;
        esac
    fi

    # The final image.
    image="$thumbnail_dir/$image_name"
}

display_image() {
    case "$image_backend" in
        "caca")
            img2txt -W "$((width / font_width)))" \
                    -H "$((height / font_height))" \
                    --gamma=0.6 "$image" ||\
                to_off "Image: libcaca failed to display the image."
        ;;

        "catimg")
            catimg -w "$((width * 2 / font_width))" "$image" ||\
                to_off "Image: catimg failed to display the image."
        ;;

        "jp2a")
            jp2a --width="$((width / font_width))" --colors "$image" ||\
                to_off "Image: jp2a failed to display the image."
        ;;

        "pixterm")
            pixterm -tc "$((width / font_width))" \
                    -tr "$((height / font_height))" \
                    "$image" ||\
                to_off "Image: pixterm failed to display the image."
        ;;

        "sixel")
            img2sixel -w "$width" "$image" ||\
                to_off "Image: libsixel failed to display the image."
        ;;

        "termpix")
            termpix --width "$((width / font_width))" "$image" ||\
                to_off "Image: termpix failed to display the image."
        ;;

        "iterm2")
            image="$(base64 < "$image")"
            iterm_cmd="\e]1337;File=width=${width}px;height=${height}px;inline=1:${image}"

            # Tmux requires an additional escape sequence for this to work.
            [[ -n "$TMUX" ]] && iterm_cmd="\ePtmux;\e${iterm_cmd}\e\\"

            printf "%b\a\n" "$iterm_cmd"
        ;;

        "tycat")
            tycat "$image" ||\
                to_off "Image: tycat failed to display the image."
        ;;

        "w3m")
            get_w3m_img_path

            # Add a tiny delay to fix issues with images not
            # appearing in specific terminal emulators.
            sleep 0.05
            printf "%b\n" "0;1;$xoffset;$yoffset;$width;$height;;;;;$image\n4;\n3;" |\
            "${w3m_img_path:-false}" -bg "$background_color" >/dev/null 2>&1 ||\
                to_off "Image: w3m-img failed to display the image."

            zws="\xE2\x80\x8B\x20"
        ;;
    esac
}

to_ascii() {
    # Log the error.
    err "$1"

    # This function makes neofetch fallback to ascii mode.
    image_backend="ascii"

    # Print the ascii art.
    get_ascii

    # Set cursor position next image/ascii.
    printf "%b" "\e[${lines:-0}A\e[9999999D"
}

to_off() {
    # This function makes neofetch fallback to off mode.
    err "$1"
    image_backend="off"
    text_padding=
}

# SCREENSHOT

take_scrot() {
    scrot_program "${scrot_dir}${scrot_name}"

    err "Scrot: Saved screenshot as: ${scrot_dir}${scrot_name}"

    [[ "$scrot_upload" == "on" ]] && scrot_upload
}

scrot_upload() {
    if ! type -p curl >/dev/null 2>&1; then
        printf "%s\n" "[!] Install curl to upload images"
        return
    fi

    image_file="${scrot_dir}${scrot_name}"

    # Print a message letting the user know we're uploading
    # the screenshot.
    printf "%s\r" "Uploading scrot"
    sleep .2
    printf "%s\r" "Uploading scrot."
    sleep .2
    printf "%s\r" "Uploading scrot.."
    sleep .2
    printf "%s\r" "Uploading scrot..."

    case "$image_host" in
        "teknik")
            image_url="$(curl -sf -F file="@${image_file};type=image/png" \
                         "https://api.teknik.io/v1/Upload")"
            image_url="$(awk -F 'url:|,' '{printf $2}' <<< "${image_url//\"}")"
        ;;

        "imgur")
            image_url="$(curl -sH "Authorization: Client-ID 0e8b44d15e9fc95" \
                         -F image="@${image_file}" "https://api.imgur.com/3/upload")"
            image_url="$(awk -F 'id:|,' '{printf $2}' <<< "${image_url//\"}")"
            [[ "$image_url" ]] && image_url="https://i.imgur.com/${image_url}.png"
        ;;
    esac

    printf "%s\n" "${image_url:-'[!] Image failed to upload'}"
}

scrot_args() {
    scrot="on"

    if [[ "$2" =~ \.(png|jpg|jpe|jpeg|gif)$ ]]; then
        scrot_name="${2##*/}"
        scrot_dir="${2/$scrot_name}"

    elif [[ -d "$2" ]]; then
        scrot_dir="$2"
    else
        scrot_dir="${PWD:+${PWD}/}"
    fi
}

scrot_program() {
    # Detect screenshot program.
    #
    # We first check to see if an X server is running before
    # falling back to OS specific screenshot tools.
    if [[ -n "$DISPLAY" ]]; then
        if [[ "$scrot_cmd" != "auto" ]] && type -p "${scrot_cmd%% *}" >/dev/null; then
            IFS=" " read -ra scrot_program <<< "$scrot_cmd"

        elif type -p maim >/dev/null; then
            scrot_program=(maim)

        elif type -p scrot >/dev/null; then
            scrot_program=(scrot)

        elif type -p import >/dev/null && [[ "$os" != "Mac OS X" ]]; then
            scrot_program=(import -window root)

        elif type -p imlib2_grab >/dev/null; then
            scrot_program=(imlib2_grab)

        elif type -p gnome-screenshot >/dev/null; then
            scrot_program=(gnome-screenshot -f)

        else
            err "Scrot: No screen capture tool found."
            return
        fi
    else
        case "$os" in
            "Mac OS X") scrot_program=(screencapture -S) ;;
            "Haiku") scrot_program=(screenshot -s) ;;
        esac
    fi

    # Print a message letting the user know we're taking
    # a screenshot.
    printf "%s\r" "Taking scrot"
    sleep .2
    printf "%s\r" "Taking scrot."
    sleep .2
    printf "%s\r" "Taking scrot.."
    sleep .2
    printf "%s\r" "Taking scrot..."

    # Take the scrot.
    "${scrot_program[@]}" "$1"

    err "Scrot: Screen captured using ${scrot_program[0]}"
}

# TEXT FORMATTING

info() {
    # Save subtitle value.
    [[ "$2" ]] && subtitle="$1"

    # Make sure that $prin is unset.
    unset -v prin

    # Call the function.
    "get_${2:-$1}"

    # If the get_func function called 'prin' directly, stop here.
    [[ "$prin" ]] && return

    # Update the variable.
    output="$(trim "${!2:-${!1}}")"

    if [[ "$2" && "${output// }" ]]; then
        prin "$1" "$output"

    elif [[ "${output// }" ]]; then
        prin "$output"

    else
        err "Info: Couldn't detect ${1}."
    fi

    unset -v subtitle
}

prin() {
    # If $2 doesn't exist we format $1 as info.
    if [[ "$(trim "$1")" && "$2" ]]; then
        string="${1}${2:+: $2}"
    else
        string="${2:-$1}"
        local subtitle_color="$info_color"
    fi
    string="$(trim "${string//$'\e[0m'}")"

    # Log length if it doesn't exist.
    if [[ -z "$length" ]]; then
        length="$(strip_sequences "$string")"
        length="${#length}"
    fi

    # Format the output.
    string="${string/:/${reset}${colon_color}:${info_color}}"
    string="${subtitle_color}${bold}${string}"

    # Print the info.
    printf "%b\n" "${text_padding:+\e[${text_padding}C}${zws}${string}${reset} "

    # Calculate info height.
    ((++info_height))

    # Log that prin was used.
    prin=1
}

get_underline() {
    if [[ "$underline_enabled" == "on" ]]; then
        printf -v underline "%${length}s"
        printf "%b%b\n" "${text_padding:+\e[${text_padding}C}${zws}${underline_color}" \
                        "${underline// /$underline_char}${reset} "
        unset -v length
    fi
    prin=1
}

get_line_break() {
    # Print it directly.
    printf "%b\n" "${zws}"

    # Calculate info height.
    ((++info_height))
    line_breaks+="\n"

    # Tell info() that we printed manually.
    prin=1
}

get_bold() {
    case "$ascii_bold" in
        "on") ascii_bold="\e[1m" ;;
        "off") ascii_bold="" ;;
    esac

    case "$bold" in
        "on") bold="\e[1m" ;;
        "off") bold="" ;;
    esac
}

trim() {
    set -f
    # shellcheck disable=2048,2086
    set -- $*
    printf "%s\\n" "${*//[[:space:]]/ }"
    set +f
}

trim_quotes() {
    trim_output="${1//\'}"
    trim_output="${trim_output//\"}"
    printf "%s" "$trim_output"
}

strip_sequences() {
    strip="${1//$'\e['3[0-9]m}"
    strip="${strip//$'\e['38\;5\;[0-9]m}"
    strip="${strip//$'\e['38\;5\;[0-9][0-9]m}"
    strip="${strip//$'\e['38\;5\;[0-9][0-9][0-9]m}"

    printf "%s\n" "$strip"
}

uppercase() {
    if ((bash_version >= 4)); then
        printf "%s" "${1^}"
    else
        printf "%s" "$1"
    fi
}

# COLORS

get_distro_colors() {
    # This function sets the text colors according
    # to your OS/Distro's logo colors.
    #
    # $ascii_distro is the same as $distro.
    case "$ascii_distro" in
        "AIX"*)
            set_colors 2 7
            ascii_file="aix"
        ;;

        "alpine_small")
            set_colors 4 7
            ascii_file="alpine_small"
        ;;

        "Alpine"*)
            set_colors 4 5 7 6
            ascii_file="alpine"
        ;;

        "Amazon"*)
            set_colors 3 7
            ascii_file="amazon"
        ;;

        "Anarchy"*)
            set_colors 7 4
            ascii_file="anarchy"
        ;;

        "Android"*)
            set_colors 2 7
            ascii_file="android"
            ascii_length_force=19
        ;;

        "Antergos"*)
            set_colors 4 6
            ascii_file="antergos"
        ;;

        "antiX"*)
            set_colors 1 7 3
            ascii_file="antix"
        ;;

        "AOSC"*)
            set_colors 4 7 1
            ascii_file="aosc"
        ;;

        "Apricity"*)
            set_colors 4 7 1
            ascii_file="apricity"
        ;;

        "arch_small")
            set_colors 6 7 1
            ascii_file="arch_small"
        ;;

        "arch_old")
            set_colors 6 7 1
            ascii_file="arch_old"
        ;;

        "ArchBox"*)
            set_colors 2 7 1
            ascii_file="archbox"
        ;;

        "ARCHlabs"*)
            set_colors 6 6 7 1
            ascii_file="archlabs"
        ;;

        *"XFerience"*)
            set_colors 6 6 7 1
            ascii_file="arch_xferience"
        ;;

        "ArchMerge"*)
            set_colors 6 6 7 1
            ascii_file="archmerge"
        ;;

        "Arch"*)
            set_colors 6 6 7 1
            ascii_file="arch"
        ;;

        "Artix"*)
            set_colors 6 4 2 7
            ascii_file="artix"
        ;;

        "Arya"*)
            set_colors 2 1
            ascii_file="arya"
        ;;

        "Bitrig"*)
            set_colors 2 7
            ascii_file="bitrig"
        ;;

        "BLAG"*)
            set_colors 5 7
            ascii_file="blag"
        ;;

        "BlankOn"*)
            set_colors 1 7 3
            ascii_file="blankon"
        ;;

       "BSD")
            set_colors 1 7 4 3 6
            ascii_file="bsd"
        ;;

        "BunsenLabs"*)
            set_colors fg 7
            ascii_file="bunsenlabs"
        ;;

        "Calculate"*)
            set_colors 7 3
            ascii_file="calculate"
        ;;

        "CentOS"*)
            set_colors 3 2 4 5 7
            ascii_file="centos"
        ;;

        "Chakra"*)
            set_colors 4 5 7 6
            ascii_file="chakra"
        ;;

        "ChaletOS"*)
            set_colors 4 7 1
            ascii_file="chaletos"
        ;;

        "Chapeau"*)
            set_colors 2 7
            ascii_file="chapeau"
        ;;

        "Chrom"*)
            set_colors 2 1 3 4 7
            ascii_file="chrome"
        ;;

        "Clover"*)
            set_colors 2 6
            ascii_file="cloveros"
        ;;

        "Container Linux by CoreOS"*)
            set_colors 4 7 1
            ascii_file="coreos"
        ;;

        "crux_small")
            set_colors 4 5 7 6
            ascii_file="crux_small"
        ;;

        "CRUX"*)
            set_colors 4 5 7 6
            ascii_file="crux"
        ;;

        "debian_small")
            set_colors 1 7 3
            ascii_file="debian_small"
        ;;

        "Debian"*)
            set_colors 1 7 3
            ascii_file="debian"
        ;;

        "Deepin"*)
            set_colors 2 7
            ascii_file="deepin"
        ;;

        "DesaOS")
            set_colors 2 7
            ascii_file="desaos"
        ;;

        "Devuan"*)
            set_colors 5 7
            ascii_file="devuan"
        ;;

        "DracOS"*)
            set_colors 1 7 3
            ascii_file="dracos"
        ;;

        "dragonfly_old"*)
            set_colors 1 7 3
            ascii_file="dragonflybsd_old"
        ;;

        "dragonfly_small"*)
            set_colors 1 7 3
            ascii_file="dragonflybsd_small"
        ;;

        "DragonFly"*)
            set_colors 1 7 3
            ascii_file="dragonflybsd"
        ;;

        "Elementary"*)
            set_colors 4 7 1
            ascii_file="elementary"
        ;;

        "Endless"*)
            set_colors 1 7
            ascii_file="endless"
        ;;

        "Exherbo"*)
            set_colors 4 7 1
            ascii_file="exherbo"
        ;;

        "Fedora"* | "RFRemix"*)
            set_colors 4 7 1
            ascii_file="fedora"
        ;;

        "freebsd_small")
            set_colors 1 7 3
            ascii_file="freebsd_small"
        ;;

        "FreeBSD"*)
            set_colors 1 7 3
            ascii_file="freebsd"
        ;;

        "FreeMiNT"*)
            # Don't explicitly set colors since
            # TosWin2 doesn't reset well.
            ascii_file="gem"
        ;;

        "Frugalware"*)
            set_colors 4 7 1
            ascii_file="frugalware"
        ;;

        "Funtoo"*)
            set_colors 5 7
            ascii_file="funtoo"
        ;;

        "GalliumOS"*)
            set_colors 4 7 1
            ascii_file="galliumos"
        ;;

        "gentoo_small")
            set_colors 5 7
            ascii_file="gentoo_small"
        ;;

        "Gentoo"*)
            set_colors 5 7
            ascii_file="gentoo"
        ;;

        "gNewSense"*)
            set_colors 4 5 7 6
            ascii_file="gnewsense"
        ;;

        "GNU")
            set_colors fg 7
            ascii_file="gnu"
        ;;

        "GoboLinux"*)
            set_colors 5 4 6 2
            ascii_file="gobolinux"
        ;;

        "Grombyang"*)
            set_colors 4 2 1
            ascii_file="grombyang"
        ;;

        "GuixSD"*)
            set_colors 3 7 6 1 8
            ascii_file="guixsd"
        ;;

        "Haiku"*)
            set_colors 2 8
            ascii_file="haiku"
        ;;

        "Hyperbola"*)
            set_colors 8
            ascii_file="hyperbola"
        ;;

        "Kali"*)
            set_colors 4 8
            ascii_file="kali"
        ;;

        "KaOS"*)
            set_colors 4 7 1
            ascii_file="kaos"
        ;;

        "KDE"*)
            set_colors 2 7
            ascii_file="kde"
        ;;

        "Kogaion"*)
            set_colors 4 7 1
            ascii_file="kogaion"
        ;;

        "Korora"*)
            set_colors 4 7 1
            ascii_file="korora"
        ;;

        "KSLinux"*)
            set_colors 4 7 1
            ascii_file="kslinux"
        ;;

        "Kubuntu"*)
            set_colors 4 7 1
            ascii_file="kubuntu"
        ;;

        "LEDE"*)
            set_colors 4 7 1
            ascii_file="lede"
        ;;

        "Linux")
            set_colors fg 8 3
            ascii_file="linux"
        ;;

        "LMDE"*)
            set_colors 2 7
            ascii_file="lmde"
        ;;

        "Lubuntu"*)
            set_colors 4 7 1
            ascii_file="lubuntu"
        ;;

        "Lunar"*)
            set_colors 4 7 3
            ascii_file="lunar"
        ;;

        "mac"*"_small")
            set_colors 2 3 1 5 4
            ascii_file="mac_small"
        ;;

        "mac" | "Darwin")
            set_colors 2 3 1 1 5 4
            ascii_file="mac"
        ;;

        "Mageia"*)
            set_colors 6 7
            ascii_file="mageia"
        ;;

        "MagpieOS"*)
            set_colors 2 1 3 5
            ascii_file="magpieos"
        ;;

        "Manjaro"*)
            set_colors 2 7
            ascii_file="manjaro"
        ;;

        "Maui"*)
            set_colors 6 7
            ascii_file="maui"
        ;;

        "Mer"*)
            set_colors 4 7 1
            ascii_file="mer"
        ;;

        "Minix"*)
            set_colors 1 7 3
            ascii_file="minix"
        ;;

        "Linux Mint"* | "LinuxMint"*)
            set_colors 2 7
            ascii_file="mint"
        ;;

        "MX"*)
            set_colors 4 6 7
            ascii_file="mx"
        ;;

        "NetBSD"*)
            set_colors 5 7
            ascii_file="netbsd"
        ;;

        "Netrunner"*)
            set_colors 4 7 1
            ascii_file="netrunner"
        ;;

        "Nitrux"*)
            set_colors 4
            ascii_file="nitrux"
        ;;

        "nixos_small")
            set_colors 4 6
            ascii_file="nixos_small"
        ;;

        "NixOS"*)
            set_colors 4 6
            ascii_file="nixos"
        ;;

        "Nurunner"*)
            set_colors 4
            ascii_file="nurunner"
        ;;

        "NuTyX"*)
            set_colors 4 1
            ascii_file="nutyx"
        ;;

        "OBRevenge"*)
            set_colors 1 7 3
            ascii_file="obrevenge"
        ;;

        "openbsd_small")
            set_colors 3 7 6 1 8
            ascii_file="openbsd_small"
        ;;

        "OpenBSD"*)
            set_colors 3 7 6 1 8
            ascii_file="openbsd"
        ;;

        "OpenIndiana"*)
            set_colors 4 7 1
            ascii_file="openindiana"
        ;;

        "OpenMandriva"*)
            set_colors 4 3
            ascii_file="openmandriva"
        ;;

        "OpenWrt"*)
            set_colors 4 7 1
            ascii_file="openwrt"
        ;;

        "Open Source Media Center"* | "osmc")
            set_colors 4 7 1
            ascii_file="osmc"
        ;;

        "Oracle"*)
            set_colors 1 7 3
            ascii_file="oracle"
        ;;

        "PacBSD"*)
            set_colors 1 7 3
            ascii_file="pacbsd"
        ;;

        "Parabola"*)
            set_colors 5 7
            ascii_file="parabola"
        ;;

        "Pardus"*)
            set_colors 3 7 6 1 8
            ascii_file="pardus"
        ;;

        "Parrot"*)
            set_colors 6 7
            ascii_file="parrot"
        ;;

        "Parsix"*)
            set_colors 3 1 7 8
            ascii_file="parsix"
        ;;

        "PCBSD"* | "TrueOS"*)
            set_colors 1 7 3
            ascii_file="trueos"
        ;;

        "PCLinuxOS"*)
            set_colors 4 7 1
            ascii_file="pclinuxos"
        ;;

        "Peppermint"*)
            set_colors 1 7 3
            ascii_file="peppermint"
        ;;

        "Pop!_OS"*)
            set_colors 6 7
            ascii_file="pop_os"
        ;;

        "Porteus"*)
            set_colors 6 7
            ascii_file="porteus"
        ;;

        "PostMarketOS"*)
            set_colors 2 7
            ascii_file="postmarketos"
        ;;

        "Puppy"* | "Quirky Werewolf"* | "Precise Puppy"*)
            set_colors 4 7
            ascii_file="puppy"
        ;;

        "Qubes"*)
            set_colors 4 5 7 6
            ascii_file="qubes"
        ;;

        "Raspbian"*)
            set_colors 2 1
            ascii_file="raspbian"
        ;;

        "Red Star"* | "Redstar"*)
            set_colors 1 7 3
            ascii_file="redstar"
        ;;

        "Redhat"* | "Red Hat"* | "rhel"*)
            set_colors 1 7 3
            ascii_file="redhat"
        ;;

        "Refracted Devuan"*)
            set_colors 8 7
            ascii_file="refracta"
        ;;

        "Rosa"*)
            set_colors 4 7 1
            ascii_file="rosa"
        ;;

        "sabotage"*)
            set_colors 4 7 1
            ascii_file="sabotage"
        ;;

        "Sabayon"*)
            set_colors 4 7 1
            ascii_file="sabayon"
        ;;

        "SailfishOS"*)
            set_colors 4 5 7 6
            ascii_file="sailfishos"
        ;;

        "SalentOS"*)
            set_colors 2 1 3 7
            ascii_file="salentos"
        ;;

        "Scientific"*)
            set_colors 4 7 1
            ascii_file="scientific"
        ;;

        "Siduction"*)
            set_colors 4 4
            ascii_file="siduction"
        ;;

        "Slackware"*)
            set_colors 4 7 1
            ascii_file="slackware"
        ;;

        "SliTaz"*)
            set_colors 3 3
            ascii_file="slitaz"
        ;;

        "SmartOS"*)
            set_colors 6 7
            ascii_file="smartos"
        ;;

        "Solus"*)
            set_colors 4 7 1
            ascii_file="solus"
        ;;

        "Source Mage"*)
            set_colors 4 7 1
            ascii_file="source_mage"
        ;;

        "Sparky"*)
            set_colors 1 7
            ascii_file="sparky"
        ;;

        "SteamOS"*)
            set_colors 5 7
            ascii_file="steamos"
        ;;

        "SunOS" | "Solaris")
            set_colors 3 7
            ascii_file="solaris"
        ;;

        "openSUSE Tumbleweed"*)
            set_colors 2 7
            ascii_file="tumbleweed"
        ;;

        "openSUSE"* | "open SUSE"* | "SUSE"*)
            set_colors 2 7
            ascii_file="suse"
        ;;

        "SwagArch"*)
            set_colors 4 7 1
            ascii_file="swagarch"
        ;;

        "Tails"*)
            set_colors 5 7
            ascii_file="tails"
        ;;

        "Trisquel"*)
            set_colors 4 6
            ascii_file="trisquel"
        ;;

        "Ubuntu-Budgie"*)
            set_colors 4 7 1
            ascii_file="ubuntu-budgie"
        ;;

        "Ubuntu-GNOME"*)
            set_colors 4 5 7 6
            ascii_file="ubuntu-gnome"
        ;;

        "Ubuntu-MATE"*)
            set_colors 2 7
            ascii_file="ubuntu-mate"
        ;;

        "ubuntu_old")
            set_colors 1 7 3
            ascii_file="ubuntu_old"
        ;;

        "Ubuntu-Studio")
            set_colors 6 7
            ascii_file="ubuntu-studio"
        ;;

        "Ubuntu"*)
            set_colors 1 7 3
            ascii_file="ubuntu"
        ;;

        "void_small")
            set_colors 2 8
            ascii_file="void_small"
        ;;

        "Void"*)
            set_colors 2 8
            ascii_file="void"
        ;;

        *"[Windows 10]"* | *"on Windows 10"* | "Windows 8"* |\
        "Windows 10"* | "windows10" | "windows8" )
            set_colors 6 7
            ascii_file="windows10"
        ;;

        "Windows"*)
            set_colors 1 2 4 3
            ascii_file="windows"
        ;;

        "Xubuntu"*)
            set_colors 4 7 1
            ascii_file="xubuntu"
        ;;

        "Zorin"*)
            set_colors 4 6
            ascii_file="zorin"
        ;;

        *)
            case "$kernel_name" in
                *"BSD")
                    set_colors 1 7 4 3 6
                    ascii_file="bsd"
                ;;

                "Darwin")
                    set_colors 2 3 1 1 5 4
                    ascii_file="mac"
                ;;

                "GNU"*)
                    set_colors fg 7
                    ascii_file="gnu"
                ;;

                "Linux")
                    set_colors fg 8 3
                    ascii_file="linux"
                ;;

                "SunOS")
                    set_colors 3 7
                    ascii_file="solaris"
                ;;

                "IRIX"*)
                    set_colors 4 7
                    ascii_file="irix"
                ;;
            esac
        ;;
    esac

    # Overwrite distro colors if '$ascii_colors' doesn't
    # equal 'distro'.
    if [[ "${ascii_colors[0]}" != "distro" ]]; then
        color_text="off"
        set_colors "${ascii_colors[@]}"
    fi
}

set_colors() {
    c1="$(color "$1")${ascii_bold}"
    c2="$(color "$2")${ascii_bold}"
    c3="$(color "$3")${ascii_bold}"
    c4="$(color "$4")${ascii_bold}"
    c5="$(color "$5")${ascii_bold}"
    c6="$(color "$6")${ascii_bold}"

    [[ "$color_text" != "off" ]] && set_text_colors "$@"
}

set_text_colors() {
    if [[ "${colors[0]}" == "distro" ]]; then
        title_color="$(color "$1")"
        at_color="$reset"
        underline_color="$reset"
        subtitle_color="$(color "$2")"
        colon_color="$reset"
        info_color="$reset"

        # If the ascii art uses 8 as a color, make the text the fg.
        ((${1:-1} == 8)) && title_color="$reset"
        ((${2:-7} == 8)) && subtitle_color="$reset"

        # If the second color is white use the first for the subtitle.
        ((${2:-7} == 7)) && subtitle_color="$(color "$1")"
        ((${1:-1} == 7)) && title_color="$reset"
    else
        title_color="$(color "${colors[0]}")"
        at_color="$(color "${colors[1]}")"
        underline_color="$(color "${colors[2]}")"
        subtitle_color="$(color "${colors[3]}")"
        colon_color="$(color "${colors[4]}")"
        info_color="$(color "${colors[5]}")"
    fi

    # Bar colors.
    if [[ "$bar_color_elapsed" == "distro" ]]; then
        bar_color_elapsed="$(color fg)"
    else
        bar_color_elapsed="$(color "$bar_color_elapsed")"
    fi

    case "$bar_color_total $1" in
        "distro "[736]) bar_color_total="$(color "$1")" ;;
        "distro "[0-9]) bar_color_total="$(color "$2")" ;;
        *) bar_color_total="$(color "$bar_color_total")" ;;
    esac
}

color() {
    case "$1" in
        [0-6]) printf "%b" "${reset}\e[3${1}m" ;;
        7 | "fg") printf "%b" "\e[37m${reset}" ;;
        *) printf "%b" "\e[38;5;${1}m" ;;
    esac
}

# OTHER

stdout() {
    image_backend="off"
    unset subtitle_color
    unset colon_color
    unset info_color
    unset underline_color
    unset bold
    unset title_color
    unset at_color
    unset text_padding
    unset zws
    unset reset
    unset color_blocks
    unset get_line_break
}

err() {
    err+="$(color 1)[!]\e[0m $1\n"
}

get_full_path() {
    # This function finds the absolute path from a relative one.
    # For example "Pictures/Wallpapers" --> "/home/dylan/Pictures/Wallpapers"

    # If the file exists in the current directory, stop here.
    [[ -f "${PWD}/${1/*\/}" ]] && { printf "%s\n" "${PWD}/${1/*\/}"; return; }

    if ! cd "${1%/*}"; then
        err "Error: Directory '${1%/*}' doesn't exist or is inaccessible"
        err "       Check that the directory exists or try another directory."
        exit 1
    fi

    local full_dir="${1##*/}"

    # Iterate down a (possible) chain of symlinks.
    while [[ -L "$full_dir" ]]; do
        full_dir="$(readlink "$full_dir")"
        cd "${full_dir%/*}" || exit
        full_dir="${full_dir##*/}"
    done

    # Final directory.
    full_dir="$(pwd -P)/${1/*\/}"

    [[ -e "$full_dir" ]] && printf "%s\n" "$full_dir"
}

get_default_config() {
    default_config="/dev/null"
    if [[ -f "CONFDIR/config.conf" ]]; then
        default_config="CONFDIR/config.conf"

    else
        [[ -z "$script_dir" ]] && script_dir="$(get_full_path "$0")"
        default_config="${script_dir%/*}/config/config.conf"
    fi

    default_config="/dev/null"
    if source "$default_config"; then
        err "Config: Sourced default config. (${default_config})"
    else
        err "Config: Default config not found, continuing..."
    fi
}

get_user_config() {
    # Check $config_file.
    config_file="/dev/null"
    if [[ -f "$config_file" ]]; then
        source "$config_file"
        err "Config: Sourced user config.    (${config_file})"
        old_options
        return
    fi
    mkdir -p "${XDG_CONFIG_HOME}/neofetch/"

    # Check ${XDG_CONFIG_HOME}/neofetch and create the
    # dir/files if they don't exist.
    if [[ -f "${XDG_CONFIG_HOME}/neofetch/config" ]]; then
        config_file="${XDG_CONFIG_HOME}/neofetch/config"

    elif [[ -f "${XDG_CONFIG_HOME}/neofetch/config.conf" ]]; then
        config_file="${XDG_CONFIG_HOME}/neofetch/config.conf"

    elif [[ -f "CONFDIR/config.conf" ]]; then
        #cp "CONFDIR/config.conf" "${XDG_CONFIG_HOME}/neofetch"
        config_file="${XDG_CONFIG_HOME}/neofetch/config.conf"

    else
        [[ -z "$script_dir" ]] && script_dir="$(get_full_path "$0")"

        #cp "${script_dir%/*}/config/config.conf" "${XDG_CONFIG_HOME}/neofetch"
        config_file="${XDG_CONFIG_HOME}/neofetch/config.conf"
    fi

    source "$config_file"
    err "Config: Sourced user config.    (${config_file})"
    old_options
}

bar() {
    # Get the values.
    elapsed="$(($1 * bar_length / $2))"

    # Create the bar with spaces.
    printf -v prog  "%${elapsed}s"
    printf -v total "%$((bar_length - elapsed))s"

    # Set the colors and swap the spaces for $bar_char_.
    bar+="${bar_color_elapsed}${prog// /${bar_char_elapsed}}"
    bar+="${bar_color_total}${total// /${bar_char_total}}"

    # Borders.
    [[ "$bar_border" == "on" ]] && \
        bar="$(color fg)[${bar}$(color fg)]"

    printf "%b" "${bar}${info_color}"
}

cache() {
    if [[ "$2" ]]; then
        mkdir -p "${cache_dir}/neofetch"
        printf "%s" "${1/*-}=\"$2\"" > "${cache_dir}/neofetch/${1/*-}"
    fi
}

get_cache_dir() {
    case "$os" in
        "Mac OS X") cache_dir="/Library/Caches" ;;
        *) cache_dir="/tmp" ;;
    esac
}

kde_config_dir() {
    # If the user is using KDE get the KDE
    # configuration directory.
    if [[ "$kde_config_dir" ]]; then
        return

    elif type -p kf5-config >/dev/null 2>&1; then
        kde_config_dir="$(kf5-config --path config)"

    elif type -p kde4-config >/dev/null 2>&1; then
        kde_config_dir="$(kde4-config --path config)"

    elif type -p kde-config >/dev/null 2>&1; then
        kde_config_dir="$(kde-config --path config)"

    elif [[ -d "${HOME}/.kde4" ]]; then
        kde_config_dir="${HOME}/.kde4/share/config"

    elif [[ -d "${HOME}/.kde3" ]]; then
        kde_config_dir="${HOME}/.kde3/share/config"
    fi

    kde_config_dir="${kde_config_dir/$'/:'*}"
}

get_term_padding() {
    # Terminal info.
    #
    # Parse terminal config files to get
    # info about padding. Due to how w3m-img
    # works padding around the terminal throws
    # off the cursor placement calculation in
    # specific terminals.
    #
    # Note: This issue only seems to affect
    # URxvt.
    ((term_run != 1)) && get_term

    case "$term" in
        "URxvt"*)
            border="$(xrdb -query | awk -F ':' '/^(URxvt|\*).internalBorder/ {printf $2; exit}')"
        ;;
    esac
}

dynamic_prompt() {
    case "$image_backend" in
        "ascii") printf "\n" ;;
        "off") return ;;
        *)
            get_term_padding
            lines="$(((border + height + yoffset) / font_height))"
            image_prompt="on"
        ;;
    esac

    # If the info is higher than the ascii/image place the prompt
    # based on the info height instead of the ascii/image height.
    if ((lines < info_height)); then
        [[ "$image_prompt" ]] && printf "\n"
        return
    else
        [[ "$image_prompt" ]] && printf "%b\n" "$line_breaks"
        lines="$((lines - info_height + 1))"
    fi

    # Set the prompt location.
    if ((lines > 1)); then
        case "$kernel_name" in
            "OpenBSD") tput cud "$lines" ;;
            *) printf "%b" "\e[${lines}B" ;;
        esac
    fi
}

old_functions() {
    # Deprecated functions.
    # Neofetch 2.0 changed the names of a few variables.
    # This function adds backwards compatibility for the
    # old variable names.
    if type printinfo >/dev/null 2>&1; then
        print_info() { printinfo ; }
        get_wmtheme() { get_wm_theme; wmtheme="$wm_theme"; }
        get_termfont() { get_term_font; termfont="$term_font"; }
        get_localip() { get_local_ip; localip="$local_ip"; }
        get_publicip() { get_public_ip; publicip="$public_ip"; }
        get_linebreak() { get_line_break; linebreak="$line_break"; }
    fi

    get_birthday() { get_install_date; birthday="$install_date"; }
}

old_options() {
    [[ -n "$osx_buildversion" ]] && \
        err "Config: \$osx_buildversion is deprecated, use \$distro_shorthand instead."
    [[ -n "$osx_codename" ]] && \
        err "Config: \$osx_codename is deprecated, use \$distro_shorthand instead."
    [[ "$cpu_cores" == "on" ]] && \
        err "Config: cpu_cores='on' is deprecated, use cpu_cores='logical|physical|off' instead."
    [[ -n "$image" ]] && \
        { err "Config: \$image is deprecated, use \$image_source instead."; image_source="$image"; }

    # All progress_ variables were changed to bar_.
    [[ -n "$progress_char" ]] && \
        err "Config: \$progress_char is deprecated, use \$bar_char_{elapsed,total} instead."
    [[ -n "$progress_border" ]] && \
        { err "Config: \$progress_border is deprecated, use \$bar_border instead."; \
          bar_border="$progress_border"; }
    [[ -n "$progress_length" ]] && \
        { err "Config: \$progress_length is deprecated, use \$bar_length instead."; \
          bar_length="$progress_length"; }
    [[ -n "$progress_color_elapsed" ]] && \
        { err "Config: \$progress_color_elapsed is deprecated, use \$bar_color_elapsed instead."; \
          bar_color_elapsed="$progress_color_elapsed"; }
    [[ -n "$progress_color_total" ]] && \
        { err "Config: \$progress_color_total is deprecated, use \$bar_color_total instead."; \
          bar_color_total="$progress_color_total"; }

    # All cpufreq values were changed in 3.0.
    [[ "$speed_type" == "current" ]] && \
        err "Config: speed_type='current' is deprecated, use speed_type='scaling_cur_freq' instead."
    [[ "$speed_type" == "min" ]] && \
        err "Config: speed_type='min' is deprecated, use speed_type='scaling_min_freq' instead."
    [[ "$speed_type" == "max" ]] && \
        err "Config: speed_type='max' is deprecated, use speed_type='scaling_max_freq' instead."
    [[ "$speed_type" == "bios" ]] && \
        err "Config: speed_type='bios' is deprecated, use speed_type='bios_limit' instead."

    # Ascii_logo_size was removed in 3.0.
    [[ "$ascii_logo_size" ]] && \
        err "Config: ascii_logo_size is deprecated, use ascii_distro='{distro}_small' instead."

    # $start and $end were replaced with ${block_range[@]} in 3.0.
    [[ "$start" && "$end" ]] && \
        { err "Config: \$start and \$end are deprecated, use block_range=(0 7) instead."; \
          block_range=("$start" "$end"); }

    # Fahrenheit support was added to CPU so the options were changed.
    [[ "$cpu_temp" == "on" ]] && \
        { err "Config: cpu_temp='on' is deprecated, use cpu_temp='C' or 'F' instead.";
          cpu_temp="C"; }

    # Birthday was renamed to Install Date in 3.0
    [[ -n "$birthday_time" ]] && \
        { err "Config: \$birthday_time is deprecated, use \3install_time instead."; \
          install_time="$birthday_time"; }

    # Scrot dir was removed in 3.1.0.
    [[ -n "$scrot_dir" ]] && scrot_dir=

    # cpu_shorthand was deprecated in 3.3.0
    [[ -n "$cpu_shorthand" ]] && \
        { err "Config: \$cpu_shorthand is deprecated, use \$cpu_brand, \$cpu_cores, and
            \$cpu_speed instead."; }
}

cache_uname() {
    # Cache the output of uname so we don't
    # have to spawn it multiple times.
    IFS=" " read -ra uname <<< "$(uname -sr)"

    kernel_name="${uname[0]}"
    kernel_version="${uname[1]}"
}

convert_time() {
    # Convert ls timestamp to 'Tue 06 Dec 2016 4:58 PM' format.
    year="$1"
    day="${3#0}"

    # Split time into hours/minutes.
    hour="${4/:*}"
    min="${4/${hour}}"

    # Get month. (Month code is used for day of week)
    # Due to different versions of 'ls', the month can be 1, 01 or Jan.
    case "$2" in
        1  | 01 | "Jan") month="Jan"; month_code=0 ;;
        2  | 02 | "Feb") month="Feb"; month_code=3 ;;
        3  | 03 | "Mar") month="Mar"; month_code=3 ;;
        4  | 04 | "Apr") month="Apr"; month_code=6 ;;
        5  | 05 | "May") month="May"; month_code=1 ;;
        6  | 06 | "Jun") month="Jun"; month_code=4 ;;
        7  | 07 | "Jul") month="Jul"; month_code=6 ;;
        8  | 08 | "Aug") month="Aug"; month_code=2 ;;
        9  | 09 | "Sep") month="Sep"; month_code=5 ;;
        10      | "Oct") month="Oct"; month_code=0 ;;
        11      | "Nov") month="Nov"; month_code=3 ;;
        12      | "Dec") month="Dec"; month_code=5 ;;
    esac

    # Get leap year.
    # Source: http://stackoverflow.com/questions/725098/leap-year-calculation
    [[ "$((year % 4))" == 0 && "$((year % 100))" != 0 || "$((year % 400))" == 0 ]] && \
    [[ "$month" =~ (Jan|Feb) ]] && \
        leap_code=1

    # Calculate day of week.
    # Source: http://blog.artofmemory.com/how-to-calculate-the-day-of-the-week-4203.html
    year_code="$((${year/??} + (${year/??} / 4) % 7))"
    week_day="$(((year_code + month_code + 6 + day - leap_code) % 7))"

    case "$week_day" in
        0) week_day="Sun" ;;
        1) week_day="Mon" ;;
        2) week_day="Tue" ;;
        3) week_day="Wed" ;;
        4) week_day="Thu" ;;
        5) week_day="Fri" ;;
        6) week_day="Sat" ;;
    esac

    # Convert 24 hour time to 12 hour time + AM/PM.
    case "$install_time_format" in
        "12h")
            case "$hour" in
                [0-9] | 0[0-9] | 1[0-1]) time="${hour/00/12}${min} AM" ;;
                *) time="$((hour - 12))${min} PM" ;;
            esac
        ;;
        *) time="$4" ;;
    esac

    # Toggle showing the time.
    [[ "$install_time" == "off" ]] && unset time

    # Print the install date.
    printf "%s" "$week_day $day $month $year $time"
}

get_ppid() {
    # Get parent process ID of PID.
    case "$os" in
        "Windows")
            ppid="$(ps -p "${1:-$PPID}" | awk '{printf $2}')"
            ppid="${ppid/'PPID'}"
        ;;

        "Linux")
            ppid="$(grep -i -F "PPid:" "/proc/${1:-$PPID}/status")"
            ppid="$(trim "${ppid/PPid:}")"
        ;;

        *)
            ppid="$(ps -p "${1:-$PPID}" -o ppid=)"
        ;;
    esac

    printf "%s" "$ppid"
}

get_process_name() {
    # Get PID name.
    case "$os" in
        "Windows")
            name="$(ps -p "${1:-$PPID}" | awk '{printf $8}')"
            name="${name/'COMMAND'}"
            name="${name/*\/}"
        ;;

        "Linux")
            name="$(< "/proc/${1:-$PPID}/comm")"
        ;;

        *)
            name="$(ps -p "${1:-$PPID}" -o comm=)"
        ;;
    esac

    printf "%s" "$name"
}

decode_url() {
    decode="${1//+/ }"
    printf "%b" "${decode//%/\\x}"
}

# FINISH UP

usage() { printf "%s" "\
Usage: neofetch --option \"value\" --option \"value\"

Neofetch is a CLI system information tool written in BASH. Neofetch
displays information about your system next to an image, your OS logo,
or any ASCII file of your choice.

NOTE: Every launch flag has a config option.

Options:

INFO:
    --disable infoname          Allows you to disable an info line from appearing
                                in the output.

                                NOTE: You can supply multiple args. eg. 'neofetch --disable cpu gpu'

    --os_arch on/off            Hide/Show OS architecture.
    --speed_type type           Change the type of cpu speed to display.
                                Possible values: current, min, max, bios,
                                scaling_current, scaling_min, scaling_max

                                NOTE: This only supports Linux with cpufreq.

    --speed_shorthand on/off    Whether or not to show decimals in CPU speed.

                                NOTE: This flag is not supported in systems with CPU speed less than
                                1 GHz.

    --cpu_brand on/off          Enable/Disable CPU brand in output.
    --cpu_cores type            Whether or not to display the number of CPU cores
                                Possible values: logical, physical, off

                                NOTE: 'physical' doesn't work on BSD.

    --cpu_speed on/off          Hide/Show cpu speed.
    --cpu_temp C/F/off          Hide/Show cpu temperature.

                                NOTE: This only works on Linux and BSD.

                                NOTE: For FreeBSD and NetBSD-based systems, you need to enable
                                coretemp kernel module. This only supports newer Intel processors.

    --distro_shorthand on/off   Shorten the output of distro (tiny, on, off)

                                NOTE: This option won't work in Windows (Cygwin)

    --kernel_shorthand on/off   Shorten the output of kernel

                                NOTE: This option won't work in BSDs (except PacBSD and PC-BSD)

    --uptime_shorthand on/off   Shorten the output of uptime (tiny, on, off)
    --refresh_rate on/off       Whether to display the refresh rate of each monitor
                                Unsupported on Windows
    --gpu_brand on/off          Enable/Disable GPU brand in output. (AMD/NVIDIA/Intel)
    --gpu_type type             Which GPU to display. (all, dedicated, integrated)

                                NOTE: This only supports Linux.

    --gtk_shorthand on/off      Shorten output of gtk theme/icons
    --gtk2 on/off               Enable/Disable gtk2 theme/font/icons output
    --gtk3 on/off               Enable/Disable gtk3 theme/font/icons output
    --shell_path on/off         Enable/Disable showing \$SHELL path
    --shell_version on/off      Enable/Disable showing \$SHELL version
    --disk_show value           Which disks to display.
                                Possible values: '/', '/dev/sdXX', '/path/to/mount point'

                                NOTE: Multiple values can be given. (--disk_show '/' '/dev/sdc1')

    --disk_subtitle type        What information to append to the Disk subtitle.
                                Takes: name, mount, dir

                                'name' shows the disk's name (sda1, sda2, etc)

                                'mount' shows the disk's mount point (/, /mnt/Local Disk, etc)

                                'dir' shows the basename of the disks's path. (/, Local Disk, etc)

    --ip_host url               URL to query for public IP
    --song_shorthand on/off     Print the Artist/Title on separate lines
    --music_player player-name  Manually specify a player to use.
                                Available values are listed in the config file
    --install_time on/off       Enable/Disable showing the time in Install Date output.
    --install_time_format 12h/24h
                                Set time format in Install Date to be 12 hour or 24 hour.

TEXT FORMATTING:
    --colors x x x x x x        Changes the text colors in this order:
                                title, @, underline, subtitle, colon, info
    --underline on/off          Enable/Disable the underline.
    --underline_char char       Character to use when underlining title
    --bold on/off               Enable/Disable bold text

COLOR BLOCKS:
    --color_blocks on/off       Enable/Disable the color blocks
    --block_width num           Width of color blocks in spaces
    --block_height num          Height of color blocks in lines
    --block_range num num       Range of colors to print as blocks

BARS:
    --bar_char 'elapsed char' 'total char'
                                Characters to use when drawing bars.
    --bar_border on/off         Whether or not to surround the bar with '[]'
    --bar_length num            Length in spaces to make the bars.
    --bar_colors num num        Colors to make the bar.
                                Set in this order: elapsed, total
    --cpu_display mode          Bar mode.
                                Possible values: bar, infobar, barinfo, off
    --memory_display mode       Bar mode.
                                Possible values: bar, infobar, barinfo, off
    --battery_display mode      Bar mode.
                                Possible values: bar, infobar, barinfo, off
    --disk_display mode         Bar mode.
                                Possible values: bar, infobar, barinfo, off

IMAGE BACKEND:
    --backend backend           Which image backend to use.
                                Possible values: 'ascii', 'caca', 'catimg', 'jp2a', 'iterm2', 'off',
                                'sixel', 'tycat', 'w3m'
    --source source             Which image or ascii file to use.
                                Possible values: 'auto', 'ascii', 'wallpaper', '/path/to/img',
                                '/path/to/ascii', '/path/to/dir/'
    --ascii source              Shortcut to use 'ascii' backend.
    --caca source               Shortcut to use 'caca' backend.
    --catimg source             Shortcut to use 'catimg' backend.
    --iterm2 source             Shortcut to use 'iterm2' backend.
    --jp2a source               Shortcut to use 'jp2a' backend.
    --pixterm source            Shortcut to use 'pixterm' backend.
    --sixel source              Shortcut to use 'sixel' backend.
    --termpix source            Shortcut to use 'termpix' backend.
    --tycat source              Shortcut to use 'tycat' backend.
    --w3m source                Shortcut to use 'w3m' backend.
    --off                       Shortcut to use 'off' backend.

    NOTE: 'source; can be any of the following: 'auto', 'ascii', 'wallpaper', '/path/to/img',
    '/path/to/ascii', '/path/to/dir/'

ASCII:
    --ascii_colors x x x x x x  Colors to print the ascii art
    --ascii_distro distro       Which Distro's ascii art to print

                                NOTE: Arch and Ubuntu have 'old' logo variants.

                                NOTE: Use 'arch_old' or 'ubuntu_old' to use the old logos.

                                NOTE: Ubuntu has flavor variants.

                                NOTE: Change this to 'Lubuntu', 'Xubuntu', 'Ubuntu-GNOME',
                                'Ubuntu-Studio' or 'Ubuntu-Budgie' to use the flavors.

                                NOTE: Alpine, Arch, CRUX, Debian, Gentoo, FreeBSD, Mac, NixOS,
                                OpenBSD, and Void have a smaller logo variant.

                                NOTE: Use '{distro name}_small' to use the small variants.

    --ascii_bold on/off         Whether or not to bold the ascii logo.
    -L, --logo                  Hide the info text and only show the ascii logo.

                                Possible values: bar, infobar, barinfo, off

IMAGE:
    --loop                      Redraw the image constantly until Ctrl+C is used. This fixes issues
                                in some terminals emulators when using image mode.
    --size 00px | --size 00%    How to size the image.
                                Possible values: auto, 00px, 00%, none
    --crop_mode mode            Which crop mode to use
                                Takes the values: normal, fit, fill
    --crop_offset value         Change the crop offset for normal mode.
                                Possible values: northwest, north, northeast,
                                west, center, east, southwest, south, southeast

    --xoffset px                How close the image will be to the left edge of the
                                window. This only works with w3m.
    --yoffset px                How close the image will be to the top edge of the
                                window. This only works with w3m.
    --bg_color color            Background color to display behind transparent image.
                                This only works with w3m.
    --gap num                   Gap between image and text.

                                NOTE: --gap can take a negative value which will move the text
                                closer to the left side.

    --clean                     Delete cached files and thumbnails.

SCREENSHOT:
    -s, --scrot /path/to/img    Take a screenshot, if path is left empty the screen-
                                shot function will use \$scrot_dir and \$scrot_name.
    -su, --upload /path/to/img  Same as --scrot but uploads the scrot to a website.
    --image_host imgur/teknik   Website to upload scrots to.
    --scrot_cmd cmd             Screenshot program to launch

OTHER:
    --config /path/to/config    Specify a path to a custom config file
    --config none               Launch the script without a config file
    --stdout                    Turn off all colors and disables any ASCII/image backend.
    --help                      Print this text and exit
    --version                   Show neofetch version
    -v                          Display error messages.
    -vv                         Display a verbose log for error reporting.

DEVELOPER:
    --gen-man                   Generate a manpage for Neofetch in your PWD. (Requires GNU help2man)


Report bugs to https://github.com/dylanaraps/neofetch/issues

"
exit 1
}

get_args() {
    # Check the commandline flags early for '--config'.
    [[ "$*" != *--config* ]] && get_user_config

    while [[ "$1" ]]; do
        case "$1" in
            # Info
            "--os_arch") os_arch="$2" ;;
            "--cpu_cores") cpu_cores="$2" ;;
            "--cpu_speed") cpu_speed="$2" ;;
            "--speed_type") speed_type="$2" ;;
            "--speed_shorthand") speed_shorthand="$2" ;;
            "--distro_shorthand") distro_shorthand="$2" ;;
            "--kernel_shorthand") kernel_shorthand="$2" ;;
            "--uptime_shorthand") uptime_shorthand="$2" ;;
            "--cpu_brand") cpu_brand="$2" ;;
            "--gpu_brand") gpu_brand="$2" ;;
            "--gpu_type") gpu_type="$2" ;;
            "--refresh_rate") refresh_rate="$2" ;;
            "--gtk_shorthand") gtk_shorthand="$2" ;;
            "--gtk2") gtk2="$2" ;;
            "--gtk3") gtk3="$2" ;;
            "--shell_path") shell_path="$2" ;;
            "--shell_version") shell_version="$2" ;;
            "--ip_host") public_ip_host="$2" ;;
            "--song_shorthand") song_shorthand="$2" ;;
            "--music_player") music_player="$2" ;;
            "--install_time") install_time="$2" ;;
            "--install_time_format") install_time_format="$2" ;;
            "--cpu_temp")
                cpu_temp="$2"
                [[ "$cpu_temp" == "on" ]] && cpu_temp="C"
            ;;

            "--disk_subtitle") disk_subtitle="$2" ;;
            "--disk_show")
                unset disk_show
                for arg in "$@"; do
                    case "$arg" in
                        "--disk_show") ;;
                        "-"*) break ;;
                        *) disk_show+=("$arg") ;;
                    esac
                done
            ;;

            "--disable")
                for func in "$@"; do
                    case "$func" in
                        "--disable") continue ;;
                        "-"*) break ;;
                        *)
                            ((bash_version >= 4)) && func="${func,,}"
                            unset -f "get_$func"
                        ;;
                    esac
                done
            ;;

            # Text Colors
            "--colors")
                unset colors
                for arg in "$2" "$3" "$4" "$5" "$6" "$7"; do
                    case "$arg" in
                        "-"*) break ;;
                        *) colors+=("$arg") ;;
                    esac
                done
                colors+=(7 7 7 7 7 7)
            ;;

            # Text Formatting
            "--underline") underline_enabled="$2" ;;
            "--underline_char") underline_char="$2" ;;
            "--bold") bold="$2" ;;

            # Color Blocks
            "--color_blocks") color_blocks="$2" ;;
            "--block_range") block_range=("$2" "$3") ;;
            "--block_width") block_width="$2" ;;
            "--block_height") block_height="$2" ;;

            # Bars
            "--bar_char")
                bar_char_elapsed="$2"
                bar_char_total="$3"
            ;;

            "--bar_border") bar_border="$2" ;;
            "--bar_length") bar_length="$2" ;;
            "--bar_colors")
                bar_color_elapsed="$2"
                bar_color_total="$3"
            ;;

            "--cpu_display") cpu_display="$2" ;;
            "--memory_display") memory_display="$2" ;;
            "--battery_display") battery_display="$2" ;;
            "--disk_display") disk_display="$2" ;;

            # Image backend
            "--backend") image_backend="$2" ;;
            "--source") image_source="$2" ;;
            "--ascii" | "--caca" | "--catimg" | "--jp2a" | "--iterm2" | "--off" | "--pixterm" |\
            "--sixel" | "--termpix" | "--tycat" | "--w3m")
                image_backend="${1/--}"
                case "$2" in
                    "-"* | "") ;;
                    *) image_source="$2" ;;
                esac
            ;;

            # Image options
            "--loop") image_loop="on" ;;
            "--image_size" | "--size") image_size="$2" ;;
            "--crop_mode") crop_mode="$2" ;;
            "--crop_offset") crop_offset="$2" ;;
            "--xoffset") xoffset="$2" ;;
            "--yoffset") yoffset="$2" ;;
            "--background_color" | "--bg_color") background_color="$2" ;;
            "--gap") gap="$2" ;;
            "--clean")
                [[ -d "$thumbnail_dir" ]] && rm -rf "$thumbnail_dir"
                rm -rf "/Library/Caches/neofetch/"
                rm -rf "/tmp/neofetch/"
                exit
            ;;

            "--ascii_colors")
                unset ascii_colors
                for arg in "$2" "$3" "$4" "$5" "$6" "$7"; do
                    case "$arg" in
                        "-"*) break ;;
                        *) ascii_colors+=("$arg")
                    esac
                done
                ascii_colors+=(7 7 7 7 7 7)
            ;;

            "--ascii_distro")
                image_backend="ascii"
                ascii_distro="$2"
                case "$2" in "-"* | "") ascii_distro="$distro" ;; esac
            ;;

            "--ascii_bold") ascii_bold="$2" ;;
            "--logo" | "-L")
                image_backend="ascii"
                print_info() { info line_break; }
            ;;

            # Screenshot
            "--scrot" | "-s")
                scrot_args "$@"
            ;;
            "--upload" | "-su")
                scrot_upload="on"
                scrot_args "$@"
            ;;

            "--image_host") image_host="$2" ;;
            "--scrot_cmd") scrot_cmd="$2" ;;

            # Other
            "--config")
                case "$2" in
                    "none" | "off" | "") ;;
                    *)
                        #config_file="$(get_full_path "$2")"
                        config_file=/dev/null
                        get_user_config
                    ;;
                esac
            ;;
            "--stdout") stdout="on" ;;
            "-v") verbose="on" ;;
            "-vv") set -x; verbose="on" ;;
            "--help") usage ;;
            "--version")
                printf "%s\\n" "Neofetch $version"
                exit 1
            ;;
            "--gen-man")
                help2man -n "A fast, highly customizable system info script" \
                          -N ./neofetch -o neofetch.1
                exit 1
            ;;
        esac

        shift
    done
}

main() {
    cache_uname
    get_os
    get_default_config
    get_args "$@"
    [[ "$verbose" != "on" ]] && exec 2>/dev/null
    get_distro
    get_bold
    get_distro_colors
    [[ "$stdout" == "on" ]] && stdout

    # Minix doesn't support these sequences.
    if [[ "$TERM" != "minix" && "$stdout" != "on" ]]; then
        # If the script exits for any reason, unhide the cursor.
        trap 'printf "\e[?25h\e[?7h"' EXIT

        # Hide the cursor and disable line wrap.
        printf "\e[?25l\e[?7l"
    fi

    image_backend
    old_functions
    get_cache_dir
    print_info
    dynamic_prompt

    # w3m-img: Draw the image a second time to fix
    # rendering issues in specific terminal emulators.
    [[ "$image_backend" == *w3m* ]] && display_image

    # Take a screenshot.
    [[ "$scrot" == "on" ]] && take_scrot

    # Add neofetch info to verbose output.
    err "Neofetch command: $0 $*"
    err "Neofetch version: $version"
    err "Neofetch config:  $config_version"

    # Show error messages.
    [[ "$verbose" == "on" ]] && printf "%b" "$err" >&2

    # If `--loop` was used, constantly redraw the image.
    while [[ "$image_loop" == "on" && "$image_backend" == "w3m" ]]; do display_image; sleep 1s; done

    return 0
}

main "$@"
