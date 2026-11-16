# Known-answer vectors for components/brave_sync/crypto/account_crypto (H3).
# Run with: python3 -I vectores.py <english.txt>
import hashlib, hmac, struct, sys, unicodedata
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey
from cryptography.hazmat.primitives import serialization

words = open(sys.argv[1]).read().split()
idx = {w: i for i, w in enumerate(words)}

SYNC_CODE = ("badge unique kiwi orient spring venue piano lake admit ill roof brother grant hour better "
             "proud cabbage fee slow economy wage final fox cancel")

def bip39_to_bytes(phrase):
    bits = "".join(format(idx[w], "011b") for w in phrase.split())
    ent = bits[:256]
    seed = int(ent, 2).to_bytes(32, "big")
    chk = format(hashlib.sha256(seed).digest()[0], "08b")
    assert bits[256:] == chk
    return seed

def hkdf(hashmod, ikm, salt, info, n):
    if not salt:
        salt = b"\x00" * hashmod().digest_size
    prk = hmac.new(salt, ikm, hashmod).digest()
    out, t, i = b"", b"", 1
    while len(out) < n:
        t = hmac.new(prk, t + info + bytes([i]), hashmod).digest()
        out += t
        i += 1
    return out[:n]

HKDF_SALT = bytes([72, 203, 156, 43, 64, 229, 225, 127, 214, 158, 50, 29, 130,
                   186, 182, 207, 6, 108, 47, 254, 245, 71, 198, 109, 44, 108,
                   32, 193, 221, 126, 119, 143, 112, 113, 87, 184, 239, 231, 230,
                   234, 28, 135, 54, 42, 9, 243, 39, 30, 179, 147, 194, 211,
                   212, 239, 225, 52, 192, 219, 145, 40, 95, 19, 142, 98])

seed = bip39_to_bytes(SYNC_CODE)
edseed = hkdf(hashlib.sha512, seed, HKDF_SALT, b"sync-auth-key", 32)
sk = Ed25519PrivateKey.from_private_bytes(edseed)
pk = sk.public_key().public_bytes(serialization.Encoding.Raw, serialization.PublicFormat.Raw)
print("seed", seed.hex())
print("chain_id", pk.hex().upper())
assert pk.hex().upper() == "502042270C8145247ED70A18F87022A39886900AB36F2FFF655635DBE516765E"

def norm_email(s):
    return unicodedata.normalize("NFC", s.strip().lower())

email = norm_email("  Prueba.Cuenta@Example.COM ")
password = unicodedata.normalize("NFC", "café con léche 2026")  # NFD input
print("email", email)
print("password_nfc_hex", password.encode().hex())

def keys(pw, em, n):
    sal = hashlib.sha256(b"flyweb-cuenta-v1" + em.encode()).digest()
    ke = hashlib.scrypt(pw.encode(), salt=sal, n=n, r=8, p=1, maxmem=2**28, dklen=32)
    kl = hkdf(hashlib.sha256, ke, b"", b"flyweb-cuenta-v1/entrar", 32)
    ku = hkdf(hashlib.sha256, ke, b"", b"flyweb-cuenta-v1/envolver", 32)
    return sal, ke, kl, ku

for n in (1 << 10, 1 << 17):
    sal, ke, kl, ku = keys(password, email, n)
    print("N", n, "salt", sal.hex())
    print("N", n, "ke", ke.hex())
    print("N", n, "kl", kl.hex())
    print("N", n, "ku", ku.hex())

gcm_nonce = bytes(range(12))
ad = b"flyweb-envoltura-v1" + hashlib.sha256(email.encode()).digest()
wrapped = gcm_nonce + AESGCM(ku).encrypt(gcm_nonce, seed, ad)
print("wrapped_n17", wrapped.hex(), len(wrapped))

def lp(b):
    return struct.pack(">H", len(b)) + b

nonce = bytes(range(40))
body = b'{"desde":0}'
msg = (b"flyweb-cuenta-v1" + lp(b"POST") + lp(b"/cuenta/v1/eventos") + lp(b"eventos")
       + lp(b"0123456789abcdef0123456789abcdef") + lp(nonce) + hashlib.sha256(body).digest())
print("proof_msg", msg.hex())
print("proof_sig", sk.sign(msg).hex())
msg0 = (b"flyweb-cuenta-v1" + lp(b"POST") + lp(b"/cuenta/v1/alta/confirmar") + lp(b"alta") + lp(b"")
        + lp(nonce) + hashlib.sha256(b"{}").digest())
print("proof_msg_empty_account", msg0.hex())
print("proof_sig_empty_account", sk.sign(msg0).hex())
