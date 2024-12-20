from moralis import evm_api

from typing import Union

from fastapi import FastAPI

app = FastAPI()


@app.get("/")
def read_root():
    return {"Hello": "World"}


@app.get("/items/{item_id}")
def read_item(item_id: int, q: Union[str, None] = None):
    return {"item_id": item_id, "q": q}

import os

api_key = os.getenv("MORALIS_API_KEY")

params = {
  "chain": "eth",
  "address": "0xDC24316b9AE028F1497c275EB9192a3Ea0f67022"
}

result = evm_api.balance.get_native_balance(
  api_key=api_key,
  params=params,
)

print(result)