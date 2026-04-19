"""Unit tests — these pass on main"""
import pytest
from myapp.auth import get_user, validate_token


def test_get_user_returns_dict():
    user = get_user(token="abc12345")
    assert user["id"] == 1
    assert "email" in user


def test_get_user_requires_token():
    with pytest.raises(ValueError):
        get_user(token="")


def test_validate_token_too_short():
    assert validate_token("abc") is False


def test_validate_token_ok():
    assert validate_token("abc12345") is True
