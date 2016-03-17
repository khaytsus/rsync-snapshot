#!/bin/bash
# ----------------------------------------------------------------------
# mikes handy rotating-filesystem-snapshot utility: daily snapshots
# ----------------------------------------------------------------------
# intended to be run daily as a cron job when hourly.0 contains the
# midnight (or whenever you want) snapshot; say, 13:00 for 4-hour snapshots.
# ----------------------------------------------------------------------

unset PATH

# ------------- system commands used by this script --------------------
ID=/usr/bin/id;
ECHO=/bin/echo;

MOUNT=/bin/mount;
RM=/bin/rm;
MV=/bin/mv;
CP=/bin/cp;

# ------------- file locations -----------------------------------------

MOUNT_DEVICE=/dev/sda1;
REMOUNT=0;
SOURCE=/;
SNAPSHOT_RW=/media8/snapshot;

# ------------- the script itself --------------------------------------

# make sure we're running as root
if (( `$ID -u` != 0 )); then { $ECHO "Sorry, must be root.  Exiting..."; exit; } fi

if [ -d $SNAPSHOT_RW ]; then
        $ECHO "$SNAPSHOT_RW folder exists..";
else
        $ECHO "$SNAPSHOT_RW does not exist..  Wrong drive?";
        exit;
fi  

# attempt to remount the RW mount point as RW; else abort
if (( $REMOUNT == 1 )); then
	$MOUNT -o remount,rw $MOUNT_DEVICE $SNAPSHOT_RW ;
	if (( $? )); then
	{
		$ECHO "snapshot: could not remount $SNAPSHOT_RW readwrite";
		exit;
	}
	fi;
fi;

# step 1: delete the oldest snapshot, if it exists:
if [ -d $SNAPSHOT_RW/daily.5 ] ; then			\
$RM -rf $SNAPSHOT_RW/daily.5 ;				\
fi ;

# step 2: shift the middle snapshots(s) back by one, if they exist
if [ -d $SNAPSHOT_RW/daily.4 ] ; then			\
$MV $SNAPSHOT_RW/daily.4 $SNAPSHOT_RW/daily.5 ;	\
fi;
if [ -d $SNAPSHOT_RW/daily.3 ] ; then			\
$MV $SNAPSHOT_RW/daily.3 $SNAPSHOT_RW/daily.4 ;	\
fi;
if [ -d $SNAPSHOT_RW/daily.2 ] ; then			\
$MV $SNAPSHOT_RW/daily.2 $SNAPSHOT_RW/daily.3 ;	\
fi;
if [ -d $SNAPSHOT_RW/daily.1 ] ; then			\
$MV $SNAPSHOT_RW/daily.1 $SNAPSHOT_RW/daily.2 ;	\
fi;
if [ -d $SNAPSHOT_RW/daily.0 ] ; then			\
$MV $SNAPSHOT_RW/daily.0 $SNAPSHOT_RW/daily.1;	\
fi;

# step 3: make a hard-link-only (except for dirs) copy of
# hourly.0, assuming that exists, into daily.0
if [ -d $SNAPSHOT_RW/hourly.0 ] ; then			\
$CP -al $SNAPSHOT_RW/hourly.0 $SNAPSHOT_RW/daily.0 ;	\
fi;

# note: do *not* update the mtime of daily.0; it will reflect
# when hourly.0 was made, which should be correct.

# now remount the RW snapshot mountpoint as readonly

if (( $REMOUNT == 1 )); then
	$MOUNT -o remount,ro $MOUNT_DEVICE $SNAPSHOT_RW ;
	if (( $? )); then
	{
		$ECHO "snapshot: could not remount $SNAPSHOT_RW readonly";
		exit;
	} fi;
fi;
