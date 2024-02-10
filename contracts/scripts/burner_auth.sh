#!/bin/bash

# Check if the burners file exists.
if [[ ! -f burners.json ]]; then
  # If the file does not exist, display a message and exit.
  echo "Burner address data not found. /n Please create burners.json."
  exit 1
fi

# Read the JSON from the file.
json=$(cat burners.json)

# Use jq to get the keys (addresses) in the JSON object.
addresses=$(echo "${json}" | jq -r 'keys[]')

pushd $(dirname "$0")/..

export RPC_URL="http://localhost:5050";

export WORLD_ADDRESS=$(cat ./target/dev/manifest.json | jq -r '.world.address')

export COMBAT_ADDRESS=$(cat ./target/dev/manifest.json | jq -r '.contracts[] | select(.name == "hegemony::systems::combat::combat" ).address')

export GAME_LOBBY_ADDRESS=$(cat ./target/dev/manifest.json | jq -r '.contracts[] | select(.name == "hegemony::systems::game_lobby::game_lobby" ).address')

export SPAWN_ADDRESS=$(cat ./target/dev/manifest.json | jq -r '.contracts[] | select(.name == "hegemony::systems::spawn::spawn" ).address')

export MOVE_ADDRESS=$(cat ./target/dev/manifest.json | jq -r '.contracts[] | select(.name == "hegemony::systems::moves::moves" ).address')

echo "---------------------------------------------------------------------------"
echo world : $WORLD_ADDRESS 
echo " "
echo actions : $ACTIONS_ADDRESS
echo "---------------------------------------------------------------------------"

# enable system -> component authorizations
COMPONENTS=("Position" "Moves" )

for address in $addresses
do
    for component in ${COMPONENTS[@]}; do
        echo "Authorizing Address: ${address} to write to Component: ${component}"
        sozo auth writer $component $address --world $WORLD_ADDRESS --rpc-url $RPC_URL
    done  
done

echo "Burner authorizations have been successfully set."