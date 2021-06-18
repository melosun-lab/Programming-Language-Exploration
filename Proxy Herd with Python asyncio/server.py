import argparse
import asyncio
import datetime
import logging
import os
import aiohttp
import json

servers = {"Riley":15645 , "Jaquez": 15646, "Juzang": 15647, "Campbell": 15648, "Bernard": 15649}
graph = {
            "Riley": ["Jaquez", "Juzang"],
            "Jaquez": ["Riley", "Bernard"],
            "Juzang": ['Riley', "Bernard", "Campbell"],
            "Campbell": ["Juzang", "Bernard"],
            "Bernard": ["Jaquez", "Juzang", "Campbell"]
        }

class Server:
    def __init__(self, arg):
        if not os.path.exists('server_logs'): os.makedirs('server_logs')
        FORMAT = '%(asctime)-8s        %(message)s'
        FILENAME = f'server_logs/{arg}_log.txt'
        logging.basicConfig(filename=FILENAME, encoding='utf-8', format=FORMAT, level=logging.INFO)
        logging.info(f'Running server {arg}...')
        self.server, self.ports, self.clients = arg, servers[arg], {}
    
    def awake(self):
        try:
            asyncio.run(self.start())
        except KeyboardInterrupt:
            self.log(f'Shutting down {self.server} server...')

    def log(self, s):
        logging.info(s)
        print(s)
    
    def check_command(self, s, msgs):
        if not msgs or msgs[0] not in ["IAMAT", "AT", "WHATSAT"]:
            if s: self.log(f'ERROR: Invalid message: {s}')
            return False
        args = {"IAMAT": 4, "AT":6, "WHATSAT": 4}
        if len(msgs) != args[msgs[0]]:
            self.log(f'ERROR: Incorrect number of arguments: {s}')
            return False
        return True
    
    def check_args(self, client_id, radius, bound):
        if not self.check_float(bound) or not (0 <= float(bound) and float(bound) <= 20):
            return False, f'Invalid input for bound: {bound}'
        if not self.check_float(radius) or not(0 <= float(radius) and float(radius) <= 50):
            return False, f'Invalid input for radius: {radius}'
        if not client_id in self.clients:
            return False, f'Invalid input for client_id: {client_id}'
        return True, ""
    
    def check_float(self, value):
        try:
            float(value)
            return True
        except ValueError:
            return False

    async def client_connected_cb(self, reader, writer):
        while not reader.at_eof():
            peer, s = writer.get_extra_info('peername'), await reader.readline()
            s = s.decode()
            self.log(f'Receiving message from {peer} : {s}')
            feedback = await self.reply(s)
            if feedback:
                writer.write(feedback.encode())
                self.log(f'Sending feedback to {peer}: {feedback}')
            writer.close()
            self.log(f'Disconnecting with client {peer}')

    async def reply(self, s):
        msgs = [msg for msg in s.strip().split() if msg]
        if not self.check_command(s, msgs): return f'? {s}'
        cbs = {"IAMAT": self.cb_iamat, "AT": self.cb_at, "WHATSAT": self.cb_whatsat}
        try:
            return await cbs[msgs[0]](*msgs[1:])
        except Exception:
            self.log(f'ERROR: Failed to process command')
            return  f'? {s}'
    
    async def cb_iamat(self, client_id, iso, time):
        if not self.check_float(time): raise Exception(f'Invalid input for time: {time}')
        coordinates = [coordinate for coordinate in "".join(iso.split("+")).split("-")]
        if len(coordinates) != 2 or not self.check_float(coordinates[0]) or not self.check_float(coordinates[1]): raise Exception(f'Invalid input for iso: {iso}')
        block = datetime.datetime.now().timestamp() - float(time)
        s = str(block) if not block else "+" + str(block)
        msg = f'AT {self.server} {s} {client_id} {iso} {time}'
        self.clients[client_id] = [msg, time]
        await self.broadcast(msg)
        return msg  

    async def cb_at(self, server_id, block, client_id, iso, time):
        if not client_id in self.clients or time > self.clients[client_id][1]:
            msg = f'AT {server_id} {block} {client_id} {iso} {time}'
            self.clients[client_id] = [msg, time]
            self.log(f'Receiving broadcast of {client_id}...')
            await self.broadcast(msg)
        else:
            self.log(f'Duplicate broadcast of {client_id}.')

    async def cb_whatsat(self, client_id, radius, bound):
        valid, err = self.check_args(client_id, radius, bound)
        if not valid: raise Exception(err)
        s = self.clients[client_id][0]
        iso = s.split()[4]
        res = await self.search(radius, bound, iso)
        return f'{s}\n{res}\n\n'
        

    async def start(self):
        new_server = await asyncio.start_server(self.client_connected_cb, "127.0.0.1", self.ports)
        sockname = new_server.sockets[0].getsockname()
        self.log(f'Start server {self.server} on {sockname}')
        async with new_server:
            await new_server.serve_forever()

    async def broadcast(self, msg):
        for adj in graph[self.server]:
            try:
                reader, writer = await asyncio.open_connection("127.0.0.1", servers[adj])
                self.log(f'Connecting to server {adj}')
                writer.write(msg.encode())
                self.log(f'Broadcasting message to server {adj}: {msg}')
                await writer.drain()
                writer.close()
                await writer.wait_closed()
                self.log(f'Closing connection with server {adj}')
            except:
                self.log(f'WARNING: Failed to broadcast server {adj}')

    async def search(self, radius, bound, iso):
        async with aiohttp.ClientSession(connector=aiohttp.TCPConnector(ssl=False)) as session:
            idx = max(iso.rfind("+"), iso.rfind("-"))
            location = f'{iso[:idx]},{iso[idx:]}'
            self.log(f'Communicating witg Google API...')
            async with session.get(f'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location={location}&radius={radius}&key=AIzaSyAjb4Mz_lVU6Vk2IETNzpVvSDW2UtwZYNg') as response:
                res = await response.json(loads=json.loads)
            num = len(res["results"])
            self.log(f'Located {num} places. Upper bound is {bound}')
            idx = int(bound)
            if num > idx: res["results"] = res["results"][:idx]
            return str(json.dumps(res, indent=4)).rstrip("\n")



if __name__ == "__main__":
    argparser = argparse.ArgumentParser()
    argparser.add_argument('arg', type=str)
    res = argparser.parse_args()
    if res.arg in servers: 
        new_server = Server(res.arg)
        new_server.awake()
    else:
        print(f'Server {res.arg} is invalid.')
        exit()

# IAMAT kiwi.cs.ucla.edu +34.068930-118.445127 1614209128.918963997
# WHATSAT kiwi.cs.ucla.edu 10 5