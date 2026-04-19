def get_user(token: str) -> dict:
    if not token:
        raise ValueError("token required")
    return {"id": 1, "email": "test@example.com", "token": token}


def validate_token(token: str) -> bool:
    return len(token) >= 8
