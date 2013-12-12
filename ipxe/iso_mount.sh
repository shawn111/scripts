#!/bin/sh

PREREQ=""

prereqs()
{
       echo "$PREREQ"
}

case $1 in
# get pre-requisites
    prereqs)
           prereqs
           exit 0
           ;;
esac

. /scripts/casper-functions
. /scripts/lupin-helpers

iso_path=
for x in $(cat /proc/cmdline); do
    case ${x} in
        iso-scan/filename=*)
            iso_path=${x#iso-scan/filename=}
            ;;
#### Add fetch patch +
        fetch=*.iso)
            FETCH=${x#fetch=}
            FILE="$(basename ${FETCH})"
            configure_networking
        	if wget "${FETCH}" -O "${FILE}"; then
                mkdir -p /root/isodevice
                mount -t iso9660 ${FILE} /root/isodevice

                echo "LIVEMEDIA=${FILE}" >> /conf/param.conf
                echo "LIVEMEDIA_OFFSET=0" >> /conf/param.conf
            else
                panic "Could not fetch ${FETCH}"
            fi
            ;;
        fish=*)
            FETCH=${x#fish=}
            FILE="$(basename ${FETCH})"

            configure_networking
			mkdir -p /root/overlayer
            echo wget "${FETCH}" -O "${FILE}"
    		if wget "${FETCH}" -O "${FILE}"; then

                cp ${FILE} /root/overlayer
                tar zxvf ${FILE} -C /root/overlayer
                mount -t aufs -o dirs=/root/isodevice:/root/overlayer aufs /cdrom
                echo "LIVEMEDIA=cdrom" >> /conf/param.conf
            fi
            ;;
### Add fetch patch -
    esac
done
if [ "$iso_path" ]; then
    if find_path "${iso_path}" /isodevice rw; then
        echo "LIVEMEDIA=${FOUNDPATH}" >> /conf/param.conf
        if [ -f "${FOUNDPATH}" ]; then
            echo "LIVEMEDIA_OFFSET=0" >> /conf/param.conf
        fi
    else
        panic "
Could not find the ISO $iso_path
This could also happen if the file system is not clean because of an operating
system crash, an interrupted boot process, an improper shutdown, or unplugging
of a removable device without first unmounting or ejecting it.  To fix this,
simply reboot into Windows, let it fully start, log in, run 'chkdsk /r', then
gracefully shut down and reboot back into Windows. After this you should be
able to reboot again and resume the installation.
"
    fi
fi
