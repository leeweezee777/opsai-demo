"""Payment processing module"""


def calculate_total(items: list[dict]) -> float:
    """Sum price * quantity for each item."""
    return sum(item["price"] * item["qty"] for item in items)


def apply_discount(total: float, pct: float) -> float:
    """Apply a percentage discount. pct should be 0-100."""
    if not 0 <= pct <= 100:
        raise ValueError(f"discount must be 0-100, got {pct}")
    return total * (1 - pct / 100)
