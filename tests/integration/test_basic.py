"""Integration tests — these pass on main"""
import pytest


def test_environment_has_requests():
    import requests
    assert requests.__version__ is not None


def test_basic_math():
    assert 2 + 2 == 4
