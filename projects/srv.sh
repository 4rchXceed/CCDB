wget https://445469ed3a7d.ngrok-free.app/bin.lua bin.lua
bin setup
bin
# Type: OPEN(dbtest); and then exit

wget https://445469ed3a7d.ngrok-free.app/projects/item_db/ccdb.json projects/item_db/ccdb.json
wget https://445469ed3a7d.ngrok-free.app/projects/item_db/item.json projects/item_db/item.json
wget https://445469ed3a7d.ngrok-free.app/projects/item_db/chest.json projects/item_db/chest.json

# Edit /cfg/dblocation.cfg to point to /projects
# Run SQL: INSERT INTO chest (move) VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10);
# get minecraft:wheat_seeds 1
# SELECT * FROM item WHERE item_id='minecraft:wheat_seeds';