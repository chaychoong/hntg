prod-iex:
  #!/usr/bin/env bash
  set -e

  fly ssh console --pty --select -C "/app/bin/hntg remote"

prod-observer:
  #!/usr/bin/env bash
  set -e

  json_data=$(fly status --json)
  release_cookie=$RELEASE_COOKIE

  # Extract the app_name
  app_name=$(echo "$json_data" | jq -r '.Name')

  # Extract private_ip for the first started machine
  private_ip=$(echo "$json_data" | jq -r '.Machines[] | select(.state == "started") | .private_ip' | head -n 1)

  # Extract image_ref tag hash for the first started machine
  image_tags=$(echo "$json_data" | jq -r '.Machines[] | select(.state == "started") | .image_ref.tag | sub("deployment-"; "")' | head -n 1)

  if [ -z "$private_ip" ]; then
      echo "No instances appear to be running at this time."
      exit 1
  fi

  # Assemble the full node name
  full_node_name="${app_name}-${image_tags}@${private_ip}"
  echo Attempting to connect to $full_node_name

  iex --sname local --cookie ${release_cookie} -e "IO.inspect(Node.connect(:'${full_node_name}'), label: \"Node Connected?\"); IO.inspect(Node.list(), label: \"Connected Nodes\"); :observer.start"
