# File Encryption and Decryption Script

 This Zsh script provides a convenient method for encrypting and decrypting files using OpenSSL with the AES-256-CBC encryption algorithm. It is designed to streamline the process of securing your sensitive files and automatically handling them based on your editing activities.

### Features

-  Encryption: Secure your files using the AES-256-CBC algorithm enhanced with PBKDF2 (Password-Based Key Derivation Function 2) for added security.
- Decryption: Decrypt your files for editing and automatically re-encrypt them after modifications.
- Editor Integration: Seamlessly open decrypted files in your preferred text editor.
Configurable: Set global variables to tailor the script's behavior to your workflow.

### Prerequisites

- Zsh
- OpenSSL
- Your preferred text editor (default is Neovim)


### Configuration

The script can be customized through several global variables:

- **EDITOR**: Sets the default text editor. Examples include nvim, vim, nano, code, etc.
- **REMOVE_AFTER_ENCRYPTION**: If set to 1, the original file will be removed after successful encryption.
- **REENCRYPT_AFTER_SAVE**: If set to 1, the script will re-encrypt the file after it has been modified and saved in the editor.
- **ITERATIONS**: Defines the number of iterations for PBKDF2. Changing this value after encrypting files will require using the original iteration count for decryption.

### Usage

####* Encrypting Files*
`$ encrypt <filename>`
```
$ encrypt ./my_secret.txt
```
- Will prompt to enter a password. Encrypting *my_secret.txt* into *my_secret.txt.enc* .
-	If *REMOVE_AFTER_ECRYPTION* is set to true(1) and if the encryption was successful.
	 - The orignal file (my_secret.txt) will be deleted.


#### *Decrypting Files*
`$ decrypt <filename>`
```
$ decrypt ./my_secret.txt.enc
```
- Will prompt you to enter in the password used to encrypt the file. Is successful, the provided file will be decrypted and opened in your prefered editor.
- If your have *REENCRYPT_AFTER_SAVE* set to true(1).
	- After leaving the editor. We then test to see if any changed were made to the encrypted file.
	- If so, you will be prompted again to enter a password for encrypting the file.
	- If you have *REMOVE_AFTER_ENCRYPTION* set to true(1) and if encryption was successful.
		- The Decrypted file will then be delected.


#### Using *encrypt* and *decrypt* as global functions
- Add to your .zshrc
```
source ~/directory_with/ZshEncrypt/encryption.sh
```
`echo "source ~/path/to/ZshEncrpt/encryption.sh" >> ~/.zshrc`

#### Be *cautious* when changing the ITERATIONS variable:
- Files encrypted with a specific iteration count must be decrypted using the same count.
Remember that losing the encryption password or iteration count may result in permanently losing access to your encrypted files.
