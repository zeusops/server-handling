#!/usr/bin/python3

import sys
# pip install --user python-valve
import valve.source.a2s

if len(sys.argv) < 3:
    print("Usage: {} serveraddress queryport".format(sys.argv[0]))
    sys.exit(1)

if len(sys.argv) == 4 and sys.argv[3] == "--players":
    players_only = True
else:
    players_only = False

server_address = sys.argv[1]
server_port = int(sys.argv[2])

done = False
tries = 0

while not done:
    with valve.source.a2s.ServerQuerier((server_address, server_port)) as server:
        try:
            info = server.info()
            players = server.players()
        except valve.source.a2s.NoResponseError:
            tries += 1
        else:
            if players_only:
                print("{player_count}/{max_players}".format(**info))
            else:
                print("Name: {server_name}\nPlayers: {player_count}/{max_players}".format(**info))
            done = True
    if tries > 1:
        print("Could not reach server! {}".format(server_address))
        done = True
