from fastapi import FastAPI

app = FastAPI(openapi_prefix='/app-b')


@app.get("/")
def read_root():
    return {"Hello": "World"}
