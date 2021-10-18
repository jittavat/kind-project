from fastapi import FastAPI
import os
import httpx
import asyncio

URL = os.getenv("TRACING_B_URL", "http://localhost:8082/")

app = FastAPI(openapi_prefix='/app-a')


async def request(client: httpx.AsyncClient):
    response = await client.get(URL)
    return response.text


async def task(t: int):
    async with httpx.AsyncClient() as client:
        tasks = [request(client) for _ in range(t)]
        result = await asyncio.gather(*tasks)
        return result


@app.get("/")
async def read_root(t: int = 100):
    x = await task(t)
    return x
