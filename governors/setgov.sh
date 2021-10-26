#usr/bin/env 
#Date Created: 26/10/2021
#Made By Joel A Okanta

RELEASED="Release Date: 2021-10-26"

GOVDIR="/sys/devices/system/cpu/cpu*/cpufreq/scaling_governor"

AVAILGOVS=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors)

while [[ 1 ]]; do
	echo "Please select from the following governors:"
	echo "${AVAILGOVS}"

	read GOV
	# use grep match input from substring of AVAILGOVS
	if grep -q "$GOV" <<< "${AVAILGOVS}"; then 
		break
	fi

done

echo -n "Changing the scaling_governor for CPU 0 1 2 3 to: "

echo "${GOV}" | sudo tee ${GOVDIR}
echo "Success your new Scaling Governor is ${GOV}"
