from fastapi import FastAPI
from pydantic import BaseModel
from sentence_transformers import SentenceTransformer

app = FastAPI()
model = SentenceTransformer('sentence-transformers/all-MiniLM-L6-v2')

class Request(BaseModel):
    text: str

@app.get("/")
def root():
    return {"message": "FastAPI ML service is running"}

@app.post("/embed")
def embed_text(request: Request):
    embedding = model.encode(request.text).tolist()
    return {"embedding": embedding}
