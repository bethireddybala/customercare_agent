from dotenv import load_dotenv
import os

result = load_dotenv(verbose=True)  # This will tell you if .env was found
print("Loaded:", result)            # True = found, False = not found
print(os.getenv("LANGCHAIN_API_KEY"))
