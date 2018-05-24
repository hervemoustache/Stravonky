#!/bin/bash
#
#   stravonky.sh: a strava script for conky (or others) 
#   Copyright (C) 2018 Hervé Moustache
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.

#version 2018-05-24-08-20

##### TO DO #####
#- Read athlete_id/access_token/cliend_id/client_secret from a file
#- Obtain an access_token if needed
#- Verify if the athlete_id & the access_token are well linked
#- Get the names of the JSON variables in a proper way (curl | jq -> in array | 2 bash arrays ?)
#- Change time/distance/speed scale in a proper way
#- Chose which stats to show in a proper way

## Requires:
##          'jq' (sudo apt install jq);
##          API Keys from Strava (https://strava.com/settings/api)
##

#### Athlete id & access_token from Strava ###
#athlete_id as a number, access_token as a sentence (with quotes'')
athlete_id=
access_token=

#########################################################################
connectiontest() {
    local -i i attempts=${1-0}
    for (( i=0; i < attempts || attempts == 0; i++ )); do
        if wget -O - 'http://ftp.debian.org/debian/README' &> /dev/null; then
            return 0
        fi
        if (( i == attempts - 1 )); then # if last attempt
            return 1
        fi
    done
}

placeholder() {
    if (( $1 == 1 )) &>/dev/null;then
        echo "No internet connection"
        echo "Strava information unavailable"
    else
        echo "No API key"
        echo "Strava information unavailable"
    fi
}


#### Scale to show ####
#/!\ not finished yet. Do not convert, only change few names print, the other have to be changed manually (watch below)
scalet="h"

if [[ $metric == metric ]] &>/dev/null;then
    scaleD="m"
    scaleV="m/s"
else
    scaleT="miles"
    scaleV="mph"
fi


#
if [[ -z "$access_token" ]] || [[ -z "$athlete_id" ]] &>/dev/null;then
    placeholder 0 && exit 1
