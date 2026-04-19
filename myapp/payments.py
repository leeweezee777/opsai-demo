def calculate_total(items):
    x=0  # bad spacing
    for i in items:
        x=x+i["price"]*i["qty"]
    return x

def apply_discount(total,pct):
    return total*(1-pct/100)  # no validation, bad spacing

