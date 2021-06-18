SERVERS = {"Riley":15745 , "Jaquez": 15746, "Juzang": 15747, "Campbell": 15748, "Bernard": 15749}
CONNECTIONS = {
                "Riley": ["Jaquez", "Juzang"],
                "Jaquez": ["Riley", "Bernard"],
                "Juzang": ['Riley', "Bernard", "Campbell"],
                "Campbell": ["Juzang", "Bernard"],
                "Bernard": ["Jaquez", "Juzang", "Campbell"]}

# default ip address
LOCALHOST = '127.0.0.1'

APIKEY = 'AIzaSyAjb4Mz_lVU6Vk2IETNzpVvSDW2UtwZYNg'