else
    connectiontest 10

    
    if (( $? == 0 )) &>/dev/null;then
        

        # get json data from strava:
        athlete_stats=$(curl -s https://www.strava.com/api/v3/athletes/$athlete_id/stats\?access_token=$access_token)
   
        # load values into array:
        #               	    ARRAY INDEX  0          1          2                3          4              5              6              7           8         9           10           11          12 -> 49
		all=($(echo "$athlete_stats" | jq -r '.biggest_ride_distance,.biggest_climb_elevation_gain,.recent_ride_totals.count,.recent_ride_totals.distance,.recent_ride_totals.moving_time,.recent_ride_totals.elapsed_time,.recent_ride_totals.elevation_gain,.recent_ride_totals.achievement_count,.recent_run_totals.count,.recent_run_totals.distance,.recent_run_totals.moving_time,.recent_run_totals.elapsed_time,.recent_run_totals.elevation_gain,.recent_run_totals.achievement_count,.recent_swim_totals.count,.recent_swim_totals.distance,.recent_swim_totals.moving_time,.recent_swim_totals.elapsed_time,.recent_swim_totals.elevation_gain,.recent_swim_totals.achievement_count,.ytd_ride_totals.count,.ytd_ride_totals.distance,.ytd_ride_totals.moving_time,.ytd_ride_totals.elapsed_time,.ytd_ride_totals.elevation_gain,.ytd_run_totals.count,.ytd_run_totals.distance,.ytd_run_totals.moving_time,.ytd_run_totals.elapsed_time,.ytd_run_totals.elevation_gain,.ytd_swim_totals.count,.ytd_swim_totals.distance,.ytd_swim_totals.moving_time,.ytd_swim_totals.elapsed_time,.ytd_swim_totals.elevation_gain,.all_ride_totals.count,.all_ride_totals.distance,.all_ride_totals.moving_time,.all_ride_totals.elapsed_time,.all_ride_totals.elevation_gain,.all_run_totals.count,.all_run_totals.distance,.all_run_totals.moving_time,.all_run_totals.elapsed_time,.all_run_totals.elevation_gain,.all_swim_totals.count,.all_swim_totals.distance,.all_swim_totals.moving_time,.all_swim_totals.elapsed_time,.all_swim_totals.elevation_gain'))
		
		#Fix an issue due the figures after the dot
		for i in `seq 0 49`;
		do
			all[$i]=${all[$i]%.*}
		done
				
		#converting m in km
		let "all[0] = all[0] / 1000"
		let "all[9] = all[9] / 1000"
		let "all[15] = all[15] / 1000"
		let "all[21] = all[21] / 1000"
		let "all[26] = all[26] / 1000"
		let "all[31] = all[31] / 1000"
		let "all[36] = all[36] / 1000"
		let "all[41] = all[41] / 1000"
		let "all[46] = all[46] / 1000"
		
		#converting s in hour
		let "all[10] = all[10] / 3600"
		let "all[11] = all[11] / 3600"
		let "all[16] = all[16] / 3600"
		let "all[17] = all[17] / 3600"
		let "all[22] = all[22] / 3600"
		let "all[23] = all[23] / 3600"
		let "all[27] = all[27] / 3600"
		let "all[28] = all[28] / 3600"
		let "all[32] = all[32] / 3600"
		let "all[33] = all[33] / 3600"
		let "all[37] = all[37] / 3600"
		let "all[38] = all[38] / 3600"
		let "all[38] = all[38] / 3600"
		let "all[42] = all[42] / 3600"
		let "all[43] = all[43] / 3600"
		let "all[47] = all[47] / 3600"
		let "all[48] = all[48] / 3600"
		
		#building sentences
		biggest_ride_distance=$(printf '%g km' ${all[0]})
		biggest_climb_elevation_gain=$(printf '%g %s' ${all[1]} $scaleD)
		recent_ride_totals__count=$(printf '%g' ${all[2]})
		recent_ride_totals__distance=$(printf '%g km' ${all[3]})
		recent_ride_totals__moving_time=$(printf '%d%s' ${all[4]} $scalet)
		recent_ride_totals__elapsed_time=$(printf '%g %s' ${all[5]} $scalet)
		recent_ride_totals__elevation_gain=$(printf '%g %s' ${all[6]} $scaleD)
		recent_ride_totals__achievement_count=$(printf '%g %s' ${all[7]})
		recent_run_totals__count=$(printf '%g' ${all[8]})
		recent_run_totals__distance=$(printf '%g km' ${all[9]})
		recent_run_totals__moving_time=$(printf '%g %s' ${all[10]} $scalet)
		recent_run_totals__elapsed_time=$(printf '%g %s' ${all[11]} $scalet)
		recent_run_totals__elevation_gain=$(printf '%g %s' ${all[12]} $scaleD)
		recent_run_totals__achievement_count=$(printf '%g %s' ${all[13]})
		recent_swim_totals__count=$(printf '%g' ${all[14]})
		recent_swim_totals__distance=$(printf '%g km' ${all[15]})
		recent_swim_totals__moving_time=$(printf '%g %s' ${all[16]} $scalet)
		recent_swim_totals__elapsed_time=$(printf '%g %s' ${all[17]} $scalet)
		recent_swim_totals__elevation_gain=$(printf '%g %s' ${all[18]} $scaleD)
		recent_swim_totals__achievement_count=$(printf '%g %s' ${all[19]} )
		ytd_ride_totals__count=$(printf '%g' ${all[20]})
		ytd_ride_totals__distance=$(printf '%g km' ${all[21]})
		ytd_ride_totals__moving_time=$(printf '%g %s' ${all[22]} $scalet)
		ytd_ride_totals__elapsed_time=$(printf '%g %s' ${all[23]} $scalet)
		ytd_ride_totals__elevation_gain=$(printf '%g %s' ${all[24]} $scaleD)
		ytd_run_totals__count=$(printf '%g' ${all[25]})
		ytd_run_totals__distance=$(printf '%g km' ${all[26]})
		ytd_run_totals__moving_time=$(printf '%g %s' ${all[27]} $scalet)
		ytd_run_totals__elapsed_time=$(printf '%g %s' ${all[28]} $scalet)
		ytd_run_totals__elevation_gain=$(printf '%g %s' ${all[29]} $scaleD)
		ytd_swim_totals__count=$(printf '%g' ${all[30]})
		ytd_swim_totals__distance=$(printf '%g km' ${all[31]})
		ytd_swim_totals__moving_time=$(printf '%g %s' ${all[32]} $scalet)
		ytd_swim_totals__elapsed_time=$(printf '%g %s' ${all[33]} $scalet)
		ytd_swim_totals__elevation_gain=$(printf '%g %s' ${all[34]} $scaleD)
		all_ride_totals__count=$(printf '%g' ${all[35]})
		all_ride_totals__distance=$(printf '%g km' ${all[36]})
		all_ride_totals__moving_time=$(printf '%g %s' ${all[37]} $scalet)
		all_ride_totals__elapsed_time=$(printf '%g %s' ${all[38]} $scalet)
		all_ride_totals__elevation_gain=$(printf '%g %s' ${all[39]} $scaleD)
		all_run_totals__count=$(printf '%g' ${all[40]})
		all_run_totals__distance=$(printf '%g km' ${all[41]})
		all_run_totals__moving_time=$(printf '%g %s' ${all[42]} $scalet)
		all_run_totals__elapsed_time=$(printf '%g %s' ${all[43]} $scalet)
		all_run_totals__elevation_gain=$(printf '%g %s' ${all[44]} $scaleD)
		all_swim_totals__count=$(printf '%g' ${all[45]})
		all_swim_totals__distance=$(printf '%g km' ${all[46]})
		all_swim_totals__moving_time=$(printf '%g %s' ${all[47]} $scalet)
		all_swim_totals__elapsed_time=$(printf '%g %s' ${all[48]} $scalet)
		all_swim_totals__elevation_gain=$(printf '%g %s' ${all[49]} $scaleD)
		
		#Final show: Comment lines you don't need
        printf "Biggest ride distance: %s\n" "$biggest_ride_distance"
        printf "Biggest climb elevation: %s\n" "$biggest_climb_elevation_gain"
        #printf ": %s\n" "$recent_ride_totals__count"
		printf "Recent ride distance: %s\n" "$recent_ride_totals__distance"
		printf "Recent ride moving time: %s\n" "$recent_ride_totals__moving_time"
		#printf ": %s\n" "$recent_ride_totals__elapsed_time"
		printf "Recent ride elevation gain: %s\n" "$recent_ride_totals__elevation_gain"
		#printf ": %s\n" "$recent_ride_totals__achievement_count"
		#printf ": %s\n" "$recent_run_totals__count"
		printf "Recent run distance: %s\n" "$recent_run_totals__distance"
		printf "Recent run moving time: %s\n" "$recent_run_totals__moving_time"
		#printf ": %s\n" "$recent_run_totals__elapsed_time"
		printf "Recent run elevation gain: %s\n" "$recent_run_totals__elevation_gain"
		#printf ": %s\n" "$recent_run_totals__achievement_count"
		#printf ": %s\n" "$recent_swim_totals__count"
		#printf ": %s\n" "$recent_swim_totals__distance"
		#printf ": %s\n" "$recent_swim_totals__moving_time"
		#printf ": %s\n" "$recent_swim_totals__elapsed_time"
		#printf ": %s\n" "$recent_swim_totals__elevation_gain"
		#printf ": %s\n" "$recent_swim_totals__achievement_count"
		printf "Year total rides: %s\n" "$ytd_ride_totals__count"
		printf "Year total ride distance: %s\n" "$ytd_ride_totals__distance"
		printf "Year total ride moving time: %s\n" "$ytd_ride_totals__moving_time"
		#printf ": %s\n" "$ytd_ride_totals__elapsed_time"
		printf "Year total ride elevation gain: %s\n" "$ytd_ride_totals__elevation_gain"
		#printf ": %s\n" "$ytd_run_totals__count"
		printf "Year total run distance: %s\n" "$ytd_run_totals__distance"
		printf "Year total run moving time: %s\n" "$ytd_run_totals__moving_time"
		#printf ": %s\n" "$ytd_run_totals__elapsed_time"
		printf "Year total run elevation gain: %s\n" "$ytd_run_totals__elevation_gain"
		#printf ": %s\n" "$ytd_swim_totals__count"
		#printf ": %s\n" "$ytd_swim_totals__distance"
		#printf ": %s\n" "$ytd_swim_totals__moving_time"
		#printf ": %s\n" "$ytd_swim_totals__elapsed_time"
		#printf ": %s\n" "$ytd_swim_totals__elevation_gain"
		printf "All ride count: %s\n" "$all_ride_totals__count"
		printf "All ride distance: %s\n" "$all_ride_totals__distance"
		printf "All ride moving time: %s\n" "$all_ride_totals__moving_time"
		#printf ": %s\n" "$all_ride_totals__elapsed_time"
		printf "All ride elevation gain: %s\n" "$all_ride_totals__elevation_gain"
		#printf ": %s\n" "$all_run_totals__count"
		printf "All run distance: %s\n" "$all_run_totals__distance"
		printf "All run moving time: %s\n" "$all_run_totals__moving_time"
		#printf ": %s\n" "$all_run_totals__elapsed_time"
		printf "All run elevation gain: %s\n" "$all_run_totals__elevation_gain"
		#printf ": %s\n" "$all_swim_totals__count"
		#printf ": %s\n" "$all_swim_totals__distance"
		#printf ": %s\n" "$all_swim_totals__moving_time"
		#printf ": %s\n" "$all_swim_totals__elapsed_time"
		#printf ": %s\n" "$all_swim_totals__elevation_gain"

    else
        placeholder 1
    fi
fi

exit
