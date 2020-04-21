from hbmqtt.broker import Broker
import os
import asyncio
import logging
import yaml


@asyncio.coroutine
def broker_coro():
    config = None

    with open('./config.yml', 'r') as stream:
        config = yaml.safe_load(stream)
        print(config)

    broker = Broker(config)
    yield from broker.start()


if __name__ == '__main__':
    formatter = "[%(asctime)s] :: %(levelname)s :: %(name)s :: %(message)s"
    logging.basicConfig(level=logging.INFO, format=formatter)
    asyncio.get_event_loop().run_until_complete(broker_coro())
    asyncio.get_event_loop().run_forever()
