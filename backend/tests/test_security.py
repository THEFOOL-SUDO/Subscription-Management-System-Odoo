import pytest
from app.core.security import (
    generate_secure_token,
    hash_password,
    hash_token,
    validate_password_complexity,
    verify_password,
)


def test_password_hashing_argon2id():
    pwd = "Brightloop#Secure2026"
    hashed = hash_password(pwd)
    assert hashed.startswith("$argon2id$")
    assert verify_password(pwd, hashed) is True
    assert verify_password("WrongPassword#1", hashed) is False


def test_password_complexity_validator():
    # Valid
    valid, msg = validate_password_complexity("Strong#Pass2026")
    assert valid is True
    assert msg == ""

    # Short (<9 chars)
    valid, msg = validate_password_complexity("Short#1")
    assert valid is False
    assert "more than 8 characters" in msg

    # Missing uppercase
    valid, msg = validate_password_complexity("lowercase#1234")
    assert valid is False
    assert "uppercase" in msg

    # Missing lowercase
    valid, msg = validate_password_complexity("UPPERCASE#1234")
    assert valid is False
    assert "lowercase" in msg

    # Missing number
    valid, msg = validate_password_complexity("NoNumbers#Pass")
    assert valid is False
    assert "number" in msg

    # Missing special character
    valid, msg = validate_password_complexity("NoSpecialChars123")
    assert valid is False
    assert "special character" in msg


def test_secure_tokens_and_hashing():
    raw_token = generate_secure_token(32)
    assert len(raw_token) == 64  # 32 bytes in hex is 64 characters
    hashed = hash_token(raw_token)
    assert len(hashed) == 64  # SHA-256 is 64 hex characters
    assert hash_token(raw_token) == hashed
