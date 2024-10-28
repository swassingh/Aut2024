def encrypt_vigenere(plaintext, key):
  key = key.upper()
  encrypted = []
  key_index = 0

  for char in plaintext:
    if char.isalpha():
      shift = ord(key[key_index]) - ord('A')
      if char.isupper():
        encrypted_char = chr((ord(char) - ord('A') + shift) % 26 + ord('A'))
      else:
        encrypted_char = chr((ord(char) - ord('a') + shift) % 26 + ord('a'))
      key_index = (key_index + 1) % len(key)
    else:
      encrypted_char = char
    encrypted.append(encrypted_char)

  return ''.join(encrypted)

def decrypt_vigenere(ciphertext, key):
  key = key.upper()
  decrypted = []
  key_index = 0

  for char in ciphertext:
    if char.isalpha():
      shift = ord(key[key_index]) - ord('A')
      if char.isupper():
        decrypted_char = chr((ord(char) - ord('A') - shift + 26) % 26 + ord('A'))
      else:
        decrypted_char = chr((ord(char) - ord('a') - shift + 26) % 26 + ord('a'))
      key_index = (key_index + 1) % len(key)
    else:
      decrypted_char = char
    decrypted.append(decrypted_char)

  return ''.join(decrypted)

if __name__ == "__main__":
  plaintext = "ALIENSDOEXIST"  # Replace with your actual plaintext
  key = "HUSKY"
  encrypted = encrypt_vigenere(plaintext, key) # type: ignore
  print(f"Encrypted: {encrypted}")
  decrypted = decrypt_vigenere(encrypted, key)
  print(f"Decrypted: {decrypted}")
