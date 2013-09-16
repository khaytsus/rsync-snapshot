#!/bin/bash
# ----------------------------------------------------------------------
# mikes handy rotating-filesystem-snapshot utility
# ----------------------------------------------------------------------
# this needs to be a lot more general, but the basic idea is it makes
# rotating backup-snapshots of /home whenever called
# ----------------------------------------------------------------------

unset PATH	# suggestion from H. Milz: avoid accidental use of $PATH

# ------------- system commands used by this script --------------------
ID=/usr/bin/id;
ECHO=/bin/echo;

MOUNT=/bin/mount;
RM=/bin/rm;
MV=/bin/mv;
CP=/bin/cp;
TOUCH=/bin/touch;
MAIL=/bin/mail;

RSYNC=/usr/bin/rsync;


# ------------- file locations -----------------------------------------

MOUNT_DEVICE=/dev/sda;
REMOUNT=0;
SOURCE=/;
SNAPSHOT_RW=/media8/snapshot;
EXCLUDES=/etc/backup_exclude-psi;


# ------------- the script itself --------------------------------------

# make sure we're running as root
if (( `$ID -u` != 0 )); then { $ECHO "Sorry, must be root.  Exiting..."; exit; } fi

if [ -d $SNAPSHOT_RW ]; then
	$ECHO "$SNAPSHOT_RW folder exists..";
else
	$ECHO "$SNAPSHOT_RW does not exist..  Wrong drive?";
	echo $0: Unable to find ${SNAPSHOT_RW}, bailing... | $MAIL -s "Backup failed" wally@theblackmoor.net
	exit;
fi

# attempt to remount the RW mount point as RW if REMOUNT=1; else abort
if (( $REMOUNT == 1 )); then
	$MOUNT -o remount,rw $MOUNT_DEVICE $SNAPSHOT_RW ;
	if (( $? )); then
	{
		$ECHO "snapshot: could not remount $SNAPSHOT_RW readwrite";
		exit;
	}
	fi;
fi;

# rotating snapshots of /

# step 1: delete the oldest snapshot, if it exists:
if [ -d $SNAPSHOT_RW/hourly.3 ] ; then			\
$RM -rf $SNAPSHOT_RW/hourly.3 ;				\
fi ;

# step 2: shift the middle snapshots(s) back by one, if they exist
if [ -d $SNAPSHOT_RW/hourly.2 ] ; then			\
$MV $SNAPSHOT_RW/hourly.2 $SNAPSHOT_RW/hourly.3 ;	\
fi;
if [ -d $SNAPSHOT_RW/hourly.1 ] ; then			\
$MV $SNAPSHOT_RW/hourly.1 $SNAPSHOT_RW/hourly.2 ;	\
fi;

# step 3: make a hard-link-only (except for dirs) copy of the latest snapshot,
# if that exists
if [ -d $SNAPSHOT_RW/hourly.0 ] ; then			\
$CP -al $SNAPSHOT_RW/hourly.0 $SNAPSHOT_RW/hourly.1 ;	\
fi;

# step 3.5 if we're using --link-dest
#/bin/mkdir $SNAPSHOT_RW/hourly.1 ;

# step 4: rsync from the system into the latest snapshot (notice that
# rsync behaves like cp --remove-destination by default, so the destination
# is unlinked first.  If it were not so, this would copy over the other
# snapshot(s) too!

$RSYNC								\
	-va --delete --delete-excluded				\
	--exclude-from="$EXCLUDES"				\
	$SOURCE $SNAPSHOT_RW/hourly.0 ;
#	--link-dest=../hourly.1				\

# step 5: update the mtime of hourly.0 to reflect the snapshot time
$TOUCH $SNAPSHOT_RW/hourly.0 ;

# now remount the RW snapshot mountpoint as readonly

if (( $REMOUNT == 1 )); then
	$MOUNT -o remount,ro $MOUNT_DEVICE $SNAPSHOT_RW ;
	if (( $? )); then
	{
		$ECHO "snapshot: could not remount $SNAPSHOT_RW readonly";
		exit;
	} fi;
fi;
