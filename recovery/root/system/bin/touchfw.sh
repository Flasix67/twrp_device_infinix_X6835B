#!/system/bin/sh
# Load Chipone ICNL9916 touch firmware by hand in recovery.
# The driver's own request_firmware() fails here, but update_from_file works.

DEV=/sys/bus/spi/devices/spi2.0/cts_firmware
FW=/vendor/firmware/chipone_ts_fw.bin

# wait for the driver to create the sysfs node (max ~60 s)
i=0
while [ ! -e "$DEV/update_from_file" ] && [ $i -lt 60 ]; do
  sleep 1
  i=$((i + 1))
done

# let the driver finish its own (failing) attempt first
sleep 5

# up to 5 tries; stop as soon as the firmware version is not 0000
n=0
while [ $n -lt 5 ]; do
  echo "$FW" > "$DEV/update_from_file"
  sleep 3
  if ! cat "$DEV/curr_version" 2>/dev/null | grep -q "0000"; then
    break
  fi
  n=$((n + 1))
done